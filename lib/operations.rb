def create_all_script_result_tbl
  query = %(DROP TABLE if exists all_test_result;
	CREATE TABLE all_test_result
	(script_name varchar(100), test_id int, m_u_tuple_count bigint, duration bigint, total_score bigint,
	harmonic_mean float(2), jaccard float(2), column_cnt int,
	tarantular_hm float(2), ochihai_hm float(2), kulczynski2_hm float(2), naish2_hm float(2),wong1_hm float(2),
	sober_hm float(2), liblit_hm float(2),mw_hm float(2),crosstab_hm float(2),
	tarantular_duration int, total_test_cnt int);)
  # pp query
  DBConn.exec(query)
end

def dump_result(script)
  query = " insert into all_test_result
	select '#{script}',
	test_id,
	m_u_tuple_count ,
	duration ,
	total_score ,
	harmonic_mean ,
	jaccard ,
	column_cnt ,
	tarantular_hm ,
	ochihai_hm ,
	kulczynski2_hm ,
	naish2_hm ,
	wong1_hm,
	sober_hm ,
	liblit_hm ,
	mw_hm ,
	crosstab_hm ,
	tarantular_duration ,
	total_test_cnt
	from test_result"
  DBConn.exec(query)
end

def faultLocalization(script, golden_record_opr, method, auto_fix)
  # method: b --- baseline SBFL methods
  #         o --- original
  #         n --- new
  # dbname = script.split('_')[0]
  dbname = script[0...-4]
  query_json = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
  create_test_result_tbl
  create_fix_result_tbl
  f_options_list = []
  t_options = {}
  query_json.each do |key, value|
    if key == 'F'
      value.each do |opt|
        query = opt['query']
        pk_list = opt['pkList']
        relevent = opt['relevent']
        # pp relevent
        f_options = { query: query, pkList: pk_list, table: 'f_result', relevent: relevent }
        f_options_list << f_options
      end

    elsif key == 'T'
      query = value['query']
      pk_list = value['pkList']
      t_options = { query: query, pkList: pk_list, table: 't_result' }
      # tqueryObj = QueryObj.new(t_options)
    end
  end

  tqueryObj = QueryObj.new(t_options)
  # pp tqueryObj.parseTree
  # return
  # create Golden record
  createGR(golden_record_opr, script, tqueryObj)
  # pp 'test'
  f_options_list.each_with_index do |f_options, idx|
    fqueryObj = QueryObj.new(f_options)
    if method == 'b'
      beginTime = Time.now
      tarantular = Tarantular.new(fqueryObj, tqueryObj, 1)
      tarantular.predicateTest
      endTime = Time.now
      tarantular_duration = (endTime - beginTime).to_i
      tarantular_rank = tarantular.relevence(f_options[:relevent])
      total_test_cnt = tarantular.total_test_cnt
      m_u_tuple_count = tarantular.failed_tuple_count
      totalScore = m_u_tuple_count
      duration = tarantular_duration
    else
      tarantular_duration = 0
      tarantular_rank = { 'tarantular_rank' => '0', 'ochihai_rank' => '0', 'naish2_rank' => '0', 'kulczynski2_rank' => '0',
                          'wong1_rank' => '0', 'sober_rank' => '0', 'liblit_rank' => '0', 'mw_rank' => '0', 'crosstab_rank' => '0',
                          'tarantular_hm' => '0', 'ochihai_hm' => '0', 'naish2_hm' => '0', 'kulczynski2_hm' => '0',
                          'wong1_hm' => '0', 'sober_hm' => '0', 'liblit_hm' => '0', 'mw_hm' => '0', 'crosstab_hm' => '0' }
      total_test_cnt = 0

      puts 'begin fault localization'
      beginTime = Time.now
      puts "fault localization start time: #{beginTime}"
      localizeErr = LozalizeError.new(fqueryObj, tqueryObj)

      if auto_fix
        puts 'fault localize: Join Key Errors'
        new_join_key,old_join_key = localizeErr.join_key_err
        if new_join_key.count >0
          puts 'finding candidate join key list'
          # pp new_join_key
          new_from,candidate_join_key = AutoFix.join_key_fix(new_join_key, fqueryObj.parseTree)
          unless (candidate_join_key - old_join_key).empty?
            # pp new_from
            puts 'Fixing join key'
            fQueryNew = AutoFix.fix_from_query(fqueryObj.query,new_from)
            pp fQueryNew
            fqueryObj = QueryObj.new(query: fQueryNew, pkList: fqueryObj.pkList, table: 'f_result')
            LozalizeError.new(fqueryObj, tqueryObj)
          else
            puts 'No Join Key Error'
          end
        else
          puts 'No Join Key Error'
        end

        # # Join type error localization
        puts 'fault localize: Join Type Errors'
        joinErrList = localizeErr.join_type_err
        if joinErrList.count > 0
          # fix join type error
          pp 'fixing join type error'
          pp 'join type error list'
          pp joinErrList

          psNew = AutoFix.JoinTypeFix(joinErrList, fqueryObj.parseTree)
          fQueryNew = ReverseParseTree.reverse(psNew)
          p 'New query after fixing join type error'
          p fQueryNew
          fqueryObj = QueryObj.new(query: fQueryNew, pkList: fqueryObj.pkList, table: 'f_result')
          # Reinitialize LocalizeErr with fixed query
          localizeErr = LozalizeError.new(fqueryObj, tqueryObj)
        else
          puts 'No Join Type Error'
        end
      end
      # Where condition fault localization
      localizeErr.selecionErr(method)

      puts 'fault localization end'
      endTime = Time.now
      puts "fault localization end time: #{endTime}"
      m_u_tuple_count = localizeErr.missing_tuple_count + localizeErr.unwanted_tuple_count

      # Projection error localization
      # prjErrList = localizeErr.projErr

      fqueryObj.score = localizeErr.getSuspiciouScore
      puts 'fquery score:'
      pp fqueryObj.score
      totalScore = fqueryObj.score['totalScore']
      duration = (endTime - beginTime).to_i
      puts "duration: #{duration}"

    end
    # pp tarantular_rank
    # return
    # tarantular_rank = tarantular.relevence(f_options[:relevent])
    # return
    update_test_result_tbl(idx, fqueryObj.query, tqueryObj.query, m_u_tuple_count, duration, totalScore, f_options[:relevent], tarantular_rank, tarantular_duration, total_test_cnt)

    if auto_fix
      puts 'begin fix'
      # create t_result stats table
      tqueryObj.create_stats_tbl
      # fqueryObj.create_stats_tbl
      excluded_tbl = tqueryObj.create_excluded_tbl
      satisfied_tbl = tqueryObj.create_satisfied_tbl

      current_query = fqueryObj.query
      current_score = totalScore
      current_queryObj = fqueryObj


      test_result = localizeErr.get_test_result

      test_result.each do |rst|
        next if rst.suspicious_score.to_i <= 0

        puts "fixing node: #{rst.branch_name} #{rst.node_name} at location #{rst.location}"
        pp rst.columns
        mutation = Mutation.new(current_queryObj,excluded_tbl,satisfied_tbl)
        neighborQueryObj = mutation.generate_neighbor_query(rst)
        localizeErr = LozalizeError.new(neighborQueryObj, tqueryObj)
        localizeErr.selecionErr(method)
        new_score = localizeErr.getSuspiciouScore
        # if new_score['totalScore'] < best_score
        current_query = neighborQueryObj.query
        current_score = new_score['totalScore']
        current_queryObj = neighborQueryObj
        # end
        break if current_score ==0
        binding.pry
        # puts 'neighborQueryObj query:'
        # pp neighborQueryObj.query
        # puts 'neighborQueryObj score:'
        # pp neighborQueryObj.score
        # hc=HillClimbingAlg.new(fqueryObj,tqueryObj)
        # hc.hill_climbing(k)
        # hc.create_stats_tbl
      end
      update_fix_result_tbl(idx,tqueryObj.query,current_query, current_score)

    end
    # exit 0
  end
