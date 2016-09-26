
# Regression Week 5: Feature Selection and LASSO (Interpretation)

In this notebook, you will use LASSO to select features, building on a pre-implemented solver for LASSO (using GraphLab Create, though you can use other solvers). You will:
* Run LASSO with different L1 penalties.
* Choose best L1 penalty using a validation set.
* Choose best L1 penalty using a validation set, with additional constraint on the size of subset.

In the second notebook, you will implement your own LASSO solver, using coordinate descent. 

# Fire up graphlab create


```python
import graphlab
import os
os.chdir('C:\Users\Kyu\Documents\python\data')
```

# Load in house sales data

Dataset is from house sales in King County, the region where the city of Seattle, WA is located.


```python
sales = graphlab.SFrame('kc_house_data.gl/')
```

# Create new features

As in Week 2, we consider features that are some transformations of inputs.


```python
from math import log, sqrt
sales['sqft_living_sqrt'] = sales['sqft_living'].apply(sqrt)
sales['sqft_lot_sqrt'] = sales['sqft_lot'].apply(sqrt)
sales['bedrooms_square'] = sales['bedrooms']*sales['bedrooms']

# In the dataset, 'floors' was defined with type string, 
# so we'll convert them to float, before creating a new feature.
sales['floors'] = sales['floors'].astype(float) 
sales['floors_square'] = sales['floors']*sales['floors']
```

* Squaring bedrooms will increase the separation between not many bedrooms (e.g. 1) and lots of bedrooms (e.g. 4) since 1^2 = 1 but 4^2 = 16. Consequently this variable will mostly affect houses with many bedrooms.
* On the other hand, taking square root of sqft_living will decrease the separation between big house and small house. The owner may not be exactly twice as happy for getting a house that is twice as big.

# Learn regression weights with L1 penalty

Let us fit a model with all the features available, plus the features we just created above.


```python
all_features = ['bedrooms', 'bedrooms_square',
            'bathrooms',
            'sqft_living', 'sqft_living_sqrt',
            'sqft_lot', 'sqft_lot_sqrt',
            'floors', 'floors_square',
            'waterfront', 'view', 'condition', 'grade',
            'sqft_above',
            'sqft_basement',
            'yr_built', 'yr_renovated']
```

Applying L1 penalty requires adding an extra parameter (`l1_penalty`) to the linear regression call in GraphLab Create. (Other tools may have separate implementations of LASSO.)  Note that it's important to set `l2_penalty=0` to ensure we don't introduce an additional L2 penalty.


