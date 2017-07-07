require_relative 'db_connection'
require_relative 'query_builder'
class JoinKeyIdent
  def initialize(tbl_list)
    # candidates are list of columns of the same data type
    @candidates = []
    col_list_query = QueryBuilder.group_cols_by_data_typcategory(tbl_list)
    col_list = db_conn.exec(col_list_query)
    col_list.each do |collist|
      if collist['count'].to_i > 1
        cols = collist.split(',').to_set
        @candidates << cols
      end
    end
  end

  def verify_rules(t_table, tQueryObj)
    thresh_hold = 1
    res = db_conn.exec("select count(1) as cnt from #{t_table}")
    total_cnt = res[0]['cnt']
    if total_cnt <= 0
      puts 't_table is empty! can not verify association rules'
      return []
    end
    pk_list = ReverseParseTree.reverseAndreplace(tQueryObj.parseTree, tQueryObj.pkList, '') + ' limit 1'
    # example_pk = db_conn.exec(query)[0].to_hash
    pk_cond = QueryBuilder.pkCondConstr(pk_list)
    satisfactory_list =[]
    @candidates.each do |r|

      list = @candidates.split(',')
      select_cols = tQueryObj.all_cols.select do |col|
                      col_fullname = col.relname+'.'+col.colname
                      list.include?(col_fullname)
                    end
      unnest_colname = select_cols.map{|c| "'#{col.relname}.#{col.colname}'"}.join(',')
      unnest_colval = select_cols.map{|c| c.relname_fullname }.join(',')
      new_target_list = " unnest(array[#{unnest_colname}) as colname, unnest(array[#{unnest_colval}) as colval"
      query = ReverseParseTree.reverseAndreplace(tQueryObj.parseTree, new_target_list, pk_cond)

      query = "with (#{query}) as t "+
              " select string_agg( t.colname ,',') as col_list from t "+
              " group by colval "+
              " having count(1) >1"

      grouped_col_list = db_conn.exec(query)
      grouped_col_list.each do |cl|
        cl.split(',').to_set.combinations(2).each do |cp|
          eq_cols_cond = tQueryObj.all_cols.select do |col|
                          col_fullname = col.relname+'.'+col.colname
                          cp.include?(col_fullname)
                         end.join(' = ')

          query =ReverseParseTree.reverseAndreplace(tQueryObj.parseTree, "count(1)::float/#{total_cnt}::float as sat", eq_cols_cond)
          res = db_conn.exec(query)
          satisfactory = res[0]['sat']
          satisfactory_list << cp if satisfactory >= thresh_hold
        end
      end
    end
    satisfactory_list
  end
end
