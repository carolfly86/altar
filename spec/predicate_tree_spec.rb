require 'predicate_tree'
require 'pg_query'
require 'pry'
# require_relative 'lib/predicate_tree'
describe PredicateTree do
  before :each do
    root = Tree::TreeNode.new('root', '')
    query1 = "select ms.id as msid, ms.parent_id, ms.is_production, s.id as sid from medidata_studies as ms join studies as s on ms.id = s.external_id where (ms.parent_id = 239 and ms.is_production = 'f') or (ms.id > 3000 and ms.is_production = 'f')"
    parse_tree = PgQuery.parse(query1).parsetree[0]
    wherePT = parse_tree['SELECT']['whereClause']
    fromPT = parse_tree['SELECT']['fromClause']

    @predicateTree = PredicateTree.new('f', true, 0)
    @predicateTree.build_full_pdtree(fromPT[0], wherePT, root)

    root = Tree::TreeNode.new('root', '')
    query2 = "select ms.id as msid, ms.parent_id, ms.is_production, s.id as sid from medidata_studies as ms join studies as s on ms.id = s.external_id where ms.id > 3000 and (ms.parent_id = 239 or ms.is_production = 'f')"
    parse_tree = PgQuery.parse(query2).parsetree[0]
    wherePT = parse_tree['SELECT']['whereClause']
    fromPT = parse_tree['SELECT']['fromClause']

    @predicateTree2 = PredicateTree.new('t', true, 0)
    @predicateTree2.build_full_pdtree(fromPT[0], wherePT, root)

    root = Tree::TreeNode.new('root', '')
    query3 = "select ms.id as msid, ms.parent_id, ms.is_production, s.id as sid from medidata_studies as ms join studies as s on ms.id = s.external_id where ms.id > 3000 and (ms.parent_id = 239 and ms.is_production = 'f')"
    parse_tree = PgQuery.parse(query3).parsetree[0]
    wherePT = parse_tree['SELECT']['whereClause']
    fromPT = parse_tree['SELECT']['fromClause']

    @predicateTree3 = PredicateTree.new('t', true, 0)
    @predicateTree3.build_full_pdtree(fromPT[0], wherePT, root)
  end
  describe '#new' do
    it 'returns a PredicateTree object' do
      expect(@predicateTree).to be_an_instance_of PredicateTree
    end
  end

  describe '#build_full_pdtree' do
    it 'should has 2 branches' do
      expect(@predicateTree.branch_count).to eq 2
      branch1 = @predicateTree.branches[0]
      branch2 = @predicateTree.branches[1]
      expect(branch1.nodes.count).to eq 2
      expect(branch2.nodes.count).to eq 2

      expect(@predicateTree2.branch_count).to eq 2
      branch1 = @predicateTree2.branches[0]
      branch2 = @predicateTree2.branches[1]
      expect(branch1.nodes.count).to eq 2
      expect(branch2.nodes.count).to eq 2

      expect(@predicateTree3.branch_count).to eq 1
      branch1 = @predicateTree3.branches[0]
      expect(branch1.nodes.count).to eq 3
    end

    it 'should has 4 columns' do
      expect(@predicateTree.all_columns.count).to eq 3
    end

    it 'should has 4 nodes' do
      expect(@predicateTree.nodes.count).to eq 4
    end
  end
end