```python
model_all = graphlab.linear_regression.create(sales, target='price', features=all_features,
                                              validation_set=None, 
                                              l2_penalty=0., l1_penalty=1e10)
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 21613
    PROGRESS: Number of features          : 17
    PROGRESS: Number of unpacked features : 17
    PROGRESS: Number of coefficients    : 18
    PROGRESS: Starting Accelerated Gradient (FISTA)
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+-----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Step size | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+-----------+--------------+--------------------+---------------+
    PROGRESS: Tuning step size. First iteration could take longer than subsequent iterations.
    PROGRESS: | 1         | 2        | 0.000002  | 1.203065     | 6962915.603493     | 426631.749026 |
    PROGRESS: | 2         | 3        | 0.000002  | 1.220065     | 6843144.200219     | 392488.929838 |
    PROGRESS: | 3         | 4        | 0.000002  | 1.237066     | 6831900.032123     | 385340.166783 |
    PROGRESS: | 4         | 5        | 0.000002  | 1.253067     | 6847166.848958     | 384842.383767 |
    PROGRESS: | 5         | 6        | 0.000002  | 1.271068     | 6869667.895833     | 385998.458623 |
    PROGRESS: | 6         | 7        | 0.000002  | 1.287069     | 6847177.773672     | 380824.455891 |
    PROGRESS: +-----------+----------+-----------+--------------+--------------------+---------------+
    PROGRESS: TERMINATED: Iteration limit reached.
    PROGRESS: This model may not be optimal. To improve it, consider increasing `max_iterations`.
    

Find what features had non-zero weight.


```python
model_all.get("coefficients").print_rows(num_rows=18)
```

    +------------------+-------+---------------+
    |       name       | index |     value     |
    +------------------+-------+---------------+
    |   (intercept)    |  None |  274873.05595 |
    |     bedrooms     |  None |      0.0      |
    | bedrooms_square  |  None |      0.0      |
    |    bathrooms     |  None | 8468.53108691 |
    |   sqft_living    |  None | 24.4207209824 |
    | sqft_living_sqrt |  None | 350.060553386 |
    |     sqft_lot     |  None |      0.0      |
    |  sqft_lot_sqrt   |  None |      0.0      |
    |      floors      |  None |      0.0      |
    |  floors_square   |  None |      0.0      |
    |    waterfront    |  None |      0.0      |
    |       view       |  None |      0.0      |
    |    condition     |  None |      0.0      |
    |      grade       |  None | 842.068034898 |
    |    sqft_above    |  None | 20.0247224171 |
    |  sqft_basement   |  None |      0.0      |
    |     yr_built     |  None |      0.0      |
    |   yr_renovated   |  None |      0.0      |
    +------------------+-------+---------------+
    [18 rows x 3 columns]
    
    

Note that a majority of the weights have been set to zero. So by setting an L1 penalty that's large enough, we are performing a subset selection. 

***QUIZ QUESTION***:
According to this list of weights, which of the features have been chosen? 

# Selecting an L1 penalty

To find a good L1 penalty, we will explore multiple values using a validation set. Let us do three way split into train, validation, and test sets:
* Split our sales data into 2 sets: training and test
* Further split our training data into two sets: train, validation

Be *very* careful that you use seed = 1 to ensure you get the same answer!


```python
(training_and_validation, testing) = sales.random_split(.9,seed=1) # initial train/test split
(training, validation) = training_and_validation.random_split(0.5, seed=1) # split training into train and validate
```

Next, we write a loop that does the following:
* For `l1_penalty` in [10^1, 10^1.5, 10^2, 10^2.5, ..., 10^7] (to get this in Python, type `np.logspace(1, 7, num=13)`.)
    * Fit a regression model with a given `l1_penalty` on TRAIN data. Specify `l1_penalty=l1_penalty` and `l2_penalty=0.` in the parameter list.
    * Compute the RSS on VALIDATION data (here you will want to use `.predict()`) for that `l1_penalty`
* Report which `l1_penalty` produced the lowest RSS on validation data.

When you call `linear_regression.create()` make sure you set `validation_set = None`.

Note: you can turn off the print out of `linear_regression.create()` with `verbose = False`


```python
import numpy as np

penalty_rss={}
penalty_list=np.logspace(1, 7, num=13)

for l1_penalty in penalty_list:
    model = graphlab.linear_regression.create(training ,
                                            target = 'price' , features = all_features ,
                                            verbose=False , validation_set=None,
                                            l2_penalty=None , l1_penalty= l1_penalty)
    RSS = ((validation['price'] - model.predict(validation))**2).sum()
    penalty_rss[l1_penalty] = RSS
    print l1_penalty, RSS
    
min(penalty_rss ,key=penalty_rss.get)
```

    10.0 6.25766333642e+14
    31.6227766017 6.25766333862e+14
    100.0 6.25766334557e+14
    316.227766017 6.25766336756e+14
    1000.0 6.25766343711e+14
    3162.27766017 6.25766365706e+14
    10000.0 6.25766435261e+14
    31622.7766017 6.25766655251e+14
    100000.0 6.257673513e+14
    316227.766017 6.25769556173e+14
    1000000.0 6.25776566319e+14
    3162277.66017 6.25799111639e+14
    10000000.0 6.258837685e+14
    




    10.0



*** QUIZ QUESTIONS ***
1. What was the best value for the `l1_penalty`?
2. What is the RSS on TEST data of the model with the best `l1_penalty`?


```python
best_model = graphlab.linear_regression.create(training ,
                                               target ='price',
                                               features = all_features,
                                               verbose = False , validation_set=None,
                                               l2_penalty = None , l1_penalty = 10.0)
