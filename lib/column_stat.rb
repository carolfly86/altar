require 'time'
require_relative 'db_connection'

class Column_Stat
  attr_reader :min, :max, :count, :dist_count
  STATS = {
      "min": {"func": "min(%s)", "type": "text" },
      "max": {"func": "max(%s)", "type": "text" },
      "count": {"func": "count(%s)", "type": "int" },
      "dist_count": {"func": "count(distinct %s)", "type": "int" }
    }

  OPR_SYMBOLS = ['=', '>', '<', '>=', '<=', '<>'].freeze

  def initialize(tbl,predicate = nil)
    @tbl = tbl
    @predicate = predicate
    @query_template = "SELECT %s from #{@tbl}"+( @predicate.to_s.empty? ? '' : " WHERE #{@predicate}")

  end

  def get_stats(col)
    select_list = STATS.map do |stat, info|
                  info[:func] % [col.renamed_colname] +" as #{stat}"
                end.join(', ')
    query = @query_template % [select_list]
    rst = DBConn.exec(query)
    result ={}
    rst[0].each do |key,val|
      result[key] = if col.typcategory == 'D' and %w(min max).include?(key)
                      val
                    else
                      val.to_numeric
                    end
    end
    return result
  end

  def get_distinct_vals(col)
    query = @query_template % ["distinct #{col.renamed_colname}"]
    rst = DBConn.exec(query)
    rst.map do |val|
      col.typcategory == 'N' ? val : "'#{val}'"
    end.join(',')
  end

  def get_count()
    query = @query_template % ["count(1) as cnt"]
    rst = DBConn.exec(query)
    rst[0]['cnt'].to_i
  end

  def compare_two_columns(col1, col2, opr_symbols = OPR_SYMBOLS )
    total_cnt = get_count()
    # opr_symbols = OPR_SYMBOLS
    operator = nil
    opr_symbols.each do |opr|
      query = @query_template % ["count(1) as cnt"]
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