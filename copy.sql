 insert into all_test_result select script_name,'4',m_u_tuple_count,duration,total_score,harmonic_mean,jaccard,column_cnt,0,0,0,0,0,0,0,0,0,tarantular_duration,mw_duration,total_test_cnt from all_test_result where test_id='0';

 COPY all_test_result TO '/tmp/balance_where.csv' DELIMITER ',' CSV HEADER;
 scp yguo@bh20-pgs-008:/tmp/employees_join_jfl.csv .

 COPY all_fix_result TO '/tmp/balance_where_fix_result.csv' DELIMITER ',' CSV HEADER;
 scp yguo@bh20-pgs-008:/tmp/balance_where_fix_result.csv .

 COPY all_fix_result TO '/tmp/polling_where_alarm.csv' DELIMITER ',' CSV HEADER;
 scp yguo@bh20-pgs-008:/tmp/polling_where_alarm.csv .