RSS=((testing['price'] - best_model.predict(testing))**2).sum()
print RSS
```

    1.56983611473e+14
    

***QUIZ QUESTION***
Also, using this value of L1 penalty, how many nonzero weights do you have?


```python
best_model.get("coefficients").print_rows(num_rows=18)
```

    +------------------+-------+------------------+
    |       name       | index |      value       |
    +------------------+-------+------------------+
    |   (intercept)    |  None |  18993.4795138   |
    |     bedrooms     |  None |  7936.96861251   |
    | bedrooms_square  |  None |  936.993723341   |
    |    bathrooms     |  None |  25409.5830315   |
    |   sqft_living    |  None |   39.115122565   |
    | sqft_living_sqrt |  None |  1124.64999347   |
    |     sqft_lot     |  None | 0.00348381659616 |
    |  sqft_lot_sqrt   |  None |  148.258443122   |
    |      floors      |  None |  21204.3350605   |
    |  floors_square   |  None |  12915.5225533   |
    |    waterfront    |  None |  601905.329341   |
    |       view       |  None |   93312.819553   |
    |    condition     |  None |  6609.03701533   |
    |      grade       |  None |  6206.93883858   |
    |    sqft_above    |  None |  43.2870380826   |
    |  sqft_basement   |  None |   122.36778499   |
    |     yr_built     |  None |  9.43363921282   |
    |   yr_renovated   |  None |  56.0719865549   |
    +------------------+-------+------------------+
    [18 rows x 3 columns]
    
    

# Limit the number of nonzero weights

What if we absolutely wanted to limit ourselves to, say, 7 features? This may be important if we want to derive "a rule of thumb" --- an interpretable model that has only a few features in them.

In this section, you are going to implement a simple, two phase procedure to achive this goal:
1. Explore a large range of `l1_penalty` values to find a narrow region of `l1_penalty` values where models are likely to have the desired number of non-zero weights.
2. Further explore the narrow region you found to find a good value for `l1_penalty` that achieves the desired sparsity.  Here, we will again use a validation set to choose the best value for `l1_penalty`.


```python
max_nonzeros = 7
```

## Exploring the larger range of values to find a narrow range with the desired sparsity

Let's define a wide range of possible `l1_penalty_values`:


```python
l1_penalty_values = np.logspace(8, 10, num=20)
```

Now, implement a loop that search through this space of possible `l1_penalty` values:

* For `l1_penalty` in `np.logspace(8, 10, num=20)`:
    * Fit a regression model with a given `l1_penalty` on TRAIN data. Specify `l1_penalty=l1_penalty` and `l2_penalty=0.` in the parameter list. When you call `linear_regression.create()` make sure you set `validation_set = None`
    * Extract the weights of the model and count the number of nonzeros. Save the number of nonzeros to a list.
        * *Hint: `model['coefficients']['value']` gives you an SArray with the parameters you learned.  If you call the method `.nnz()` on it, you will find the number of non-zero parameters!* 


```python
coefficients=[]
info = []
sparse_penalty = np.logspace(8, 10, num = 20)
for l1_penalty in sparse_penalty:
    model = graphlab.linear_regression.create(training,
                                            target = 'price',
                                            features = all_features,
                                            verbose = False , validation_set = None,
                                            l2_penalty=None , l1_penalty= l1_penalty)
    nnz = model['coefficients']['value'].nnz()
    info.append((l1_penalty, nnz))

for x in enumerate(info):
    print x
