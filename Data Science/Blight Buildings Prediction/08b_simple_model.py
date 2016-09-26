#pip3 install --user --install-option="--prefix=" scikit-learn
# https://github.com/savarin/pyconuk-introtutorial
# http://manishamde.github.io/blog/2013/03/07/pandas-and-python-top-10/#numpy

import numpy as np
import pandas as pd

# numpy is on arrays:
modeldata = np.genfromtxt('data/modeldata.csv',delimiter=',',names=True)

# pandas will provide a dataframe:
df = pd.read_csv('data/modeldata.csv',header=0)
dfIDs = pd.DataFrame.from_records(df,columns=['building','ID'])
df = df.drop(['building','lon','lat'], axis=1)
df.info()

from sklearn.cross_validation import train_test_split
#train, test = train_test_split(df, test_size = 0.2)

train = df.query('group!=1').drop(['group'], axis=1)
test = df.query('group==1').drop(['group'], axis=1)

train_data = train.values
test_data = test.values

from sklearn.linear_model import LinearRegression
from sklearn.linear_model import LogisticRegression

lm = LinearRegression(fit_intercept=True, normalize=False)
lm = lm.fit(train_data[0:,1].reshape(-1,1), train_data[0:,0])
prob = pd.Series(lm.predict(test_data[0:,1].reshape(-1,1)))
pred = prob.map(lambda x:  x > 0.59 and 1 or 0)
validate = pd.Series(test.label.values == pred)
print("linear: label ~ count   accuracy:")
print(validate.sum()/validate.size)
#0.75941339675

lm = LinearRegression(fit_intercept=True, normalize=False)
lm = lm.fit(train_data[0:,1:9], train_data[0:,0])
prob = pd.Series(lm.predict(test_data[0:,1:9]))
pred = prob.map(lambda x:  x > 0.586 and 1 or 0)
validate = pd.Series(test.label.values == pred)
print("linear: label ~ count + keywords   accuracy:")
print(validate.sum()/validate.size)
#0.759809750297 => very small improvement


### logistic regression does not work
from sklearn.linear_model import LogisticRegression
logm = LogisticRegression(fit_intercept=True)
logm = logm.fit(train_data[0:,1].reshape(-1,1), train_data[0:,0])
pred = logm.predict(test_data[0:,1].reshape(-1,1))
validate = pd.Series(test.label.values == pred)
print("logistic: label ~ count   accuracy:")
print(validate.sum()/pred.size)
#0.575137686861
logm = LogisticRegression(fit_intercept=True)
logm = logm.fit(train_data[0:,1:9], train_data[0:,0])
pred = logm.predict(test_data[0:,1:9])
validate = pd.Series(test.label.values == pred)
print("logistic: label ~ count + keywords   accuracy:")
print(validate.sum()/validate.size)
#0.609756097561
logm = LogisticRegression(fit_intercept=True)
logm = logm.fit(train_data[0:,[1,19,20]], train_data[0:,0])
pred = logm.predict(test_data[0:,[1,19,20]])
validate = pd.Series(test.label.values == pred)
print("logistic: label ~ count + callcount + crimecount   accuracy:")
print(validate.sum()/validate.size)
#0.621557828482
logm = LogisticRegression(fit_intercept=False)
logm = logm.fit(train_data[0:,[1,19,20]], train_data[0:,0])
pred = logm.predict(test_data[0:,[1,19,20]])
validate = pd.Series(test.label.values == pred)
print("logistic: label ~ count + callcount + crimecount   accuracy:")
print(validate.sum()/validate.size)
#0.621557828482


import sklearn.metrics as metrics
metrics.accuracy_score(test.label,pred)
#0.6097560975609756
metrics.roc_auc_score(test.label,pred)
#0.60621768080159055


from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

clf = LinearDiscriminantAnalysis()
clf=clf.fit(train_data[0:,1].reshape(-1,1), train_data[0:,0])
pred = clf.predict(test_data[0:,1].reshape(-1,1))
print("lda: label ~ count   accuracy:")
clf.score(test_data[0:,1].reshape(-1,1),test.label)
#0.57513768686073963
clf = LinearDiscriminantAnalysis()
clf=clf.fit(train_data[0:,[1,19,20]], train_data[0:,0])
pred = clf.predict(test_data[0:,[1,19,20]])
print("lda: label ~ count + callcount + crimecount   accuracy:")
clf.score(test_data[0:,[2,13,14]],test.label)
#0.75735590487706572















