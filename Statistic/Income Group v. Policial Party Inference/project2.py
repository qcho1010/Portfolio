# -*- coding: utf-8 -*-
"""
Created on Sat Jan 30 16:42:59 2016

@author: Kyu
"""

from pandas import Series, DataFrame
import matplotlib.pylab as plt
from sklearn.cross_validation import train_test_split
from sklearn.metrics import classification_report
import pandas as pd
import numpy as np
from sklearn import preprocessing

data = pd.read_csv('data.csv', low_memory=False)

data.prevote_regpty.value_counts() # What political party are you registered
data.interest_whovote2008.value_counts() # who did you vote 2008
data.incgroup_prepost.value_counts()
data.dem_marital.value_counts() # Marital status
data.dem_empstatus_1digitfinal.value_counts() # empl status based
data.dem_raceeth.value_counts() # race and ethnicity group
data.dem_parents.value_counts() # Native status of parents
data.orientn_rgay.value_counts() # Sexual orientation 

# 7
data.health_2010hcr_x.value_counts() # Support 2010 health care law
data.tea_supp_x.value_counts() # Tea Party support

# 6
data.finance_finfam.value_counts() # living with how many family members

# 5
data.ecblame_pres.value_counts() # How much is President to blame for poor econ conditions
data.ecblame_fmpr.value_counts() # How much former President to blame for poor econ conds
data.ecblame_dem.value_counts() # How much Dems in Congress to blame for poor econ conds
data.ecblame_rep.value_counts() # How much Reps in Congress to blame for poor econ conds

data.finance_finpast_x.value_counts() # Better or worse off than 1 year ago
data.finance_finnext_x.value_counts() # Better or worse off 1 year from now

data.effic_undstd.value_counts() # Good understanding of political issues
data.effic_carestd.value_counts() # Publ officials don't care what people think

data.econ_ecpast_x.value_counts() # U.S. economy better or worse than 1 year ago
data.econ_ecnext_x.value_counts() # U.S. economy better or worse 1 year from now
data.econ_unpast_x.value_counts() # Unemployment better or worse than 1 year ago

data.interest_attention.value_counts() # how much do you care about the gov
data.ineq_incgap_x.value_counts() #  Income gap size compared to 20 years ago
data.gun_importance.value_counts() # Importance of gun access issue
data.dem_eduspgroup.value_counts() # level of highest education
data.happ_lifesatisf.value_counts() # How satisfied is R with life

# 4
data.presapp_job_x.value_counts() # dApproval of President handling of job
data.presapp_econ_x.value_counts() # Approval of President handling economy
data.presapp_foreign_x.value_counts() #  Approval of President handling foreign relations
data.presapp_health_x.value_counts() #  Approval of President handling health care
data.presapp_war_x.value_counts() # Approval of President handling war in Afghanistan

data.immig_policy.value_counts() # U.S. government policy toward unauthorized immigrants
data.dem2_numchild.value_counts() # Total Number of children in HH

# 3
data.fedspend_ss.value_counts() # Federal Budget Spending: Social Security
data.fedspend_schools.value_counts() # Federal Budget Spending: public schools
data.fedspend_scitech.value_counts() # Federal Budget Spending: science and technology
data.fedspend_crime.value_counts() #  Federal Budget Spending: dealing with crime
data.fedspend_welfare.value_counts() # Federal Budget Spending: welfare programs
data.fedspend_child.value_counts() # Federal Budget Spending: child care
data.fedspend_poor.value_counts() # Federal Budget Spending: aid to the poor
data.fedspend_enviro.value_counts() # Federal Budget Spending: protecting the environment

data.campfin_limcorp.value_counts() # Should gov be able to limit corporate contributions
data.campfin_banads.value_counts() # Ban corporate/union ads for candidates

data.presapp_track.value_counts() # presapp_track: Are things in the country on right track
data.libcpre_choose.value_counts() # Liberal/conservative self-placement
data.divgov_splitgov.value_counts() # Party Control or split government