```

    (0, (100000000.0, 18))
    (1, (127427498.57031322, 18))
    (2, (162377673.91887242, 18))
    (3, (206913808.11147901, 18))
    (4, (263665089.87303555, 17))
    (5, (335981828.62837881, 17))
    (6, (428133239.8719396, 17))
    (7, (545559478.11685145, 17))
    (8, (695192796.17755914, 17))
    (9, (885866790.41008317, 16))
    (10, (1128837891.6846883, 15))
    (11, (1438449888.2876658, 15))
    (12, (1832980710.8324375, 13))
    (13, (2335721469.0901213, 12))
    (14, (2976351441.6313128, 10))
    (15, (3792690190.7322536, 6))
    (16, (4832930238.5717525, 5))
    (17, (6158482110.6602545, 3))
    (18, (7847599703.5146227, 1))
    (19, (10000000000.0, 1))
    

Out of this large range, we want to find the two ends of our desired narrow range of `l1_penalty`.  At one end, we will have `l1_penalty` values that have too few non-zeros, and at the other end, we will have an `l1_penalty` that has too many non-zeros.  

More formally, find:
* The largest `l1_penalty` that has more non-zeros than `max_nonzero` (if we pick a penalty smaller than this value, we will definitely have too many non-zero weights)
    * Store this value in the variable `l1_penalty_min` (we will use it later)
* The smallest `l1_penalty` that has fewer non-zeros than `max_nonzero` (if we pick a penalty larger than this value, we will definitely have too few non-zero weights)
    * Store this value in the variable `l1_penalty_max` (we will use it later)


*Hint: there are many ways to do this, e.g.:*
* Programmatically within the loop above
* Creating a list with the number of non-zeros for each value of `l1_penalty` and inspecting it to find the appropriate boundaries.


```python
l1_penalty_min = 2976351441.6313128
l1_penalty_max = 3792690190.7322536
```

***QUIZ QUESTIONS***

What values did you find for `l1_penalty_min` and`l1_penalty_max`? 

## Exploring the narrow range of values to find the solution with the right number of non-zeros that has lowest RSS on the validation set 

We will now explore the narrow region of `l1_penalty` values we found:


```python
l1_penalty_values = np.linspace(l1_penalty_min, l1_penalty_max, 20)
```

* For `l1_penalty` in `np.linspace(l1_penalty_min,l1_penalty_max,20)`:
    * Fit a regression model with a given `l1_penalty` on TRAIN data. Specify `l1_penalty=l1_penalty` and `l2_penalty=0.` in the parameter list. When you call `linear_regression.create()` make sure you set `validation_set = None`
    * Measure the RSS of the learned model on the VALIDATION set

Find the model that the lowest RSS on the VALIDATION set and has sparsity *equal* to `max_nonzero`.


```python
narrow_rss={}
for l1_penalty in l1_penalty_values:
    model = graphlab.linear_regression.create(training ,
                                            target = 'price' ,
                                            features = all_features ,
                                            verbose=False ,validation_set=None,
                                            l2_penalty=None , l1_penalty = l1_penalty)
    RSS = ((validation['price'] - model.predict(validation))**2).sum()
    
    if model['coefficients']['value'].nnz() == max_nonzeros:
        narrow_rss[l1_penalty] = RSS
        print l1_penalty, RSS, model['coefficients']['value'].nnz()
    
min(narrow_rss ,key = narrow_rss.get)
```

    3448968612.16 1.04693766593e+15 7
    3491933809.48 1.05114779682e+15 7
    3534899006.81 1.05599290691e+15 7
    3577864204.13 1.0607997039e+15 7
    




    3448968612.1634364



***QUIZ QUESTIONS***
1. What value of `l1_penalty` in our narrow range has the lowest RSS on the VALIDATION set and has sparsity *equal* to `max_nonzeros`?
2. What features in this model have non-zero coefficients?


```python
perfect_model = graphlab.linear_regression.create(training ,
                                                  target='price',
                                                  features=all_features ,
                                                  verbose=False , validation_set=None,
                                                  l2_penalty=None , l1_penalty= 3367210135.7240372)

non_zero_weight_test = perfect_model["coefficients"][perfect_model["coefficients"]["value"] > 0]
non_zero_weight_test.print_rows(num_rows=18)
```

    +------------------+-------+---------------+
    |       name       | index |     value     |
    +------------------+-------+---------------+
    |   (intercept)    |  None | 217827.762483 |
    |     bedrooms     |  None | 952.614606234 |
    |    bathrooms     |  None | 16281.7424855 |
    |   sqft_living    |  None | 32.7598311258 |
    | sqft_living_sqrt |  None | 709.644028331 |
    |      floors      |  None | 420.626796592 |
    |      grade       |  None | 3030.59064509 |
    |    sqft_above    |  None | 30.5383614198 |
    +------------------+-------+---------------+
    [8 rows x 3 columns]
    
    


```python

```
