
# coding: utf-8

# # Big Mart Sales Prediction

# **Kyu Cho  
# October 14, 2016**

# # Introduction

# The data scientists at BigMart have collected 2013 sales data for 1559 products across 10 stores in different cities. Also, certain attributes of each product and store have been defined. The aim is to build a predictive model and find out the sales of each product at a particular store.  
# Using this model, BigMart will try to understand the properties of products and stores which play a key role in increasing sales.  

# # Variables

# We have train (8523) and test (5681) data set.
# - Variable = Description  
# - Item_Identifier = Unique product ID  
# - Item_Weight = Weight of product  
# - Item_Fat_Content = Whether the product is low fat or not  
# - Item_Visibility = The % of total display area of all products in a store allocated to the particular product    
# - Item_Type = The category to which the product belongs  
# - Item_MRP = Maximum Retail Price (list price) of the product  
# - Outlet_Identifier = Unique store ID  
# - Outlet_Establishment_Year = The year in which store was established  
# - Outlet_Size = The size of the store in terms of ground area covered  
# - Outlet_Location_Type = The type of city in which the store is located  
# - Outlet_Type = Whether the outlet is just a grocery store or some sort of supermarket
# - Item_Outlet_Sales = Sales of the product in the particulat store. This is the outcome variable to be predicted.  

# # Table of Contents

# 1. Hypothesis Generation : understanding the problem better by brainstorming possible factors that can impact the outcome
# 2. Data Exploration : looking at categorical and continuous feature summaries and making inferences about the data.
# 3. Data Cleaning : imputing missing values in the data and checking for outliers
# 4. Feature Engineering : modifying existing variables and creating new ones for analysis
# 5. Model Building : making predictive models on the data

# # 1. Hypothesis Generation

# **Store Level Hypotheses**  
# **City type**: Stores located in urban or Tier 1 cities should have higher sales because of the higher income levels of people there.  
# **Population Density**: Stores located in densely populated areas should have higher sales because of more demand.  
# **Store Capacity**: Stores which are very big in size should have higher sales as they act like one-stop-shops and people would prefer getting everything from one place  
# **Competitors**: Stores having similar establishments nearby should have less sales because of more competition.  
# **Marketing**: Stores which have a good marketing division should have higher sales as it will be able to attract customers through the right offers and advertising.  
# **Location**: Stores located within popular marketplaces should have higher sales because of better access to customers.  
# **Customer Behavior**: Stores keeping the right set of products to meet the local needs of customers will have higher sales.  
# **Ambiance**: Stores which are well-maintained and managed by polite and humble people are expected to have higher footfall and thus higher sales.  
# 
# **Product Level Hypotheses**  
# **Brand**: Branded products should have higher sales because of higher trust in the customer.  
# **Packaging**: Products with good packaging can attract customers and sell more.  
# **Utility**: Daily use products should have a higher tendency to sell as compared to the specific use products.  
# **Display Area**: Products which are given bigger shelves in the store are likely to catch attention first and sell more.  
# **Visibility in Store**: The location of product in a store will impact sales. Ones which are right at entrance will catch the eye of customer first rather than the ones in back.  
# **Advertising**: Better advertising of products in the store will should higher sales in most cases.  
# **Promotional Offers**: Products accompanied with attractive offers and discounts will sell more.  
# These are just some basic 15 hypothesis I have made, but you can think further and create some of your own. Remember that the data might not be sufficient to test all of these, but forming these gives us a better understanding of the problem and we can even look for open source information if available.  

# # 2. Data Exploration

# In[1]:

import os
os.chdir('C:\Users\Kyu\Google Drive\Portfolio\project 105')


# In[2]:

import pandas as pd
import numpy as np

# Read files:
train = pd.read_csv("train.csv", low_memory=False)
test = pd.read_csv("test.csv", low_memory=False)


# In[3]:

train[:5]


# In[4]:

# check discrepancy btw two sets
train.columns.equals(test.columns)


# In[5]:

# check different column
train.columns.difference(test.columns)


