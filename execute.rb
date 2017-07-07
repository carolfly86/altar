#!/usr/bin/env ruby
require 'pg_query'
require 'trollop'
require 'pp'
require 'pg'
require 'yaml'
require 'json'
require 'pry'

Dir['lib/*'].each { |file| require_relative file }
# create t_result table
tqueryJson = JSON.parse(File.read('sql/true.json'))

tQuery = tqueryJson['query']
t_pkList = tqueryJson['pkList']
tTable = 't_result'
query = QueryBuilder.create_tbl(tTable, t_pkList, tQuery)
DBConn.exec(query)

query = 'DROP TABLE if exists cs; '\
        ' CREATE TABLE if not exists cs (cs_id varchar(30), exp_id varchar(30), separation float null, selectivity float null, significance float null)'
DBConn.exec(query)

query = 'DROP TABLE if exists q_cs; '\
        ' CREATE TABLE if not exists q_cs (q_id varchar(30),cs_id varchar(30),exp_id varchar(30), scope float null, satisfaction float null, weighted_satisfaction float null, weighted_significance float null)'
DBConn.exec(query)

query = 'DROP TABLE if exists q_similarity; '\
        ' CREATE TABLE if not exists q_similarity (q_id varchar(30), similarity float null)'
DBConn.exec(query)

# calculate constraint set separation and selectivity
Dir['expectation1/cs*.json'].each do |cs|
  puts cs
  cs_id = cs.split('/')[1].gsub('.json', '')
  csJson = JSON.parse(File.read(cs.to_s))
  pp csJson
  csJson['expectations'].each_with_index do |e, index|
    # exp_id = e.split('/')[3].gsub('.json','')
    exp_id = "exp_#{index}"
    puts exp_id
    # expJson = JSON.parse(File.read("#{e}"))
    # pp expJson
    expJson = e
    exp_am = Expectation_AM.new(expJson['support'], expJson['behavior'])

    # p exp.behaviorDomain()

    separation = exp_am.separationScore
    puts "separation: #{separation}"

    selectivity = exp_am.selectivityScore
    puts "selectivity: #{selectivity}"

    significance = (separation.to_f * selectivity.to_f).to_f
    puts "significance: #{significance}"

    query = 'INSERT INTO cs (cs_id, exp_id,separation,selectivity,significance)' \
            " SELECT '#{cs_id}','#{exp_id}', #{separation}, #{selectivity}, #{significance}"
    p query
    DBConn.exec(query)
  end