end

def randomMutation(fqueryObj, tqueryObj)
  # options = {:script=> script, :table =>'f_result' }
  # fqueryObj = QueryObj.new(options)
  # pp fqueryObj

  # t_options = {:script=> 'true', :table =>'t_result' }
  # tqueryObj = QueryObj.new(t_options)
  # pp tqueryObj
  tqueryObj.create_stats_tbl
  newQ = fqueryObj.generate_neighbor_program(127, 0)
end

def createGR(golden_record_opr, script, tqueryObj)
  if golden_record_opr == 'c'
    create_golden_record(tqueryObj)
    puts 'Please verify golden record: verified (Y), not verified(N)'
    verified = STDIN.gets.chomp
    if verified == 'Y'
      DBConn.dump_golden_record(script)
    else
      abort('not verified')
    end
  elsif golden_record_opr == 'i'
    # import golden record
    query = 'drop table IF EXISTS golden_record;'
    DBConn.exec(query)
    # binding.pry
    DBConn.exec_golden_record_script(script)
    # abort('test')
  end
end

def create_golden_record(tQueryObj)
  # tQueryObj.parseTree
  # parseTree = tQueryObj.parseTree
  # wherePT = tQueryObj.parseTree['SELECT']['whereClause']
  # fromPT = tQueryObj.parseTree['SELECT']['fromClause']
  # col_list = DBConn.getAllRelFieldList(fromPT)
  # new_target_list = col_list.map do |col|
  #   "#{col.fullname} as #{col.renamed_colname}"
  # end.join(', ')
  new_target_list = tQueryObj.all_cols_select
  # tPredicateTree = PredicateTree.new('t', true, 0)
  # root = Tree::TreeNode.new('root', '')
  # tPredicateTree.build_full_pdtree(fromPT[0], wherePT, root)
  # pdtree = tPredicateTree.pdtree
  # pdtree.print_tree
  tQueryObj.predicate_tree_construct('t', true, 0)
  excluded_tbl = tQueryObj.create_excluded_tbl
  satisfied_tbl = tQueryObj.create_satisfied_tbl
  # all_queries = []
  # br_queries = []
  # tPredicateTree.branches.each do |br|
  #   br_query = ''
  #   brq = {}
  #   br.nodes.each_with_index do |nd, idx|
  #     all_queries << nd.query unless all_queries.include?(nd.query)
  #     br_query = br_query + (idx > 0 ? ' AND ' : '') + nd.query
  #   end
  #   brq[br.name] = br_query
  #   br_queries << brq
  # end

  # excluded_predicates = all_queries.map { |query| "NOT (#{query})" }.join(' AND ')
  # excluded_target_list = "#{new_target_list} , 'excluded'::varchar(30) as type, ''::varchar(30) as branch"
  # excluded_query = ReverseParseTree.reverseAndreplace(parseTree, excluded_target_list, excluded_predicates)
  # excluded_query = "#{excluded_query} limit 1"
  # pp excluded_query
  # binding.pry
  # DBConn.tblCreation('golden_record', '', excluded_query)

  excluded_query =  "select #{new_target_list},'excluded'::varchar(30) as type, ''::varchar(30) as branch from #{excluded_tbl} limit 1"
  DBConn.tblCreation('golden_record', '', excluded_query)

  query = "select count(1) as cnt from golden_record where type = 'excluded'"
  res = DBConn.exec(query)
  # if no excluded rows are found, we generate an excluded row which contains all Null values
  if res[0]['cnt'].to_i == 0
    # binding.pry
    null_target_list = col_list.map do |col|
      "null as #{col.renamed_colname}"
    end.join(', ')
    null_target_list = " #{null_target_list} , 'excluded' as type, '' as branch"
    null_query = ReverseParseTree.reverseAndreplace(parseTree, null_target_list, '')
    null_query = "INSERT INTO golden_record #{null_query} limit 1"
    DBConn.exec(null_query)
    # binding.pry
  end

  satisfied_query = "SELECT distinct on (branch) #{new_target_list},'satisfied'::varchar(30) as type, branch from  #{satisfied_tbl}"
  satisfied_query = "INSERT INTO golden_record #{satisfied_query}"
  DBConn.exec(satisfied_query)
  # br_queries.each do |q|
  #   q.each_pair do |key, val|
  #     satisfied_target_list = "#{new_target_list} , 'satisfied'::varchar(30) as type, '#{key}'::varchar(30) as branch"
  #     satisfied_query = ReverseParseTree.reverseAndreplace(parseTree, satisfied_target_list, val)
  #     satisfied_query = "INSERT INTO golden_record #{satisfied_query} limit 1"
  #     # pp satisfied_query
  #     DBConn.exec(satisfied_query)
  #   end
  # end
