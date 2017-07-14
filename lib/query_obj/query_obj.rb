require 'json'
require 'pg'
require 'pg_query'
require 'jsonpath'
# require_relative 'db_connection'

class QueryObj
  attr_reader :query, :pkList, :table, :parseTree, :all_cols
  attr_accessor :score
  OPR_SYMBOLS = [['='], ['<>'], ['>'], ['<'], ['>='], ['<=']].freeze

  def initialize(options)
    script = options.fetch(:queryJson, '')
    @table = options.fetch(:table)
    @score = options.fetch(:score, {})
    # initialize with script
    if script != ''
      dbname = script.split('_')[0]
      @queryJson = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
      @query = @queryJson['query']
      @pkList = @queryJson['pkList']
    # initialize with query and pklist
    else
      @query = options.fetch(:query)
      @pkList = options.fetch(:pkList)
    end
    # pp @query
    @parseTree = options.fetch(:parseTree, PgQuery.parse(@query).parsetree[0])
    DBConn.tblCreation(@table, @pkList, @query)

    @all_cols = DBConn.getAllRelFieldList(parseTree['SELECT']['fromClause'])
  end
  def pk_list
    if @pk_list.nil?
      pkListQuery = QueryBuilder.find_pk_cols(@table)
      res = DBConn.exec(pkListQuery)

      @pk_list = []
      res.each do |r|
        @pk_list << r['attname']
      end
    end
    @pk_list
  end

  def pk_full_list
    self.pk_list
    self.rel_names
    if @pk_full_list.nil?
      @pk_full_list = []

      @pk_list.each do |pk_col|
        h = {}
        col = ReverseParseTree.find_col_by_name(@parseTree['SELECT']['targetList'], pk_col)
        h['alias'] = col['alias']
        h['col'] = col['col']
        if col['col'].split('.').count > 1
          h['colname'] = col['col'].split('.')[1]
          rel = col['col'].split('.')[0]
          @rel_names.each do |r|
            relname = JsonPath.new('$..relname').on(r)
            relalias = JsonPath.new('$..aliasname').on(r)
            if relname.include?(rel) || relalias.include?(rel)
              h['relname'] = relname[0]
              h['relalias'] = relalias.count == 0 ? rel : relalias[0]
            end
          end

        else
          h['colname'] = col['col']
          relList = @rel_names.map { |rel| '"' + rel['relname'] + '"' }.join(',')
          query = QueryBuilder.find_rel_by_colname(relList, h['colname'])
          res = DBConn.exec(query)
          h['relname'] = res[0]['relname']
          h['relalias'] = h['relname']
        end
        @pk_full_list.push(h)
      end
    end
    @pk_full_list
  end

  def rel_names
    @rel_names ||= JsonPath.on(@parseTree['SELECT']['fromClause'].to_json, '$..RANGEVAR')
  end

  def create_full_rst_tbl
    self.all_cols_select
    self.pk_full_list
    renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
    targetListReplacement = "#{renamed_pk_col},#{@all_cols_select}"
    query =  ReverseParseTree.reverseAndreplace(@parseTree, targetListReplacement, '')
    query = QueryBuilder.create_tbl("#{@table}_full_rst", @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', '), query)
    DBConn.exec(query)

    return "#{@table}_full_rst"
  end

  def all_cols_select
    @all_cols_select ||= @all_cols.map do |field|
      col = field.relalias.nil? ? "#{field.relname}.#{field.colname}" : "#{field.relalias}.#{field.colname}"
      "#{col} as #{field.renamed_colname}"
    end.join(',')
  end

  def all_cols_renamed
    @all_cols_renamed ||= @all_cols.map do |field|
      "#{field.renamed_colname} "
    end.join(',')
  end

  def create_stats_tbl
    tblName = "#{@table}_stat"
    creationQuery = "select ''::text as key, ''::text as value from t_result where 1 =2"
    # puts creationQuery
    DBConn.tblCreation(tblName, 'key', creationQuery)

    parseTree = @parseTree

    # fromPT = parseTree['SELECT']['fromClause']
    originalTargeList = parseTree['SELECT']['targetList']
    # fields = DBConn.getAllRelFieldList(fromPT)
    keyList = []
    valueList = []
    selectList = []
    pkJoinList = []
    stats = %w(min max)
    pkArray = @pkList.split(',').map { |col| col.delete(' ') }
    pkArray.each do |pkcol|
      originalTargeList.each do |targetCol|
        targetField = targetCol['RESTARGET']['val']['COLUMNREF']['fields']
        if targetField.count > 1 && targetField[1].to_s == pkcol
          pkJoinList << "t.#{pkcol} = #{targetField[0]}.#{targetField[1]}"
          pkArray.delete(pkcol)
        end
      end
    end

    @all_cols.each do |field|
      # puts field.colname
      rel_alias = field.relalias
      stats.each do |stat|
        # SELECT
        # UNNEST(ARRAY['address_id_max','address_id_min']) AS key,
        # UNNEST(ARRAY[max(address_id),min(address_id)]) AS value
        # FROM address
        # only add N(umeric) and D(ata) type fields
        if %w(N D).include? field.typcategory
          keyList << "'#{field.relname}_#{field.colname}_#{stat}'"
          valueList << "#{stat}(result.#{field.relname}_#{field.colname})::text"
        end
      end
      selectList << "#{rel_alias}.#{field.colname} as #{field.relname}_#{field.colname} "

      # construnct pk join cond
      if pkArray.include?(field.colname)
        pkJoinList << "t_result.#{field.colname} = #{rel_alias}.#{field.colname}"
      end
    end

    # # remove the where clause in query and replace targetList
    whereClauseReplacement = []
    selectQuery = ReverseParseTree.reverseAndreplace(parseTree, selectList.join(','), whereClauseReplacement)
    resultQuery = %(with result as (#{selectQuery} join t_result on #{pkJoinList.join(' AND ')}))
    newTargetList = "UNNEST(ARRAY[#{keyList.join(',')}]) AS key, UNNEST(ARRAY[#{valueList.join(',')}]) as value"

    newQuery = %(#{resultQuery} SELECT #{newTargetList} FROM result)
    query = %(INSERT INTO #{tblName} #{newQuery})
    # puts query
    DBConn.exec(query)
  end
end