# In[6]:

# combine two sets
train['source'] = 'train'
test['source'] = 'test'
data = pd.concat([train, test], ignore_index=True)
print train.shape, test.shape, data.shape


# In[7]:

data.describe()


# **Item_Visibility** has a min value of zero. This makes no practical sense because when a product is being sold in a store, the visibility cannot be 0.
# **Outlet_Establishment_Years** vary from 1985 to 2009. The values might not be apt in this form. Rather, if we can convert them to how old the particular store is, it should have a better impact on sales.

# In[8]:

data.columns


# In[9]:

data.dtypes


# In[10]:

# check missing value
data.apply(lambda x: sum(x.isnull()))


# In[11]:

# check factor variable levels
data.apply(lambda x: len(x.unique()))


# - 1559 products  
# - 10 outlets/stores 
# - Item_Type has 16 unique values.  
# Let’s explore further using the frequency of different categories in each nominal variable.  

# In[12]:

# Filter categorical variables
categorical_columns = [x for x in data.columns if data.dtypes[x] == 'object']

# Exclude ID cols and source:
categorical_columns = [x for x in categorical_columns if x not in ['Item_Identifier','Outlet_Identifier','source']]

# Frequency table 
print("Frequency Table")
for col in categorical_columns:
    print('\nFrequency table for varible %s' % col)
    print(data[col].value_counts(sort=True, dropna=False))


# **Item_Fat_Content**: Some of ‘Low Fat’ values mis-coded as ‘low fat’ and ‘LF’. Also, some of ‘Regular’ are mentioned as ‘regular’.  
# **Item_Type**: Not all categories have substantial numbers. It looks like combining them can give better results.  
# **Outlet_Type**: Supermarket Type2 and Type3 can be combined. But we should check if that’s a good idea before doing it.  

# In[13]:

# low fat, Lf = Low Fat
# reg = Ragular 
data['Item_Fat_Content'].replace({'LF': 'Low Fat', 
                                  'low fat': 'Low Fat', 
                                  'reg':'Regular'}, inplace=True)
data["Item_Fat_Content"].value_counts(sort=True, dropna=False)


# In[14]:

import seaborn as sns
get_ipython().magic(u'matplotlib inline')
import matplotlib.pyplot as plt


# In[15]:

sns.countplot(x="Item_Fat_Content", hue="Outlet_Type", data=data);


# - Supermarket Type 1 sells the most low fat products. 

# In[16]:

sns.countplot(x="Item_Fat_Content",  hue="Item_Type", data=data);


# In[17]:

data['Item_MRP'].hist()


# - Data looks normally distributed. Don't have to worry about skewness

# # 3. Data Cleaning

# ## Imputing Missing Values
# ### 'Item_Weight'

# In[18]:

# table avg. weight per item
# data.pivot_table(values='Item_Weight', index='Item_Identifier')
item_avg_weight = data.groupby("Item_Identifier").Item_Weight.mean()

# get null index
miss_idx = data['Item_Weight'].isnull() 

print('Orignal #missing: %d' % sum(miss_idx))

# input missing data
data.loc[miss_idx, 'Item_Weight'] = data.loc[miss_idx, 'Item_Identifier'].apply(lambda x: item_avg_weight[x])
print('Final # missing: %d' % sum(data['Item_Weight'].isnull()))


# ### 'Outlet_Size'

# In[19]:

from scipy.stats import mode

# determine the mode for each
outlet_size_mode = data.pivot_table(values='Outlet_Size', columns='Outlet_Type', aggfunc=(lambda x:mode(x).mode[0]))
print('Mode for each Outlet_Type:')
print(outlet_size_mode)

# get null index
miss_idx = data['Outlet_Size'].isnull() 

# input missing data
print('\nOrignal #missing: %d' % sum(miss_idx))
data.loc[miss_idx, 'Outlet_Size'] = data.loc[miss_idx, 'Outlet_Type'].apply(lambda x: outlet_size_mode[x])
print('Final # missing: %d' % sum(data['Outlet_Size'].isnull()))