# 2
data.health_insured.value_counts() # Does R have health insurance
data.dem_veteran.value_counts() # ever served on active duty in Armed Forces
data.owngun_owngun.value_counts() # own a gun
data.gender_respondent.value_counts() # Gender 

data.describe()
data.shape[0]
data.dtypes
data.columns

#-------------------------------------------------------------------------------
# Data Cleaning
#-------------------------------------------------------------------------------
# explanatory variable
predictors = [[]]
predictors = data[['interest_whovote2008','presapp_econ_x',
'presapp_health_x','health_2010hcr_x','presapp_job_x','dem_edugroup','ecblame_fmpr',
'gun_importance']]

predictors = data[['gender_respondent',
'interest_attention','interest_whovote2008','presapp_track','presapp_job_x','presapp_econ_x',
'presapp_foreign_x','presapp_health_x','presapp_war_x','finance_finfam','finance_finpast_x',
'finance_finnext_x','health_insured','health_2010hcr_x','libcpre_choose',
'divgov_splitgov','campfin_limcorp','campfin_banads','ineq_incgap_x','effic_undstd',
'effic_carestd','econ_ecpast_x',
'econ_ecnext_x','econ_unpast_x','ecblame_pres','ecblame_fmpr','ecblame_dem',
'tea_supp_x','gun_importance','immig_policy','fedspend_ss','fedspend_schools',
'fedspend_scitech','fedspend_crime','fedspend_welfare','fedspend_child',
'fedspend_poor','fedspend_enviro','dem_marital','dem_edugroup','dem_eduspgroup',
'dem_veteran','dem_empstatus_1digitfinal','dem_raceeth','dem_parents','dem2_numchild',
'owngun_owngun', 'orientn_rgay', 'happ_lifesatisf']]

# target variable
targets = data['prevote_regpty']

# Convert categorical variable to numpy arrays and fill NaN values to zero.
# predictors[col] = number.fit_transform(predictors[col].replace(np.nan,'0', regex=True))
def convert(dta):
    number = preprocessing.LabelEncoder()
    for col in dta.columns:
        dta[col] = number.fit_transform(dta[col].fillna(''))
    return dta
    
	# Catagorizing income group function
def incgroup_prepost(row):
    if type(row) == float and np.isnan(row):
        return float('NaN')
    elif row == "$15,000-$17,499" or row == "$10,000-$12,499" or row == "$5,000-$9,999" or row == "$17,500-$19,999" or row == "Under $5,000":
        return 1
    elif row == "$27,500-$29,999" or row == "$25,000-$27,499" or row == "$20,000-$22,499" or row == "$22,500-$24,999":
        return 2
    elif row == "$35,000-$39,999" or row == "$30,000-$34,999":
        return 3
    elif row == "$45,000-$49,999" or row == "$40,000-$44,999":
        return 4
    elif row == "$50,000-$54,999" or row == "$55,000-$59,999":
        return 5
    elif row == "$60,000-$64,999" or row == "$65,000-$69,999":
        return 6
    elif row == "$70,000-$74,999" or row == "$75,000-$79,999":
        return 7
    elif row == "$80,000-$89,999":
        return 8
    elif row == "$90,000-$99,999":
        return 9
    elif row == "$100,000-$109,999":
        return 10
    elif row == "$110,000-$124,999" or row == "$125,000-$149,999":
        return 11
    elif row == "$150,000-$174,999" or row == "$175,000-$249,999":
        return 15
    elif row == "$250,000 Or More":
        return 25

# Explantory var Cleaning
predictors = convert(predictors)
predictors['incgroup_prepost'] = (data['incgroup_prepost'].apply(lambda row: incgroup_prepost(row))).fillna('0')

# Response var Cleaning
number = preprocessing.LabelEncoder()
targets = number.fit_transform(targets.fillna(''))

