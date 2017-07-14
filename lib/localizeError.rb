require 'pg'
require 'pg_query'
require 'jsonpath'
require 'rubytree'
require_relative 'reverse_parsetree'
require_relative 'string_util'
require_relative 'hash_util'
require_relative 'array_helper'
require_relative 'join_key_ident'

require_relative 'query_builder'
require_relative 'db_connection'

class LozalizeError
  # attr_accessor :fPS
  # def initialize(fQuery, tQuery, parseTree)
  attr_reader :missing_tuple_count, :unwanted_tuple_count
  def initialize(fQueryObj, tQueryObj, is_new = true)
    # @fQuery=fqueryObj['query']
    # @tQuery=tqueryObj['query']

    @fQueryObj = fQueryObj
    @tQueryObj = tQueryObj

    @fTable = fQueryObj.table
    @tTable = tQueryObj.table

    @all_columns = fQueryObj.allCols

    @fPS = fQueryObj.parseTree
    @tPS = tQueryObj.parseTree
    @is_new = is_new
    @test_id = @is_new ? 0 : generate_new_testid

    @missingQuery = nil
    @unwantedQuery = nil

    # @pkListQuery = QueryBuilder.find_pk_cols(@tTable)
    # res = DBConn.exec(@pkListQuery)

    @pkList = tQueryObj.pk_list
    # res.each do |r|
    #   @pkList << r['attname']
    # end

    # pp "@pkList: #{@pkList}"
    # pp @ps
    @pkJoin = ''
    pkSelectArry = []
    pkJoinArry = []
    @pkList.each do |c|
      pkJoinArry.push("t.#{c} = f.#{c}")
      pkSelectArry.push("f.#{c}")
    end
    # pp @pkList
    @pkSelect = pkSelectArry.join(',')
    @pkJoin = pkJoinArry.join(' AND ')

    @wherePT = @fPS['SELECT']['whereClause']
    @fromPT =  @fPS['SELECT']['fromClause']
    # @relNames = JsonPath.on(@fromPT.to_json, '$..RANGEVAR')
    @relNames = tQueryObj.rel_names

    @pkFullList = tQueryObj.pk_full_list

    # @pkList.each do |pk_col|
    #   h = {}
    #   # binding.pry
    #   # col = ReverseParseTree.find_col_by_name(@ps['SELECT']['targetList'], c)['fullname']
    #   col = ReverseParseTree.find_col_by_name(@fPS['SELECT']['targetList'], pk_col)
    #   # pp @fPS['SELECT']['targetList']
    #   # abort('test')
    #   h['alias'] = col['alias']
    #   h['col'] = col['col']
    #   if col['col'].split('.').count > 1
    #     h['colname'] = col['col'].split('.')[1]
    #     rel = col['col'].split('.')[0]
    #     @relNames.each do |r|
    #       relname = JsonPath.new('$..relname').on(r)
    #       relalias = JsonPath.new('$..aliasname').on(r)
    #       if relname.include?(rel) || relalias.include?(rel)
    #         h['relname'] = relname[0]
    #         h['relalias'] = relalias.count == 0 ? rel : relalias[0]
    #       end
    #     end

    #   else
    #     h['colname'] = col['col']
    #     relList = @relNames.map { |rel| '"' + rel['relname'] + '"' }.join(',')
    #     query = QueryBuilder.find_rel_by_colname(relList, h['colname'])
    #     res = DBConn.exec(query)
    #     h['relname'] = res[0]['relname']
    #     h['relalias'] = h['relname']
    #   end
    #   @pkFullList.push(h)
    # end
    # generate predicate tree from where clause
    root = Tree::TreeNode.new('root', '')
    @predicateTree = PredicateTree.new('f', @is_new, @test_id)
    # pp @wherePT
    @predicateTree.build_full_pdtree(@fromPT[0], @wherePT, root)
    @pdtree = @predicateTree.pdtree
    # @pdtree.print_tree
    # pp 'branches'
    # pp @predicateTree.branches
    # pp 'nodes'
    # pp @predicateTree.nodes

    # @predicateTree.node_query_mapping_insert()

    # pp whereCondArry.to_a
    @fromCondStr = ReverseParseTree.fromClauseConstr(@fromPT)
    @whereStr = ReverseParseTree.whereClauseConst(@wherePT)

    # pp @whereStr
    @missing_tuple_count = 0
    @unwanted_tuple_count = 0
    # create_t_f_union_table
    # create_t_f_intersect_table
    # create_t_f_all_table
    allcolumns_construct
  end

  def generate_new_testid
    query = 'select max(test_id) as test_id from node_query_mapping'
    rst = DBConn.exec(query)
    if rst.count == 0
      0
    else
      rst[0]['test_id'].to_i + 1
    end
  end

  def create_t_f_union_table
    query = "select #{@pkSelect} from #{@tTable} UNION select #{@pkSelect} from #{@fTable}"
    query = QueryBuilder.create_tbl('t_f_union', @pkList, query)
    puts'create t_f_union'
    puts query
    # create
    DBConn.exec(query)
  end

  def create_t_f_intersect_table
    query = "select #{@pkSelect} from #{@tTable} INTERSECT select #{@pkSelect} from #{@fTable}"
    query = QueryBuilder.create_tbl('t_f_union', @pkList, query)
    puts'create t_f_intersect'
    puts query
    # create
    DBConn.exec(query)
  end

  def create_t_f_all_table
    query = ReverseParseTree.reverseAndreplace(@fParseTree, @pkList, '')
    query = QueryBuilder.create_tbl('t_f_all', @pkList, query)
    puts'create t_f_all'
    puts query
    DBConn.exec(query)
  end
  # def similarityBitMap()
  #   colList = @pkSelect.gsub(/f\./,'').split(',').map{|c| "t.#{c} as #{c}_pk, CASE WHEN t.#{c} is null or f.#{c} is null then 0 else 1 END as #{c}"}.join(',')
  #   colCnt = ''
  #   sumCnt = ''
  #   matchingColQuery = QueryBuilder.find_matching_cols(@tTable, @fTable)
  #  # p matchingColQuery
  #   matchingCol = DBConn.exec(matchingColQuery)
  #   matchingCol.each do |r|
  #     unless @pkList.include? r['col1']
  #       if (r['is_matching'] == '1')
  #         colList += " , CASE WHEN t.#{r['col1']} = f.#{r['col1']} then 1 else 0 end as #{r['col1']}"
  #         colCnt += " sum(#{r['col1']}) as #{r['col1']}_cnt,"
  #         sumCnt += "#{r['col1']}_cnt+"
  #       else
  #         colList += r['col1'].nil? ? " , 0 as #{r['col2']}" : " , 0 as #{r['col1']}"
  #       end
  #     end
  #   end
  #   query = "drop table if exists similarityBitMap; select #{colList} into similarityBitMap from #{@fTable} f FULL OUTER JOIN #{@tTable} t ON #{@pkJoin}"
  #   # p query
  #   DBConn.exec(query)
  #   query = "select count(1) as total_cnt from similarityBitMap"
  #   res = DBConn.exec(query)
  #   total_cnt = res[0]['total_cnt'].to_f
  #   # puts "total_cnt: #{total_cnt}"
  #   colNum = (matchingCol.count - @pkList.count).to_f
  #   # puts "colNum: #{colNum}"

  #   total_field = total_cnt*colNum
  #   # puts "total_field: #{total_field}"
  #   colCnt = colCnt[0...-1]
  #   sumCnt = sumCnt[0...-1]
  #   query = "with t as(select #{colCnt} from similarityBitMap) select #{sumCnt} as sum from t;"
  #   # puts query
  #   res = DBConn.exec(query)
  #   sum = res[0]['sum'].to_f

  #   # puts "sum: #{sum}"

  #   puts "similarity: "
  #   puts (sum/total_field).to_f
  #   (sum/total_field).to_f
  # end
  # projection error localization
  def projErr
    projErrList = []
    targetList = @fPS['SELECT']['targetList']

    targetList.each_with_index do |node, index|
      # pp n
      col = ReverseParseTree.colNameConstr(node)
      # node['RESTARGET']['name'] || ( node['RESTARGET']['val']['COLUMNREF']['fields'].count()==1 ) ? node['RESTARGET']['val']['COLUMNREF']['fields'][0] : node['RESTARGET']['val']['COLUMNREF']['fields'][1]
      colName = col['alias']
      # puts colName
      # p colName
      next if @pkList.include? colName
      query = "select count(1) from #{@fTable} f JOIN #{@tTable} t ON #{@pkJoin} WHERE t.#{colName} != f.#{colName}"
      # p query
      res = DBConn.exec(query)
      if res.getvalue(0, 0).to_i > 0
        # puts "index:#{index}"
        projErrList.push(index)
      end
    end
    projErrList
  end

  # join error localization : Join Type, Join condition
  def joinErr
    # joinErrList = []
    unwanted_joinErrList = []
    missing_joinErrList = []
    return joinErrList if @fPS['SELECT']['fromClause'][0]['JOINEXPR'].nil?
    if @missingQuery.nil? && @unwantedQuery.nil?

      ftuples_tbl_create
      find_failed_tuples
    end

    if @unwanted_tuple_count + @missing_tuple_count == 0
      p 'no failed rows found. There is no Join Error'
      return []
    end
    joinKeyErrList = joinKeyTest
    exit
    tbl2PK = @pkList.map do |c|
      "tbl2.#{c}_pk"
    end.join(',')
    unwantedQuery = @unwantedQuery.gsub('tbl2.*', tbl2PK)
    missingQuery = @missingQuery.gsub('tbl2.*', tbl2PK)
    # test if thers is join key errors

    if @unwanted_tuple_count > 0
      # query = @unwantedQuery.gsub('tbl2.*',tbl2PK)
      errlist = jointypeTest(unwantedQuery, 'U')
      unwanted_joinErrList = errList unless errlist.nil?
    end

    if @missing_tuple_count > 0
      # query = @missingQuery.gsub('tbl2.*',tbl2PK)

      errlist = jointypeTest(missingQuery, 'M')
      missing_joinErrList = errList unless errlist.nil?
    end

    # joinErrList = unwanted_joinErrList + missing_joinErrList
    unwanted_joinErrList + missing_joinErrList
  end

  def joinKeyTest
    pkList = @pkFullList.map { |pk| pk['col'] }.join(',')

    query = "SELECT #{pkList} FROM #{@fromCondStr}"
    tQuery = ReverseParseTree.reverseAndreplace(@tPS, pkList, '')
    # test if tquery is subset of test query without where condition
    testQuery = QueryBuilder.subset_test(query, tQuery)
    pp testQuery
    res = DBConn.exec(testQuery)
    # p testQuery
    result = res[0]['result']
    table_list = @relNames.map { |rel| '"' + rel['relname'] + '"' }.join(',')
    pp table_list
    join_keys = []
    unless result == 'IS SUBSET'
      assoc_rules = Association_Rules(table_list)
      pp assoc_rules
      join_keys = assoc_rules.verify_rules(@tTable, @allColumns_select, @tQueryObj.query)
    end
    join_keys
  end

  def jointypeTest(pkQuery, testDataType)
    if testDataType == 'U' # unwanted
      fromCondStr = @fromCondStr
    else
      # for missing data set, we need to replace all join to OUTER JOIN
      fromPT = JsonPath.for(@fromPT.to_json).gsub('$..jointype') { |_v| '2' }.to_hash
      fromCondStr = ReverseParseTree.fromClauseConstr(fromPT)
      # p fromCondStr
    end
    joinErrList = []
    joinJson = @fPS['SELECT']['fromClause'][0].to_json
    joinList = JsonPath.on(joinJson, '$..JOINEXPR')

    joinList.each_with_index do |join, index|
      joinType = join['jointype']
      has_quals = join.key? 'quals'
      # joinQuals = join['JOINEXPR'].has_key? 'quals' ? join['JOINEXPR']['quals'] : nil
      larg = join['larg']
      lLoc = JsonPath.on(larg, '$..location')[0]

      rarg = join['rarg']
      rLoc = JsonPath.on(rarg, '$..location')[0]

      # pp join
      # join null testing is not needed for inner join, unwanted dataset
      next if (joinType.to_s == '0') && (testDataType == 'U')
      # LEFT NULL
      lNull = joinArgNull(larg)
      lRst = joinNullTest(lNull, pkQuery, fromCondStr)
      joinErrList << joinNullRst(lRst, joinType, 'L', lLoc, has_quals, index)
      # Right Null
      rNull = joinArgNull(rarg)
      rRst = joinNullTest(rNull, pkQuery, fromCondStr)
      joinErrList << joinNullRst(rRst, joinType, 'R', rLoc, has_quals, index)
    end
    joinErrList.compact!
  end

  def joinArgNull(arg)
    h = {}
    h = arg
    relList = h.find_all_values_for('RANGEVAR')
    pkNull = []
    relList.each do |r|
      rel = ReverseParseTree.relnameConstr(r)
      relName = rel['relname']
      relAlias = rel['alias']
      relFullName = rel['fullname']
      query = QueryBuilder.find_pk_cols(relName)
      pkCol = DBConn.exec(query)
      # pkList << pkCol.map{ |row| relAlias + ' '+ row['attname']}.join(', ')
      pkNull << pkCol.map { |row| relAlias + '.' + row['attname'] + ' is null' }.join(' AND ')
    end
    pkNull.join(' AND ')
  end

  def joinNullTest(pkNull, pkQuery, fromCondStr)
    pkNodes = []
    @pkList.each do |c|
      pkNodes <<  ReverseParseTree.find_col_by_name(@fPS['SELECT']['targetList'], c)
    end
    pkNodes.compact!
    # pp pkNodes.to_a
    reversedPKList = pkNodes.map { |n| n['col'] }.join(',')

    query = "SELECT #{reversedPKList} FROM #{fromCondStr} "
    query += !@whereStr.empty? ? "WHERE #{@whereStr} AND #{pkNull}" : " WHERE #{pkNull}"

    testQuery = QueryBuilder.subset_test(query, pkQuery)

    res = DBConn.exec(testQuery)
    # p testQuery
    result = res[0]['result']

    unless result == 'IS SUBSET'
      testQuery = QueryBuilder.subset_test(pkQuery, query)
      # p query
      res = DBConn.exec(testQuery)
      # p testQuery
      result = res[0]['result']
    end
    result
  end

  def joinNullRst(rst, jointype, joinSide, location, has_quals, index)
    # p rst

    if rst == 'IS SUBSET'
      joinTypeDesc = ReverseParseTree.joinTypeConvert(jointype.to_s, has_quals)
      # p "Error in Join type #{joinTypeDesc} of #{joinSide}"
      h = {}
      h['location'] = location
      h['joinSide'] = joinSide
      h['joinType'] = jointype
      h['index'] = index
      h
    end
  end

  def find_failed_tuples
    # Unwanted rows
    # query,res = find_unwanted_tuples()
    # unWantedPK = pkArryGen(res)
    @unWantedPK = find_unwanted_tuples
    # Missing rows
    # query,res = find_missing_tuples()
    # missinPK = pkArryGen(res)
    @missingPK = find_missing_tuples
    # return unWantedPK,missinPK
  end

  # where cond error localization
  def selecionErr(method)
    whereErrList = []
    # joinErrList = []

    if @missingQuery.nil? && @unwantedQuery.nil?
      # allcolumns_construct('or',true)
      ftuples_tbl_create
      find_failed_tuples
    end

    # allcolumns_construct(method,true)
    # ftuples_tbl_create
    # find_failed_tuples() if @unWantedPK.nil? && @missinPK.nil?

    # # pkNull = @pkSelect.gsub(',',' IS NULL AND ')
    # @unwanted_tuple_count = unWantedPK.count()
    tnTableCreation('tuple_node_test_result') if @is_new

    if @unwanted_tuple_count + @missing_tuple_count == 0
      p 'no failed rows found. There is no selection error'
      return whereErrList
    end

    if @unwanted_tuple_count > 0
      # p "Unwanted Pk count #{unWantedPK.count()}"
      # create unwanted_tuple_branch table
      # binding.pry
      whereErrList = whereCondTest(@unWantedPK, 'U')
      # joinErrList = jointypeErr(query,'U')
    end

    if @missing_tuple_count > 0
      # p "Missing PK count #{missinPK.count()}"
      # binding.pry
      whereErrList = whereCondTest(@missingPK, 'M')
      # joinErrList = jointypeErr(query,'M')
    end

    # create aggregated tuple_suspicious_nodes
    pk = @pkFullList.map { |pk| pk['alias'] }.join(',')
    query = 'create materialized view tuple_node_test_result_aggr as '\
            "select #{pk}, string_agg(branch_name||'-'||node_name, ',' order by node_name,branch_name) as suspicious_nodes from tuple_node_test_result group by #{pk}"
    # pp query
    DBConn.exec(query)

    suspicious_score_upd(@predicateTree.branches)

    # exnorate algorithm
    # binding.pry
    case method
    when 'o'
      puts 'old exonerate algorithm'

      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      column_combinations_construct
      tuple_mutation_test(missinPK, 'M', constraint_query, false)
      tuple_mutation_test(unWantedPK, 'U', constraint_query, false)
    when 'or'
      puts 'old exonerate algorithm with duplicate removal'
      # reset suspicious score
      query = "update node_query_mapping set suspicious_score = 0 where type = 'f'"
      res = DBConn.exec(query)

      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      # allcolumns_construct()
      tuple_mutation_test_with_dup_removal('M', constraint_query)
      tuple_mutation_test_with_dup_removal('U', constraint_query)
    when 'n'
      puts 'new exonerate algorithm'
      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      tuple_mutation_test_reverse(missinPK, 'M', constraint_query, false)
      tuple_mutation_test_reverse(unWantedPK, 'U', constraint_query, false)

    when 'b'
      puts 'baseline'
    else
      puts 'Unknown method'
    end
    # remove constraint_nodes in node_query_mapping
    query = "delete from node_query_mapping where test_id = #{@test_id} and type = 't'"
    DBConn.exec(query)

    # j = Hash.new
    # # j['JoinErr'] = joinErrList if joinErrList.count >0
    # j['WhereErr'] = whereErrList
    # j
    whereErrList
  end

  def true_query_PT_construct
    @tWherePT = @tPS['SELECT']['whereClause']
    @tPredicateTree = PredicateTree.new('t', false, @test_id)
    root = Tree::TreeNode.new('root', '')
    @tPredicateTree.build_full_pdtree(@fromPT[0], @tWherePT, root)
  end

  def constraint_predicate_construct
    t_predicate_collist = @tPredicateTree.all_columns
    # pp "t_predicate_collist: #{t_predicate_collist}"
    # pp 't_predicate_tree.all_columns'
    # rename_where_pt = @tQueryObj.parseTree['SELECT']['whereClause']
    # binding.pry
    constraintPredicateQuery = ReverseParseTree.whereClauseConst(@tWherePT)
    # pp 'before'
    # pp @constraintPredicateQuery
    constraintPredicateQuery = RewriteQuery.rewrite_predicate_query(constraintPredicateQuery, t_predicate_collist)
  end

  def allcolumns_construct
    # all_columns = DBConn.getAllRelFieldList(@fromPT)

    # @allColumnList = all_columns
    # pp @allColumnList
    # @all_column_combinations = []

    # max = all_columns.count()
    # 1.upto(max) do |i|
    #   all_columns.combination(i).each do |cc|
    #     @all_column_combinations << cc.to_set
    #   end
    # end

    # pp @allColumnList
    @allColumns_select = tQueryObj.all_cols_select
    @allColumns_renamed = tQueryObj.all_cols_renamed
  end

  def column_combinations_construct
    @column_combinations = method.start_with?('o') && compute_cc ? Columns_Combination.new(all_columns) : all_columns
  end

  def tuple_mutation_test_reverse(pkArry, type, constraint_predicate, duplicate_removal)
    # tPredicateArry =tPredicateTree.predicateArrayGen(tPDTree)
    pkArry.each do |pk|
      # pp pk
      # pp type
      # @column_combinations.reset_processed()
      # pkCond=QueryBuilder.pkCondConstr_strip_tbl_alias(pk)
      pkCond = QueryBuilder.pkCondConstr_strip_tbl_alias_colalias(pk)
      # pp "#{pkCond}: #{Time.now}"
      # only need exonerating if multiple nodes in a branch are suspicious
      branchQuery = "select distinct branch_name from tuple_node_test_result where #{pkCond};"
      res = DBConn.exec(branchQuery)
      # pp "begin: #{Time.now}"
      if type == 'U'
        # pp branchQuery
        res.each do |branch_name|
          # distinct_query = "select distinct node_name from node_query_mapping where branch_name = '#{branch_name['branch_name']}'"
          # distinct_nodes =DBConn.exec(distinct_query)
          # if distinct_nodes.count()>1
          branch = []
          branch << @predicateTree.branches.find { |br| br.name == branch_name['branch_name'] }
          # pp "branch: #{Time.now}"
          tupleMutationReverse = TupleMutationReverse.new(@test_id, pk, type, branch, @fQueryObj, constraint_predicate)
          # pp "new: #{Time.now}"
          tupleMutationReverse.allcolumns_construct(@column_combinations, @allColumns_select, @allColumns_renamed)
          # pp "allcolumns_construct: #{Time.now}"
          tupleMutationReverse.unwanted_to_satisfied(duplicate_removal)
          # pp "unwanted_to_satisfied: #{Time.now}"
          # end
        end
      elsif type == 'M'
        # # only need exonerating if multiple branches are suspicious
        #  branchQuery="select distinct branch_name from tuple_node_test_result where #{pkCond};"
        #  # pp branchQuery
        #  res = DBConn.exec(branchQuery)
        # if res.count()>1
        tupleMutationReverse = TupleMutationReverse.new(@test_id, pk, type, @predicateTree.branches, @fQueryObj, constraint_predicate)
        # tupleMutation.allcolumns_construct(@all_column_combinations, @allColumns_select,@allColumns_renamed)
        tupleMutationReverse.allcolumns_construct(@column_combinations, @allColumns_select, @allColumns_renamed)

        tupleMutationReverse.missing_to_excluded(duplicate_removal)
        # abort('missing')
        # end
      end
    end
  end

  def tuple_mutation_test(pkArry, type, constraint_predicate, duplicate_removal)
    # tPredicateArry =tPredicateTree.predicateArrayGen(tPDTree)
    pkArry.each do |pk|
      # pp pk
      # pp type
      @column_combinations.reset_processed
      # pkCond=QueryBuilder.pkCondConstr_strip_tbl_alias(pk)
      pkCond = QueryBuilder.pkCondConstr_strip_tbl_alias_colalias(pk)
      # pp "#{pkCond}: #{Time.now}"
      # only need exonerating if multiple nodes in a branch are suspicious
      branchQuery = "select distinct branch_name from tuple_node_test_result where #{pkCond};"
      res = DBConn.exec(branchQuery)
      # pp "begin: #{Time.now}"
      if type == 'U'
        # pp branchQuery
        res.each do |branch_name|
          # distinct_query = "select distinct node_name from node_query_mapping where branch_name = '#{branch_name['branch_name']}'"
          # distinct_nodes =DBConn.exec(distinct_query)
          # if distinct_nodes.count()>1
          branch = []
          branch << @predicateTree.branches.find { |br| br.name == branch_name['branch_name'] }
          # pp "branch: #{Time.now}"
          tupleMutation = TupleMutation.new(@test_id, pk, type, branch, @fQueryObj, constraint_predicate)
          # pp "new: #{Time.now}"
          tupleMutation.allcolumns_construct(@column_combinations, @allColumns_select, @allColumns_renamed)
          # pp "allcolumns_construct: #{Time.now}"
          tupleMutation.unwanted_to_satisfied(duplicate_removal)
          # pp "unwanted_to_satisfied: #{Time.now}"
          # end
        end
      elsif type == 'M'
        # # only need exonerating if multiple branches are suspicious
        #  branchQuery="select distinct branch_name from tuple_node_test_result where #{pkCond};"
        #  # pp branchQuery
        #  res = DBConn.exec(branchQuery)
        # if res.count()>1
        tupleMutation = TupleMutation.new(@test_id, pk, type, @predicateTree.branches, @fQueryObj, constraint_predicate)
        # tupleMutation.allcolumns_construct(@all_column_combinations, @allColumns_select,@allColumns_renamed)
        tupleMutation.allcolumns_construct(@column_combinations, @allColumns_select, @allColumns_renamed)

        tupleMutation.missing_to_excluded(duplicate_removal)
        # abort('missing')
        # end
      end
    end
  end

  def tuple_mutation_test_with_dup_removal(type, constraint_predicate)
    targetList = @pkFullList.map { |pk| "#{pk['alias']}_pk as #{pk['alias']}" }.join(', ')
    query = "select #{targetList} from ftuples where type='#{type}' limit 1"
    pp query
    res = DBConn.exec(query)
    cnt = 1
    while res.cmd_tuples > 0
      # puts cnt
      # puts "begin: #{Time.now}"
      pkArry = pkArryGen(res)
      # whereCondTest(pkArry,type)
      # pp pkArry
      # puts test
      tuple_mutation_test(pkArry, type, constraint_predicate, true)
      res = DBConn.exec(query)
      # pp res
      # puts test
      # puts "end: #{Time.now}"
      cnt += 1
    end
  end

  def suspicious_score_upd(predicate_tree_branches)
    predicate_tree_branches.each do |br|
      br.nodes.each do |nd|
        query = "suspicious_score = #{nd.suspicious_score}"

        @predicateTree.node_query_mapping_upd(br.name, nd.name, query)
      end
    end
  end

  # create tuple node table
  def tnTableCreation(tableName)
    pk_list = @pkList.join(',')
    pk_list = "#{pk_list},branch_name,node_name"
    q = QueryBuilder.create_tbl(tableName, pk_list, "select #{@pkSelect}, 0 as test_id,''::varchar(30) as node_name, ''::varchar(30) as branch_name, ''::varchar(5) as type from #{@fTable} f where 1 = 0")
    # pp q
    DBConn.exec(q)

    # q="ALTER TABLE #{tableName} add column test_id int, add column node_name varchar(30), add column branch_name varchar(30), add column type varchar(5);"
    # DBConn.exec(q)
    # pk=@pkList.join(',')
    # # add index
    #  q="create index ix_#{tableName}t on #{tableName} (#{pk},branch_name);"
    #  pp q
    # DBConn.exec(q)
  end

  def pkArryGen(res)
    pkArry = []
    res.each do |r|
      pk = []
      @pkFullList.each do |pkcol|
        h = {}
        # binding.pry
        colname = pkcol['colname']
        h['val'] = r[colname].nil? ? r[pkcol['alias']] : r[colname]
        h['alias'] = pkcol['alias']
        h['col'] = pkcol['col']
        pk.push(h)
      end
      pkArry.push(pk)
    end
    pkArry
  end

  def getSuspiciouScore
    query = "select location, sum(suspicious_score) as suspicious_score, array_agg(DISTINCT c ORDER BY c) as cols from node_query_mapping, unnest(columns) c where test_id = #{@test_id} group by location"
    rst = DBConn.exec(query)
    score = {}
    score['totalScore'] = 0
    rst.each do |t|
      score['totalScore'] += t['suspicious_score'].to_i
      loc = t['location']
      score[loc] = t['suspicious_score']
    end
    score
  end

  def whereCondTest(pkArry, type)
    return if @wherePT.nil?
    # whereCondArry = ReverseParseTree.whereCondSplit(@wherePT)
    selectQuery = 'SELECT COUNT(1) FROM ' + @fromCondStr + ' WHERE '
    # p selectQuery
    pkArry.each do |pk|
      @predicateTree.branches.each do |branch|
        branchQuery = selectQuery + QueryBuilder.pkCondConstr(pk)
        # pp pk
        nodeQuery = branchQuery
        pkVal = QueryBuilder.pkValConstr(pk)
        currentNode = branch
        branch.nodes.each do |node|
          branchQuery = branchQuery + ' AND ' + node.query
          nodeQuery_new = nodeQuery + ' AND ' + node.query
          # suspicious score+ for each node fails missing tuple
          next unless type == 'M'
          # puts 'nodeQuery_new'
          # pp nodeQuery_new
          # binding.pry
          res = DBConn.exec(nodeQuery_new)
          # pp res[0]['count']
          if res[0]['count'].to_i == 0
            # p 'failed!'
            # pp nodeQuery_new
            node.suspicious_score += 1
            # pp currentNode.content
            query = "INSERT INTO tuple_node_test_result values (#{pkVal}, #{@test_id},'#{node.name}', '#{branch.name}','M')"
            DBConn.exec(query)
          else
            # p 'passed'
            # pp nodeQuery
            nodeQuery = nodeQuery_new
          end
          # end
        end

        # suspicious score+ for each BRANCH that passes unwanted tuple
        next unless type == 'U'
        # puts'U'
        # puts branchQuery
        res = DBConn.exec(branchQuery)
        # pp res[0]['count']
        next unless res[0]['count'].to_i > 0
        # p 'failed'
        # pp branchQuery
        # pp currentNode.has_children?
        currentNode = branch
        # puts 'currentNode'
        # pp currentNode
        branch.nodes.each do |node|
          # currentNode = currentNode.children[0]
          # unless currentNode.name=~ /^PH*/
          query = "INSERT INTO tuple_node_test_result values (#{pkVal},#{@test_id},'#{node.name}', '#{branch.name}','U')"
          DBConn.exec(query)
          # p query
          node.suspicious_score += 1
          # end
        end
      end
    end
  end

  def find_unwanted_tuples
    pkNull = @pkSelect.gsub(',', ' IS NULL AND ')
    select_query = 'SELECT #TARGETLIST#'\
                   " FROM #{@fTable} f LEFT JOIN #{@tTable} t ON #{@pkJoin} where #{pkNull.gsub('f.', 't.')} IS NULL"

    # Unwanted rows
    targetList = @pkSelect

    query = select_query.gsub('#TARGETLIST#', targetList)
    res = DBConn.exec(query)
    @unwanted_tuple_count = res.count

    # Insert into ftuples_tbl
    renamedPKCol = @pkFullList.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
    targetList = "#{renamedPKCol},'none'::varchar(300) as mutation_cols,'U'::varchar(1) as type,#{@allColumns_select}"
    val_query = ReverseParseTree.reverseAndreplace(@fPS, targetList, '1=1')
    pkjoin = @pkFullList.map do |c|
      "tbl1.#{c['alias']} = tbl2.#{c['alias']}_pk"
    end.join(' AND ')
    @unwantedQuery = "select tbl2.* from (#{query}) as tbl1 JOIN (#{val_query}) as tbl2 ON #{pkjoin}"

    query = "INSERT INTO ftuples #{@unwantedQuery}"
    # puts query
    DBConn.exec(query)
    # puts 'unwanted rows query'
    # puts query
    pkArryGen(res)
    # return query,res
  end

  def find_missing_tuples
    pkNull = @pkSelect.gsub(',', ' IS NULL AND ')

    select_query = 'SELECT #TARGETLIST#'\
                   " FROM #{@tTable} t LEFT JOIN #{@fTable} f ON #{@pkJoin} where #{pkNull} IS NULL"
    # Unwanted rows
    targetList = @pkSelect.gsub('f.', 't.')
    query = select_query.gsub('#TARGETLIST#', targetList)
    res = DBConn.exec(query)
    @missing_tuple_count = res.count

    # Insert into ftuples_tbl
    renamedPKCol = @pkFullList.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
    targetList = "#{renamedPKCol},'none'::varchar(300) as mutation_cols,'M'::varchar(1) as type,#{@allColumns_select}"
    val_query = ReverseParseTree.reverseAndreplace(@fPS, targetList, '1=1')
    pkjoin = @pkFullList.map do |c|
      "tbl1.#{c['alias']} = tbl2.#{c['alias']}_pk"
    end.join(' AND ')
    @missingQuery = "select tbl2.* from (#{query}) as tbl1 JOIN (#{val_query}) as tbl2 ON #{pkjoin}"
    query = "INSERT INTO ftuples #{@missingQuery}"
    # pp query
    DBConn.exec(query)
    # puts 'unwanted rows query'
    # puts query
    pkArryGen(res)
    # return query, res
  end

  def ftuples_tbl_create
    renamedPKCol = @pkFullList.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')

    targetListReplacement = "#{renamedPKCol},'none'::varchar(800) as mutation_cols,'none'::varchar(1) as type,#{@allColumns_select}"
    query =  ReverseParseTree.reverseAndreplace(@fPS, targetListReplacement, '1=2')
    pkList = @pkFullList.map { |pk| "#{pk['alias']}_pk" }.join(', ') + ',mutation_cols, type'
    query = QueryBuilder.create_tbl('ftuples', pkList, query)
    DBConn.exec(query)
  end
end
