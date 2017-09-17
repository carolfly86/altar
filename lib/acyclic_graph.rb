require 'pp'
require 'pry'
class AcyclicGraph
	attr_reader :edges, :access_paths
	def initialize(edges)
    	# candidates are list of columns of the same data type
    	# @edges = edges
      @edges =[]
      build_access_path(edges)
  	end

  def build_access_path(edges)
    @access_paths =[]
    edges.each do |e|
      # pp e
      add_edge(e)
    end
  end

  	# only add edge if the new graph is acyclic
	def add_edge(edge)
    # pp @access_paths
    # pp edge
    added = false
    return added if @edges.include?(edge)
    visited_path = @access_paths.each_with_index.select{|p,idx|  !(p & edge).empty? }
    if visited_path.count == 2
      # if the two vertexes are visited in 2 paths
      # We'll combine the 2 paths
      new_path =[]
      to_del_idx =[]
      visited_path.each do |p|
        idx  = p[1]
        v_path = p[0]
        new_path = new_path + v_path
        to_del_idx << idx
      end
      @access_paths.delete_if.with_index{|p,idx| to_del_idx.include?(idx)}
      @access_paths << new_path
      @edges << edge unless @edges.include?(edge)
      added = true
    elsif visited_path.count == 1
      v_path = visited_path[0][0]
      # binding.pry
      if (v_path & edge).count() == 2
        # binding.pry
        # add edge only when it does not create cycle
        puts "Refuse to add edge #{edge.to_s} as it create cycle"
      else
        # v_path = visited_path[0][1]
        vertext = edge - v_path
        v_path  = v_path + vertext
        idx = visited_path[0][1]
        @access_paths.delete_at(idx)
        @access_paths << v_path
        @edges << edge unless @edges.include?(edge)
        added = true
      end
    elsif visited_path.count == 0
      @access_paths << edge
      @edges << edge unless @edges.include?(edge)
      added = true
    end
    # puts "added is #{added}"

    return added
	end
end