end
# cfg = YAML.load_file( File.join(File.dirname(__FILE__), "config/default.yml") )
# conn = PG::Connection.open(dbname: cfg['default']['database'], user: cfg['default']['user'], password: cfg['default']['password'])
Dir['sql/q*.json'].each do |sql|
  puts '**********************************'
  putssql.to_s
  fqueryJson = JSON.parse(File.read(sql.to_s))
  # tqueryJson = JSON.parse(File.read('sql/true.json'))
  q_id = sql.split('/')[1].gsub('.json', '')

  fQuery = fqueryJson['query']
  f_pkList = fqueryJson['pkList']
  fTable = 'f_result'
  query = QueryBuilder.create_tbl(fTable, f_pkList, fQuery)
  DBConn.exec(query)

  # tQuery = tqueryJson['query']
  # t_pkList = tqueryJson['pkList']
  # tTable = 't_result'
  # query = QueryBuilder.create_tbl(tTable, t_pkList, tQuery)
  # DBConn.exec(query)

  localizeErr = LozalizeError.new(fQuery, fTable, tTable)
  similarity = localizeErr.similarityBitMap
  query = "insert into q_similarity select '#{q_id}', #{similarity}"
  DBConn.exec(query)

  # calculate total satisfication and coverage
  pkArray = f_pkList.split(',')
  colsQuery = QueryBuilder.find_cols_by_data_typcategory(fTable)
  cols = DBConn.exec(colsQuery)
  colArray = []
  cols.each do |r|
    colArray << r['column_name'] unless pkArray.include? r['column_name']
  end
  sfSumQuery = colArray.map { |c| " sum(case when #{c}>1 then 1 else 0 end) " }.join('+')
  cvSumQuery = colArray.map { |c| " sum(case when #{c}>0 then 1 else 0 end) " }.join('+')
  colCnt = cols.count - pkArray.count
  Dir['expectation1/cs*.json'].each do |cs|
    cs_id = cs.split('/')[1].gsub('.json', '')
    csJson = JSON.parse(File.read(cs.to_s))

    # create satisfactionMap table
    satisfactionMapTbl = "#{q_id}_#{cs_id}_satisfaction"
    # drop satisfaction table
    query = QueryBuilder.satisfactionMap(satisfactionMapTbl, fTable, f_pkList)
    p query
    DBConn.exec(query)

    # coverageMapTbl = "#{q_id}_#{cs_id}_coverage"
    # query = QueryBuilder.satisfactionMap(coverageMapTbl,fTable,f_pkList)
    # p query
    # DBConn.exec(query)

    csJson['expectations'].each_with_index do |e, index|
      exp_id = "exp_#{index}"
      puts exp_id
      expJson = e # JSON.parse(File.read("#{e}"))
      pp expJson

      exp_am = Expectation_AM.new(expJson['support'], expJson['behavior'])
      # exp_am.support = expJson['support']
      # exp_am.behavior = expJson['behavior']

      # p exp.behaviorDomain()

      support = exp_am.supportScore('f_result')
      puts "support: #{support}"

      satisfaction = exp_am.satisfaction('f_result')
      puts "satisfaction: #{satisfaction}"

      weightedSatisfaction = satisfaction.to_f * support.to_f
      puts "weightedSatisfaction: #{weightedSatisfaction}"

      # get significance
      query = "select significance from cs where cs_id = '#{cs_id}' and exp_id = '#{exp_id}'"
      res = DBConn.exec(query)
      q_significance = res[0]['significance']
      weightedSignificance = q_significance.to_f * support.to_f

      exp_am.updSatCvgMapTbl('f_result', f_pkList, satisfactionMapTbl)

      query = 'INSERT INTO q_cs (q_id, cs_id, exp_id, scope, satisfaction,weighted_satisfaction, weighted_significance)' \
              " SELECT '#{q_id}','#{cs_id}','#{exp_id}', #{support}, #{satisfaction}, #{weightedSatisfaction},#{weightedSignificance}"
      p query
      DBConn.exec(query)
    end

    query = "select ( (select #{cvSumQuery} from #{satisfactionMapTbl})::float/(select count(1)*#{colCnt} from #{satisfactionMapTbl})::float)::float as score;"
    p query
    res = DBConn.exec(query)
    totalCoverage = res[0]['score'].to_f

    if totalCoverage > 0
      query = "select ( (select #{sfSumQuery} from #{satisfactionMapTbl})::float/(select #{cvSumQuery} from #{satisfactionMapTbl})::float)::float as score;"
      p query
      res = DBConn.exec(query)
      totalSatisfiction = res[0]['score'].to_f
    else
      totalSatisfiction = 0
    end
    query = 'INSERT INTO q_cs (q_id, cs_id, exp_id, scope, satisfaction,weighted_satisfaction,weighted_significance)' \
            " SELECT '#{q_id}','#{cs_id}','total', sum(scope), #{totalSatisfiction}, sum(weighted_satisfaction) , sum(weighted_significance)"\
            " FROM ( select q_id, cs_id,scope, weighted_satisfaction, weighted_significance from q_cs where q_id = '#{q_id}' and cs_id = '#{cs_id}' ) as A"\
            ' group by q_id, cs_id'
    p query
    DBConn.exec(query)
  end
end
