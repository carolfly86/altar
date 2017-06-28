from id3 import Id3Estimator, export_graphviz
import numpy as np
from numpy import genfromtxt
feature_names = ["id","parent_id"]
# feature_names = ["id"]
X = genfromtxt('/Users/yguo/RubymineProjects/altar/sql/balance/svm-X.out')
y= genfromtxt('/Users/yguo/RubymineProjects/altar/sql/balance/svm-y.out')


clf = Id3Estimator()
clf.fit(X, y, check_input=True)

export_graphviz(clf.tree_, "out.dot", feature_names)