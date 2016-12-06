def queryTest(script,golden_record_opr,method)
# method: b --- baseline SBFL methods
#         o --- original 
#         n --- new
	dbname = script.split('_')[0]
	query_json = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
	create_test_result_tbl()
	f_options_list = []
	t_options = Hash.new()
	query_json.each do |key,value|
		if key == 'F'
			value.each do |opt|
				query=opt['query']
				pk_list=opt['pkList']
				relevent = opt['relevent']
				# pp relevent
				f_options = {:query=> query, :pkList =>pk_list,  :table =>'f_result', :relevent =>relevent }
				f_options_list<< f_options
			end

		elsif key == 'T'
			query=value['query']
			pk_list=value['pkList']
			t_options = {:query=> query, :pkList =>pk_list, :table =>'t_result' }
			# tqueryObj = QueryObj.new(t_options)
		end
	end
	# f_options = {:script=> fqueryScript, :table =>'f_result' }
	# fqueryObj = QueryObj.new(f_options)
	# # pp fqueryObj
	# t_options = {:script=> 'true', :table =>'t_result' }
	# tqueryObj = QueryObj.new(t_options)
	# #
	tqueryObj = QueryObj.new(t_options)
	# pp tqueryObj.parseTree
	# return
	if golden_record_opr == 'c'
		create_golden_record(tqueryObj)
		puts "Please verify golden record: verified (Y), not verified(N)"
		verified = STDIN.gets.chomp
		if verified == 'Y'
			DBConn.dump_golden_record(script)
		else
			abort('not verified')
		end
	elsif golden_record_opr == 'i'
		query = 'drop table IF EXISTS golden_record;'
		DBConn.exec(query)
		# gr_script = "sql/golden_record/#{script}_gr.sql"
		DBConn.exec_script(script)
		# abort('test')
	end
	# pp 'test'
	f_options_list.each_with_index do |f_options,idx|

		fqueryObj = QueryObj.new(f_options)
		if method == 'o'
			beginTime = Time.now
			tarantular = Tarantular.new(fqueryObj,tqueryObj,1)
			tarantular.predicateTest()
			endTime = Time.now
			tarantular_duration = (endTime - beginTime).to_i
			tarantular_rank = tarantular.relevence(f_options[:relevent])
			total_test_cnt = tarantular.total_test_cnt
		else
			tarantular_duration = 0
			tarantular_rank = {'tarantular_rank'=>'0', 'ochihai_rank'=>'0' }
			total_test_cnt = 0
		end
		# pp tarantular_rank
		# return
		# tarantular_rank = tarantular.relevence(f_options[:relevent])
		# return
		puts "begin test"
		beginTime = Time.now
		localizeErr = LozalizeError.new(fqueryObj,tqueryObj)
		selectionErrList = localizeErr.selecionErr(method)
		puts 'test end'
		endTime = Time.now
		m_u_tuple_count = localizeErr.missing_tuple_count + localizeErr.unwanted_tuple_count
		fqueryObj.score = localizeErr.getSuspiciouScore()
		puts 'fquery score:'
		pp fqueryObj.score
		pp fqueryObj.score['totalScore']
		duration = (endTime - beginTime).to_i
		puts "duration: #{duration}"
		update_test_result_tbl(idx,fqueryObj.query,tqueryObj.query,m_u_tuple_count,duration,fqueryObj.score['totalScore'],f_options[:relevent],tarantular_rank,tarantular_duration,total_test_cnt)
	end

	# puts "begin fix"
	# fqueryObj.score.each do |k,v|
	# 	unless k == 'totalScore'
	# 		if v.to_i >0
	# 			puts "fixing location #{k}"
	# 			hc=HillClimbingAlg.new(fqueryObj,tqueryObj)
	# 			hc.hill_climbing(k)
	# 			# hc.create_stats_tbl
	# 		end
	# 	end
	# end

end
def randomMutation(script)
	options = {:script=> script, :table =>'f_result' }
	fqueryObj = QueryObj.new(options)
	pp fqueryObj

	t_options = {:script=> 'true', :table =>'t_result' }
	tqueryObj = QueryObj.new(t_options)
	pp tqueryObj
	tqueryObj.create_stats_tbl
	return
	newQ = fqueryObj. generate_neighbor_program(127,0)

