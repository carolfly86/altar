select avg(count) from (select count(1) as count,table_name from information_schema.columns where table_schema='public' and table_name in (select tablename from pg_tables where tableowner!='myuser')group by table_name) as t;

select avg(n_live_tup) from pg_stat_user_tables where schemaname='public' and relname in (select tablename from pg_tables where tableowner='yguo');

select avg(count) from (select count(1) as count,table_name from information_schema.columns where table_schema='public' and table_name in (select tablename from pg_tables where tableowner='yguo')group by table_name) as t;

select avg(n_live_tup) from pg_stat_user_tables where relname in (select tablename from pg_tables where tableowner='yguo');