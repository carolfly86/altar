require 'pg_query'
require 'pp'
q='select * from a where c=a and cd=1 and (r=1 and f=0)'
pp PgQuery.parse(q)