end
def create_golden_record(tQueryObj)
	# tQueryObj.parseTree
	parseTree = tQueryObj.parseTree
    wherePT= tQueryObj.parseTree['SELECT']['whereClause']
    fromPT=tQueryObj.parseTree['SELECT']['fromClause']
    col_list = DBConn.getAllRelFieldList(fromPT)
    new_target_list = col_list.map do |col|
    					"#{col.fullname} as #{col.renamed_colname}"
    				end.join(', ')

    tPredicateTree = PredicateTree.new('t',true, 0)
    root =Tree::TreeNode.new('root', '')
    tPredicateTree.build_full_pdtree(fromPT[0],wherePT,root)
    pdtree = tPredicateTree.pdtree
    # pdtree.print_tree


    all_queries = []
    br_queries =[]
    tPredicateTree.branches.each do |br|
    	br_query = ''
    	brq = Hash.new()
    	br.nodes.each_with_index do |nd,idx|
    		all_queries << nd.query unless all_queries.include?(nd.query)
    		br_query = br_query+ ( idx >0 ? ' AND ' : '') + nd.query
    	end
    	brq[br.name] = br_query
    	br_queries << brq
	end

	excluded_predicates = all_queries.map{|query| "NOT (#{query})"}.join(' AND ')
	excluded_target_list = "#{new_target_list} , 'excluded'::varchar(30) as type, ''::varchar(30) as branch"
	excluded_query = ReverseParseTree.reverseAndreplace(parseTree, excluded_target_list, excluded_predicates)
	excluded_query = "#{excluded_query} limit 1"
	# pp excluded_query

	DBConn.tblCreation('golden_record', '', excluded_query)

	br_queries.each do |q|
		q.each_pair do |key,val|
			satisfied_target_list = "#{new_target_list} , 'satisfied'::varchar(30) as type, '#{key}'::varchar(30) as branch"
			satisfied_query = ReverseParseTree.reverseAndreplace(parseTree, satisfied_target_list, val)
			satisfied_query = "INSERT INTO golden_record #{satisfied_query} limit 1"
			# pp satisfied_query
			DBConn.exec(satisfied_query)
		end
	end

end


def create_test_result_tbl()
	query =  %Q(DROP TABLE if exists test_result;
	CREATE TABLE test_result
	(test_id int, fquery text, tquery text, m_u_tuple_count bigint, duration bigint, total_score bigint, harmonic_mean float(2), jaccard float(2), column_cnt int, ochihai_rank varchar(50), tarantular_rank varchar(50), tarantular_duration int, total_test_cnt int);)
  	 # pp query
    DBConn.exec(query)

    query =  %Q(DROP TABLE if exists test_result_detail;
	CREATE TABLE test_result_detail
	(test_id int, branch_name varchar(30), node_name varchar(30), query text, columns text, score bigint);)
  	 # pp query
    DBConn.exec(query)
end
def update_test_result_tbl(test_id,fquery,tquery,m_u_tuple_count,duration,total_score,relevent,rank,tarantular_duration,total_test_cnt)

	fquery = fquery.gsub("'","''")
	tquery = tquery.gsub("'","''")
	query =  %Q(INSERT INTO test_result
				select #{test_id},
				'"#{fquery}"',
				'"#{tquery}"',
				#{m_u_tuple_count},
				#{duration},
				#{total_score},
				0,
				0,
				0,
				'#{rank['ochihai_rank']}',
				'#{rank['tarantular_rank']}',
				#{tarantular_duration},
				#{total_test_cnt}

			)
	# puts query
    DBConn.exec(query)

    query =  %Q(INSERT INTO test_result_detail
				select #{test_id},
				branch_name,
				node_name,
				query,
				columns,
				suspicious_score
				from node_query_mapping
				where type = 'f' and suspicious_score >0
			)
	# puts query
    DBConn.exec(query)

 	query = "select #{test_id},
				branch_name,
				node_name,
				query,
				columns,
				suspicious_score
				from node_query_mapping
				where type = 'f' and suspicious_score >0"
    res = DBConn.exec(query)
    puts 'result:'
    answer = Set.new
    res.each do |r|
    	pp r
    	predicate = "#{r['branch_name']}-#{r['node_name']}"
    	answer.add(predicate)
    end

    # update accuracy
    # pp relevent.to_a
    # binding.pry
    accuracy = Accuracy.new(answer,relevent.to_set)
    harmonic_mean = accuracy.harmonic_mean
    jaccard = accuracy.jaccard

    query = QueryBuilder.find_cols_by_data_typcategory('golden_record')
    res = DBConn.exec(query)
    column_cnt = res.count()-2

    query = "update test_result set harmonic_mean = #{harmonic_mean}, jaccard = #{jaccard}, column_cnt = #{column_cnt} where test_id = #{test_id}"
    res = DBConn.exec(query)
end