# Spliting Data
pred_train, pred_test, tar_train, tar_test  = train_test_split(predictors, targets, test_size=.4)

#-------------------------------------------------------------------------------
# Building Decision Tree Model
#-------------------------------------------------------------------------------
from sklearn.tree import DecisionTreeClassifier
import sklearn.metrics
import pandas as pd
import numpy as np

#Build model on training data
classifier = DecisionTreeClassifier()
classifier = classifier.fit(pred_train,tar_train)

predictions = classifier.predict(pred_test)

sklearn.metrics.confusion_matrix(tar_test,predictions)
sklearn.metrics.accuracy_score(tar_test, predictions)

#Displaying the decision tree
from sklearn import tree
#from StringIO import StringIO
from io import StringIO
#from StringIO import StringIO 
from IPython.display import Image
out = StringIO()
tree.export_graphviz(classifier, out_file = out)
import pydotplus
graph = pydotplus.graph_from_dot_data(out.getvalue())
Image(graph.create_png())

#-------------------------------------------------------------------------------
# Building RandomForest Model
#-------------------------------------------------------------------------------
#Build model on training data
from sklearn.ensemble import RandomForestClassifier
import sklearn.metrics
import pandas as pd
import numpy as np

classifier = RandomForestClassifier(n_estimators=25)
classifier = classifier.fit(pred_train,tar_train)

predictions = classifier.predict(pred_test)

sklearn.metrics.confusion_matrix(tar_test,predictions)
sklearn.metrics.accuracy_score(tar_test, predictions)


# Finding Best number of tree
trees = range(25)
accuracy = np.zeros(25)

for idx in range(len(trees)):
   classifier = RandomForestClassifier(n_estimators=idx + 1)
   classifier = classifier.fit(pred_train,tar_train)
   predictions = classifier.predict(pred_test)
   accuracy[idx] = sklearn.metrics.accuracy_score(tar_test, predictions)
   
plt.cla()
plt.plot(trees, accuracy)


# Feature importances with forests of trees
from sklearn.datasets import make_classification
from sklearn.ensemble import ExtraTreesClassifier
import numpy as np
import matplotlib.pyplot as plt

forest = ExtraTreesClassifier(n_estimators=250,
                              random_state=0)
forest.fit(pred_train,tar_train)                     
importances = forest.feature_importances_
std = np.std([tree.feature_importances_ for tree in forest.estimators_],
             axis=0)
indices = np.argsort(importances)[::-1]
# Print the feature ranking
print("Feature ranking:")

for f in range(pred_train.shape[1]):
    print("%d. feature %d (%f)" % (f + 1, indices[f], importances[indices[f]]))

# Plot the feature importances of the forest
plt.figure()
plt.title("Feature importances")
plt.bar(range(pred_train.shape[1]), importances[indices],
       color="r", yerr=std[indices], align="center")
plt.xticks(range(pred_train.shape[1]), indices)
plt.xlim([-1, pred_train.shape[1]])
plt.show()

print(predictors[[2,]].columns)
print(predictors[[49,]].columns)
print(predictors[[5,]].columns)
print(predictors[[7,]].columns)
print(predictors[[13,]].columns)
print(predictors[[4,]].columns)
print(predictors[[39,]].columns)
print(predictors[[25,]].columns)
print(predictors[[28,]].columns)
print(predictors[[1,]].columns)

#-------------------------------------------------------------------------------
# Building Lasso Model
#-------------------------------------------------------------------------------
# standardize predictors to have mean=0 and sd=1
import matplotlib.pylab as plt
from sklearn.linear_model import LassoLarsCV
from sklearn import preprocessing

# standardize clustering variables to have mean=0 and sd=1
predictors = predictors.copy()
def stdNscale(dta):
    for col in dta.columns:
        predictors[col] = preprocessing.scale(predictors[col].astype('float64'))
    return dta
predictors = stdNscale(predictors)
targets = preprocessing.scale(targets.astype('float64'))

