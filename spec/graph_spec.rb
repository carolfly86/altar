require 'graph'
describe Graph do
  before :each do
    @c_graph_edges = [[1, 2], [2, 3], [3, 4], [3, 5], [3, 6], [6, 2]]
    @c_graph = Graph.new(@c_graph_edges)

    @ac_graph_edges = [[1, 2], [2, 3]]
    @ac_graph = Graph.new(@ac_graph_edges)

  end
  describe '#new' do
    it 'returns a Branch object' do
      expect(@c_graph).to be_an_instance_of Graph
    end
    it '@edges is c_graph_edges' do
        expect(@c_graph.edges).to eq(@c_graph_edges)
    end
  end
  describe '#cyclic?' do
    context '@c_graph' do
        it 'should returns true' do
            expect(@c_graph.cyclic?).to eq(true)
        end
    end
    context '@ac_graph' do
        it 'should returns false' do
            expect(@ac_graph.cyclic?).to eq(false)
        end
    end
  end
  describe '#add_edge_acyclic?' do
    it 'should add [3,4]' do
        edge = [3,4]
        @ac_graph.add_edge_acyclic(edge)
        expect(@ac_graph.edges).to eq([[1, 2], [2, 3], [3,4]])
    end

    it 'should NOT add [3,1]' do
        edge = [3,1]
        @ac_graph.add_edge_acyclic(edge)
        expect(@ac_graph.edges).to eq ([[1, 2], [2, 3]])
    end
  end
end
