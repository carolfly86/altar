# ..... Example starts.
require 'tree' # Load the library
require 'pry'
# ..... Create the root node first.  Note that every node has a name and an optional content payload.
root_node = Tree::TreeNode.new('ROOT', 'Root Content')
root_node.print_tree

# ..... Now insert the child nodes.  Note that you can "chain" the child insertions for a given path to any depth.
root_node << Tree::TreeNode.new('CHILD1', 'Child1 Content') << Tree::TreeNode.new('GRANDCHILD1', 'GrandChild1 Content')
root_node << Tree::TreeNode.new('CHILD2', 'Child2 Content')

# ..... Lets print the representation to stdout.  This is primarily used for debugging purposes.
# ..... Lets directly access children and grandchildren of the root.  The can be "chained" for a given path to any depth.
child1       = root_node['CHILD1']
grand_child1 = root_node['CHILD1']['GRANDCHILD1']
child3 = Tree::TreeNode.new('CHILD3', 'Child3 Content')
# grand_child1<<child3
test = root_node.detached_subtree_copy
test << child3
p root_node.breadth
p 'root'
root_node.print_tree
p'test'
test.print_tree
# ..... Now lets retrieve siblings of the current node as an array.
siblings_of_child1 = child1.siblings

# ..... Lets retrieve immediate children of the root node as an array.
children_of_root = root_node.children

# ..... Retrieve the parent of a node.
parent = child1.parent

# ..... This is a depth-first and L-to-R pre-ordered traversal.
root_node.each { |node| node.content.reverse }

# ..... Lets remove a child node from the root node.
root_node.remove!(child1)
