require_relative 'db_connection'

class Node
  attr_accessor :name, :query, :columns, :suspicious_score, :location
  def is_passed?(pkCond, test_id, tuple_type)
    query = "select count(1) as cnt from tuple_node_test_result where #{pkCond} and test_id = #{test_id} and type = '#{tuple_type}' and node_name = '#{@name}'"
    res = DBConn.exec(query)
    # if not in
    cnt = res[0]['cnt'].to_i
    passed = false

    # for missing tuples, if it does no exist in tuple_node_test_result
    # it must be failed
    passed = true if (cnt == 0) && (tuple_type == 'M')
    # for unwanted tuptles if it exists in tuple_node_test_result
    # it must passed
    passed = true if cnt > 0 && (tuple_type == 'U')

    passed
  end
end
