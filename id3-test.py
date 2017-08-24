from id3 import Id3Estimator, export_graphviz
import numpy as np
from numpy import genfromtxt
import pprint
import pdb
# pdb.set_trace()
# feature_names = ["salaries_emp_no","salaries_salary", "salaries_from_date", "salaries_to_date"]
# # feature_names = ["id"]
# X = genfromtxt('/Users/yguo/RubymineProjects/altar/sql/employees/svm-X.out')
# y= genfromtxt('/Users/yguo/RubymineProjects/altar/sql/employees/svm-y.out')
feature_names = ["age",
                 "gender",
                 "sector",
                 "degree"]

X = np.array([[45, "male", "private", "m"],
              [50, "female", "private", "m"],
              [61, "other", "public", "b"],
              [40, "male", "private", "none"],
              [34, "female", "private", "none"],
              [33, "male", "public", "none"],
              [43, "other", "private", "m"],
              [35, "male", "private", "m"],
              [34, "female", "private", "m"],
              [35, "male", "public", "m"],
              [34, "other", "public", "m"],
              [34, "other", "public", "b"],
              [34, "female", "public", "b"],
              [34, "male", "public", "b"],
              [34, "female", "private", "b"],
              [34, "male", "private", "b"],
              [34, "other", "private", "b"]])

y = np.array(["(30k,38k)",
              "(30k,38k)",
              "(30k,38k)",
              "(13k,15k)",
              "(13k,15k)",
              "(13k,15k)",
              "(23k,30k)",
              "(23k,30k)",
              "(23k,30k)",
              "(15k,23k)",
              "(15k,23k)",
              "(15k,23k)",
              "(15k,23k)",
              "(15k,23k)",
              "(23k,30k)",
              "(23k,30k)",
              "(23k,30k)"])

clf = Id3Estimator()
clf.fit(X, y, check_input=True)


# clf = Id3Estimator()
# clf.fit(X, y, check_input=True)

# pp = pprint.PrettyPrinter(indent=4)
# pp.pprint(clf.tree_)
export_graphviz(clf.tree_, "out.dot", feature_names)

# dot -Tpng out.dot -o out.png