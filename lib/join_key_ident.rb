require_relative 'db_connection'
require_relative 'query_builder'
require_relative 'acyclic_graph'
class JoinKeyIdent
  def initialize(query_obj)
    # candidates are list of columns of the same data type
    @query_obj = query_obj

  end

  def extract_from_table()
    # @candidates is sets of columns in the same data typecategory
    @candidates = []
    tbl_list = @query_obj.rel_names.map{|r| "'#{r['relname']}'"}.join(',')
    col_list_query = QueryBuilder.group_cols_by_data_typcategory(tbl_list)
    pp col_list_query
    col_list = DBConn.exec(col_list_query)
    col_list.each do |collist|
      if collist['count'].to_i > 1
        cols = collist['col_list'].split(',').to_set
        @candidates << cols
      end
    end

    t_full_table = @query_obj.create_full_rst_tbl
    nullable_tbl = Table.new(@query_obj.nullable_tbl)
    if nullable_tbl.row_count() >0
      not_null_query = " where " + nullable_tbl.columns.map{|c| "#{c.colname} is not null"}.join(' AND ')
      # null_query = " where " + nullable_tbl.columns.map{|c| "#{c.colname} is null"}.join(' OR ')
    else
      not_null_query = ''
      # null_query = ''
    end
    thresh_hold = 1
    res = DBConn.exec("select count(1) as cnt from #{t_full_table}")
    total_cnt = res[0]['cnt']
    # pp total_cnt
    if total_cnt.to_i <= 0
      puts "#{t_full_table} is empty! can not verify association rules"
      return []
    end
    renamed_pk = @query_obj.pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', ')
    query = "select #{renamed_pk} from #{t_full_table} #{not_null_query} limit 1"
    # check one example row first
    # if assiociation rule can be found in example row the process to all rows
    # example pk must satisfy not null condition
    res = DBConn.exec(query)
    # if all rows are null then example pk can be nullable 
    if res.count()==0
      query = "select #{renamed_pk} from #{t_full_table} limit 1"
      example_pk = DBConn.exec(query)[0]
    else
      example_pk = res[0]
    end

    pk_cond = example_pk.map do |k,v|
                if v.nil?
                  "#{k} is null"
                else
                  k + ' = ' + v.to_s.str_int_rep 
                end
              end.join(' AND ')
    join_key_list =[]
    # pp pk_cond
    # acyclic_graph = AcyclicGraph.new([])
    @candidates.each do |list|

      # list = @candidates.split(',')
      select_cols = @query_obj.all_cols.select do |col|
                      # col_fullname = col.relname+'.'+col.colname
                      list.include?(col.relname_fullname)
                    end
      unnest_colname = select_cols.map{|c| "'#{c.renamed_colname}'"}.join(',')
      unnest_colval = select_cols.map{|c| "#{c.renamed_colname}::text" }.join(',')
      new_target_list = " unnest(array[#{unnest_colname}]) as colname, unnest(array[#{unnest_colval}]) as colval"

      query = "select #{new_target_list} from (select * from #{t_full_table} where #{pk_cond} limit 1) as t"
      query = "with t as (#{query}) "+
              " select string_agg( t.colname ,',') as col_list from t "+
              " where colval is not null "+
              " group by colval "+
              " having count(1) >1"
      # pp query
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
          query = "select count(1)/#{total_cnt} as sat from #{t_full_table} "
          if nullable_tbl.row_count() == 0
            query = query + "where #{eq_cols_cond}"
          else
            null_query = nullable_column_query(col_pair)
            if null_query.empty?
              cp_null = cp.map{|c| "#{c} IS NULL"}.join(" AND ")
              query = query +"where #{eq_cols_cond} or (#{cp_null})"
            else
              query = query +"where (#{null_query}) OR (#{eq_cols_cond})"
            end
          end

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
    pp join_key_list.map{|c| c.map{|col| col.renamed_colname} }
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

  def none_inner_join_list()
    if @none_inner_join_list.nil?
      join_list = @query_obj.join_list
      @none_inner_join_list =join_list.select{|join| join['jointype'].to_i >0}
    end
    return @none_inner_join_list
  end

  def nullable_column_query(column_pair)
    query = ''
    none_inner_join_list = none_inner_join_list()
    if none_inner_join_list.count>0
      cp_rels = column_pair.map{|c| c.relname }
      none_inner_join_list.each do |join|
        r_rel_list = join['r_rel_list'].map{|r| r.relname} & cp_rels
        l_rel_list = join['l_rel_list'].map{|r| r.relname} & cp_rels

        if r_rel_list.count>0 && l_rel_list.count>0
          jointype = join['jointype']
          r_rel_col = column_pair.find{|c| c.relname == r_rel_list[0]}
          l_rel_col = column_pair.find{|c| c.relname == l_rel_list[0]}
          # case jointype
          # when 1 # LEFT JOIN
          #   l_is_not_null = "#{l_rel_col.renamed_colname} is not null"
          #   r_is_null =  "#{r_rel_col.renamed_colname} is null"
          #   query = "#{l_is_not_null} and #{r_is_null}"
          # when 3 # RIGHT JOIN
          #   l_is_null = "#{l_rel_col.renamed_colname} is null"
          #   r_is_not_null =  "#{r_rel_col.renamed_colname} is not null"
          #   query = "#{l_is_null} and #{r_is_not_null}"

          # when 2 # FULL JOIN
          #   l_is_not_null = "#{l_rel_col.renamed_colname} is not null"
          #   r_is_not_null = "#{r_rel_col.renamed_colname} is not null"
          #   query = "#{l_is_not_null} OR #{r_is_not_null}"
          # else
          #   query = ''
          # end
          query = "#{l_rel_col.renamed_colname} is null OR #{r_rel_col.renamed_colname} is null"
          return query
        end
      end
    end
    return query
  end

end
