class TupleMutationReverse
   def initialize(test_id, pk, type, branches, fQueryObj, constraintPredicateQuery)
     @pk = pk
     # pp @pk
     @type = type
     @renamedPK = @pk.map do |pk|
       newPK = {}
       col = QueryBuilder.get_colalias(pk)
       newPK['col'] = (col.include?('.') ? col.split('.')[1].to_s : col) + '_pk'
       newPK['val'] = pk['val']
       newPK
     end

     @branches = branches
     @test_id = test_id
     branchNames = @branches.map { |br| "'#{br.name}'" }.join(',')
     @branchCond = "t.branch_name in (#{branchNames})"
     @mutation_tbl = 'mutation_tuple'

     @fParseTree = fQueryObj.parseTree
     f_fromPT = @fParseTree['SELECT']['fromClause']
     @constraintPredicate = constraintPredicateQuery

    @satisfiedQuery = 'SELECT mutation_branches,mutation_nodes, mutation_cols '\
                   ' FROM mutation_tuple '\
                   " WHERE mutation_branches <> 'none' and mutation_cols <>'none' and " +
                   @constraintPredicate

     @pkCond = QueryBuilder.pkCondConstr(@pk)
     @pkCol = QueryBuilder.pkColConstr(@pk)
     @pkJoin = QueryBuilder.pkJoinConstr(@pk)
     @pkVal = QueryBuilder.pkValConstr(@pk)

     @renamePKCond = QueryBuilder.pkCondConstr(@renamedPK)
     @renamedPKCol = QueryBuilder.pkValWithColConstr(@renamedPK)

     @pkCond_strip_tbl_alias = QueryBuilder.pkCondConstr_strip_tbl_alias_colalias(@pk)

     # constraint_construct(t_predicate_tree, tWherePT)
     @excluded_query = %(
 				(select mutation_branches,mutation_nodes,mutation_cols
 				FROM #{@mutation_tbl}
 				where mutation_branches <> 'none' and mutation_nodes <>'none' and mutation_cols <>'none' )
 				except (#{@satisfiedQuery}))

     query = 'select t.branch_name, t.node_name, n.columns from tuple_node_test_result t'\
             ' JOIN node_query_mapping n on t.branch_name = n.branch_name and t.node_name = n.node_name'\
             " where n.test_id = #{@test_id} and n.type = 'f' and #{@pkCond_strip_tbl_alias} order by t.node_name"
     @suspicious_nodes = DBConn.exec(query).to_a
   end

  def allcolumns_construct(remaining_cols, allColumns_select, allColumns_renamed)
    # @all_column_combinations = all_column_combinations
    # @remaining_cols=all_column_combinations
    @remaining_cols = remaining_cols
    @allColumns_select = allColumns_select
    @allColumns_renamed = allColumns_renamed
    @allCols_renamed_array = @allColumns_renamed.split(',').map { |v| v.delete(' ') }
  end

  def unwanted_to_satisfied(duplicate_removal = false)
     branch_node_pairs
    found = false
    # @remaining_cols=@all_column_combinations.clone
    @updateTup = get_first_satisfiedPK
    # nodes = @branches[0].nodes
    branch_name = @branches[0].name
    mutationTbl_upd(@bn_pairs, @updateTup, @pkCond)
    # binding.pry
    # after mutation, if the tuple is satisfied then it's innocent
    satisfied = DBConn.exec(@satisfiedQuery)
    if satisfied.count > 0
      # uniq_branches = satisfied.to_a.uniq{|s| s['mutation_branches']}
      # if uniq_branches.count < @branches.combination(i).count
      # found = true
      unless satisfied.count == @branches[0].nodes.count
        found = true
        satisfied_nodes = satisfied.map do |s|
                   sn = {}
                   sn['branch_name'] = s['mutation_branches']
                   sn['node_name'] = s['mutation_nodes']
                   sn['columns'] = s['mutation_cols']
                   sn
 				end
        exnorate_nodes(satisfied_nodes, 1, duplicate_removal)
      else
        found = false
      end
    end
    unless found

       puts 'Failed to find guilty column in existing nodes!'
      remaining_bn_pairs = @remaining_cols.map do |rc|
                   bn = {}
                  bn['branch'] = branch_name
                  bn['nodes'] = 'missing_node1'
                  bn['columns'] = []
                  bn['columns'] << rc
                  pp bn
                  bn
			end
      mutationTbl_upd(remaining_bn_pairs, @updateTup, @pkCond)

      excluded = DBConn.exec(@excluded_query)
      if excluded.count > 0
         excluded_nodes = []
        existing_columns = @branches[0].columns.map { |c| c.relname_fullname }
        blm_nd = {}
        blm_nd['branch_name'] = branch_name
        blm_nd['node_name'] = "missing_node#{excluded.count}"
        # mutation column not in existing columns
        blm_nd['columns'] = "{#{excluded.select { |e| !existing_columns.include?(e['mutation_cols']) }.map { |s| s['mutation_cols'] }.join(',')}}"
        blm_nd['query'] = ''
        blm_nd['location'] = 0
        blm_nd['type'] = 'f'
        excluded_nodes << blm_nd
        exnorate_all_nodes_in_branch(branch_name, duplicate_removal)

        blame_nodes(excluded_nodes, 1, duplicate_removal)
      else
        pp 'No need to exonrate'
         # abort('Fail to find the error')
      end

    end
  end

  def missing_to_excluded(duplicate_removal = false)
     branch_node_pairs
    found = false
    # @remaining_cols=@all_column_combinations.clone
    max = @branches.count
    @updateTup = get_first_exludedPK
    mutationTbl_upd(@bn_pairs, @updateTup, @pkCond)
    # after mutation, if the tuple is excluded then it's innocent
    excluded = DBConn.exec(@excluded_query)
# if @pk.any? { |pk| (pk['col'] == 'e.emp_no') && (pk['val'] == '94968')}

    if excluded.count > 0
       uniq_branches = []
      # binding.pry
      satisfied = DBConn.exec(@satisfiedQuery).to_a
      excluded_array = excluded.to_a + satisfied_branch_exonerate(satisfied)
      excluded_array.uniq { |s| s['mutation_branches'] }.each do |br|
        # pp br
         uniq_branches += br['mutation_branches'].split(',')
      end

      uniq_branches.uniq!

      unless uniq_branches.count == max
         found = true
        excluded_nodes = []
        uniq_branches.each do |ubr|
          # s['mutation_branches'].split(',').each do |br|
           excluded_nodes += @suspicious_nodes.find_all{|nd| nd['branch_name'] == ubr}
           # end
        end
        # # check if satisfied branches are independent
        excluded_nodes.uniq!
        exnorate_nodes(excluded_nodes, 1, duplicate_removal)
      else
         found = false
      end
    end
    unless found
       puts 'Failed to find guilty column in existing nodes!'
      remaining_bn_pairs = @remaining_cols.map do |rc|
                   bn = {}
                  bn['branch'] = 'missing_branch1'
                  bn['nodes'] = 'missing_node1'
                  bn['columns'] = []
                  bn['columns'] << rc
                  bn
			end
      mutationTbl_upd(remaining_bn_pairs, @updateTup, @pkCond)
      satisfied = DBConn.exec(@satisfiedQuery)
      if satisfied.count > 0
         satisfied_nodes = []
        blm_nd = {}
        i = satisfied.count
        blm_nd['branch_name'] = "missing_branch#{i}"
        blm_nd['node_name'] = "missing_node#{i}"
        blm_nd['columns'] = "{#{satisfied.map { |s| s['mutation_cols'] }.join(',')}}"
        blm_nd['query'] = ''
        blm_nd['location'] = 0
        blm_nd['type'] = 'f'

        satisfied_nodes << blm_nd
        exnorate_all_suspicious_nodes(duplicate_removal)

        blame_nodes(satisfied_nodes, 1, duplicate_removal)
			# exnorate_all_suspicious_nodes(duplicate_removal)
      else
        abort('Fail to find the error')
      end
    end
  end
  

  def satisfied_branch_exonerate(satisfied_branches)
    # satisfied_branches = @branches.select{|br| !uniq_branches.any?(br.name)}
     exnorate_branch = []
    if satisfied_branches.count > 1
      satisfied_branches.combination(2).each do |br_pair|
        pp br_pair
        # binding.pry
        col1 = br_pair[0]['mutation_cols'].split(',').to_set
        col2 = br_pair[1]['mutation_cols'].split(',').to_set
        intersect_cols = col1 & col2
        # columns in 1st branch overlaps with 2nd branch
        if (intersect_cols != []) && (col1 != col2)
          sn = {}
          # column1 is a subset of column2
          subset_br = br_pair[0] if intersect_cols == col1
          # column2 is a subset of column1
          subset_br = br_pair[1] if intersect_cols == col2
          sn['mutation_branches'] = subset_br['mutation_branches']
          sn['mutation_nodes'] = subset_br['mutation_nodes']
          sn['mutation_cols'] = subset_br['mutation_cols']
          exnorate_branch << sn unless exnorate_branch.include?(sn)
        end
      end
    end
    exnorate_branch
  end

  def mutate_to_satisfied_tuple
     res = DBConn.exec(@satisfiedQuery)
  end

  def get_first_exludedPK
    # allColumns = @allColumnList.map do |field|
    # 	# "#{field.colname} as #{field.relname}_#{field.colname} "
    # 	"#{field.relname}_#{field.colname} "
    # end.join(',')
     query = "select #{@allColumns_renamed} from golden_record where type = 'excluded';"
    # pp query
    res = DBConn.exec(query)
    abort('Cannot find excluded tuple!') if res.ntuples == 0
    res
  end

  # excluded pk is in the table
  # but not in t_restul or f_result
  # this function return the first excluded pk with the different value in predicateColumn
  def get_first_satisfiedPK
    # allColumns = @allColumnList.map do |field|
    # 	# "#{field.colname} as #{field.relname}_#{field.colname} "
    # 	"#{field.relname}_#{field.colname} "
    # end.join(',')
     query = "select #{@allColumns_renamed} from golden_record where type = 'satisfied' and branch = '#{@branches[0].name}';"
    res = DBConn.exec(query)
    abort("Cannot find satisfied tuple at #{@branches[0].name}!") if res.ntuples == 0
    res
  end

  def mutationTbl_create(whereCond)
    # colCombination = @allColumnList.combination(ith_combination).to_a.map{|c| c.map{|col| col.colname}.join(',')}.map{|c| "'#{c}'"}.join(',')

     renamedPKCol = @pk.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')

    targetListReplacement = "#{renamedPKCol},'none'::varchar(300) as mutation_branches,'none'::varchar(300) as mutation_nodes,'none'::varchar(300) as mutation_cols,#{@allColumns_select}"
    query =  ReverseParseTree.reverseAndreplace(@fParseTree, targetListReplacement, whereCond)
    pkList = @renamedPK.map { |pk| QueryBuilder.get_colalias(pk) }.join(', ') + ',mutation_branches,mutation_nodes,mutation_cols'
    query = QueryBuilder.create_tbl(@mutation_tbl, pkList, query)
    # puts 'mutationTbl_create'
    # puts query
    # create
    DBConn.exec(query)
  end

  def mutationTbl_upd(bn_pairs, updateTup, whereCond)
     mutationTbl_create(whereCond)
    updQueryArray = []
    # insert
    query = ''
    # find=false
    bn_pairs.each_with_index do |bn, id|
      # replace all columns except the column in bn
      # puts "bn['columns']"
      # pp bn['columns']
      insert_tup = @allCols_renamed_array.map do |col|
               if bn['columns'].any? { |bn_col| bn_col.renamed_colname == col }
                 # find=true
                 col
               else
                 val = updateTup[0][col].nil? ? 'NULL' : updateTup[0][col].to_s.str_int_rep
                 "#{val} as #{col}"
               end
			end.join(',')

      mutation_columns = bn['columns'].to_a.map { |c| c.relname_fullname }.join(',')
      # pp mutation_columns
      query = query + "INSERT INTO #{@mutation_tbl} "\
              "select #{@renamedPKCol},'#{bn['branch']}' as mutation_branches,'#{bn['nodes']}' as mutation_nodes, '#{mutation_columns}' as mutation_cols ,#{insert_tup} "\
              "from #{@mutation_tbl} where mutation_branches = 'none' and mutation_cols = 'none'; "

       # "from #{@mutation_tbl} where #{@renamePKCond} and mutation_branches = 'none' and mutation_cols = 'none'; "
    end
    pp query
    DBConn.exec(query)
     # pp testddd
  end

  def branch_node_pairs
     @bn_pairs = []
    # puts "#{ith_combination} ith_combination"
    @branches.each do |br|
       if @type == 'M'
         # combinde nodes
         bn_c = {}
         bn_c['branch'] = br.name
         bn_c['nodes'] = ''
         bn_c['columns'] = []
         suspicious_nodes = @suspicious_nodes.select { |sn| sn['branch_name'] == br.name }.map { |n| n['node_name'] }
        nodes = br.nodes.select { |nd| suspicious_nodes.include?(nd.name) }
        # binding.pry
         nodes.each_with_index do |nd, idx|
           # if nd.columns.count() >1
           # nd.columns.each do |col|
           # 	bn_s= Hash.new()
           # 	bn_s['branch'] = br.name
           # 	bn_s['nodes']=nd.name
           # 	bn_s['columns'] =  col
           # 	@bn_pairs << bn_s
           # 	@remaining_cols = @remaining_cols - col
           # end
           # end
           bn_c['nodes'] = bn_c['nodes'] + (idx > 0 ? ',' : '') + "#{nd.name}"
           column_array = nd.columns.uniq { |c| c.hash }
           bn_c['columns'] = bn_c['columns'] + column_array
         end
         @remaining_cols -= bn_c['columns'] if bn_c['columns'].count == 1
         @bn_pairs << bn_c if nodes.count > 0

       else
         br.nodes.each_with_index do |nd, _idx|
           bn = {}
           bn['branch'] = br.name
           # bn['columns'] = Set.new()
           bn['nodes'] = nd.name
           column_array = nd.columns.uniq { |c| c.hash }
           # binding.pry
           @remaining_cols -= column_array if column_array.count == 1
           bn['columns'] = column_array
           @bn_pairs << bn
         end

       end
    end
     # pp bn_pairs
  end

  def exnorate_nodes(nodes, decr = 1, eliminate)
    # binding.pry
    # puts 'exonerating'
     if eliminate
       # pp "suspicious_nodes: "
       # pp @suspicious_nodes
       # pp "nodes:"
       # pp nodes
       guilty_nodes = @suspicious_nodes - nodes
       # pp "guilty_nodes"
       # pp guilty_nodes
       eliminate_redundant_tuples(guilty_nodes, 'e')
     else
       nodes.each do |nd|
         # pp nd
         branch_node_cond = " branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' " # and columns = '#{nd['columns']}'"
         query = 'UPDATE node_query_mapping'\
                " SET suspicious_score = suspicious_score - #{decr} "\
                 " where test_id = #{@test_id} and type='f' and suspicious_score >0 "\
                 " and #{branch_node_cond}"
         pp query
         # binding.pry
         DBConn.exec(query)
          # pp tedds
       end
     end
  end

  def exnorate_all_nodes_in_branch(branch, eliminate)
     unless eliminate
       query = 'UPDATE node_query_mapping '\
              ' SET suspicious_score = suspicious_score - 1 '\
               " where test_id = #{@test_id} and type = 'f' and suspicious_score >0 and branch_name not like 'missing%' and node_name not like 'missing%'"\
               " and branch_name = '#{branch}'"
       pp query
       DBConn.exec(query)
     end
  end

  def exnorate_all_suspicious_nodes(eliminate)
     unless eliminate
       nodes_query = @suspicious_nodes.map do |sn|
               "( branch_name = '#{sn['branch_name']}' and node_name = '#{sn['node_name']}') "
 			end.join(' or ')
       query = 'UPDATE node_query_mapping '\
              ' SET suspicious_score = suspicious_score - 1 '\
               " where test_id = #{@test_id} and type = 'f' and suspicious_score >0 and branch_name not like 'missing%' and node_name not like 'missing%' "\
               " and (#{nodes_query}) "
       pp query
       # abort('test')
       DBConn.exec(query)
     end
  end

  def blame_nodes(nodes, incr = 1, eliminate)
     if eliminate
       guilty_nodes = nodes
       eliminate_redundant_tuples(guilty_nodes, 'b')
     else
       nodes.each do |nd|
         branch_node_cond = " branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' and columns = '#{nd['columns']}'"
         query = 'UPDATE node_query_mapping'\
                " SET suspicious_score = suspicious_score + #{incr} "\
                 "where test_id = #{@test_id} and type='f' "\
                 "and #{branch_node_cond}"
         # pp query
         res = DBConn.exec(query)
         if res.cmd_tuples == 0
          binding.pry
         end
           # insert_query = 'INSERT INTO node_query_mapping '
           insert_query = nodes.map do |nd|
             %(INSERT INTO node_query_mapping select #{@test_id} as test_id,
 						'#{nd['branch_name']}' as branch_name,
 						'#{nd['node_name']}' as node_name,
 						'#{nd['query']}' as query,
 						'#{nd['location']}' as location,
 						'#{nd['columns']}' as columns,
 						#{incr} as suspicious_score,
 						'#{nd['type']}' as type)
           end.join('; ')
           # binding.pry
           # pp query
           res = DBConn.exec(insert_query)
         end
       end
     end
  end

  def eliminate_redundant_tuples(guilty_nodes, guilty_type)
    # create mutation table containing all failed rows
     renamedPKCols = @renamedPK.map { |pk| QueryBuilder.get_colalias(pk) }.join(', ')

    pkJoin = @renamedPK.map { |pk| "f.#{pk['col']} = t.#{pk['col'].gsub('_pk', '')}" }.join(' AND ')
    pkList = renamedPKCols + ',type'
    query = 'select * from ftuples where 1=2'
    query = QueryBuilder.create_tbl('ftuples_mutate', pkList, query)
    DBConn.exec(query)

    fault_inducing_cols = []
    guilty_nodes.each do |gn|
       if guilty_type == 'e'
        # exonrate guilty nodes can be find in @branches
         branch = @branches.find { |br| br.name == gn['branch_name'] }
         # for missing tuple, all columns in guilty branch must be mutated
         if @type == 'M'
           columns = branch.columns
         else
           node = branch.nodes.find { |nd| nd.name == gn['node_name'] }
           columns = node.columns
         end
       # blame guilty nodes are not available in @branches thus must be initialized
       else
         columns = []
         cols_str = gn['columns'].delete('{').delete('}')
         cols_str.split(',').each do |c|
           column = Column.new
           col = c.split('.')
           column.relname = col[0]
           column.colname = col[1]
           columns << column
         end
         # gn['columns'] = "{#{columns.map{|c| c.relname_fullname }.join(',')}}"
         # gn['query'] =''
         # gn['location'] = 0
          # gn['type'] = 'f'

       end
      fault_inducing_cols += columns
    end

    if guilty_nodes.select { |gn| gn['branch_name'] =~ /^missing/ || gn['node_name'] =~ /^missing/ } == []
       suspicious_nodes_cond = "AND suspicious_nodes = '" + @suspicious_nodes.map { |gn| "#{gn['branch_name']}-#{gn['node_name']}" }.join(',') + "'"
    else
       suspicious_nodes_cond = ''
    end
    puts "suspicious_nodes_cond: #{suspicious_nodes_cond}"
    # update identified guilty columns in mutation table
    all_cols = @allColumns_renamed.split(',').map { |v| v.delete(' ') }
    insert_tup = all_cols.map do |col|
               if fault_inducing_cols.any? { |fi_col| fi_col.renamed_colname == col }
                 val = @updateTup[0][col].nil? ? 'NULL' : @updateTup[0][col].to_s.str_int_rep
                 "#{val} as #{col}"
               else
                 col
               end
		end.join(',')
    mutation_columns = fault_inducing_cols.to_a.map { |c| c.relname_fullname }.join(',')

    query = 'INSERT INTO ftuples_mutate ' \
              "select #{renamedPKCols},'#{mutation_columns}' as mutation_cols, type ,#{insert_tup} "\
             'from ftuples f '\
             'JOIN tuple_node_test_result_aggr t on' \
             " #{pkJoin} "\
             " where type = '#{@type}' "\
             "#{suspicious_nodes_cond} "
    # create
    # pp query

    # pp Time.now
    res = DBConn.exec(query)
    # pp Time.now
if res.cmd_tuples == 0

    # remove redundant tuples
    renamedPKJoin = @renamedPK.map { |pk| "f.#{pk['col']} = fm.#{pk['col']}" }.join(' AND ')
    eliminate = (if @type == 'U'
                       " with dup_pks AS (select #{renamedPKCols} from ftuples_mutate where #{@constraintPredicate}) "
             #
                    else
             " with dup_pks AS ((select #{renamedPKCols} from ftuples_mutate) except (select #{renamedPKCols} from ftuples_mutate where #{@constraintPredicate})) "
          end) + " delete from ftuples  f using dup_pks fm where #{renamedPKJoin} "

    # binding.pry
    # puts eliminate
    # pp Time.now
    res = DBConn.exec(eliminate)
    # pp Time.now
    dup_cnt = res.cmd_tuples
    puts "duplicate remove count #{dup_cnt}"
    # # blame
    # pp guilty_nodes
    # binding.pry
    blame_nodes(guilty_nodes, dup_cnt, false)
  end
end
