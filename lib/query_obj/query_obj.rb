require 'json'
require 'pg'
require 'pg_query'

# require_relative 'db_connection'

class QueryObj
  attr_reader :query, :pkList, :table, :parseTree
  attr_accessor :score
  OPR_SYMBOLS = [ ['='],['<>'], ['>'], ['<'], ['>='], ['<=']]

  def initialize(options)
    script=options.fetch(:queryJson,'')
    @table=options.fetch(:table)
    @score=options.fetch(:score, Hash.new)
    # initialize with script
    if script != ''
      dbname = script.split('_')[0]
      @queryJson= JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
      @query=@queryJson['query']
      @pkList=@queryJson['pkList']
    # initialize with query and pklist  
    else
      @query=options.fetch(:query)
      @pkList=options.fetch(:pkList)
    end
    # pp @query
    @parseTree = options.fetch(:parseTree,PgQuery.parse(@query).parsetree[0])
    DBConn.tblCreation(@table, @pkList, @query)

  end


  def create_stats_tbl()

        tblName = "#{table}_stat"
        creationQuery = "select ''::text as key, ''::text as value from t_result where 1 =2"
        # puts creationQuery
        DBConn.tblCreation(tblName, 'key', creationQuery)

        parseTree = @parseTree

        fromPT = parseTree['SELECT']['fromClause']
        originalTargeList = parseTree['SELECT']['targetList']
        fields = DBConn.getAllRelFieldList(fromPT)
        keyList = []
        valueList =[]
        selectList=[]
        pkJoinList=[]
        stats=['min','max']
        pkArray = @pkList.split(',').map{|col| col.delete(' ')}
        pkArray.each do |pkcol|
          originalTargeList.each do |targetCol|
            targetField = targetCol['RESTARGET']['val']['COLUMNREF']['fields']
            if targetField.count >1 && targetField[1].to_s == pkcol
              pkJoinList<<"t.#{pkcol} = #{targetField[0]}.#{targetField[1]}"
              pkArray.delet(pkcol)
            end
          end
        end


        fields.each do |field|
          puts field.colname
          stats.each do |stat|
            # SELECT
            # UNNEST(ARRAY['address_id_max','address_id_min']) AS key,
            # UNNEST(ARRAY[max(address_id),min(address_id)]) AS value
            # FROM address
            # only add N(umeric) and D(ata) type fields
            if ['N','D'].include? field.typcategory
              keyList << "'#{field.relname}_#{field.colname}_#{stat}'"
              valueList << "#{stat}(result.#{field.relname}_#{field.colname})::text"
            end
          end
          selectList << "#{field.relname}.#{field.colname} as #{field.relname}_#{field.colname} "

          # construnct pk join cond
          if pkArray.include?(field.colname)
            pkJoinList<<"t.#{field.colname} = #{field.relname}.#{field.colname}"
          end
        end


        # # remove the where clause in query and replace targetList
        whereClauseReplacement = Array.new()
        selectQuery =  ReverseParseTree.reverseAndreplace(parseTree, selectList.join(','),whereClauseReplacement) 
        resultQuery = %Q(with result as (#{selectQuery} join t_result t on #{pkJoinList.join(' AND ')}))
        newTargetList = "UNNEST(ARRAY[#{keyList.join(',')}]) AS key, UNNEST(ARRAY[#{valueList.join(',')}]) as value"

        newQuery = %Q(#{resultQuery} SELECT #{newTargetList} FROM result)
        query = %Q(INSERT INTO #{tblName} #{newQuery})
        puts query
        DBConn.exec(query)
  end

end