# # 4. Feature Engineering

# ## Step 1: Consider combining Outlet_Type

# In[20]:

# data.pivot_table(values='Item_Outlet_Sales', index='Outlet_Type')
data.groupby('Outlet_Type').Item_Outlet_Sales.mean()


# Looks fine

# ## Step 2: Modify Item_Visibility

# We noticed that the minimum value here is 0, which makes no practical sense.  
# Lets consider it like missing information and impute it with mean visibility of that product.

# In[21]:

# determine average visibility of a product
# data.pivot_table(values='Item_Visibility', index='Item_Identifier')
visibility_avg = data.groupby('Item_Identifier').Item_Visibility.mean()

# impute 0 values with mean visibility of that product
miss_idx = (data['Item_Visibility'] == 0)

print 'Number of 0 values initially: %d' % sum(miss_idx)
data.loc[miss_idx, 'Item_Visibility'] = data.loc[miss_idx, 'Item_Identifier'].apply(lambda x: visibility_avg[x])
print 'Number of 0 values after modification: %d' % sum(data['Item_Visibility'] == 0)


# In step 1, we hypothesized that products with higher visibility are likely to sell more.  
# But along with comparing products on absolute terms, we should look at the visibility of the product in that particular store as compared to the mean visibility of that product across all stores. This will give some idea about how much importance was given to that product in a store as compared to other stores. We can use the ‘visibility_avg’ variable made above to achieve this.,

# In[22]:

# Determine another variable with means ratio
data['Item_Visibility_MeanRatio'] = data.apply(lambda x: x['Item_Visibility']/visibility_avg[x['Item_Identifier']], axis=1)
print data['Item_Visibility_MeanRatio'].describe()


# Thus the new variable has been successfully created. Again, this is just 1 example of how to create new features. I highly  encourage you to try more of these, as good features can drastically improve model performance and they invariably prove to be the difference between the best and the average model.

# ## Step 3: Create a broad category of type of item

# - Combine the Item_Type variable (16 categories)
# - The unique ID of each item starts with either FD, DR or NC
#     + these look like being Food, Drinks and Non-Consumables
#     + use the Item_Identifier variable to create a new column

# In[23]:

# get the first two characters of ID
data['Item_Type_Combined'] = data['Item_Identifier'].apply(lambda x: x[0:2])

# rename them to more intuitive categories
data['Item_Type_Combined'] = data['Item_Type_Combined'].map({'FD':'Food',
                                                             'NC':'Non-Consumable',
                                                             'DR':'Drinks'})
data['Item_Type_Combined'].value_counts()


# ## Step 4: Combine categories based on sales
# - The ones with high average sales could be combined together

# In[24]:

# get idx of train part
train_idx = (data['source'] == 'train')

# subset the data
sub_data = data.loc[train_idx, ['Item_Identifier', 'Item_Outlet_Sales']]

# get avg. item sales by item_Identifier
item_avg_sales = sub_data.groupby("Item_Identifier").Item_Outlet_Sales.mean()

# extract the avg. sale percentile to group them into four categories
percentile = np.percentile(item_avg_sales, np.arange(0, 100, 25))
twentyfive = percentile[1]
fifty = percentile[2]
seventyfive = percentile[3]

# extract the Item_Identifier idx that fall between those percentiles
first_idx = item_avg_sales.apply(lambda x: x < twentyfive)
second_idx = item_avg_sales.apply(lambda x: x >= twentyfive and x < fifty)
third_idx = item_avg_sales.apply(lambda x: x >= fifty and x < seventyfive)
fourth_idx = item_avg_sales.apply(lambda x: x > seventyfive)

# extract the Item_Identifier names for each percentiles
first = item_avg_sales.loc[first_idx, ].index.values
second = item_avg_sales.loc[second_idx, ].index.values
thrid = item_avg_sales.loc[third_idx, ].index.values
fourth = item_avg_sales.loc[fourth_idx, ].index.values