end

def create_fix_result_tbl
  query = %(DROP TABLE if exists fix_result;
  CREATE TABLE fix_result
  (test_id int, tquery text, fixed_query text, final_score int)
  )
  DBConn.exec(query)
end

def update_fix_result_tbl(test_id,tquery,fixed_query, score)
  fixed_query = fixed_query.gsub("'", "''")
  tquery = tquery.gsub("'", "''")
  query =  %(INSERT INTO fix_result
        select #{test_id},
        '"#{tquery}"',
        '"#{fixed_query}"',
        #{score})
  DBConn.exec(query)
end

def create_test_result_tbl
  query = %(DROP TABLE if exists test_result;
	CREATE TABLE test_result
	(test_id int, fquery text, tquery text, m_u_tuple_count bigint, duration bigint, total_score bigint,
	harmonic_mean float(2), jaccard float(2), column_cnt int,
	tarantular_rank varchar(50), ochihai_rank varchar(50), kulczynski2_rank varchar(50), naish2_rank varchar(50),wong1_rank varchar(50),
	sober_rank varchar(50), liblit_rank varchar(50),mw_rank varchar(50),
	tarantular_hm float(2), ochihai_hm float(2), kulczynski2_hm float(2), naish2_hm float(2),wong1_hm float(2),
	sober_hm float(2), liblit_hm float(2),mw_hm float(2),crosstab_hm float(2),
	tarantular_duration int, total_test_cnt int);)
  # pp query
  DBConn.exec(query)

  query = %(DROP TABLE if exists test_result_detail;
 	CREATE TABLE test_result_detail
 	(test_id int, branch_name varchar(30), node_name varchar(30), query text, columns text, score bigint);)
  # pp query
  DBConn.exec(query)
end

def update_test_result_tbl(test_id, fquery, tquery, m_u_tuple_count, duration, total_score, relevent, rank, tarantular_duration, total_test_cnt)
  fquery = fquery.gsub("'", "''")
  tquery = tquery.gsub("'", "''")
  query =  %(INSERT INTO test_result
				select #{test_id},
				'"#{fquery}"',
				'"#{tquery}"',
				#{m_u_tuple_count},
				#{duration},
				#{total_score},
				0,
				0,
				0,
				'#{rank['tarantular_rank']}',
				'#{rank['ochihai_rank']}',
				'#{rank['kulczynski2_rank']}',
				'#{rank['naish2_rank']}',
				'#{rank['wong1_rank']}',
				'#{rank['sober_rank']}',
				'#{rank['liblit_rank']}',
				'#{rank['mw_rank']}',
				'#{rank['tarantular_hm']}',
				'#{rank['ochihai_hm']}',
				'#{rank['kulczynski2_hm']}',
				'#{rank['naish2_hm']}',
				'#{rank['wong1_hm']}',
				'#{rank['sober_hm']}',
				'#{rank['liblit_hm']}',
				'#{rank['mw_hm']}',
				'#{rank['crosstab_hm']}',
				#{tarantular_duration},
				#{total_test_cnt}

			)
  # pp query
  DBConn.exec(query)

  query = %(INSERT INTO test_result_detail
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
    # pp r
    predicate = "#{r['branch_name']}-#{r['node_name']}"
    answer.add(predicate)
  end

  # update accuracy
  # pp relevent.to_a
  # binding.pry
  accuracy = Accuracy.new(answer, relevent.to_set)
  harmonic_mean = accuracy.harmonic_mean
  jaccard = accuracy.jaccard

  query = QueryBuilder.find_cols_by_data_typcategory('golden_record')
  res = DBConn.exec(query)
  column_cnt = res.count - 2

  query = "update test_result set harmonic_mean = #{harmonic_mean}, jaccard = #{jaccard}, column_cnt = #{column_cnt} where test_id = #{test_id}"
  res = DBConn.exec(query)
end
