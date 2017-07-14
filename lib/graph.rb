require 'pp'
class Graph
	attr_reader :edges
	def initialize(edges)
    	# candidates are list of columns of the same data type
    	@edges = edges
  	end

  	def cyclic?(edges=nil)
  		edges ||=@edges
	    m,n = edges.transpose
	    # superme nodes (nodes only visited once)
	    sp_nodes = (m-n) + (n-m)
	    # pp sp_nodes
	    # binding.pry
	    cycle_path_set = edges.select{|kp| (kp & sp_nodes).empty? }
	    return cycle_path_set.count > 1
  	end

  	# only add edge if the new graph is acyclic
  	def add_edge_acyclic(edge)
  		new_edges = [*@edges,edge]
  		# binding.pry
  		unless self.cyclic?(new_edges)
  			@edges << edge
  		end
  	end
end