# function to categorize each row
def id_to_percentile(x):
    if x in first:
        return('first')
    elif x in second:
        return('second')
    elif x in thrid:
        return('thrid')
    elif x in fourth:
        return('fourth')

data['Percentile'] = data['Item_Identifier'].apply(lambda x: id_to_percentile(x))


# In[25]:

data['Percentile'].value_counts()


# ## Step 5: Determine the years of operation of a store

# - Create a new column depicting the years of operation of a store.

# In[26]:

# Years, since the data is collected in 2013, we use 2013 as a starting year
data['Outlet_Years'] = 2013 - data['Outlet_Establishment_Year']
data['Outlet_Years'].describe()


# ## Step 6: Modify categories of Item_Fat_Content

# - In step 3, there were some non-consumables as well and a fat-content should not be specified for them.
#     + create a separate category for such kind of observations.

# In[27]:

# get idx for Non-consumable row
NC_idx = (data['Item_Type_Combined'] == "Non-Consumable")

# create new categories
data.loc[NC_idx, 'Item_Fat_Content'] = "Non-Edible"

data['Item_Fat_Content'].value_counts()


# ## Step 7: One-Hot Enoding  for Categorical variables

# In[28]:

np.array(data.select_dtypes(include=["object_"]).columns)


# In[29]:

from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()

# New variable for outlet
data['Outlet'] = le.fit_transform(data['Outlet_Identifier'])
var_mod = ['Item_Fat_Content', 'Outlet_Location_Type', 'Outlet_Size', 'Item_Type_Combined', 'Outlet_Type', 'Outlet', 'Percentile']
le = LabelEncoder()
for i in var_mod:
    data[i] = le.fit_transform(data[i])


# In[30]:

data.head()


# In[31]:

# one-hot-encoding
data = pd.get_dummies(data, columns=['Item_Fat_Content', 'Outlet_Location_Type', 'Outlet_Size', 'Outlet_Type',
                              'Item_Type_Combined', 'Outlet', 'Percentile'])


# In[32]:

data.dtypes


# ## Step 8: Exporting Data

# - Convert data back into train and test data sets.

# In[33]:

# drop the columns which have been converted to different types
data.drop(['Item_Type', 'Outlet_Establishment_Year'], axis=1, inplace=True)

# divide into test and train
train = data.loc[data['source']=="train"]
test = data.loc[data['source']=="test"]

# drop unnecessary columns
test.drop(['Item_Outlet_Sales', 'source'], axis=1, inplace=True)
train.drop(['source'], axis=1, inplace=True)

# export files as modified versions
train.to_csv("train_modified.csv", index=False)
test.to_csv("test_modified.csv", index=False)


# # Model Building

# ## Define a generic Function

# In[34]:

from sklearn import cross_validation, metrics

# Define target and ID columns:
target = 'Item_Outlet_Sales'
IDcol = ['Item_Identifier','Outlet_Identifier']

def modelfit(alg, dtrain, dtest, predictors, target, IDcol, filename):
    # Fit the algorithm on the data
    alg.fit(dtrain[predictors], dtrain[target])
        
    # Predict training set:
    dtrain_predictions = alg.predict(dtrain[predictors])

    # Perform cross-validation:
    cv_score = cross_validation.cross_val_score(alg, dtrain[predictors], 
                                                dtrain[target], 
                                                cv=20, 
                                                scoring='mean_squared_error')
    cv_score = np.sqrt(np.abs(cv_score))
    
    # Print model report:
    print "\nModel Report"
    print "RMSE : %.4g" % np.sqrt(metrics.mean_squared_error(dtrain[target].values, 
                                                             dtrain_predictions))
    print "CV Score : Mean - %.4g | Std - %.4g | Min - %.4g | Max - %.4g" % (np.mean(cv_score), 
                                                                             np.std(cv_score),
                                                                             np.min(cv_score),
                                                                             np.max(cv_score))
    
    # Predict on testing data:
    dtest[target] = alg.predict(dtest[predictors])
    
    # Export submission file:
    IDcol.append(target)
    submission = pd.DataFrame({ x: dtest[x] for x in IDcol})
    submission.to_csv(filename, index=False)


