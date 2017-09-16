def create_all_test_result_tbl
  query = %(DROP TABLE if exists all_test_result;
	CREATE TABLE all_test_result
	(script_name varchar(100), test_id char(5), m_u_tuple_count bigint, duration bigint, total_score bigint,
	harmonic_mean float(2), jaccard float(2), column_cnt int,
	tarantular_hm float(2), ochihai_hm float(2), kulczynski2_hm float(2), naish2_hm float(2),wong1_hm float(2),
	sober_hm float(2), liblit_hm float(2),mw_hm float(2),crosstab_hm float(2),
	tarantular_duration int, total_test_cnt int);)
  # pp query
  DBConn.exec(query)
end

def dump_test_result(script)
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
def create_test_result_tbl
  query = %(DROP TABLE if exists test_result;
	CREATE TABLE test_result
	(test_id char(5), test_type char(5),
  fquery text, tquery text, m_u_tuple_count bigint, duration bigint, total_score bigint,
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
 	(test_id char(5), test_type char(5),
  branch_name varchar(30), node_name varchar(30), query text, columns text, score bigint);)
  # pp query
  DBConn.exec(query)
end

def update_test_result_tbl(test_id, test_type, fquery, tquery, m_u_tuple_count, duration, total_score, relevent, rank, tarantular_duration, total_test_cnt)
  fquery = fquery.gsub("'", "''")
  tquery = tquery.gsub("'", "''")
  query =  %(INSERT INTO test_result
				select '#{test_id}',
        '#{test_type}',
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
 				select '#{test_id}',
        '#{test_type}',
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

  query = "update test_result set harmonic_mean = #{harmonic_mean}, jaccard = #{jaccard}, column_cnt = #{column_cnt} where test_id = '#{test_id}' and test_type = '#{test_type}'"
  res = DBConn.exec(query)
end
