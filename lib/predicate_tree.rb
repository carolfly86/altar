require 'rubytree'
require_relative 'reverse_parsetree'

class PredicateTree
  # def initialize(support,behavior)
  # end
  # attr_accessor :count, :content
  attr_reader :node_count, :pdtree, :branches, :branch_count, :nodes, :all_columns
  def initialize(type, is_new, test_id)
    @node_count = 0
    @branch_count = 0
    # @wherePT=wherePT
    @type = type

    # @rootNode=Tree::TreeNode.new('root', '')
    @nqTblName = 'node_query_mapping'
    node_query_mapping_create if is_new
    @test_id = test_id
    @branches = []
    @nodes = []
    @all_columns = []
    # pdtree_construct(wherePT, @pdtree )
    # curNode = Tree::TreeNode.new(nodeName, '')
  end

  def build_full_pdtree(fromPT, wherePT, root)
    # relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
    # pp relNames
    # root.print_tree
    @pdtree = pdtree_construct(fromPT, wherePT, root, 0)
    if @pdtree.node_height == 0
      root << @pdtree
      @pdtree = root
    end
    # @pdtree.print_tree
    @pdtree.children.each do |subtree|
      unless subtree.name =~ /^PH*/
        branch = add_branch(subtree)
        @pdtree << branch
      end
    end

    node_query_mapping_insert
  end

  def pdtree_construct(fromPT, wherePT, curNode, depth = 0)
    logicOpr = wherePT.keys[0].to_s
    lexpr = wherePT[logicOpr]['lexpr']
    rexpr = wherePT[logicOpr]['rexpr']
    depth += 1

    # puts "depth: #{depth}"
    # p logicOpr
    if logicOpr == 'AEXPR AND'
      # pp 'lexpr'
      # pp lexpr
      # pp 'rexpr'
      # pp rexpr
      lexprNode = pdtree_construct(fromPT, lexpr, curNode, depth)
      rexprNode = pdtree_construct(fromPT, rexpr, curNode, depth)
      # p 'c'
      # curNode.print_tree
      # p 'l'
      # lexprNode.print_tree
      # p 'r'
      # rexprNode.print_tree
      # p lexprNode.breadth
      # p rexprNode.breadth
      # p lexprNode.out_degree
      # p rexprNode.out_degree
      # pp rexprNode
      if lexprNode.out_degree > 1 || rexprNode.out_degree > 1
        # puts 'reform'
        structure_reform(lexprNode, rexprNode, curNode)
        # puts 'after reform'
        # p 'c'
        # curNode.print_tree
        # p 'l'
        # lexprNode.print_tree
        # p 'r'
        # rexprNode.print_tree
        return curNode
      else
        append_to_end(lexprNode, rexprNode)
        # append_to_end(curNode,lexprNode)
        # return curNode
        # puts 'after'
        # lexprNode.print_tree
        # puts "current depth #{depth}"
        # p '-------------'
        if depth == 1
          # lexprNode = add_branch(lexprNode)
          curNode << lexprNode unless curNode == lexprNode
          return curNode
        else
          return lexprNode
        end
        # curNode<<lexprNode unless curNode==lexprNode
      end
    # or operator are tested as a whole
    elsif logicOpr == 'AEXPR OR'
      # puts 'OR'
      # pp 'lexpr'
      # pp lexpr
      # pp 'rexpr'
      # pp rexpr
      # puts 'before'
      # p 'c'
      # curNode.print_tree
      # p 'l'
      # lexprNode.print_tree unless lexprNode.nil?
      # p 'r'
      # rexprNode.print_tree unless rexprNode.nil?
      lexprNode = pdtree_construct(fromPT, lexpr, curNode, depth)
      rexprNode = pdtree_construct(fromPT, rexpr, curNode, depth)
      # puts 'after'
      # p 'c'
      # curNode.print_tree
      # p 'l'
      # lexprNode.print_tree
      # p 'r'
      # rexprNode.print_tree

      # puts "lroot: #{lexprNode.root.name}"
      # puts "rroot: #{rexprNode.root.name}"
        #
      # lexprNode = add_branch(lexprNode)
      curNode << lexprNode if lexprNode.root.name != 'root'
      # end #unless curNode==lexprNode
      # if rexprNode.root.name != 'root'
      #   rexprNode = add_branch(rexprNode)
      curNode << rexprNode if rexprNode.root.name != 'root'
      # end
      # curNode<<rexprNode unless curNode==rexprNode
      # p 'l after'
      # lexprNode.print_tree
      # p 'curNode after'
      # curNode.print_tree
      # puts "current depth #{depth}"
      # p '-------------'

      return curNode
    else
      @node_count+= 1
      nodeName = "N#{@node_count}"
      h = {}
      h['query'] = ReverseParseTree.whereClauseConst(wherePT)
      h['location'] = logicOpr == 'NULLTEST' ? wherePT[logicOpr]['arg']['COLUMNREF']['location'] : wherePT[logicOpr]['location']
      h['columns'] = []
      cols = ReverseParseTree.columnsInPredicate(wherePT)
      # convert string to Column object
      cols.each do |col|
        column = Column.new
        column.colname = col.count > 1 ? col[1] : col[0]
        column.relalias = col.count > 1 ? col[0] : nil
        column.updateRelname(fromPT)
        h['columns'] << column
        @all_columns << column unless @all_columns.include?(column)
        # end
      end
      h['suspicious_score'] = 0
      # pp h
      curNode = Tree::TreeNode.new(nodeName, h)
      # p @nqTblName

      @nodes << transfer_child_to_node(curNode)
      # node_query_mapping_insert( nodeName,h['query'],h['location'],h['columns'],h['suspicious_score'])
      return curNode
    end
    # pp 'result'
    # curNode.print_tree
  end

  def add_branch(subtree)
    phName = "PH#{@branch_count}"
    ph = Tree::TreeNode.new(phName, '')
    br = Branch.new
    br.name = phName
    br.nodes = []
    @branches << br

    br.nodes << transfer_child_to_node(subtree)

    currentNode = subtree
    while currentNode.has_children?
      currentNode.children.each do |child|
        br.nodes << transfer_child_to_node(child)
      end
      currentNode = currentNode.children[0]
    end

    @branch_count+= 1

    ph = Tree::TreeNode.new(phName, '')
    ph << subtree
    ph
  end

  def get_all_columns
    columns = []
    @branches.each do |br|
      br.nodes.each do |nd|
        # pp 'get_all_columns'
        # pp nd
        columns + nd.columns
      end
    end
    columns
  end

  # def node_query_mapping_insert( nodeName,query,loc,columns, suspicious_score)
  def node_query_mapping_insert
    branches.each do |br|
      br.nodes.each do |nd|
        nodeName = nd.name
        # columnsArray=nd.columns.map{|c| "'"+(c.relalias.nil? ? '' : c.relalias+'.')+c.colname+"'"}.join(',')
        columnsArray = nd.columns.map { |c| "'" + c.relname + '.' + c.colname + "'" }.join(',')
        query = "INSERT INTO #{@nqTblName} values (#{@test_id} ,'#{br.name}','#{nd.name}', '#{nd.query.gsub(/'/, '\'\'')}',#{nd.location}, ARRAY[#{columnsArray}], #{nd.suspicious_score} , '#{@type}' )"
        # pp query
        DBConn.exec(query)
      end
    end
  end

  def node_query_mapping_upd(branch_name, node_name, query)
    query = "UPDATE #{@nqTblName} SET #{query} where test_id=#{@test_id} and branch_name = '#{branch_name}' and node_name = '#{node_name}'"
    # pp query
    DBConn.exec(query)
  end

  def node_query_mapping_create
    query = "DROP TABLE if exists #{@nqTblName}; CREATE TABLE #{@nqTblName} (test_id int, branch_name varchar(30), node_name varchar(30), query text, location int, columns text[], suspicious_score int, type varchar(1));"
    DBConn.exec(query)
  end

  # append child to the end of tree
  def append_to_end(tree, child)
    deepChild = find_deepest_child(tree)
    deepChild << child unless deepChild == child
    # p 'deepChild'
    # deepChild.print_tree
    # p 'tree'
    # tree.print_tree
    # tree
  end

  def find_deepest_child(tree)
    depth = 0
    dpChild = tree.root
    tree.each_leaf do |node|
      # p 'node'
      # node.print_tree
      dpChild = node if node.node_depth >depth
    end
    dpChild
  end

  # tree structure does not support multi parents
  # in order to present (a or b) and (c or d)
  # we need to reform the structure to
  # (a and c) or (a and d) or (b and c) or (b and d)
  def structure_reform(lNode, rNode, curNode)
    # reset branches for reform
    @branches = []
    @branch_count = 0
    # puts 'before cleanup'
    # lNode.print_tree
    # rNode.print_tree
    # rNode.print_tree
    # remove_PH_node(lNode)
    # remove_PH_node(rNode)
    # remove_PH_node(curNode)
    # puts 'after cleanup'
    # lNode.print_tree
    # rNode.print_tree
    # rNode.print_tree
    lChildren = lNode.children.count == 0 ? [lNode] : lNode.children
    rChildren = rNode.children.count == 0 ? [rNode] : rNode.children
    count = 0
    # p 'lnode'
    # pp lChildren
    # p 'rnode'
    lChildren.each do |ln|
      rChildren.each do |rn|
        # p '--------------'
        # p 'ln'
        # ln.print_tree
        # p 'rn'
        # rn.print_tree

        # phName="PH#{@branch_count}"
        # ph =Tree::TreeNode.new(phName, '')
        ln_append = ln.detached_subtree_copy
        # p 'ln_append before'
        # ln_append.print_tree
        append_to_end(ln_append, rn)
        # p 'ln_append'
        # ln_append.print_tree
        # ph<<ln_append #unless curNode==newNode
        ln_append = add_branch(ln_append)
        # p 'ln_append after'
        # ln_append.print_tree
        curNode << ln_append
        # p 'ph'
        # ph.print_tree
        # p 'curNode'
        # curNode.print_tree
      end
    end
  end

  # # remove any PH child in tree
  # def remove_PH_node(tree)
  #   tree.children.each do |child|
  #     if child.name =~/^PH/
  #       tree.remove!(child)
  #       child.children.each do |gc|
  #         tree << gc
  #       end
  #     end
  #   end
  # end
  def transfer_child_to_node(child)
    nd = Node.new
      nd.name = child.name
      nd.query = child.content['query']
      nd.location = child.content['location']
      nd.columns = child.content['columns']
      nd.suspicious_score = child.content['suspicious_score']
      nd
  end

  def predicateArrayGen(pdtree)
    predicateArry = []
    pdtree.children.each do |branch|
       currentNode = branch
       while currentNode.has_children?
         currentNode = currentNode.children[0]
         loc = currentNode.content['location']
         suspicious_score = currentNode.content['suspicious_score']
         element = predicateArry.find_hash('name', currentNode.name)
         node = {}
         if element.nil?
           node['name'] = currentNode.name
           node.merge!(currentNode.content)
           predicateArry << node
         else
           element['suspicious_score'] = element['suspicious_score'] + suspicious_score
         end
       end
    end
    predicateArry
  end

end