# split data into train and test sets
pred_train, pred_test, tar_train, tar_test = train_test_split(predictors, targets, 
                                                              test_size=.3, random_state=123)
                                                              
                                                              
# specify the lasso regression model
model = LassoLarsCV(cv=10, precompute=False).fit(pred_train,tar_train)

# print variable names and regression coefficients
dict(zip(predictors.columns, model.coef_))

# plot coefficient progression
m_log_alphas = -np.log10(model.alphas_)
ax = plt.gca()
plt.plot(m_log_alphas, model.coef_path_.T)
plt.axvline(-np.log10(model.alpha_), linestyle='--', color='k',
            label='alpha CV')
plt.ylabel('Regression Coefficients')
plt.xlabel('-log(alpha)')
plt.title('Regression Coefficients Progression for Lasso Paths')

# plot mean square error for each fold
m_log_alphascv = -np.log10(model.cv_alphas_)
plt.figure()
plt.plot(m_log_alphascv, model.cv_mse_path_, ':')
plt.plot(m_log_alphascv, model.cv_mse_path_.mean(axis=-1), 'k',
         label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model.alpha_), linestyle='--', color='k',
            label='alpha CV')
plt.legend()
plt.xlabel('-log(alpha)')
plt.ylabel('Mean squared error')
plt.title('Mean squared error on each fold')
         

# MSE from training and test data
from sklearn.metrics import mean_squared_error
train_error = mean_squared_error(tar_train, model.predict(pred_train))
test_error = mean_squared_error(tar_test, model.predict(pred_test))
print ('training data MSE')
print(train_error)
print ('test data MSE')
print(test_error)

# R-square from training and test data
rsquared_train = model.score(pred_train, tar_train)
rsquared_test = model.score(pred_test, tar_test)
print ('training data R-square')
print(rsquared_train)
print ('test data R-square')
print(rsquared_test)


#-------------------------------------------------------------------------------
# Building kmeans Model
#-------------------------------------------------------------------------------
from pandas import Series, DataFrame
import pandas as pd
import numpy as np
import matplotlib.pylab as plt
from sklearn.cross_validation import train_test_split
from sklearn import preprocessing
from sklearn.cluster import KMeans

# standardize clustering variables to have mean=0 and sd=1
predictors = predictors.copy()
def stdNscale(dta):
    for col in dta.columns:
        predictors[col] = preprocessing.scale(predictors[col].astype('float64'))
    return dta
predictors = stdNscale(predictors)

# No need to standardize target variable
targets = targets.astype('float64')

# split data into train and test sets
clus_train, clus_test = train_test_split(predictors, test_size=.3, random_state=123)                                  
       
# k-means cluster analysis for 1-9 clusters                                                           
from scipy.spatial.distance import cdist
clusters = range(1,10)
meandist = []
           
for k in clusters:
    model = KMeans(n_clusters=k)
    model.fit(clus_train)
    clusassign = model.predict(clus_train)
    meandist.append(sum(np.min(cdist(clus_train, model.cluster_centers_, 'euclidean'), axis=1))/clus_train.shape[0])                                            
    
    
"""
Plot average distance from observations from the cluster centroid
to use the Elbow Method to identify number of clusters to choose
"""
plt.plot(clusters, meandist)
plt.xlabel('Number of clusters')
plt.ylabel('Average distance')
plt.title('Selecting k with the Elbow Method')
  
# Interpret 3 cluster solution
model3 = KMeans(n_clusters=3)
model3.fit(clus_train)
clusassign = model3.predict(clus_train)

# plot clusters
from sklearn.decomposition import PCA
pca_2 = PCA(2)
plot_columns = pca_2.fit_transform(clus_train)
plt.scatter(x=plot_columns[:,0], y=plot_columns[:,1], c=model3.labels_,)
plt.xlabel('Canonical variable 1')
plt.ylabel('Canonical variable 2')
plt.title('Scatterplot of Canonical Variables for 3 Clusters')
plt.show()


