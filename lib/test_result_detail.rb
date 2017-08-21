require_relative 'db_connection'
class Test_Result_Detail
  attr_accessor :branch_name, :node_name, :query, :location, :columns, :suspicious_score
  
  # calculate the percentage of missing rows and unwanted rows
  def get_test_row_distribution
    query = "select count(1),type from tuple_node_test_result where branch_name='"+branch_name+"' and node_name='"+node_name+"' group by type;"
    rst = DBConn.exec(query)
    rst_hash = {}
    rst_hash['total'] = 0
    rst.each do |r|
      rst_hash[r['type']] = r['count'].to_i
      rst_hash['total'] = 0+r['count'].to_i
    end
    rst_hash
  end
end