require 'time'
require_relative 'db_connection'

class Column_Stat
  attr_reader :min, :max, :count, :dist_count, :query_template
  STATS = {
      "min": {"func": "min(%s)", "type": "text" },
      "max": {"func": "max(%s)", "type": "text" }
    }
  BOOL_STATS = {
      "bool_or": {"func": "bool_or(%s)", "type": "bool" },
      "bool_and": {"func": "bool_and(%s)", "type": "bool" }
    }
  COUNT_STATS = {
      "count": {"func": "count(1)", "type": "int" },
      "dist_count": {"func": "count(distinct %s)+count(distinct case when %s is null then 1 end)", "type": "int" },
      "is_null_count": {"func": "sum(case when %s is null then 1 else 0 end)", "type": "int" }
  }
  OPR_SYMBOLS = ['=', '>', '<', '>=', '<=', '<>'].freeze

  def initialize(tbl,predicate = nil)
    @tbl = tbl
    @predicate = predicate
    @query_template = "SELECT #TARGET# from #{@tbl}"+( @predicate.to_s.empty? ? '' : " WHERE #{@predicate}")

  end

  def get_stats(col)
    stats = case col.typcategory 
                when 'B' then BOOL_STATS 
                when 'U' then {}
                else  STATS
                end
    stats.merge!(COUNT_STATS)
    # binding.pry if col.typcategory == 'U'
    select_list = stats.map do |stat, info|
                  info[:func] % [col.renamed_colname, col.renamed_colname] +" as #{stat}"
                end.join(', ')
    query = @query_template.gsub('#TARGET#', select_list)
    rst = DBConn.exec(query)
    result ={}
    rst[0].each do |key,val|
      result[key] = if col.is_numeric_type? or COUNT_STATS.keys.include?(key.to_sym)
                      val.nil? ? val : val.to_numeric
                    else
                      val
                    end
    end
    return result
  end

  def get_distinct_vals(col)
    query = @query_template.gsub('#TARGET#', "distinct #{col.renamed_colname}")
    rst = DBConn.exec(query)
    rst.map{|v| v[col.renamed_colname]}
  end

  def get_count()
    query = @query_template.gsub('#TARGET#', "count(1) as cnt")
    rst = DBConn.exec(query)
    rst[0]['cnt'].to_i
  end

  def compare_two_columns(col1, col2, opr_symbols = OPR_SYMBOLS )
    total_cnt = get_count()
    # opr_symbols = OPR_SYMBOLS
    operator = nil
    opr_symbols.each do |opr|
      query = @query_template.gsub('#TARGET#', "count(1) as cnt")
      col_compare_clause = "#{col1.renamed_colname} #{opr} #{col2.renamed_colname}"
      query = query + (@predicate.to_s.empty? ? "WHERE #{col_compare_clause}" : " AND #{col_compare_clause}")
      rst = DBConn.exec(query)
      if rst[0]['cnt'].to_i == total_cnt
        operator = opr
        break
      end
    end
    return operator
  end
end

class Excluded_Col_Stat < Column_Stat
  def initialize(tbl,col)

    excluded_pred = "failed_cols like '\%#{col.renamed_colname};\%'"
    cnt_query = "select count(1) as cnt from #{tbl} where #{excluded_pred}"
    rst = DBConn.exec(cnt_query)
    if rst[0]['cnt'].to_i == 0 
      super(tbl)
    else
      super(tbl,excluded_pred)
    end
    pp "excluded_pred: #{excluded_pred}"
  end
end
