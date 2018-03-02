require_relative 'db_connection'
require 'hashdiff'
module XDiff
  def self.compare(pred_tree1,pred_tree2)
    total_node = pred_tree1.node_count + pred_tree2.node_count
    pred_tree1.to_hash
    pred_tree2.to_hash
    diff_node = HashDiff.diff(pred_tree1.to_hash, pred_tree2.to_hash)
    similarity = 1- diff_node.count.to_f / total_node.to_f
  end
end