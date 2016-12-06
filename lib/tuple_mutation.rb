class TupleMutation
	def initialize(test_id,pk,type,branches,fQueryObj,constraintPredicateQuery)
		@pk = pk
		# pp @pk
		@type = type
		@renamedPK = @pk.map do|pk|
			newPK = Hash.new()
			col = QueryBuilder.get_colalias(pk)
			newPK['col'] = (col.include?('.') ? col.split('.')[1].to_s : col )+'_pk'
			newPK['val'] = pk['val']
			# newPK['alias'] = pk['alias']
			newPK
		end

		@branches=branches
		@test_id = test_id
		branchNames = @branches.map{|br| "'#{br.name}'"}.join(',')
		@branchCond="t.branch_name in (#{branchNames})"
		@mutation_tbl='mutation_tuple'

		@fParseTree = fQueryObj.parseTree
		f_fromPT = @fParseTree['SELECT']['fromClause']
		@constraintPredicateQuery = constraintPredicateQuery

		@pkCond=QueryBuilder.pkCondConstr(@pk)
		@pkCol = QueryBuilder.pkColConstr(@pk)
		@pkJoin=QueryBuilder.pkJoinConstr(@pk)
		@pkVal= QueryBuilder.pkValConstr(@pk)

		@renamePKCond = QueryBuilder.pkCondConstr(@renamedPK)
		@renamedPKCol = QueryBuilder.pkValWithColConstr(@renamedPK)

		@pkCond_strip_tbl_alias = QueryBuilder.pkCondConstr_strip_tbl_alias_colalias(@pk)

		# constraint_construct(t_predicate_tree, tWherePT)
		@excluded_query = %Q(
				(select mutation_branches,mutation_nodes,mutation_cols
				FROM #{@mutation_tbl}
				where mutation_branches <> 'none' and mutation_nodes <>'none' and mutation_cols <>'none' )
				except (#{@constraintPredicateQuery}))

		if type == 'M'
			query = "select branch_name,node_name from tuple_node_test_result where #{@pkCond_strip_tbl_alias}"
			@suspicious_nodes = DBConn.exec(query).to_a
		end

	end

	# def constraint_construct(t_predicate_tree, tWherePT)

	# 	@constraintColumnList= t_predicate_tree.all_columns
	# 	# pp 't_predicate_tree.all_columns'
	# 	pp t_predicate_tree.all_columns
	# 	@constraintPredicateQuery=ReverseParseTree.whereClauseConst(tWherePT)
	# 	pp 'before'
	# 	pp @constraintPredicateQuery
	# 	@constraintPredicateQuery=rewrite_predicate_query(@constraintPredicateQuery, @constraintColumnList)

	# 	pp 'after @constraintPredicateQuery'
	# 	puts @constraintPredicateQuery
	# 	@excluded_query = %Q(
	# 			(select mutation_branches,mutation_nodes,mutation_cols
	# 			FROM #{@mutation_tbl}
	# 			where mutation_branches <> 'none' and mutation_nodes <>'none' and mutation_cols <>'none' )
	# 			except (#{@constraintPredicateQuery}))
	# end
	# def predicate_construct
		# # get the failed predicates related the error in this pk
		# query ="select distinct t.branch_name,n.node_name,query,columns,suspicious_score "+
		# 		"from node_query_mapping n join tuple_node_test_result t "+
		# 		"on t.node_name=n.node_name and t.test_id = n.test_id "+
		# 		"where t.test_id = #{@test_id} and n.type='f' and #{@pkCond_strip_tbl_alias} "+ (branchNames.empty? ? '': " and #{@branchCond}")
		# @predicateList =PredicateUtil.get_predicateList(query)

		# # pp "@constraintPredicateList: #{@constraintPredicateList}"
		# @columnList=Array.new()
		# @columnList=PredicateUtil.get_predicateColumns(@predicateList).uniq{ |c| c.colname+c.relname }

		# remove pk from columnlist
		# @pkCol.split(',').each do |pkcol|
		# 	@columnList.select!{|col| col.colname != pkcol.delete(' ') }
		# end

		# @columns=PredicateUtil.column_str_constr(@columnList)
		# @columnList.delete(@pkCol)


		# pp @allColumns
		# mutationTbl_create()
		# @predicateQuery=PredicateUtil.get_predicateQuery(@predicateList)
		# @predicateQuery = rewrite_predicate_query(@predicateQuery)
	# end
	def allcolumns_construct(all_column_combinations,allColumns_select,allColumns_renamed)
		# @all_column_combinations = all_column_combinations
		@remaining_cols=all_column_combinations
		@allColumns_select = allColumns_select
		@allColumns_renamed =allColumns_renamed
	end

	#unwanted to satisfied mutation
	def unwanted_to_satisfied()
		# t_pkCol=@pkCol.split(',').map{|c| "t.#{c}"}.join(',')
		found = false
		# @remaining_cols=@all_column_combinations.clone
		updateTup = get_first_satisfiedPK()
		nodes = @branches[0].nodes.map{|nd| nd.name }
		max = nodes.count()

		1.upto(max) do |i|
			bn_pair = unwanted_branch_node_pairs(i)
			mutationTbl_upd(bn_pair,updateTup,@pkCond)

			# binding.pry
			exluded=DBConn.exec(@excluded_query)
			# pp "excluded_query2: #{Time.now}"
			nd_combinations_set = nodes.combination(i).map{|nd| nd.to_set}.to_set
			# pp "nd_combinations_set: #{Time.now}"
			if exluded.count() < nd_combinations_set.count
				found = true
				# binding.pry
				exluded_nodes=[]
				exluded.each do |e|
					# pp "e:#{e} :#{Time.now}"

					if i == 1
						ex_nd = Hash.new()
						ex_nd['branch_name'] = @branches[0].name
						ex_nd['node_name'] = e['mutation_nodes']
						exluded_nodes << ex_nd
						# pp "i=1 :#{Time.now}"
					else
						nd_combinations_set.delete(e['mutation_nodes'].split(',').to_set)
						(nodes - nd_combinations_set.flatten.to_a).each do |nd|
							# pp "nd: #{nd} :#{Time.now}"
							ex_nd = Hash.new()
							ex_nd['branch_name'] = @branches[0].name
							ex_nd['node_name'] = nd
							exluded_nodes << ex_nd unless exluded_nodes.include?(ex_nd)
						end
					end
				end
				# pp "nodes to be exonerated"
				# pp exluded_nodes
				# pp "exnorate_nodes :#{Time.now}"
				exnorate_nodes(exluded_nodes)
				# pp "exnorate_nodes2 :#{Time.now}"
				return
			end
		end
		# if not able to find suspicious node
		# it might be due to missing node on some column combinations
		unless found
			puts 'fail to find in existing branches. Trying column combinations'
			exnorate_all_nodes_in_branch(@branches[0].name)
			# max = @remaining_cols.map{|cols| cols.count}.max
			max = @remaining_cols.get_max_ith_combination()
			# puts max
			1.upto(max) do |i|
				# ith_col_combinations = @remaining_cols.select{|cols| cols.count == i }
				ith_col_combinations = @remaining_cols.get_ith_combinations(i)
				# the ith combination is the the number of guilty branches
				bn_pair = remaining_col_combination_bn_pairs(ith_col_combinations)
				# mutationTbl_create()
				# pp "#{i}th column combination"
				# pp ith_col_combinations
				mutationTbl_upd(bn_pair,updateTup,@pkCond)
				satisfied=DBConn.exec(@constraintPredicateQuery)
				if satisfied.count() >0
					# 1.upto(i) do |j|
					blm_nodes = []
					nd = Hash.new()
					nd['branch_name'] = @branches[0].name
					nd['node_name'] = "missing_node#{i}"

					nd['columns'] = "{#{satisfied.map{|e| e['mutation_cols']}.join(',')}}"
					nd['query'] =''
					nd['location'] = 0
					nd['type'] = 'f'
					blm_nodes <<nd

					# if satisfied.count >1
					# 	binding.pry
					# 	abort('test')
					# end

					blame_nodes(blm_nodes)
					# end
					found = true
					return
				end
			end
		end
		unless found
			abort('Fail to find the error')
		end
	end

	#missing to excluded mutation
	def missing_to_excluded()

		# f_pkCol=@pkCol.split(',').map{|c| "#{c}"}.join(',')
		# target_tuple=find_target_tuple(@pkCond)
		# exluded_pk=get_exludedPKList()
		found = false
		# @remaining_cols=@all_column_combinations.clone
		max = @branches.count()
		updateTup = get_first_exludedPK()
		# binding.pry
		1.upto(max) do |i|
			bn_pair = missing_branch_node_pairs(i)
			# mutationTbl_create()
			mutationTbl_upd(bn_pair,updateTup,@pkCond)
			# binding.pry
			# pp @constraintPredicateQuery
			satisfied=DBConn.exec(@constraintPredicateQuery)
			if satisfied.count() >0
				uniq_branches = satisfied.to_a.uniq{|s| s['mutation_branches']}
				if uniq_branches.count < @branches.combination(i).count
					found = true
					satisfied_nodes =[]
					uniq_branches.each do |s|
						# if i == 1
						# 	"'#{s['mutation_branches']}'"
						# else
						# 	s['mutation_branches'].split(',').uniq.map{|b| "'#{b}'"}.join(',')
						# end
						s['mutation_branches'].split(',').each do |br|
							satisfied_nodes = satisfied_nodes + @suspicious_nodes.find_all{|nd| nd['branch_name'] == br}
						end
					end
					# query = "select branch_name,node_name from tuple_node_test_result where #{@pkCond_strip_tbl_alias} and branch_name in (#{satisfied_branches})"
					# satisfied_nodes = DBConn.exec(query)
					satisfied_nodes.uniq!
					exnorate_nodes(satisfied_nodes)
					return
				end
			end
		end
		# if not able to find suspicious branch
		# it might be due to missing branch on some column combinations
		unless found
			puts 'fail to find in existing branches. Trying column combinations'
			# exnorate_all_suspicious_nodes
			# max = @remaining_cols.map{|cols| cols.count}.max
			max = @remaining_cols.get_max_ith_combination()
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
				mutationTbl_upd(bn_pair,updateTup,@pkCond)

				excluded=DBConn.exec(@excluded_query)
				if excluded.count() >0
					1.upto(i) do |j|
						nodes = []
						nd = Hash.new()
						# binding.pry
						nd['branch_name'] = "missing_branch#{i}"
						nd['node_name'] = "missing_node#{i}"
						nd['columns'] = "{#{excluded.map{|e| e['mutation_cols']}.join(',')}}"
						nd['query'] =''
						nd['location'] = 0
						nd['type'] = 'f'
						nodes <<nd
						# if i >1
						# 	binding.pry
						# 	abort('test')
						# end
						# if there's only one branch
						# or if the missing branch containing same set of columns as the existing branch
						# then we cannot exonerate
						old_cols = @branches.map{|b| b.columns}.flatten.map{|c| "#{c.relname}.#{c.colname}"}
						new_cols = excluded.map{|e| e['mutation_cols'].split(',')}.flatten.uniq

						if @branches.count == 1 || (old_cols-new_cols).empty?
							# binding.pry
							# old_cols = @branches[0].columns.map{|c| "#{c.renamed_colname}"}.join(',')
							puts 'No need to exonerate'
							found = true
							# @remaining_cols.recover_processed(i)
							return
						end

						blame_nodes(nodes)
					end
					# @remaining_cols.recover_processed(i)
					found = true
					break
				end
			end
			exnorate_all_suspicious_nodes
		end
		unless found
			abort('Fail to find the error')
		end
	end

	def mutate_to_satisfied_tuple()
		res = DBConn.exec(@constraintPredicateQuery)
	end

	def get_first_exludedPK()

		# allColumns = @allColumnList.map do |field|
		# 	# "#{field.colname} as #{field.relname}_#{field.colname} "
		# 	"#{field.relname}_#{field.colname} "
		# end.join(',')
		query = "select #{@allColumns_renamed} from golden_record where type = 'excluded';"
		# pp query
		res = DBConn.exec(query)
		abort('Cannot find excluded tuple!') if res.ntuples==0
		res
	end
	# excluded pk is in the table
	# but not in t_restul or f_result
	# this function return the first excluded pk with the different value in predicateColumn
	def get_first_satisfiedPK()
		# allColumns = @allColumnList.map do |field|
		# 	# "#{field.colname} as #{field.relname}_#{field.colname} "
		# 	"#{field.relname}_#{field.colname} "
		# end.join(',')
		query = "select #{@allColumns_renamed} from golden_record where type = 'satisfied' and branch = '#{@branches[0].name}';"
		res = DBConn.exec(query)
		abort("Cannot find satisfied tuple at #{@branches[0].name}!") if res.ntuples==0
		res

	end

	def is_satisfied?()
		included=returned_by_query?(@predicateQuery)
		satisfied=returned_by_query?(@constraintPredicateQuery)
		# binding.pry
		return (included and satisfied)
	end
	def is_unwanted?()
		included=returned_by_query?(@predicateQuery)
		satisfied=returned_by_query?(@constraintPredicateQuery)
		# binding.pry
		return (included and (not satisfied))
	end
	def is_missing?()
		included=returned_by_query?(@predicateQuery)
		satisfied=returned_by_query?(@constraintPredicateQuery)
		# binding.pry
		return ((not included) and  satisfied)
	end
	def is_excluded?()
		included=returned_by_query?(@predicateQuery)
		satisfied=returned_by_query?(@constraintPredicateQuery)
		# binding.pry
		return ((not included) and  (not satisfied))
	end

	def returned_by_query?(query)
		res=DBConn.exec(query)
		return res[0]['count'].to_i>0
	end

	def mutationTbl_create(whereCond)
		# colCombination = @allColumnList.combination(ith_combination).to_a.map{|c| c.map{|col| col.colname}.join(',')}.map{|c| "'#{c}'"}.join(',')

		renamedPKCol = @pk.map{|pk|  "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')

		targetListReplacement ="#{renamedPKCol},'none'::varchar(300) as mutation_branches,'none'::varchar(300) as mutation_nodes,'none'::varchar(300) as mutation_cols,#{@allColumns_select}"
		query =  ReverseParseTree.reverseAndreplace(@fParseTree, targetListReplacement,whereCond)
		pkList = @renamedPK.map{|pk| QueryBuilder.get_colalias(pk) }.join(', ')+',mutation_branches,mutation_nodes,mutation_cols'
		query=QueryBuilder.create_tbl(@mutation_tbl,pkList,query)
		# puts 'mutationTbl_create'
		# puts query
		# create
		DBConn.exec(query)

	end
	def mutationTbl_upd(bn_pairs,updateTup, whereCond)

		mutationTbl_create(whereCond)
		# binding.pry
		updQueryArray = []
		# renamedPKCond = @pk.map{|pk|  pk['col']+'_pk' +' = '+ pk['val'].to_s.str_int_rep }.join(' AND ')

		# query = "select #{@allColumns_renamed} from #{@mutation_tbl} where #{@renamePKCond} and mutation_branches = 'none' and mutation_cols = 'none'"
		# res = DBConn.exec(query)
		# original_tup =res[0]

		all_cols = @allColumns_renamed.split(',').map{|v| v.gsub(' ','')}
		#insert
		query = ""
		find=false
		bn_pairs.each_with_index do |bn,id|
			# insert_tup=  original_tup.map do |key,original_value|

			# 	# # bn['cols'].split(',').each do |col|
			# 	# pp bn
			# 	# pp "bn['cols'] "
			# 	# pp bn['cols']
			# 	# pp 'updateTup'
			# 	# pp updateTup
			# 	if bn['cols'].to_a.any?{|col| key == col.renamed_colname }
			# 		val = updateTup[0][key].nil? ? 'NULL' : updateTup[0][key].to_s.str_int_rep
			# 		"#{val} as #{key}"
			# 	else
			# 		val = original_value.nil? ? 'NULL' : original_value.to_s.str_int_rep
			# 		"#{val} as #{key} "
			# 	end
			# 	# binding.pry if original_value.nil? || updateTup[0][key].nil?
			# end.join(',')

			insert_tup = all_cols.map do |col|
							if bn['cols'].to_a.any?{|bn_col| bn_col.renamed_colname == col }
								find=true
								val = updateTup[0][col].nil? ? 'NULL' : updateTup[0][col].to_s.str_int_rep
								"#{val} as #{col}"
							else
								col
							end
						end.join(',')

			mutation_columns = bn['cols'].to_a.map{|c| c.fullname}.join(',')
			query = query + "INSERT INTO #{@mutation_tbl} "+
			                "select #{@renamedPKCol},'#{bn['branches']}' as mutation_branches,'#{bn['nodes']}' as mutation_nodes, '#{mutation_columns}' as mutation_cols ,#{insert_tup} "+
			                "from #{@mutation_tbl} where mutation_branches = 'none' and mutation_cols = 'none'; "

			                # "from #{@mutation_tbl} where #{@renamePKCond} and mutation_branches = 'none' and mutation_cols = 'none'; "
		end

		DBConn.exec(query)
		# binding.pry
	end



	def remaining_col_combination_bn_pairs(ith_col_combinations)
		bn_pairs = []
		ith_col_combinations.each do |cols|
			# pp cols
			bn= Hash.new()
			bn['branches'] = 'missing_branch'
			bn['nodes']='missing_node'
			bn['cols'] = cols
			bn_pairs << bn
		end
		bn_pairs
	end
	def missing_branch_node_pairs(ith_combination)
		bn_pairs = []
		@branches.combination(ith_combination).each do |br_comb|
			bn= Hash.new()
			bn['branches'] = br_comb.map{|br| br.name}.join(',')
			bn['nodes'] = ''
			bn['cols'] = Set.new()
			br_comb.each_with_index do |br,idx|
				# pp @pkCond_strip_tbl_alias
				# only need to find passed_node if it's on single branch
				passed_nodes = ith_combination == 1 ? br.passed_nodes(@pkCond_strip_tbl_alias,@test_id,@type) : []
				# pp passed_nodes
				if passed_nodes.count() > 0
					node = passed_nodes[0]
					# cols_strip_relalias = node.columns.map {|c| c.strip_relalias}
					# colnames = node.columns {|c| c.colname }.join(',')
					bn['nodes'] = node.name
					# @remaining_cols.delete(cols_strip_relalias.to_set)
					column_set = node.columns.to_set
					bn['cols']= column_set
					# bn['cols'] = bn['cols'] + ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"
					# pp node
					# @remaining_cols.delete(column_set)
				else
					if ith_combination == 1
						br.nodes.each do |nd|
							bn1= Hash.new()
							bn1['branches'] = bn['branches']
							bn1['nodes']=nd.name
							# bn1['cols'] = "#{nd.columns.join(',')}"
							column_set = nd.columns.to_set
							bn1['cols'] = column_set
							# pp nd
							@remaining_cols.delete(column_set)

							bn_pairs << bn1
						end
					else
						node = br.nodes[0]
						bn['nodes']=bn['nodes'] +(bn['nodes'].empty? ? '': ',')+ node.name
						# cols_strip_relalias = node.columns.map {|c| c.strip_relalias}
						# @remaining_cols.delete(cols_strip_relalias.to_set)
						# bn['cols'] = bn['cols'] + ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"	
						column_set = node.columns.to_set
						# pp "bn['cols']"
						# pp bn['cols']
						bn['cols']= bn['cols']+column_set
					end
				end
			end
			if bn['cols'].count() > 0
			 	bn_pairs << bn
			 	# pp 'delete again'
				@remaining_cols.delete(bn['cols'])
			end

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
				bn= Hash.new()
				bn['branches'] = br.name
				bn['nodes']=''
				bn['cols'] = Set.new()
				nd_comb.each_with_index do |nd,idx|
					bn['nodes'] = bn['nodes']+ ( idx >0 ? "," : "") + "#{nd.name}"
					# cols_strip_relalias = nd.columns.map {|c| c.strip_relalias}
					# colnames = nd.columns.map {|c| c.colname}
					# bn['cols'] = bn['cols']+ ( idx >0 ? "," : "") + "#{cols_strip_relalias.join(',')}"
					column_set = nd.columns.uniq{|c| c.hash }.to_set
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

	def exnorate_nodes(nodes)
		# puts 'exonerating'

		nodes.each do |nd|
			# pp nd
			branch_node_cond=" branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' "#and columns = '#{nd['columns']}'"
			query ="UPDATE node_query_mapping"+
			      " SET suspicious_score = suspicious_score -1 "+
				  " where test_id = #{@test_id} and type='f' and suspicious_score >0 "+ 
				  " and #{branch_node_cond}"
			# pp query
			DBConn.exec(query)
		end

	end
	def exnorate_all_nodes_in_branch(branch)
		query ="UPDATE node_query_mapping "+
		      " SET suspicious_score = suspicious_score - 1 "+
			  " where test_id = #{@test_id} and type = 'f' and suspicious_score >0 and branch_name not like 'missing%' and node_name not like 'missing%'"+
			   " and branch_name = '#{branch}'"
		# pp query
		DBConn.exec(query)
	end
	def exnorate_all_suspicious_nodes()
		nodes_query = @suspicious_nodes.map do |sn|
						"( branch_name = '#{sn['branch_name']}' and node_name = '#{sn['node_name']}') "
					end.join(' or ')
		query ="UPDATE node_query_mapping "+
		      " SET suspicious_score = suspicious_score - 1 "+
			  " where test_id = #{@test_id} and type = 'f' and suspicious_score >0 and branch_name not like 'missing%' and node_name not like 'missing%' "+
			  " and #{nodes_query} "
		# pp query
		# abort('test')
		DBConn.exec(query)
	end
	def blame_nodes(nodes)

		nodes.each do |nd|
			branch_node_cond=" branch_name = '#{nd['branch_name']}' and node_name = '#{nd['node_name']}' and columns = '#{nd['columns']}'"
			query ="UPDATE node_query_mapping"+
			      " SET suspicious_score = suspicious_score + 1 "+
				  "where test_id = #{@test_id} and type='f' "+
				  "and #{branch_node_cond}"
			# pp query
			res = DBConn.exec(query)
			if res.cmd_tuples()==0
				insert_query = 'INSERT INTO node_query_mapping '
				select_query = nodes.map do |nd|
					%Q(select #{@test_id} as test_id, 
					'#{nd['branch_name']}' as branch_name,
					'#{nd['node_name']}' as node_name, 
					'#{nd['query']}' as query, 
					'#{nd['location']}' as location, 
					'#{nd['columns']}' as columns, 
					1 as suspicious_score,
					'#{nd['type']}' as type)
				end.join(' UNION ')
				query = insert_query+select_query
				# pp query
				res = DBConn.exec(query)
			end
		end
	end


	def eliminate_redundant_tuples(guilty_nodes,updateTup, type)
		
		# create mutation table containing all failed rows
		# update identified guilty columns in mutation table
		mutationTbl_upd(guilty_nodes,updateTup, '')
		if type == 'U' # unwanted
		else
		end
		# remove redundant tuples
		# update suspicious score

	end

end