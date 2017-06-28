require_relative 'db_connection'
require_relative 'query_builder'
class Association_Rules
    def initialize(tbl_list)
      @candidates = []
      col_list_query = QueryBuilder.group_cols_by_data_typcategory(tbl_list)
      col_list = db_conn.exec(col_list_query)
      col_list.each do |collist|
        if collist['count'].to_i >1
            cols = collist.split(',').to_set
            @candidates << cols
        end
      end
    end
    def verify_rules(t_table,tQueryObj, allColumns)
        thresh_hold = 1
        res = db_conn.exec("select count(1) as cnt from #{t_table}")
        total_cnt = res[0]['cnt']
        if total_cnt <=0
            puts 't_table is empty! can not verify association rules'
            return []
        end
        query =  ReverseParseTree.reverseAndreplace(tQueryObj.parseTree, @allColumns_select ,'') + ' limit 1'
        example_pk = db_conn.exec(query)[0].to_hash
        satisfactory_list =[]
        @candidates.each do |r|
            list = @candidates.split(',').map{|c| c.tr('.','_')}
            example_list =example_pk.select{|k,v| list.include?(k)}
            example_list.sort_by {|_key, value| value}.to_h
            query = " select count(1)::float/#{total_cnt}::float as sat from #{dataset} where #{r} "
            res = db_conn.exec(query)
            satisfactory = res[0]['sat']
            if satisfactory >= thresh_hold
                satisfactory_list << r
            end
        end
        return satisfactory_list
    end

end