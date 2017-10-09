from id3 import Id3Estimator, export_graphviz
import numpy as np
from numpy import genfromtxt
import csv
import os
import pdb
import sys
import pygraphviz as pgv
from pprint import pprint
from datetime import datetime
# python id3-training.py '/Users/yguo/RubymineProjects/altar/sql/employees/feature' '/Users/yguo/RubymineProjects/altar/sql/employees/svm-X.out' '/Users/yguo/RubymineProjects/altar/sql/employees/svm-Y.out'
# python id3-training.py dbname script

def is_leaf(graph,node):
	if graph.out_degree(node) == 0:
		return True
	else:
		return False

def is_pure_node(node):
	score_str = get_score_str(node)
	if "/" in score_str:
		return False
	else:
		return True


def get_siblings(graph,node):
	parent = graph.predecessors(node)[0]
	return [n for n in graph.successors(parent) if n!=node ]

def num_of_same_level_nodes(graph,node):
	parent = graph.predecessors(node)[0]
	return len(graph.successors(parent))

def get_score_str(node):
	labels = node.attr['label'].split('\n')
	if len(labels) == 0:
		return ''

	return labels[1].replace('(','').replace(")","")

def get_node_type(node):
	return node.attr['label'].split('\n')[0]


def get_score(node):
	score_str = get_score_str(node)
	if "/" in score_str:
		return int(score_str.split("/")[0])
	else:
		if len(score_str) == 0:
			return 0
		else:
			return int(score_str)

def get_sibling_score(graph,node,label='1'):
	if is_pure_node(node):
		return get_score(node)

	siblings_nodes = get_siblings(graph,node)
	parent = graph.predecessors(node)[0]
	score = get_score(node)
	same_label_siblings = [n for n in siblings_nodes if get_node_type(n) == label]
	return sum([get_score(n) for n in same_label_siblings])+score


def get_sibling_clause(graph,node,label='1'):
	if is_pure_node(node):
		return get_clause(graph,node,'')

	siblings = get_siblings(graph,node)
	parent = graph.predecessors(node)[0]
	col = parent.attr['label'].replace('\n','')
	if num_of_same_level_nodes(graph,node)-1 == len(siblings):
		return get_clause(graph,parent,'')
	else:
		same_label_siblings = [n for n in siblings if get_node_type(n) == label]
		clause_list = []
		for n in same_label_siblings:
			expr = graph.in_edges(n)[0].attr['label']
			clause_list.append("( "+col + " "+ expr +" )")
		cur_clause =  (' OR ').join(clause_list)
		return get_clause(graph,parent,cur_clause)


def get_clause(graph,node,prev_clause=''):
	if len(graph.predecessors(node)) == 0:
		return 'none'
	predecessor = graph.predecessors(node)[0]
	col = predecessor.attr['label'].replace('\n','')
	# print(col)
	expr = graph.in_edges(node)[0].attr['label']
	previous_clause = prev_clause + " AND " if len(prev_clause)>0 else ''
	cur_clause = previous_clause + col + " "+ expr

	if len(graph.predecessors(predecessor))>0:
		cur_clause = get_clause(graph,predecessor, cur_clause)

	return cur_clause

def convert_dot_to_predicate(filename,out_dir):
	B=pgv.AGraph(filename) # create a new graph from file
	# B.draw(out_dir+".png",prog='dot')
	branches = []
	satisfy_score = 0
	for node in B.nodes():
		# print(node)
		# labels = node.attr['label'].split('\n')
		# print(node.attr['label'])

		if is_leaf(B,node) and get_node_type(node) == '1':
			# score_str = labels[1].replace('(','').replace(")","")
			if is_pure_node(node):
				score = get_score(node)
				branch_clause = get_clause(B,node,'')
			else:
				score = get_sibling_score(B,node)
				branch_clause = get_sibling_clause(B,node)


			branches.append("( "+branch_clause+" )")
			satisfy_score = satisfy_score + score

	predicate = (' OR ').join(branches)

	return [satisfy_score,predicate]

start = datetime.now()
cur_path = os.path.dirname(os.path.realpath(__file__))
graph_dir = os.path.join(cur_path,"../../graph/")+ sys.argv[1]+ "/"+sys.argv[2]
feature_file = graph_dir + "-feature"
datatype_file = graph_dir + "-datatype"
x_file = graph_dir + "-x.out"
y_file = graph_dir + "-y.out"
dot_file = graph_dir+ ".dot"

with open(feature_file) as f:
    feature_names = f.readlines()
feature_names = [x.strip() for x in feature_names]

X = np.array(genfromtxt(x_file,dtype=None,delimiter="~").tolist())
y = genfromtxt(y_file,dtype='i4')

if len(feature_names)==1:
	X=X.reshape(-1, 1)

clf = Id3Estimator()
clf.fit(X, y, check_input=True)
end = datetime.now()
delta = end - start

try:
	export_graphviz(clf.tree_, dot_file, feature_names)
except:
    print("Unexpected error:", sys.exc_info()[0])

result = convert_dot_to_predicate(dot_file,graph_dir)

path, filename = os.path.split(graph_dir)
result.insert(0,filename)
result.append(delta.seconds)
pprint(result)

with open(path+"/result.csv", 'a') as f:
	writer = csv.writer(f)
	writer.writerow(result)

# # dot -Tpng out.dot -o out.png