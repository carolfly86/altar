require_relative 'db_connection'
require_relative 'query_builder'
require_relative 'acyclic_graph'
class JoinKeyIdent
  def initialize(query_obj)
    # candidates are list of columns of the same data type
    @query_obj = query_obj

  end

  def extract_from_table()
    @candidates = []
    tbl_list = @query_obj.rel_names.map{|r| "'#{r['relname']}'"}.join(',')
    col_list_query = QueryBuilder.group_cols_by_data_typcategory(tbl_list)
    col_list = DBConn.exec(col_list_query)
    col_list.each do |collist|
      if collist['count'].to_i > 1
        cols = collist['col_list'].split(',').to_set
        @candidates << cols
      end
    end

    t_full_table = @query_obj.create_full_rst_tbl

    thresh_hold = 1
    res = DBConn.exec("select count(1) as cnt from #{t_full_table}")
    total_cnt = res[0]['cnt']
    pp total_cnt
    if total_cnt.to_i <= 0
      puts "#{t_full_table} is empty! can not verify association rules"
      return []
    end
    renamed_pk = @query_obj.pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', ')
    query = "select #{renamed_pk} from #{t_full_table} limit 1"
    example_pk = DBConn.exec(query)[0]
    pk_cond = example_pk.map { |k,v|  k + ' = ' + v.to_s.str_int_rep }.join(' AND ')
    join_key_list =[]
    # pp pk_cond
    # acyclic_graph = AcyclicGraph.new([])

    @candidates.each do |list|

      # list = @candidates.split(',')
      select_cols = @query_obj.all_cols.select do |col|
                      col_fullname = col.relname+'.'+col.colname
                      list.include?(col_fullname)
                    end
      unnest_colname = select_cols.map{|c| "'#{c.renamed_colname}'"}.join(',')
      unnest_colval = select_cols.map{|c| c.renamed_colname }.join(',')
      new_target_list = " unnest(array[#{unnest_colname}]) as colname, unnest(array[#{unnest_colval}]) as colval"
      query = "select #{new_target_list} from #{t_full_table} where #{pk_cond}"
      query = "with t as (#{query}) "+
              " select string_agg( t.colname ,',') as col_list from t "+
              " group by colval "+
              " having count(1) >1"
      pp query
      grouped_col_list = DBConn.exec(query)
      grouped_col_list.each do |cl|
        # binding.pry
        col_pairs = cl['col_list'].split(',').combination(2)
        col_pairs.each do |cp|
          col_pair =[]
          cp.each do |c|
            col_pair << @query_obj.all_cols.find do |col|
                          col.renamed_colname == c
                        end
          end
          # if two columns are from the same relname
          # no need to compare
          next if col_pair.map{|c| c.relname }.uniq.count()==1

          eq_cols_cond = cp.join(' = ')
          query = "select count(1)::float/#{total_cnt}::float as sat from #{t_full_table} where #{eq_cols_cond}"
          pp query
          res = DBConn.exec(query)
          satisfactory = res[0]['sat']

          if satisfactory.to_i >= thresh_hold
            # edge = col_pair.map{|c| c.hash }
            # # binding.pry
            # added = acyclic_graph.add_edge(edge)
            join_key_list << col_pair.to_set
          end
        end
      end
    end
    # pp join_key_list
    join_key_list.to_set
  end

  def extract_from_parse_tree()
    join_exprs = JsonPath.on(@query_obj.parseTree['SELECT']['fromClause'].to_json, '$..AEXPR')
    join_key_list = []
    join_exprs.each do |k|
      cols = JsonPath.on(k, '$..fields')
      cp = []
      cols.each do |c| 
        cp << @query_obj.all_cols.find do |col|
                                          col.relalias == c[0] && col.colname == c[1]
                                        end
      end
      join_key_list << cp.to_set
    end
    # pp join_key_list
    join_key_list.to_set
  end



end
