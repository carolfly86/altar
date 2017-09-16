def create_fix_result_tbl
  query = %(DROP TABLE if exists fix_result;
  CREATE TABLE fix_result
  (test_id char(5), test_type char(5), tquery text, fixed_query text,
  duration int, final_score int)
  )
  DBConn.exec(query)
end

def update_fix_result_tbl(test_id,test_type,tquery,fixed_query,duration, score)
  fixed_query = fixed_query.gsub("'", "''")
  tquery = tquery.gsub("'", "''")
  query =  %(INSERT INTO fix_result
        select '#{test_id}',
        '#{test_type}',
        '"#{tquery}"',
        '"#{fixed_query}"',
        #{duration},
        #{score})
  DBConn.exec(query)
end

def create_all_fix_result_tbl
  query = %(DROP TABLE if exists all_fix_result;
  CREATE TABLE all_fix_result
  (script_name varchar(100), test_id char(5),
  test_type char(5),
  tquery text,fixed_query text,
  duration bigint, final_score bigint
   );)
  # pp query
  DBConn.exec(query)
end

def dump_fix_result(script)
    query = " insert into all_fix_result
  select '#{script}',
  test_id,
  test_type,
  tquery,
  fixed_query,
  duration,
  final_score
  from fix_result"
  DBConn.exec(query)
end