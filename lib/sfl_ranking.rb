module SFL_Ranking
  def self.ranking_update(name, result)
    # update result
    if result.values.uniq.length == 1
      # all ms_scores are same, not able to rank
      query = "update tarantular_result set #{name}_rank = 0"
      DBConn.exec(query)
    else
      i = 1
      pp result
      result.sort_by { |_key, value| value }.to_h.each do |k, _v|
        # puts k
        # puts v
        query = "update tarantular_result set #{name}_rank = #{i} where bn_name = '#{k}'"
        puts query
        DBConn.exec(query)
        i += 1
      end
    end
  end

  def self.tie_check(name)
    query = "select count(1) as cnt from (select distinct #{name}_score from tarantular_result) as t;"
    res = DBConn.exec(query)
    if res[0]['cnt'].to_i == 1
      query = "update tarantular_result SET #{name}_rank = 0"
       end
  end
end