"""
BEGIN multiple steps to merge cluster assignment with clustering variables to examine
cluster variable means by cluster
"""
# create a unique identifier variable from the index for the 
# cluster training data to merge with the cluster assignment variable
clus_train.reset_index(level=0, inplace=True)
# create a list that has the new index variable
cluslist = list(clus_train['index'])
# create a list of cluster assignments
labels = list(model3.labels_)
# combine index variable list with cluster assignment list into a dictionary
newlist = dict(zip(cluslist, labels))
# convert newlist dictionary to a dataframe
newclus = DataFrame.from_dict(newlist, orient='index')
# rename the cluster assignment column
newclus.columns = ['cluster']

# now do the same for the cluster assignment variable
# create a unique identifier variable from the index for the 
# cluster assignment dataframe 
# to merge with cluster training data
newclus.reset_index(level=0, inplace=True)
# merge the cluster assignment dataframe with the cluster training variable dataframe
# by the index variable
merged_train = pd.merge(clus_train, newclus, on='index')
merged_train.head(n=100)
# cluster frequencies
merged_train.cluster.value_counts()

"""
END multiple steps to merge cluster assignment with clustering variables to examine
cluster variable means by cluster
"""

# FINALLY calculate clustering variable means by cluster
clustergrp = merged_train.groupby('cluster').mean()
print ("Clustering variable means by cluster")
print(clustergrp)


# validate clusters in training data by examining cluster differences in political party using ANOVA
# first have to merge political party with clustering variables and cluster assignment data 
gpa_data = pd.DataFrame(targets)
gpa_data.columns = ['prevote_regpty']
gpa_train, gpa_test = train_test_split(gpa_data, test_size=.3, random_state=123)
gpa_train1 = pd.DataFrame(gpa_train)
gpa_train1.reset_index(level=0, inplace=True)
merged_train_all = pd.merge(gpa_train1, merged_train, on='index')
sub1 = merged_train_all[['prevote_regpty', 'cluster']].dropna()


import statsmodels.formula.api as smf
import statsmodels.stats.multicomp as multi 

gpamod = smf.ols(formula='prevote_regpty ~ C(cluster)', data=sub1).fit()
print (gpamod.summary())

print ('means for political party by cluster')
m1= sub1.groupby('cluster').mean()
print (m1)

print ('standard deviations for political party by cluster')
m2= sub1.groupby('cluster').std()
print (m2)

mc1 = multi.MultiComparison(sub1['prevote_regpty'], sub1['cluster'])
res1 = mc1.tukeyhsd()
print(res1.summary())



"""
VALIDATION
BEGIN multiple steps to merge cluster assignment with clustering variables to examine
cluster variable means by cluster in test data set
"""
# create a variable out of the index for the cluster training dataframe to merge on
clus_test.reset_index(level=0, inplace=True)
# create a list that has the new index variable
cluslistval = list(clus_test['index'])
# create a list of cluster assignments
labelsval = list(model3.labels_)
# combine index variable list with labels list into a dictionary
newlistval = dict(zip(cluslistval, labelsval))
# convert newlist dictionary to a dataframe
newclusval = DataFrame.from_dict(newlistval, orient='index')
# rename the cluster assignment column
newclusval.columns = ['cluster']
# create a variable out of the index for the cluster assignment dataframe to merge on
newclusval.reset_index(level=0, inplace=True)
# merge the cluster assignment dataframe with the cluster training variable dataframe
# by the index variable
merged_test = pd.merge(clus_test, newclusval, on='index')
# cluster frequencies
merged_test.cluster.value_counts()
"""
END multiple steps to merge cluster assignment with clustering variables to examine
cluster variable means by cluster
"""

# calculate test data clustering variable means by cluster
clustergrpval = merged_test.groupby('cluster').mean()
print ("Test data clustering variable means by cluster")
print(clustergrpval)








