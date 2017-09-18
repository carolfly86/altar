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

    @fQueryObj = fQueryObj
    @tQueryObj = tQueryObj

    @fTable = fQueryObj.table
    @tTable = tQueryObj.table

    @all_columns = fQueryObj.all_cols

    @fPS = fQueryObj.parseTree
    @tPS = tQueryObj.parseTree
    @is_new = is_new
    @test_id = @is_new ? 0 : generate_new_testid

    @missingQuery = nil
    @unwantedQuery = nil

    @pkList = tQueryObj.pk_list

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
    # generate predicate tree from where clause
    unless @wherePT.nil?
      fQueryObj.predicate_tree_construct('f', @is_new, @test_id)
      @predicateTree = fQueryObj.predicate_tree
      @pdtree = @predicateTree.pdtree
      @whereStr = ReverseParseTree.whereClauseConst(@wherePT)
    end
    # puts tes
    # @predicateTree.node_query_mapping_insert()
    @fromCondStr = ReverseParseTree.fromClauseConstr(@fromPT)

    # pp @whereStr
    @missing_tuple_count = 0
    @unwanted_tuple_count = 0
    # create_t_f_union_table
    # create_t_f_intersect_table
    # create_t_f_all_table
    allcolumns_construct

    ftuples_tbl_create
    find_failed_tuples
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
    query = "select #{@pkSelect},'t' from #{@tTable} UNION select #{@pkSelect},'f' from #{@fTable}"
    query = QueryBuilder.create_tbl('t_f_union', @pkList, query)
    puts'create t_f_union'
    puts query
    # create
    DBConn.exec(query)
  end

  def create_t_f_intersect_table
    query = "select #{@pkSelect},'t' from #{@tTable} INTERSECT select #{@pkSelect},'f' from #{@fTable}"
    query = QueryBuilder.create_tbl('t_f_intersect', @pkList, query)
    puts'create t_f_intersect'
    puts query
    # create
    DBConn.exec(query)
  end

  def create_t_f_all_table
    query = ReverseParseTree.reverseAndreplace(@fParseTree, @pkList, '1=1')
    query = QueryBuilder.create_tbl('t_f_all', @pkList, query)
    puts'create t_f_all'
    puts query
    DBConn.exec(query)
  end

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


  def none_nullalble_failing_rows()
    nullable_tbl = find_failing_nullable_rows()
    return @ftuples_tbl.row_count() if nullable_tbl.nil?

    target_list = nullable_tbl.columns.map{|c| c.colname}.join(', ')
    except_query = @ftuples_tbl.except_query(nullable_tbl,target_list)
    query = " with expt as (#{except_query}) select count(1) as cnt from expt"
    return DBConn.exec(query)[0]['cnt'].to_i
  end

  def find_failing_nullable_rows()
    # binding.pry
    if @nullable_f_tbl.nil?
      f_nullable_tbl = Table.new(@fQueryObj.nullable_tbl)
      t_nullable_tbl = Table.new(@tQueryObj.nullable_tbl)
      if t_nullable_tbl.row_count() == 0 and f_nullable_tbl.row_count() == 0
        return nil
      elsif t_nullable_tbl.row_count() == 0 and f_nullable_tbl.row_count() > 0
        query = "select *, 'U'::varchar(2) as type from #{f_nullable_tbl.relname}"
      elsif f_nullable_tbl.row_count() == 0 and t_nullable_tbl.row_count() > 0
        query = "select *, 'M'::varchar(2) as type from #{t_nullable_tbl.relname}"
      else
        unwanted_query = "SELECT *, 'U'::varchar(2) as type from ("+f_nullable_tbl.except_query(t_nullable_tbl)+") as unwanted"
        missing_query = "SELECT *, 'M'::varchar(2) as type from ("+t_nullable_tbl.except_query(f_nullable_tbl)+") as missing"
        query = "(#{unwanted_query}) UNION (#{missing_query})"
      end
      tbl_name = 'nullable_f_tbl'
      DBConn.tblCreation(tbl_name, '', query)
      @nullable_f_tbl = Failing_Row_Table.new(tbl_name)
    end
    return @nullable_f_tbl
  end

  # join error localization : Join Type, Join condition
  def join_type_err
    # joinErrList = []
    unwanted_joinErrList = []
    missing_joinErrList = []
    return [] unless @fQueryObj.has_join?()

    nullable_f_tbl = find_failing_nullable_rows

    if nullable_f_tbl.nil?
      p 'No failing nullable rows found. There is no Join Type Error'
      return []
    end

    return join_type_test(nullable_f_tbl)
  end

  def join_type_test(nullable_f_tbl)

    joinErrList = []
    joinJson = @fPS['SELECT']['fromClause'][0].to_json
    joinList = JsonPath.on(joinJson, '$..JOINEXPR')
    f_rel_list = @fQueryObj.rel_list
    joinList.each_with_index do |join, index|
      joinType = join['jointype']
      has_quals = join.key? 'quals'
      # joinQuals = join['JOINEXPR'].has_key? 'quals' ? join['JOINEXPR']['quals'] : nil
      larg = join['larg']
      l_rel_list = join_arg_rel_list(larg,f_rel_list)
      lLoc = JsonPath.on(larg, '$..location')[0]

      rarg = join['rarg']
      r_rel_list = join_arg_rel_list(rarg,f_rel_list)
      rLoc = JsonPath.on(rarg, '$..location')[0]

      # pp join
      # join null testing is not needed for 
      # 1. inner join if there is no missing rows
      # 2. full join if there is no unwated rows
      next if (((joinType.to_s == '0') && (nullable_f_tbl.missing_row_count == 0) )\
              ||\
              ((joinType.to_s == '2') && (nullable_f_tbl.unwanted_row_count == 0) ))

      if has_quals
        quals = join['quals']
        joinSide =[]
        join_key_rel_alias = JsonPath.on(quals, '$..COLUMNREF').map{|key| key['fields'][0]}

        # remove rels not used in join key
        l_rel_list.delete_if{|rel| not join_key_rel_alias.include?(rel.relalias) }
        r_rel_list.delete_if{|rel| not join_key_rel_alias.include?(rel.relalias) }

        l_null_query_template = rel_pk_null_query(l_rel_list)
        r_null_query_template = rel_pk_null_query(r_rel_list)

        l_type = join_failing_row_type(joinType, true)
        r_type = join_failing_row_type(joinType, false)
        l_null_query = "DELETE FROM #{nullable_f_tbl.relname} WHERE type = '#{l_type}' AND "\
                      + l_null_query_template.gsub('#BOOL#', ' ') + ' AND '\
                      + r_null_query_template.gsub('#BOOL#', ' NOT ')
        r_null_query = "DELETE FROM #{nullable_f_tbl.relname} WHERE type = '#{r_type}' AND "\
                      + l_null_query_template.gsub('#BOOL#', ' NOT ')+ ' AND '\
                      + r_null_query_template.gsub('#BOOL#', ' ')
        # puts l_null_query
        res = DBConn.exec(l_null_query)
        joinSide << 'L' if res.cmd_tuples >0
        # joinErrList << joinNullRst(joinType, 'L', lLoc, index) 
        # puts r_null_query
        res = DBConn.exec(r_null_query)
        joinSide << 'R' if res.cmd_tuples >0

        if joinSide.count >0
          joinErrList << joinNullRst(joinType, joinSide.join(','), rLoc, index)
        end
      end
    end
    return joinErrList

  end

  def join_failing_row_type(join_type, is_l_null)
    if is_l_null
      case join_type
      when 0 # INNER JOIN
        'M'
      when 1 # LEFT JOIN
        'M'
      when 2 # FULL JOIN
        'U'
      when 3 # RIGHT JOIN
        'U'
      else
        ''
      end
    else
      case join_type
      when 0 # INNER JOIN
        'M'
      when 1 # LEFT JOIN
        'U'
      when 2 # FULL JOIN
        'U'
      when 3 # RIGHT JOIN
        'M'
      else
        ''
      end
    end
  end


  def rel_pk_null_query(rel_list)
    rel_list.map do |rel|
      rel.pk_column_list.map{|col| "#{col.renamed_colname} is#BOOL#null"}.join(' AND ')
    end.join(' AND ')
  end

  def join_arg_rel_list(arg,full_rel_list)
    relname_list = JsonPath.on(arg, '$..relname')
    rel_list = []
    relname_list.each do |name|
      rel_list << full_rel_list.find{|tbl| tbl.relname == name}
    end
    return rel_list
  end


  def join_key_err
    result_keys = []
    f_jk = JoinKeyIdent.new(@fQueryObj)
    f_key_list = f_jk.extract_from_parse_tree
    if none_nullalble_failing_rows > 0
      t_jk = JoinKeyIdent.new(@tQueryObj)
      t_key_list = t_jk.extract_from_table


      join_key_err_list = {}
      unwanted_keys = f_key_list - t_key_list
      missing_keys = t_key_list - f_key_list
      missing_keys.each do |kp|
        # if any unwanted tuple does not satisfy the missing key
        # then this missing key is neccessary
        # otherwise the missing key is not neccessary

        # or if a missing tuple satisfy the missing key
        # then the missing key is neccessary
         joinkey_not_eq = kp.map{|k| "#{k.renamed_colname}"}.join(' <> ')
         joinkey_eq = kp.map{|k| "#{k.renamed_colname}"}.join(' = ')
         joinkey_null =  kp.map{|k| "#{k.renamed_colname} is null "}.join('OR ')
         query = " select count(1) as cnt from ftuples "+
                 " where (type ='U' and (#{joinkey_not_eq} or #{joinkey_null}))" +
                 " or (type ='M' and (#{joinkey_eq} or #{joinkey_null}) )"
         # pp query
         res = DBConn.exec(query)
         result = res[0]['cnt']
         if result.to_i ==  0
           binding.pry
           missing_keys.delete(kp)
         end
      end
      # binding.pry
      if unwanted_keys.count + missing_keys.count>0
        result_keys = f_key_list - unwanted_keys + missing_keys
      end
    end
    return result_keys,f_key_list
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
    puts testQuery
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

  def joinNullRst(jointype, joinSide, location, index)
    # p rst

    # if rst == 'IS SUBSET'
      # joinTypeDesc = ReverseParseTree.joinTypeConvert(jointype.to_s, has_quals)
      # p "Error in Join type #{joinTypeDesc} of #{joinSide}"
      h = {}
      h['location'] = location
      h['joinSide'] = joinSide
      h['joinType'] = jointype
      h['index'] = index
      h
    # end
  end

  def find_failed_tuples
    # Unwanted rows
    @unWantedPK = find_unwanted_tuples
    # Missing rows
    @missingPK = find_missing_tuples
  end

  # where cond error localization
  def selecionErr(method)

    tnTableCreation('tuple_node_test_result') if @is_new

    if @unwanted_tuple_count + @missing_tuple_count == 0
      p 'no failed rows found. There is no selection error'
      return
    end

    if @unwanted_tuple_count > 0
      # p "Unwanted Pk count #{unWantedPK.count()}"
      # create unwanted_tuple_branch table
      # binding.pry

      # whereErrList = whereCondTest(@unWantedPK, 'U')
      where_cond_test('U')
      # joinErrList = jointypeErr(query,'U')
    end

    if @missing_tuple_count > 0
      # p "Missing PK count #{missinPK.count()}"
      # binding.pry
      # whereErrList = whereCondTest(@missingPK, 'M')
      where_cond_test('M')
      # joinErrList = jointypeErr(query,'M')
    end
    # create aggregated tuple_suspicious_nodes
    pk = @pkFullList.map { |pk| pk['alias'] }.join(',')
    query = 'create materialized view tuple_node_test_result_aggr as '\
            "select #{pk}, string_agg(branch_name||'-'||node_name, ',' order by node_name,branch_name) as suspicious_nodes from tuple_node_test_result group by #{pk}"
    pp query
    DBConn.exec(query)

    unless @predicateTree.nil?
      suspicious_score_upd(@predicateTree.branches)
    end
    # exnorate algorithm
    # binding.pry
    @column_combinations = method.start_with?('o') ? Columns_Combination.new(@all_columns) : @all_columns
    case method
    when 'o'
      puts 'old exonerate algorithm'

      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      # column_combinations_construct
      tuple_mutation_test(@missingPK, 'M', constraint_query, false)
      tuple_mutation_test(@unWantedPK, 'U', constraint_query, false)
    when 'or'
      puts 'old exonerate algorithm with duplicate removal'
      # reset suspicious score
      query = "update node_query_mapping set suspicious_score = 0 where type = 'f'"
      res = DBConn.exec(query)

      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      # allcolumns_construct()
      puts 'Missing starts'
      puts Time.now()
      tuple_mutation_test_with_dup_removal('M', constraint_query)
      puts 'Unwanted starts'
      puts Time.now()

      tuple_mutation_test_with_dup_removal('U', constraint_query)
    when 'n'
      puts 'new exonerate algorithm'
      true_query_PT_construct
      constraint_query = constraint_predicate_construct
      tuple_mutation_test_reverse(@missingPK, 'M', constraint_query, false)
      tuple_mutation_test_reverse(@unWantedPK, 'U', constraint_query, false)

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
    # whereErrList
  end

  def true_query_PT_construct
    # @tWherePT = @tPS['SELECT']['whereClause']
    # @tPredicateTree = PredicateTree.new('t', false, @test_id)
    # root = Tree::TreeNode.new('root', '')
    # @tPredicateTree.build_full_pdtree(@fromPT[0], @tWherePT, root)
    @tQueryObj.predicate_tree_construct('t', false, @test_id)
    @tPredicateTree = @tQueryObj.predicate_tree
  end

  def constraint_predicate_construct
    t_predicate_collist = @tPredicateTree.all_columns
    # pp "t_predicate_collist: #{t_predicate_collist}"
    # pp 't_predicate_tree.all_columns'
    # rename_where_pt = @tQueryObj.parseTree['SELECT']['whereClause']
    # binding.pry
    constraintPredicateQuery = ReverseParseTree.whereClauseConst(@tPS['SELECT']['whereClause'])
    # pp 'before'
    # pp @constraintPredicateQuery
    # pp constraintPredicateQuery
    # binding.pry
    constraintPredicateQuery = RewriteQuery.rewrite_predicate_query(constraintPredicateQuery, t_predicate_collist)
  end

  def allcolumns_construct
    @allColumns_select = @tQueryObj.all_cols_select
    @allColumns_renamed = @tQueryObj.all_cols_renamed
  end

  def column_combinations_construct
    @column_combinations = Columns_Combination.new(@all_columns) #: @all_columns
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
          pp pk
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
      
      # pp type
      @column_combinations.reset_processed
      # pkCond=QueryBuilder.pkCondConstr_strip_tbl_alias(pk)
      pkCond = QueryBuilder.pkCondConstr_strip_tbl_alias_colalias(pk)
      # pp "#{pkCond}: #{Time.now}"
      # only need exonerating if multiple nodes in a branch are suspicious
      branchQuery = "select distinct branch_name from tuple_node_test_result where #{pkCond};"
      res = DBConn.exec(branchQuery)
      # pp "begin: #{Time.now}"
      # binding.pry
      if type == 'U'
        # pp branchQuery
        res.each do |branch_name|
          # distinct_query = "select distinct node_name from node_query_mapping where branch_name = '#{branch_name['branch_name']}'"
          # distinct_nodes =DBConn.exec(distinct_query)
          # if distinct_nodes.count()>1
          # puts "ftuples_is_empty? #{ftuples_is_empty?}"
          break if ftuples_is_empty?
          branch = []
          branch << @predicateTree.branches.find { |br| br.name == branch_name['branch_name'] }
          # pp "branch: #{Time.now}"
          tupleMutation = TupleMutation.new(@test_id, pk, type, branch, @fQueryObj, constraint_predicate)
          # pp "new: #{Time.now}"
          tupleMutation.allcolumns_construct(@column_combinations, @allColumns_select, @allColumns_renamed)
          # pp "allcolumns_construct: #{Time.now}"
          # puts '*******'
          # pp pk
          # pp branch_name
          # puts 'going to unwanted_to_satisfied'
          tupleMutation.unwanted_to_satisfied(duplicate_removal)
          # puts '**********'
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
    # pp query
    res = DBConn.exec(query)
    cnt = 1
    while res.cmd_tuples > 0
      # puts cnt
      # puts "begin: #{Time.now}"
      pkArry = pkArryGen(res)
      # whereCondTest(pkArry,type)
      pp pkArry
      # # puts test
      # puts 'going to tuple_mutation_test'
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

  def ftuples_is_empty?
    # query = "select count(1) as cnt from ftuples"
    # res = DBConn.exec(query)
    return @ftuples_tbl.row_count == 0
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
    query = "select location, sum(suspicious_score) as suspicious_score from node_query_mapping where test_id = #{@test_id} group by location"
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
  def get_test_result
    query = "select location,branch_name,node_name, "+
    "sum(suspicious_score) as suspicious_score, array_agg(DISTINCT c ORDER BY c) as cols "+
    "from node_query_mapping, unnest(columns) c where test_id = #{@test_id} and suspicious_score >0"+
    " group by location, branch_name,node_name "+
    # last process missing nodes
    " order by location desc"
    rst = DBConn.exec(query)
    test_result = []
    # test_result['totalScore'] = 0
    # test_result['nodes'] = []
    rst.each do |t|
      trd = Test_Result_Detail.new()
      trd.branch_name = t['branch_name']
      trd.node_name = t['node_name']
      trd.location = t['location']
      trd.columns = []
      t['cols'].gsub('{', '').gsub('}','').split(',').each do |c|
        trd.columns << @tQueryObj.all_cols.find{|col| col.hash == c.split('.').hash }
      end
      trd.suspicious_score = t['suspicious_score']
      test_result << trd
      # test_result['totalScore'] += trd.suspicious_score.to_i
    end
    test_result
  end


  # for missing tuples, each branch must have at least one node failed
  # all such node are suspicious
  def where_cond_test_m(tuple_node_test_result_tbl)
    pk = @pkFullList.map { |pk| "#{pk['alias']}_pk" }.join(', ')
    @predicateTree.branches.each do |branch|
      branch.nodes.each do |nd|
        query = "INSERT INTO #{tuple_node_test_result_tbl} "+
                "select #{pk}, #{@test_id},'#{nd.name}', '#{branch.name}',type "+
                "from ftuples where type = 'M'"

        node_query = RewriteQuery.rewrite_predicate_query(nd.query, nd.columns)

        node_query =  query + " AND NOT (#{node_query})"

        res = DBConn.exec(node_query)
        nd.suspicious_score += res.cmd_tuples()
      end
    end
  end

  # for unwanted tuples, at least one branch must passed
  # all nodes in such branch are suspicious
  def where_cond_test_u(tuple_node_test_result_tbl)
    pk = @pkFullList.map { |pk| "#{pk['alias']}_pk" }.join(', ')
    @predicateTree.branches.each do |branch|

      branch_query = RewriteQuery.rewrite_predicate_query(branch.branch_query, branch.columns)
      # branch_query = query + " AND "+ branch_query

      branch.nodes.each do |node|
        query = "INSERT INTO #{tuple_node_test_result_tbl} "+
            "select #{pk}, #{@test_id},'#{node.name}', '#{branch.name}',type "+
            "from ftuples where type = 'U' AND #{branch_query}"
        # puts query
        res = DBConn.exec(query)
        node.suspicious_score += res.cmd_tuples()
      end
    end
  end

  def where_cond_test(type)
    return if @wherePT.nil?
    if type == 'M'
      where_cond_test_m('tuple_node_test_result')
    else
      where_cond_test_u('tuple_node_test_result')      
    end
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
          query = "INSERT INTO tuple_node_test_result values (#{pkVal},#{@test_id},'#{node.name}', '#{branch.name}','U')"
          DBConn.exec(query)
          node.suspicious_score += 1
          # end
        end
      end
    end
  end

  def find_unwanted_tuples
    pkNull = @pkSelect.gsub(',', ' IS NULL AND ')
    # select_query = 'SELECT #TARGETLIST#'\
    #                " FROM #{@fTable} f LEFT JOIN #{@tTable} t ON #{@pkJoin} where #{pkNull.gsub('f.', 't.')} IS NULL"
    select_query = "SELECT #TARGETLIST# FROM #{@fTable} except SELECT #TARGETLIST# FROM #{@tTable}"
    # Unwanted rows
    targetList = @pkSelect.gsub('f.', '')

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

    # select_query = 'SELECT #TARGETLIST#'\
    #                " FROM #{@tTable} t LEFT JOIN #{@fTable} f ON #{@pkJoin} where #{pkNull} IS NULL"
   
    select_query = "SELECT #TARGETLIST# FROM #{@tTable} except SELECT #TARGETLIST# FROM #{@fTable}"
    # Unwanted rows
    targetList = @pkSelect.gsub('f.', '')
    query = select_query.gsub('#TARGETLIST#', targetList)
    res = DBConn.exec(query)
    @missing_tuple_count = res.count

    # Insert into ftuples_tbl
    renamedPKCol = @pkFullList.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
    targetList = "#{renamedPKCol},'none'::varchar(300) as mutation_cols,'M'::varchar(1) as type,#{@allColumns_select}"
    val_query = ReverseParseTree.reverseAndreplace(@tPS, targetList, '1=1')
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
    @ftuples_tbl = Failing_Row_Table.new('ftuples')
    # pp query
    DBConn.exec(query)
  end
end
