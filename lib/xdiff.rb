require_relative 'db_connection'
require 'hashdiff'
module XDiff
  def self.where_compare(pred_tree1,pred_tree2)
    total_node = pred_tree1.node_count + pred_tree2.node_count
    pred_tree1.to_hash
    pred_tree2.to_hash
    diff_node = HashDiff.diff(pred_tree1.to_hash, pred_tree2.to_hash)
    similarity = 1- diff_node.count.to_f / total_node.to_f
  end

  def self.join_compare(query1,query2)
    parse_tree1 = ParseTree.new(query1)
    parse_tree2 = ParseTree.new(query2)
    join_list1=parse_tree1.join_list
    join_hash1 = self.join_hash(parse_tree1.join_list)
    join_hash2 = self.join_hash(parse_tree2.join_list)
    diff = HashDiff.diff(join_hash1, join_hash2)
    total = [self.join_types_count(join_hash1),self.join_types_count(join_hash2)].max+
            self.join_columns_count(join_hash1) + self.join_columns_count(join_hash2)

    similarity = 1 - diff.count.to_f / total.to_f
  end

  def self.join_hash(join_list)
    hash = Hash.new
    join_list.each do |join|
      id = join['id']
      hash[id] = Hash.new()
      hash[id]['jointype'] = join['jointype']
      columns = JsonPath.on(join['quals'].to_json, '$..COLUMNREF')
      hash[id]['columns'] = columns.map{|c| c['fields'].join('.')}.sort
    end
    return hash
  end

  def self.join_types_count(j_hash)
    return j_hash.count()
  end

  def self.join_columns_count(j_hash)
    total = 0
    j_hash.each do |k,v|
      total = total + v['columns'].count
    end
    return total
  end

end