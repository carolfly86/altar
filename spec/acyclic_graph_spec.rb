require 'acyclic_graph'
describe AcyclicGraph do
  before :each do
    @c_graph_edges = [[1, 2], [2, 3], [3, 4], [3, 5], [3, 6], [6, 2]]
    @c_access_path = [[1,2,3,4,5,6]]
    @c_graph = AcyclicGraph.new(@c_graph_edges)

    @ac_graph_edges = [[1, 2],[3, 4]]
    @ac_graph = AcyclicGraph.new(@ac_graph_edges)

  end
  describe '#new' do
    it 'returns a AcyclicGraph object' do
      expect(@c_graph).to be_an_instance_of AcyclicGraph
    end
    it '@edges is does not include [6,2]' do
      expect(@c_graph.edges).not_to include([6,2])
    end
    it '@edges is match def edge' do
      edges = [[1, 2], [2, 3], [3, 4], [3, 5], [3, 6]]
      expect(@c_graph.edges).to match_array(edges)
    end
    it '@access_path is valid' do
      access_path = [[1,2,3,4,5,6]]
      expect(@c_graph.access_paths).to match_array(access_path)
    end
  end

  describe '#add_edge' do
    it 'should add [2,3]' do
        edge = [2, 3]
        @ac_graph.add_edge(edge)
        expect(@ac_graph.edges).to match_array([[1, 2], [3, 4], [2, 3]])
        expect(@ac_graph.access_paths).to match_array([[1,2,3,4]])
    end

    it 'should NOT add [3,1]' do
        edge = [2, 3]
        @ac_graph.add_edge(edge)
        edge = [3, 1]
        @ac_graph.add_edge(edge)
        expect(@ac_graph.edges).to match_array ([[1, 2], [3, 4], [2, 3]])
        expect(@ac_graph.access_paths).to match_array([[1,2,3,4]])

    end
  end
end
