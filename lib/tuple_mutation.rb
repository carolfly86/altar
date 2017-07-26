class TupleMutation
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
            " where n.test_id = #{@test_id} and n.type = 'f' and #{@pkCond_strip_tbl_alias} " +
            # (@type == 'U'? " and t.branch_name = '#{@branches[0].name}' "  : "") +
            'order by t.node_name'
    # pp query
    @suspicious_nodes = DBConn.exec(query).to_a

    @subset_col_query = 'SELECT mutation_branches,mutation_nodes, mutation_cols  FROM mutation_tuple mt1 '\
                             'where exists (select 1 from mutation_tuple mt2 where mt2.mutation_cols != mt1.mutation_cols and strpos(mt2.mutation_cols,mt1.mutation_cols) >0)'
  end

  def allcolumns_construct(all_column_combinations, allColumns_select, allColumns_renamed)
    # @all_column_combinations = all_column_combinations
    @remaining_cols = all_column_combinations
    @allColumns_select = allColumns_select
    @allColumns_renamed = allColumns_renamed
  end

  def unwanted_to_satisfied_reverse(_duplicate_removal = false)
    found = false
    # @remaining_cols=@all_column_combinations.clone
    @updateTup = get_first_satisfiedPK
    nodes = @branches[0].nodes
    mutationTbl_upd_reverse(nodes, @updateTup, @pkCond)
  end

  # unwanted to satisfied mutation
  def unwanted_to_satisfied(duplicate_removal = false)
    # puts 'unwanted_to_satisfied'
    # t_pkCol=@pkCol.split(',').map{|c| "t.#{c}"}.join(',')
    found = false
    # @remaining_cols=@all_column_combinations.clone
    @updateTup = get_first_satisfiedPK
    nodes = @branches[0].nodes.map(&:name)
    max = nodes.count

    1.upto(max) do |i|
      bn_pair = unwanted_branch_node_pairs(i)
      mutationTbl_upd(bn_pair, @updateTup, @pkCond)

      # binding.pry
      exluded = DBConn.exec(@excluded_query)
      # pp "excluded_query2: #{Time.now}"
      nd_combinations_set = nodes.combination(i).map(&:to_set).to_set
      # binding.pry if @pk.any?{|pk| pk['col'] == 'e.emp_no' and pk['val'] == '248447'}
      # pp "nd_combinations_set: #{Time.now}"
      next unless exluded.count < nd_combinations_set.count
      found = true
      # binding.pry
      exluded_nodes = []
      exluded.each do |e|
        # pp "e:#{e} :#{Time.now}"
        if i == 1
          ex_nd = {}
          ex_nd['branch_name'] = @branches[0].name
          ex_nd['node_name'] = e['mutation_nodes']
          ex_nd['columns'] = "{#{e['mutation_cols']}}"
          # ex_nd['node_name'] = e['mutation_nodes']
          exluded_nodes << ex_nd
        # pp "i=1 :#{Time.now}"
        else
          # binding.pry
          nd_combinations_set.delete(e['mutation_nodes'].split(',').to_set)
          (nodes - nd_combinations_set.flatten.to_a).each do |nd|
            # pp "nd: #{nd} :#{Time.now}"
            ex_nd = {}
            ex_nd['branch_name'] = @branches[0].name
            ex_nd['node_name'] = nd
            # ex_nd['columns'] = "{#{e['mutation_cols']}}"
            ex_nd['columns'] = @suspicious_nodes.find { |sn| sn['node_name'] == nd && sn['branch_name'] == @branches[0].name }['columns']
            exluded_nodes << ex_nd unless exluded_nodes.include?(ex_nd)
          end
        end
      end
      # pp "nodes to be exonerated"
      # pp exluded_nodes
      # pp "exnorate_nodes :#{Time.now}"
      # pp exluded_nodes
      exnorate_nodes(exluded_nodes, 1, duplicate_removal)
      # pp "exnorate_nodes2 :#{Time.now}"
      return
    end
    # if not able to find suspicious node
    # it might be due to missing node on some column combinations
    unless found
      puts 'fail to find in existing branches. Trying column combinations'
      exnorate_all_nodes_in_branch(@branches[0].name, duplicate_removal)
      # max = @remaining_cols.map{|cols| cols.count}.max
      max = @remaining_cols.get_max_ith_combination
      # puts max
      1.upto(max) do |i|
        # ith_col_combinations = @remaining_cols.select{|cols| cols.count == i }
        ith_col_combinations = @remaining_cols.get_ith_combinations(i)
        # the ith combination is the the number of guilty branches
        bn_pair = remaining_col_combination_bn_pairs(ith_col_combinations)
        # mutationTbl_create()
        # pp "#{i}th column combination"
        # pp ith_col_combinations
        mutationTbl_upd(bn_pair, @updateTup, @pkCond)
        # binding.pry #if @pk.any?{|pk| pk['col'] == 'e.emp_no' and pk['val'] == '248447'}

        satisfied = DBConn.exec(@satisfiedQuery)
        next unless satisfied.count > 0
        # 1.upto(i) do |j|
        blm_nodes = []
        nd = {}
        # binding.pry if satisfied.count()>1
        nd['branch_name'] = @branches[0].name
        nd['node_name'] = "missing_node#{i}"

        nd['columns'] = "{#{satisfied.map { |e| e['mutation_cols'] }.join(',')}}"
        nd['query'] = ''
        nd['location'] = 0
        nd['type'] = 'f'
        blm_nodes << nd

        # if satisfied.count >1
        # 	binding.pry
        # 	abort('test')
        # end

        blame_nodes(blm_nodes, 1, duplicate_removal)
        # end
        found = true
        return
      end
    end
    abort('Fail to find the error') unless found
  end

  # missing to excluded mutation
  def missing_to_excluded(duplicate_removal = false)
    # puts 'missing_to_excluded'

    # f_pkCol=@pkCol.split(',').map{|c| "#{c}"}.join(',')
    # target_tuple=find_target_tuple(@pkCond)
    # exluded_pk=get_exludedPKList()
    found = false
    # @remaining_cols=@all_column_combinations.clone
    max = @branches.count
    @updateTup = get_first_exludedPK
    # binding.pry
    1.upto(max) do |i|
      bn_pair = missing_branch_node_pairs(i)
      # mutationTbl_create()
      mutationTbl_upd(bn_pair, @updateTup, @pkCond)
      # binding.pry
      # pp @satisfiedQuery

      # subset col query returns nodes that contain colum(s) that is subset from another node
      # satisfiedQuery = "#{@satisfiedQuery} UNION #{@subset_col_query}"
      satisfiedQuery = @satisfiedQuery
      # binding.pry
      # pp satisfiedQuery
      satisfied = DBConn.exec(satisfiedQuery)
      excluded = DBConn.exec(@excluded_query)
      # binding.pry
      next unless satisfied.count > 0
      uniq_branches = satisfied.to_a.uniq { |s| s['mutation_branches'] }
      excluded_branches = excluded.to_a.map { |s| s['mutation_branches'].split(',') }.flatten.uniq
      # binding.pry
      next unless uniq_branches.count < @branches.combination(i).count
      # if @branches.combination(i).count - uniq_branches.count == i
      found = true
      satisfied_nodes = []
      uniq_branches.each do |s|
        # if i == 1
        # 	"'#{s['mutation_branches']}'"
        # else
        # 	s['mutation_branches'].split(',').uniq.map{|b| "'#{b}'"}.join(',')
        # end
        # binding.pry
        s['mutation_branches'].split(',').each do |br|
          if uniq_branches.count > 1
            unless excluded_branches.include?(br)
              satisfied_nodes += @suspicious_nodes.find_all { |nd| nd['branch_name'] == br }
            end
          else
            satisfied_nodes += @suspicious_nodes.find_all { |nd| nd['branch_name'] == br }
          end
        end
      end
      # query = "select branch_name,node_name from tuple_node_test_result where #{@pkCond_strip_tbl_alias} and branch_name in (#{satisfied_branches})"
      # satisfied_nodes = DBConn.exec(query)
      satisfied_nodes.uniq!
      # binding.pry if @pk.any?{|pk| pk['col'] == 'stat_id' and pk['val'] == '77823'}
      exnorate_nodes(satisfied_nodes, 1, duplicate_removal)
      return
    end
    # if not able to find suspicious branch
    # it might be due to missing branch on some column combinations
    unless found
      puts 'fail to find in existing branches. Trying column combinations'
      # binding.pry
      # exnorate_all_suspicious_nodes
      # max = @remaining_cols.map{|cols| cols.count}.max
      max = @remaining_cols.get_max_ith_combination
      # pp "max: #{max}"
      1.upto(max) do |i|
        # ith_col_combinations = @remaining_cols.select{|cols| cols.count == i }
        ith_col_combinations = @remaining_cols.get_ith_combinations(i)
        # puts "#{i} combination"
        # pp ith_col_combinations
        # pp @remaining_cols.count
        # puts '-----------------------'
        # the ith combination is the the number of guilty branches
        bn_pair = remaining_col_combination_bn_pairs(ith_col_combinations)
        # mutationTbl_create()
        mutationTbl_upd(bn_pair, @updateTup, @pkCond)
        # binding.pry
        excluded = DBConn.exec(@excluded_query)
        # binding.pry
        next unless excluded.count > 0
        # 1.upto(i) do |j|
        # binding.pry
        cib =  Column_In_Branch.new(i)
        cib.populate_cols_in_branch(excluded)
        cols_in_branch = cib.cols_in_branch
        cols_in_branch.each do |cols|
          nodes = []
          nd = {}
          nd['branch_name'] = "missing_branch#{i}"
          nd['node_name'] = "missing_node#{i}"
          nd['columns'] = "{#{cols.uniq.join(',')}}"
          # nd['columns'] = "{#{cols.map { |e| e['mutation_cols'].split(',') }.flatten.uniq.join(',')}}"
          nd['query'] = ''
          nd['location'] = 0
          nd['type'] = 'f'
          nodes << nd
          # if i >1
          # 	binding.pry
          # 	abort('test')
          # end
          # if there's only one branch
          # or if the missing branch containing same set of columns as the existing branch
          # then we cannot exonerate
          old_cols = @branches.map(&:columns).flatten.map { |c| "#{c.relname}.#{c.colname}" }
          new_cols = cols.uniq
          # new_cols = excluded.map { |e| e['mutation_cols'].split(',') }.flatten.uniq
          # binding.pry
          if @branches.count == 1 && old_cols.to_set == new_cols.to_set # @branches.count == 1 || (old_cols-new_cols).empty?
            # binding.pry
            # old_cols = @branches[0].columns.map{|c| "#{c.renamed_colname}"}.join(',')
            puts 'No need to exonerate'
            # binding.pry
            eliminate_redundant_tuples(@suspicious_nodes, 'b') if duplicate_removal
            found = true
            # @remaining_cols.recover_processed(i)
            return
          end

          blame_nodes(nodes, 1, duplicate_removal)
        end
        # @remaining_cols.recover_processed(i)
        found = true
        break
      end
      exnorate_all_suspicious_nodes(duplicate_removal)
    end
    abort('Fail to find the error') unless found
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

  def is_satisfied?
    included = returned_by_query?(@predicateQuery)
    satisfied = returned_by_query?(@satisfiedQuery)
    # binding.pry
    (included && satisfied)
  end

  def is_unwanted?
    included = returned_by_query?(@predicateQuery)
    satisfied = returned_by_query?(@satisfiedQuery)
    # binding.pry
    (included && !satisfied)
  end

  def is_missing?
    included = returned_by_query?(@predicateQuery)
    satisfied = returned_by_query?(@satisfiedQuery)
    # binding.pry
    (!included && satisfied)
  end

  def is_excluded?
    included = returned_by_query?(@predicateQuery)
    satisfied = returned_by_query?(@satisfiedQuery)
    # binding.pry
    (!included && !satisfied)
  end

  def returned_by_query?(query)
    res = DBConn.exec(query)
    res[0]['count'].to_i > 0
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
    # binding.pry
    updQueryArray = []
    all_cols = @allColumns_renamed.split(',').map { |v| v.delete(' ') }
    # insert
    query = ''
    find = false
    bn_pairs.each_with_index do |bn, _id|
      insert_tup = all_cols.map do |col|
        if bn['cols'].to_a.any? { |bn_col| bn_col.renamed_colname == col }
          find = true
          val = updateTup[0][col].nil? ? 'NULL' : updateTup[0][col].to_s.str_int_rep
          "#{val} as #{col}"
        else
          col
         end
      end.join(',')

      mutation_columns = bn['cols'].to_a.map(&:relname_fullname).join(',')
      query += "INSERT INTO #{@mutation_tbl} "\
              "select #{@renamedPKCol},'#{bn['branches']}' as mutation_branches,'#{bn['nodes']}' as mutation_nodes, '#{mutation_columns}' as mutation_cols ,#{insert_tup} "\
              "from #{@mutation_tbl} where mutation_branches = 'none' and mutation_cols = 'none'; "

      # "from #{@mutation_tbl} where #{@renamePKCond} and mutation_branches = 'none' and mutation_cols = 'none'; "
    end
    # pp query
    DBConn.exec(query)
    # binding.pry
  end

  def remaining_col_combination_bn_pairs(ith_col_combinations)
    bn_pairs = []
    ith_col_combinations.each do |cols|
      # pp cols
      bn = {}
      bn['branches'] = 'missing_branch'
      bn['nodes'] = 'missing_node'
      bn['cols'] = cols
      bn_pairs << bn
    end
    bn_pairs
  end

  def missing_branch_node_pairs(ith_combination)
    bn_pairs = []
    @branches.combination(ith_combination).each do |br_comb|
      bn = {}
      bn['branches'] = br_comb.map(&:name).join(',')
      bn['nodes'] = ''
      bn['cols'] = Set.new
      br_comb.each_with_index do |br, _idx|
        # pp @pkCond_strip_tbl_alias
        # only need to find passed_node if it's on single branch
        passed_nodes = ith_combination == 1 ? br.passed_nodes(@pkCond_strip_tbl_alias, @test_id, @type) : []
        if passed_nodes.count > 0
          # pp 'passed_nodes'
          # pp passed_nodes
          node = passed_nodes[0]
          # cols_strip_relalias = node.columns.map {|c| c.strip_relalias}
          # colnames = node.columns {|c| c.colname }.join(',')
          bn['nodes'] = node.name
          # @remaining_cols.delete(cols_strip_relalias.to_set)
          column_set = node.columns.to_set
          bn['cols'] = column_set
        # bn['cols'] = bn['cols'] + ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"
        # pp node
        # @remaining_cols.delete(column_set)
        else
          if ith_combination == 1
            br.nodes.each do |nd|
              bn1 = {}
              bn1['branches'] = bn['branches']
              bn1['nodes'] = nd.name
              # bn1['cols'] = "#{nd.columns.join(',')}"
              column_set = nd.columns.to_set
              bn1['cols'] = column_set
              # pp nd
              # @remaining_cols.delete(column_set)
              bn_pairs << bn1
            end
          else
            node = br.nodes[0]
            bn['nodes'] = bn['nodes'] + (bn['nodes'].empty? ? '' : ',') + node.name
            # cols_strip_relalias = node.columns.map {|c| c.strip_relalias}
            # @remaining_cols.delete(cols_strip_relalias.to_set)
            # bn['cols'] = bn['cols'] + ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"
            column_set = node.columns.to_set
            # pp "bn['cols']"
            # pp bn['cols']
            bn['cols'] = bn['cols'] + column_set
          end
        end
      end
      next unless bn['cols'].count > 0
      bn_pairs << bn
      # pp 'delete again'
      # @remaining_cols.delete(bn['cols'])
    end
    bn_pairs
  end

  def unwanted_branch_node_pairs(ith_combination)
    bn_pairs = []
    # puts "#{ith_combination} ith_combination"

    @branches.each do |br|
      # max = br.nodes.count()
      # 1.upto(max) do |i|
      br.nodes.combination(ith_combination).each do |nd_comb|
        # cols = Set.new()
        bn = {}
        bn['branches'] = br.name
        bn['nodes'] = ''
        bn['cols'] = Set.new
        nd_comb.each_with_index do |nd, idx|
          bn['nodes'] = bn['nodes'] + (idx > 0 ? ',' : '') + nd.name.to_s
          # cols_strip_relalias = nd.columns.map {|c| c.strip_relalias}
          # colnames = nd.columns.map {|c| c.colname}
          # bn['cols'] = bn['cols']+ ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"
          column_set = nd.columns.uniq(&:hash).to_set
          # if ith_combination >1
          # 	binding.pry
          # end
          bn['cols'].merge(column_set)
          # cols.merge(nd.columns)
        end
        @remaining_cols.delete(bn['cols'])
        bn_pairs << bn
      end
      # end
    end
    # pp bn_pairs

    bn_pairs
  end

  def exnorate_nodes(nodes, decr = 1, eliminate)
    # binding.pry
    # puts 'exonerating'
    if eliminate
      # pp "suspicious_nodes: "
      # pp @suspicious_nodes
      # pp "nodes:"
      # pp nodes
      if @type == 'U'
        # binding.pry

        suspicious_nodes = @suspicious_nodes.select { |sn| sn['branch_name'] == @branches[0].name }
      else
        suspicious_nodes = @suspicious_nodes
      end
      # binding.pry
      guilty_nodes = suspicious_nodes - nodes
      # pp "guilty_nodes"
      # pp guilty_nodes
      abort('no guilty_nodes! ') if guilty_nodes.count == 0
      eliminate_redundant_tuples(guilty_nodes, 'e')
    else
      nodes.each do |nd|
        # pp nd
        branch_node_cond = " branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' " # and columns = '#{nd['columns']}'"
        query = 'UPDATE node_query_mapping'\
               " SET suspicious_score = suspicious_score - #{decr} "\
                " where test_id = #{@test_id} and type='f' and suspicious_score >0 "\
                " and #{branch_node_cond}"
        # pp query
        DBConn.exec(query)
      end
    end
  end

  def exnorate_all_nodes_in_branch(branch, eliminate)
    unless eliminate
      query = 'UPDATE node_query_mapping '\
             ' SET suspicious_score = suspicious_score - 1 '\
              " where test_id = #{@test_id} and type = 'f' and suspicious_score >0 and branch_name not like 'missing%' and node_name not like 'missing%'"\
              " and branch_name = '#{branch}'"
      # pp query
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
      # pp query
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
        # binding.pry
        branch_node_cond = " branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' and columns = '#{nd['columns']}'"
        query = 'UPDATE node_query_mapping'\
               " SET suspicious_score = suspicious_score + #{incr} "\
                "where test_id = #{@test_id} and type='f' "\
                "and #{branch_node_cond}"
        # pp query
        res = DBConn.exec(query)
        next unless res.cmd_tuples == 0
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

  def eliminate_redundant_tuples(guilty_nodes, _guilty_type)
    # create mutation table containing all failed rows

    suspicious_nodes_val = @suspicious_nodes.map { |sn| "#{sn['branch_name']}-#{sn['node_name']}" }.join(',')
    all_cols = []
    all_cols_suspicious_nodes_cond = "AND suspicious_nodes = '" + suspicious_nodes_val + "'"

    branches = guilty_nodes.map { |gn| gn['branch_name'] }.uniq
    # binding.pry
    branches.each do |br|
      # binding.pry
      columns = []
      g_nodes = guilty_nodes.find_all { |gn| gn['branch_name'] == br }

      if @type == 'M'
        query = "select columns from node_query_mapping where test_id = #{@test_id} and type = 'f' and branch_name = '#{br}'"

        cols = DBConn.exec(query).to_a.map { |c| c['columns'] }
      # binding.pry
      # cols = branch.columns
      else
        cols = g_nodes.map { |g| g['columns'] }
      end
      # cols = g_nodes.map{|g| g['columns']}
      cols.each do |col|
        cols_str = col.delete('{').delete('}')
        cols_str.split(',').each do |c|
          column = Column.new
          col_name = c.split('.')
          column.relname = col_name[0]
          column.colname = col_name[1]
          columns << column
        end
      end

      all_cols += columns

      if @type == 'U'
        suspicious_nodes_cond = "AND suspicious_nodes = '" + suspicious_nodes_val + "'"
      else
        if br =~ /^missing/
          suspicious_nodes_cond = ''
          all_cols_suspicious_nodes_cond = ''
        else
          suspicious_nodes_cond = "AND suspicious_nodes = '" + suspicious_nodes_val + "'"
        end
      end

      puts "suspicious_nodes_cond: #{suspicious_nodes_cond}"
      # blm_nodes = []
      # blm_nodes << g_nodes
      find_duplicate_tuples(columns, g_nodes, suspicious_nodes_cond)
    end
    # guilty_nodes.each do |gn|
    # 	gn
    # 	if guilty_type == 'e'
    # 	# exonrate guilty nodes can be find in @branches
    # 		branch = @branches.find{|br| br.name == gn['branch_name']}
    # 		# for missing tuple, all columns in guilty branch must be mutated
    # 		if @type == 'M'
    # 			columns = branch.columns
    # 		else
    # 			# binding.pry
    # 			# pp gn['branch_name']
    # 			node = branch.nodes.find{|nd| nd.name == gn['node_name']}
    # 			columns = node.columns
    # 		end
    # 	# blame guilty nodes are not available in @branches thus must be initialized
    # 	else
    # 		columns = []
    # 		cols_str = gn['columns'].gsub('{','').gsub('}','')
    # 		cols_str.split(',').each do |c|
    # 			column = Column.new()
    # 			col = c.split('.')
    # 			column.relname = col[0]
    # 			column.colname =  col[1]
    # 			columns << column
    # 		end
    # 		# gn['columns'] = "{#{columns.map{|c| c.relname_fullname }.join(',')}}"
    # 		# gn['query'] =''
    # 		# gn['location'] = 0
    # 		# gn['type'] = 'f'

    # 	end
    # 	all_cols = all_cols + columns

    # 	if @type == 'U'
    # 		suspicious_nodes_cond = "AND suspicious_nodes = '" +suspicious_nodes_val+"'"
    # 	else
    # 		if  gn['branch_name'] =~ /^missing/
    # 			suspicious_nodes_cond =''
    # 			all_cols_suspicious_nodes_cond = ''
    # 		else
    # 			suspicious_nodes_cond = "AND suspicious_nodes = '" + suspicious_nodes_val+"'"
    # 		end
    # 	end

    # 	puts "suspicious_nodes_cond: #{suspicious_nodes_cond}"
    # 	blm_nodes = []
    # 	blm_nodes << gn
    # 	find_duplicate_tuples(columns,blm_nodes,suspicious_nodes_cond)
    # end
    if branches.count > 1
      # binding.pry
      find_duplicate_tuples(all_cols, guilty_nodes, all_cols_suspicious_nodes_cond)
    end
  end

  def find_duplicate_tuples(columns, blm_nodes, suspicious_nodes_cond)
    pkJoin = @renamedPK.map { |pk| "f.#{pk['col']} = t.#{pk['col'].gsub('_pk', '')}" }.join(' AND ')
    renamedPKCols = @renamedPK.map { |pk| QueryBuilder.get_colalias(pk) }.join(', ')

    pkList = renamedPKCols + ',type'
    query = 'select * from ftuples where 1=2'
    query = QueryBuilder.create_tbl('ftuples_mutate', pkList, query)
    DBConn.exec(query)

    # update identified guilty columns in mutation table
    all_cols = @allColumns_renamed.split(',').map { |v| v.delete(' ') }
    insert_tup = all_cols.map do |col|
      if columns.any? { |fi_col| fi_col.renamed_colname == col }
        val = @updateTup[0][col].nil? ? 'NULL' : @updateTup[0][col].to_s.str_int_rep
        "#{val} as #{col}"
      else
        col
      end
    end.join(',')
    mutation_columns = columns.to_a.map(&:relname_fullname).join(',')

    query = 'INSERT INTO ftuples_mutate ' \
             "select #{renamedPKCols},'#{mutation_columns}' as mutation_cols, type ,#{insert_tup} "\
            'from ftuples f ' +
            #    "where exists (select 1 from tuple_node_test_result t "+
            # "where #{pkJoin} and t.type = '#{@type}' "+
            # "#{suspicious_nodes_cond} "+
            # " )"
            'JOIN tuple_node_test_result_aggr t on' \
            " #{pkJoin} "\
            " where type = '#{@type}' "\
            "#{suspicious_nodes_cond} "
    # create
    # pp query
    # binding.pry
    # pp Time.now
    res = DBConn.exec(query)
    # pp Time.now
    # binding.pry if res.cmd_tuples == 0

    # remove redundant tuples
    renamedPKJoin = @renamedPK.map { |pk| "f.#{pk['col']} = fm.#{pk['col']}" }.join(' AND ')
    eliminate = (if @type == 'U'
                   " with dup_pks AS (select #{renamedPKCols} from ftuples_mutate where #{@constraintPredicate}) "
                 else
                   " with dup_pks AS ((select #{renamedPKCols} from ftuples_mutate) except (select #{renamedPKCols} from ftuples_mutate where #{@constraintPredicate})) "
          end) + " delete from ftuples f using dup_pks fm where #{renamedPKJoin} "

    # binding.pry if @pk.any?{|pk| pk['col'] == 'e.emp_no' and pk['val'] == '248447'}

    puts eliminate
    # pp Time.now
    res = DBConn.exec(eliminate)
    # binding.pry if res.cmd_tuples == 0
    # binding.pry
    dup_cnt = res.cmd_tuples
    puts "duplicate remove count #{dup_cnt}"
    # # blame
    # pp guilty_nodes
    # binding.pry
    blame_nodes(blm_nodes, dup_cnt, false)
  end
end
