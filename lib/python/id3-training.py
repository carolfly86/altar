from id3 import Id3Estimator, export_graphviz
import numpy as np
from numpy import genfromtxt
import csv 
import os 
import pdb
import sys
import pygraphviz as pgv
# python id3-training.py '/Users/yguo/RubymineProjects/altar/sql/employees/feature' '/Users/yguo/RubymineProjects/altar/sql/employees/svm-X.out' '/Users/yguo/RubymineProjects/altar/sql/employees/svm-Y.out'
# python id3-training.py dbname script

def is_leaf(graph,node):
	if graph.out_degree(node) == 0:
		return 1
	else:
		return 0

def get_clause(graph,node,prev_clause=''):
	predecessor = graph.predecessors(node)[0]
	col = predecessor.attr['label'].replace('\n','')
	print(col)
	expr = graph.in_edges(node)[0].attr['label']
	previous_clause = prev_clause + " AND " if len(prev_clause)>0 else ''

	if len(graph.predecessors(predecessor))>0:
		cur_clause = previous_clause + get_clause(graph,node, cur_clause)
	else:
		cur_clause = previous_clause + col + " "+ expr
	return cur_clause

def convert_dot_to_predicate(filename,out_dir):
	B=pgv.AGraph(filename) # create a new graph from file
	B.draw(out_dir+".png",prog='dot')
	branches = []
	satisfy_score = 0
	for node in B.nodes():
		print(node)
		labels = node.attr['label'].split('\n')
		print(node.attr['label'])
		if is_leaf(B,node) and labels[0] == '1.0':
			branches.append(get_clause(B,node,''))
			satisfy_score = satisfy_score + int(labels[1].replace('(','').replace(")",""))

	predicate = (' OR ').join(branches)

	print('predicate')
	print(predicate)
	print(satisfy_score)
	path, filename = os.path.split(out_dir)
	print(path)
	print(filename)
	with open(path+"/result.csv", 'a') as f:
		writer = csv.writer(f)
		writer.writerow([filename,satisfy_score,predicate])


graph_dir = "/Users/yguo/RubymineProjects/altar/graph/"+ sys.argv[1]+ "/"+sys.argv[2]
feature_file = graph_dir + "-feature"
x_file = graph_dir + "-x.out"
y_file = graph_dir + "-y.out"
dot_file = graph_dir+ ".dot"

print(graph_dir)
with open(feature_file) as f:
    feature_names = f.readlines()
feature_names = [x.strip() for x in feature_names]

X = genfromtxt(x_file)
y= genfromtxt(y_file)

clf = Id3Estimator()
clf.fit(X, y, check_input=True)

# pp = pprint.PrettyPrinter(indent=4)
export_graphviz(clf.tree_, dot_file, feature_names)

convert_dot_to_predicate(dot_file,graph_dir)

# dot -Tpng out.dot -o out.png