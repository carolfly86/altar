module RewriteQuery
  # rewrite the query to return all fields in all reltaions.
  # also rename columns appearing in more than one relation.
  # for example, updated_date column is in both customer table and address table,
  # then the updated_date in customer table will be selected as customer_updated_date,
  # and the one in address table will be address_updated_date
  def self.return_all_fields(query, fields)
    parseTree = PgQuery.parse(query).parsetree[0]
    # distinct = parseTree['SELECT']['distinctClause']||''
    fromPT = parseTree['SELECT']['fromClause']
    # fields = DBConn.getAllRelFieldList(fromPT)
    newTargetList = []
    rewriteCols = {}
    fields.group_by(&:colname).each do |key, val|
      col = if val.size > 1
              rewriteCols[key] = val
              val.map { |c| "#{c.relalias}.#{c.colname} as #{c.relname}_#{c.colname}" }.join(',')
            else
              val.map { |c| "#{c.relalias}.#{c.colname}" }.join(',')
            end
      newTargetList << col
    end
    targetListReplacement = newTargetList.join(',')
    newQuery = ReverseParseTree.reverseAndreplace(parseTree, targetListReplacement, '')
    [newQuery, rewriteCols]
  end

  def self.rewrite_predicate_query(query, column_list)
    # pp column_list
    column_list.each do |col|
      # binding.pry
      query = RewriteQuery.replace_fullname_with_renamed_colname(query, col)
    end
    # query="SELECT mutation_branches,mutation_nodes, mutation_cols "+
    #       " FROM mutation_tuple "+
    #       " WHERE mutation_branches <> 'none' and mutation_cols <>'none' and "+
    query
  end

  def self.rename_duplicate_columns(colList)
    colList.group_by(&:colname).each do |_key, val|
      if val.size > 1
        val.each do |col|
          col.colalias = col.relname.to_s.empty? ? "#{col.relalias}_#{col.colname}" : "#{col.relname}_#{col.colname}"
        end
      else
        col = val[0]
        col.colalias = col.colname
      end
    end
  end
  class << self
    # create below methods to replace col attribute in query
    #  :replace_colname_with_colalias,
    #  :replace_colname_with_fullname,
    #  :replace_colname_with_expr,
    #  :replace_colalias_with_colname,
    #  :replace_colalias_with_fullname,
    #  :replace_colalias_with_expr,
    #  :replace_fullname_with_colname,
    #  :replace_fullname_with_colalias,
    #  :replace_fullname_with_expr,
    #  :replace_expr_with_colname,
    #  :replace_expr_with_colalias,
    #  :replace_expr_with_fullname
    c = %w(colname colalias fullname expr renamed_colname)
    c.product(c).delete_if { |c| c[0] == c[1] }.each do |type|
      define_method("replace_#{type[0]}_with_#{type[1]}") do |query, col|
        eval("col.#{type[0]}.nil? ? query : col.#{type[1]}.nil? ? query : query.gsub(col.#{type[0]},col.#{type[1]})")
      end
    end
  end

  # def RewriteQuery.replace_fullname_with_renamed_colname(query,col)
  #   # from ( table_alias.colname | colname)  to renamed_colname

  #   query.gsub(col.fullname,col.renamed_colname)
  #   # query
  # end
  # def RewriteQuery.remove_tbl_alias(query,col)
  #   query.gsub(col.fullname,col.colname)
  # end
end
