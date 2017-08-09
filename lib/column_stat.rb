require_relative 'db_connection'

class Column_Stat
  attr_reader :min, :max, :count, :dist_count
  STATS = {
      "min": {"func": "min(%s)", "type": "text" },
      "max": {"func": "max(%s)", "type": "text" },
      "count": {"func": "count(%s)", "type": "int" },
      "dist_count": {"func": "count(distinct %s)", "type": "int" }
    }
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
    return rst[0].to_hash
  end
  def get_distinct_vals(col)
    query = @query_template % ["distinct #{col.renamed_colname}"]
    rst = DBConn.exec(query)
    rst.map do |val|
      col.typcategory == 'N' ? val : "'#{val}'"
    end.join(',')
  end
end