import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.cross_validation import cross_val_score
from sklearn.cross_validation import ShuffleSplit
from scipy.sparse import csr_matrix
from sklearn import cross_validation
from sklearn.feature_selection import VarianceThreshold
from sklearn import preprocessing
from sklearn import linear_model
from sklearn.neighbors import KNeighborsRegressor
from sklearn import tree
from scipy import sparse
import csv

data = pd.read_csv('Kantar_pt_compact_cost_without0.csv',header=None,names=["Cost_per30","DOW","Hour","Group","Program","Channel"],skip_blank_lines=True,nrows=1000000)
y = data['Cost_per30']
x = data[['DOW','Hour','Group','Program','Channel']]
dow = pd.get_dummies(x['DOW'])
hour = pd.get_dummies(x['Hour'])
group = pd.get_dummies(x['Group'])
program = pd.get_dummies(x['Program'])
channel = pd.get_dummies(x['Channel'])
X = pd.concat([dow,hour,group,program,channel], axis=1)

############## Compare different method and select one ##################
### Random forest ###
n_fold = 10
scoremean = []
scoremedian = []
for n in range(n_fold):
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.1, random_state=n*1000)
	clf = RandomForestRegressor(n_estimators=20).fit(X_train, y_train)
	pred = clf.predict(X_test)
	diff = abs(pred-y_test)/y_test
	mean = np.mean(diff)
	scoremean.append(mean)
	median = np.median(diff)
	scoremedian.append(median)
np.mean(scoremean)
np.mean(scoremedian)


### Decision Tree Regression ###
n_fold = 10
scoremeantree = []
scoremediantree = []
for n in range(n_fold):
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.1, random_state=n*1000)
  clftree = tree.DecisionTreeRegressor().fit(X_train,y_train)
  predtree = clftree.predict(X_test)
  difftree = abs(predtree-y_test)/y_test
  mean = np.mean(difftree)
	scoremeantree.append(mean)
	median = np.median(difftree)
	scoremediantree.append(median)
np.mean(scoremeantree)
np.mean(scoremediantree)


### K-nn Regression ###
# k=10
scoremeanknn = []
scoremediantknn = []
for n in range(n_fold):
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.1, random_state=n*1000)
  neigh = KNeighborsRegressor(n_neighbors=10)
  neigh.fit(X_train,y_train)
  predknn = neigh.predict(X_test)
  diffknn = abs(predknn-y_test)/y_test
  mean = np.mean(diffknn)
	scoremeanknn.append(mean)
	median = np.median(diffknn)
	scoremediantknn.append(median)
np.mean(scoremeanknn)
np.mean(scoremediantknn)

# k = 50 
scoremeanknn = []
scoremediantknn = []
for n in range(n_fold):
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.1, random_state=n*1000)
  neigh = KNeighborsRegressor(n_neighbors=50)
  neigh.fit(X_train,y_train)
  predknn = neigh.predict(X_test)
  diffknn = abs(predknn-y_test)/y_test
  mean = np.mean(diffknn)
	scoremeanknn.append(mean)
	median = np.median(diffknn)
	scoremediantknn.append(median)
np.mean(scoremeanknn)
np.mean(scoremediantknn)

### Lasso Regression ###
scoremeanlas = []
scoremediantlas = []
for n in range(n_fold):
	X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.1, random_state=n*1000)
  clflasso = linear_model.Lasso(alpha = 0.1)
  clflasso.fit(X_train,y_train)
  predlasso = clflasso.predict(X_test)
  difflasso = abs(predlasso-y_test)/y_test
  mean = np.mean(difflasso)
	scoremeanlas.append(mean)
	median = np.median(difflasso)
	scoremediantlas.append(median)
np.mean(scoremeanlas)
np.mean(scoremediantlas)