# ## 1. Base Model

# In[35]:

# Mean based:
mean_sales = train['Item_Outlet_Sales'].mean()

# Define a dataframe with IDs for submission:
base1 = test[['Item_Identifier','Outlet_Identifier']]
base1.loc['Item_Outlet_Sales'] = mean_sales

# Export submission file
# base1.to_csv("alg0.csv",index=False)


# ### Public LB Score: 1202

# ## 2. Linear Regression

# In[36]:

IDcol


# In[37]:

from sklearn.linear_model import LinearRegression, Ridge, Lasso

predictors = [x for x in train.columns if x not in [target] + IDcol]

alg1 = LinearRegression(normalize=True)
modelfit(alg1, train, test, predictors, target, IDcol, 'alg1.csv')

coef1 = pd.Series(alg1.coef_, predictors).sort_values()
coef1.plot(kind='bar', title='Model Coefficients')


# ### Public LB Score: 1202

# # 3. Ridge Regression

# In[38]:

from sklearn.linear_model import LinearRegression, Ridge, Lasso

predictors = [x for x in train.columns if x not in [target] + IDcol]

alg2 = Ridge(alpha=0.05, 
             normalize=True)
modelfit(alg2, train, test, predictors, target, IDcol, 'alg2.csv')

coef2 = pd.Series(alg2.coef_, predictors).sort_values()
coef2.plot(kind='bar', title='Model Coefficients')


# ## 3. Decision Tree

# In[39]:

from sklearn.tree import DecisionTreeRegressor

predictors = [x for x in train.columns if x not in [target] + IDcol]

alg3 = DecisionTreeRegressor(max_depth=15, 
                             min_samples_leaf=100)
modelfit(alg3, train, test, predictors, target, IDcol, 'alg3.csv')

coef3 = pd.Series(alg3.feature_importances_, predictors).sort_values(ascending=False)
coef3.plot(kind='bar', title='Feature Importances')


# ### Public LB Score: 1162
# 
# - RMSE is 1058 and the mean CV error is 1091. 
#     + slightly overfitting. 
#         + try making a decision tree with just top 4 variables, a max_depth of 8 and min_samples_leaf as 150

# In[40]:

predictors = ['Item_MRP','Outlet_Type_0','Outlet_5','Outlet_Years']

alg4 = DecisionTreeRegressor(max_depth=8, 
                             min_samples_leaf=150)
modelfit(alg4, train, test, predictors, target, IDcol, 'alg4.csv')

coef4 = pd.Series(alg4.feature_importances_, predictors).sort_values(ascending=False)
coef4.plot(kind='bar', title='Feature Importances')


# ### Public LB Score: 1157

# ## 4. Random Forest

# In[41]:

from sklearn.ensemble import RandomForestRegressor

predictors = [x for x in train.columns if x not in [target] + IDcol]

alg5 = RandomForestRegressor(n_estimators=200, 
                             max_depth=5, 
                             min_samples_leaf=100, 
                             n_jobs=4)
modelfit(alg5, train, test, predictors, target, IDcol, 'alg5.csv')

coef5 = pd.Series(alg5.feature_importances_, predictors).sort_values(ascending=False)
coef5.plot(kind='bar', title='Feature Importances')


# ### Public LB Score: 1154
# - Try making another random forest with max_depth of 6 and 400 trees. 

# In[42]:

predictors = [x for x in train.columns if x not in [target] + IDcol]

alg6 = RandomForestRegressor(n_estimators=400,
                             max_depth=6, 
                             min_samples_leaf=100,
                             n_jobs=4)
modelfit(alg6, train, test, predictors, target, IDcol, 'alg6.csv')

coef6 = pd.Series(alg6.feature_importances_, predictors).sort_values(ascending=False)
coef6.plot(kind='bar', title='Feature Importances')


# ### LB Score: 1152
# 
# TODO:
#     - Try with better algorithms like GBM and XGBoost and try ensemble techniques.
