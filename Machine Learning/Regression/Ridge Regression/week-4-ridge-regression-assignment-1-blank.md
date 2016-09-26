
# Regression Week 4: Ridge Regression (interpretation)

In this notebook, we will run ridge regression multiple times with different L2 penalties to see which one produces the best fit. We will revisit the example of polynomial regression as a means to see the effect of L2 regularization. In particular, we will:
* Use a pre-built implementation of regression (GraphLab Create) to run polynomial regression
* Use matplotlib to visualize polynomial regressions
* Use a pre-built implementation of regression (GraphLab Create) to run polynomial regression, this time with L2 penalty
* Use matplotlib to visualize polynomial regressions under L2 regularization
* Choose best L2 penalty using cross-validation.
* Assess the final fit using test data.

We will continue to use the House data from previous notebooks.  (In the next programming assignment for this module, you will implement your own ridge regression learning algorithm using gradient descent.)

# Fire up graphlab create


```python
import graphlab
import os
os.chdir('C:\Users\Kyu\Documents\python\data')
```

# Polynomial regression, revisited

We build on the material from Week 3, where we wrote the function to produce an SFrame with columns containing the powers of a given input. Copy and paste the function `polynomial_sframe` from Week 3:


```python
def polynomial_sframe(feature, degree):
    # assume that degree >= 1
    # initialize the SFrame:
    poly_sframe = graphlab.SFrame()
    
    # and set poly_sframe['power_1'] equal to the passed feature
    poly_sframe['power_1'] = feature
    
    # first check if degree > 1
    if degree > 1:
        # then loop over the remaining degrees:
        # range usually starts at 0 and stops at the endpoint-1. We want it to start at 2 and stop at degree
        for power in range(2, degree+1): 
            # first we'll give the column a name:
            name = 'power_' + str(power)
            
            # then assign poly_sframe[name] to the appropriate power of feature
            poly_sframe[name] = feature.apply(lambda x: x**power)            
    return poly_sframe
```

Let's use matplotlib to visualize what a polynomial regression looks like on the house data.


```python
import matplotlib.pyplot as plt
%matplotlib inline
```


```python
sales = graphlab.SFrame('kc_house_data.gl/')
```

    [INFO] [1;32m1452599320 : INFO:     (initialize_globals_from_environment:282): Setting configuration variable GRAPHLAB_FILEIO_ALTERNATIVE_SSL_CERT_FILE to C:\Users\Kyu\AppData\Local\Dato\Dato Launcher\lib\site-packages\certifi\cacert.pem
    [0m[1;32m1452599320 : INFO:     (initialize_globals_from_environment:282): Setting configuration variable GRAPHLAB_FILEIO_ALTERNATIVE_SSL_CERT_DIR to 
    [0mThis non-commercial license of GraphLab Create is assigned to chok20734@gmail.com and will expire on October 03, 2016. For commercial licensing options, visit https://dato.com/buy/.
    
    [INFO] Start server at: ipc:///tmp/graphlab_server-1192 - Server binary: C:\Users\Kyu\AppData\Local\Dato\Dato Launcher\lib\site-packages\graphlab\unity_server.exe - Server log: C:\Users\Kyu\AppData\Local\Temp\graphlab_server_1452599320.log.0
    [INFO] GraphLab Server Version: 1.7.1
    

As in Week 3, we will use the sqft_living variable. For plotting purposes (connecting the dots), you'll need to sort by the values of sqft_living. For houses with identical square footage, we break the tie by their prices.


```python
sales = sales.sort(['sqft_living','price'])
```

Let us revisit the 15th-order polynomial model using the 'sqft_living' input. Generate polynomial features up to degree 15 using `polynomial_sframe()` and fit a model with these features. When fitting the model, use an L2 penalty of `1e-5`:


```python
l2_small_penalty = 1e-5
```

Note: When we have so many features and so few data points, the solution can become highly numerically unstable, which can sometimes lead to strange unpredictable results.  Thus, rather than using no regularization, we will introduce a tiny amount of regularization (`l2_penalty=1e-5`) to make the solution numerically stable.  (In lecture, we discussed the fact that regularization can also help with numerical stability, and here we are seeing a practical example.)

With the L2 penalty specified above, fit the model and print out the learned weights.

Hint: make sure to add 'price' column to the new SFrame before calling `graphlab.linear_regression.create()`. Also, make sure GraphLab Create doesn't create its own validation set by using the option `validation_set=None` in this call.


```python
poly_data = polynomial_sframe(sales['sqft_living'], 15)
my_features = poly_data.column_names() # get the name of the features
poly_data['price'] = sales['price'] # add price to the data since it's the target
model_small_penalty = graphlab.linear_regression.create(poly_data, 
                                                        target = 'price', 
                                                        features = my_features, 
                                                        l2_penalty = l2_small_penalty, 
                                                        validation_set = None, verbose=False)
model_small_penalty.get("coefficients").print_rows(num_rows = 16)
```

    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   167924.875841    |
    |   power_1   |  None |   103.090893797    |
    |   power_2   |  None |   0.134604621257   |
    |   power_3   |  None | -0.000129071407468 |
    |   power_4   |  None | 5.18929108761e-08  |
    |   power_5   |  None | -7.77169612721e-12 |
    |   power_6   |  None | 1.71145218533e-16  |
    |   power_7   |  None | 4.51177699518e-20  |
    |   power_8   |  None | -4.78838936778e-25 |
    |   power_9   |  None | -2.3334346463e-28  |
    |   power_10  |  None | -7.29023231247e-33 |
    |   power_11  |  None | 7.22829256215e-37  |
    |   power_12  |  None | 6.90471227099e-41  |
    |   power_13  |  None | -3.6584362837e-46  |
    |   power_14  |  None | -3.79576279667e-49 |
    |   power_15  |  None |  1.1372327781e-53  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    

***QUIZ QUESTION:  What's the learned value for the coefficient of feature `power_1`?***

# Observe overfitting

Recall from Week 3 that the polynomial fit of degree 15 changed wildly whenever the data changed. In particular, when we split the sales data into four subsets and fit the model of degree 15, the result came out to be very different for each subset. The model had a *high variance*. We will see in a moment that ridge regression reduces such variance. But first, we must reproduce the experiment we did in Week 3.

First, split the data into split the sales data into four subsets of roughly equal size and call them `set_1`, `set_2`, `set_3`, and `set_4`. Use `.random_split` function and make sure you set `seed=0`. 


```python
(semi_split1, semi_split2) = sales.random_split(.5,seed=0)
(set_1, set_2) = semi_split1.random_split(0.5, seed=0)
(set_3, set_4) = semi_split2.random_split(0.5, seed=0)
```

Next, fit a 15th degree polynomial on `set_1`, `set_2`, `set_3`, and `set_4`, using 'sqft_living' to predict prices. Print the weights and make a plot of the resulting model.

Hint: When calling `graphlab.linear_regression.create()`, use the same L2 penalty as before (i.e. `l2_small_penalty`).  Also, make sure GraphLab Create doesn't create its own validation set by using the option `validation_set = None` in this call.

## Set 1


```python
poly15_data = polynomial_sframe(set_1['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_1['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_small_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   9306.46792522    |
    |   power_1   |  None |   585.865801186    |
    |   power_2   |  None |  -0.397305870598   |
    |   power_3   |  None | 0.000141470887099  |
    |   power_4   |  None | -1.52945953305e-08 |
    |   power_5   |  None | -3.79756780265e-13 |
    |   power_6   |  None | 5.97481870723e-17  |
    |   power_7   |  None | 1.06888524681e-20  |
    |   power_8   |  None | 1.59343964904e-25  |
    |   power_9   |  None | -6.92834959509e-29 |
    |   power_10  |  None | -6.8381336466e-33  |
    |   power_11  |  None | -1.62686217832e-37 |
    |   power_12  |  None | 2.85118702934e-41  |
    |   power_13  |  None | 3.79998239846e-45  |
    |   power_14  |  None |  1.5265262459e-49  |
    |   power_15  |  None | -2.33807330697e-53 |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x207ca160>,
     <matplotlib.lines.Line2D at 0x207ca358>]




![png](output_23_2.png)


## Set 2


```python
poly15_data = polynomial_sframe(set_2['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_2['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_small_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   -25115.9037549   |
    |   power_1   |  None |   783.493795104    |
    |   power_2   |  None |  -0.767759290897   |
    |   power_3   |  None | 0.000438766356965  |
    |   power_4   |  None | -1.1516916092e-07  |
    |   power_5   |  None |  6.8428125326e-12  |
    |   power_6   |  None |  2.511951718e-15   |
    |   power_7   |  None | -2.06440512705e-19 |
    |   power_8   |  None | -4.59673154456e-23 |
    |   power_9   |  None | -2.71276981414e-29 |
    |   power_10  |  None | 6.21818512416e-31  |
    |   power_11  |  None | 6.51741309695e-35  |
    |   power_12  |  None | -9.41315022686e-40 |
    |   power_13  |  None | -1.02421375019e-42 |
    |   power_14  |  None | -1.00391104627e-46 |
    |   power_15  |  None | 1.30113372898e-50  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x20a1acf8>,
     <matplotlib.lines.Line2D at 0x20a1aef0>]




![png](output_25_2.png)


## Set 3


```python
poly15_data = polynomial_sframe(set_3['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_3['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_small_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   462426.558221    |
    |   power_1   |  None |   -759.251821168   |
    |   power_2   |  None |   1.02867002422    |
    |   power_3   |  None | -0.000528264515677 |
    |   power_4   |  None | 1.15422905278e-07  |
    |   power_5   |  None | -2.26095897095e-12 |
    |   power_6   |  None | -2.08214296129e-15 |
    |   power_7   |  None | 4.08770616978e-20  |
    |   power_8   |  None | 2.57079123887e-23  |
    |   power_9   |  None | 1.24311267792e-27  |
    |   power_10  |  None | -1.72025871021e-31 |
    |   power_11  |  None | -2.9676099516e-35  |
    |   power_12  |  None | -1.06574961828e-39 |
    |   power_13  |  None | 2.42635688317e-43  |
    |   power_14  |  None | 3.55598704036e-47  |
    |   power_15  |  None | -2.85777445732e-51 |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x20b6db38>,
     <matplotlib.lines.Line2D at 0x20b6dd30>]




![png](output_27_2.png)


## Set 4


```python
poly15_data = polynomial_sframe(set_4['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_4['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_small_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   -170240.048644   |
    |   power_1   |  None |   1247.59040376    |
    |   power_2   |  None |   -1.22460920389   |
    |   power_3   |  None | 0.000555254683096  |
    |   power_4   |  None | -6.38262574645e-08 |
    |   power_5   |  None | -2.20215960151e-11 |
    |   power_6   |  None |  4.8183469801e-15  |
    |   power_7   |  None | 4.21461555894e-19  |
    |   power_8   |  None | -7.99880713416e-23 |
    |   power_9   |  None | -1.32365900598e-26 |
    |   power_10  |  None | 1.60197794127e-31  |
    |   power_11  |  None | 2.39904346241e-34  |
    |   power_12  |  None | 2.33354468016e-38  |
    |   power_13  |  None | -1.79874057986e-42 |
    |   power_14  |  None | -6.02862619887e-46 |
    |   power_15  |  None |  4.3947263519e-50  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x20d19f98>,
     <matplotlib.lines.Line2D at 0x20d2a1d0>]




![png](output_29_2.png)


The four curves should differ from one another a lot, as should the coefficients you learned.

***QUIZ QUESTION:  For the models learned in each of these training sets, what are the smallest and largest values you learned for the coefficient of feature `power_1`?***  (For the purpose of answering this question, negative numbers are considered "smaller" than positive numbers. So -5 is smaller than -3, and -3 is smaller than 5 and so forth.)

# Ridge regression comes to rescue

Generally, whenever we see weights change so much in response to change in data, we believe the variance of our estimate to be large. Ridge regression aims to address this issue by penalizing "large" weights. (Weights of `model15` looked quite small, but they are not that small because 'sqft_living' input is in the order of thousands.)

With the argument `l2_penalty=1e5`, fit a 15th-order polynomial model on `set_1`, `set_2`, `set_3`, and `set_4`. Other than the change in the `l2_penalty` parameter, the code should be the same as the experiment above. Also, make sure GraphLab Create doesn't create its own validation set by using the option `validation_set = None` in this call.

## Set1


```python
l2_large_penalty = 1e5
```


```python
poly15_data = polynomial_sframe(set_1['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_1['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_large_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+-------------------+
    |     name    | index |       value       |
    +-------------+-------+-------------------+
    | (intercept) |  None |   530317.024516   |
    |   power_1   |  None |   2.58738875673   |
    |   power_2   |  None |  0.00127414400592 |
    |   power_3   |  None | 1.74934226932e-07 |
    |   power_4   |  None | 1.06022119097e-11 |
    |   power_5   |  None | 5.42247604482e-16 |
    |   power_6   |  None | 2.89563828343e-20 |
    |   power_7   |  None | 1.65000666351e-24 |
    |   power_8   |  None | 9.86081528409e-29 |
    |   power_9   |  None | 6.06589348254e-33 |
    |   power_10  |  None |  3.7891786887e-37 |
    |   power_11  |  None | 2.38223121312e-41 |
    |   power_12  |  None | 1.49847969215e-45 |
    |   power_13  |  None | 9.39161190285e-50 |
    |   power_14  |  None | 5.84523161981e-54 |
    |   power_15  |  None | 3.60120207203e-58 |
    +-------------+-------+-------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x211e09b0>,
     <matplotlib.lines.Line2D at 0x211e0ba8>]




![png](output_35_2.png)


## Set2


```python
poly15_data = polynomial_sframe(set_2['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_2['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_large_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+-------------------+
    |     name    | index |       value       |
    +-------------+-------+-------------------+
    | (intercept) |  None |   519216.897383   |
    |   power_1   |  None |   2.04470474182   |
    |   power_2   |  None |  0.0011314362684  |
    |   power_3   |  None | 2.93074277549e-07 |
    |   power_4   |  None | 4.43540598453e-11 |
    |   power_5   |  None | 4.80849112204e-15 |
    |   power_6   |  None | 4.53091707826e-19 |
    |   power_7   |  None | 4.16042910575e-23 |
    |   power_8   |  None | 3.90094635128e-27 |
    |   power_9   |  None |  3.7773187602e-31 |
    |   power_10  |  None | 3.76650326842e-35 |
    |   power_11  |  None | 3.84228094754e-39 |
    |   power_12  |  None | 3.98520828414e-43 |
    |   power_13  |  None | 4.18272762394e-47 |
    |   power_14  |  None | 4.42738332878e-51 |
    |   power_15  |  None | 4.71518245412e-55 |
    +-------------+-------+-------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x21498cf8>,
     <matplotlib.lines.Line2D at 0x214a74e0>]




![png](output_37_2.png)


## Set3


```python
poly15_data = polynomial_sframe(set_3['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_3['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_large_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+-------------------+
    |     name    | index |       value       |
    +-------------+-------+-------------------+
    | (intercept) |  None |   522911.518048   |
    |   power_1   |  None |   2.26890421877   |
    |   power_2   |  None |  0.00125905041842 |
    |   power_3   |  None | 2.77552918155e-07 |
    |   power_4   |  None |  3.2093309779e-11 |
    |   power_5   |  None | 2.87573572364e-15 |
    |   power_6   |  None | 2.50076112671e-19 |
    |   power_7   |  None | 2.24685265906e-23 |
    |   power_8   |  None | 2.09349983135e-27 |
    |   power_9   |  None | 2.00435383296e-31 |
    |   power_10  |  None | 1.95410800249e-35 |
    |   power_11  |  None | 1.92734119456e-39 |
    |   power_12  |  None | 1.91483699013e-43 |
    |   power_13  |  None | 1.91102277046e-47 |
    |   power_14  |  None | 1.91246242302e-51 |
    |   power_15  |  None | 1.91699558035e-55 |
    +-------------+-------+-------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x214cda58>,
     <matplotlib.lines.Line2D at 0x214cdc50>]




![png](output_39_2.png)


## Set4


```python
poly15_data = polynomial_sframe(set_4['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_4['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           l2_penalty = l2_large_penalty, 
                                           validation_set = None, verbose=False)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    +-------------+-------+-------------------+
    |     name    | index |       value       |
    +-------------+-------+-------------------+
    | (intercept) |  None |   513667.087087   |
    |   power_1   |  None |   1.91040938244   |
    |   power_2   |  None |  0.00110058029175 |
    |   power_3   |  None | 3.12753987879e-07 |
    |   power_4   |  None | 5.50067886825e-11 |
    |   power_5   |  None | 7.20467557825e-15 |
    |   power_6   |  None | 8.24977249384e-19 |
    |   power_7   |  None | 9.06503223498e-23 |
    |   power_8   |  None | 9.95683160453e-27 |
    |   power_9   |  None | 1.10838127982e-30 |
    |   power_10  |  None | 1.25315224143e-34 |
    |   power_11  |  None | 1.43600781402e-38 |
    |   power_12  |  None |  1.662699678e-42  |
    |   power_13  |  None |  1.9398172453e-46 |
    |   power_14  |  None |  2.2754148577e-50 |
    |   power_15  |  None | 2.67948784897e-54 |
    +-------------+-------+-------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x1f797630>,
     <matplotlib.lines.Line2D at 0x216b8668>]




![png](output_41_2.png)


These curves should vary a lot less, now that you applied a high degree of regularization.

***QUIZ QUESTION:  For the models learned with the high level of regularization in each of these training sets, what are the smallest and largest values you learned for the coefficient of feature `power_1`?*** (For the purpose of answering this question, negative numbers are considered "smaller" than positive numbers. So -5 is smaller than -3, and -3 is smaller than 5 and so forth.)

# Selecting an L2 penalty via cross-validation

Just like the polynomial degree, the L2 penalty is a "magic" parameter we need to select. We could use the validation set approach as we did in the last module, but that approach has a major disadvantage: it leaves fewer observations available for training. **Cross-validation** seeks to overcome this issue by using all of the training set in a smart way.

We will implement a kind of cross-validation called **k-fold cross-validation**. The method gets its name because it involves dividing the training set into k segments of roughtly equal size. Similar to the validation set method, we measure the validation error with one of the segments designated as the validation set. The major difference is that we repeat the process k times as follows:

Set aside segment 0 as the validation set, and fit a model on rest of data, and evalutate it on this validation set<br>
Set aside segment 1 as the validation set, and fit a model on rest of data, and evalutate it on this validation set<br>
...<br>
Set aside segment k-1 as the validation set, and fit a model on rest of data, and evalutate it on this validation set

After this process, we compute the average of the k validation errors, and use it as an estimate of the generalization error. Notice that  all observations are used for both training and validation, as we iterate over segments of data. 

To estimate the generalization error well, it is crucial to shuffle the training data before dividing them into segments. GraphLab Create has a utility function for shuffling a given SFrame. We reserve 10% of the data as the test set and shuffle the remainder. (Make sure to use `seed=1` to get consistent answer.)


```python
(train_valid, test) = sales.random_split(.9, seed=1)
train_valid_shuffled = graphlab.toolkits.cross_validation.shuffle(train_valid, random_seed=1)
```

Once the data is shuffled, we divide it into equal segments. Each segment should receive `n/k` elements, where `n` is the number of observations in the training set and `k` is the number of segments. Since the segment 0 starts at index 0 and contains `n/k` elements, it ends at index `(n/k)-1`. The segment 1 starts where the segment 0 left off, at index `(n/k)`. With `n/k` elements, the segment 1 ends at index `(n*2/k)-1`. Continuing in this fashion, we deduce that the segment `i` starts at index `(n*i/k)` and ends at `(n*(i+1)/k)-1`.

With this pattern in mind, we write a short loop that prints the starting and ending indices of each segment, just to make sure you are getting the splits right.


```python
n = len(train_valid_shuffled)
k = 10 # 10-fold cross-validation

for i in xrange(k):
    start = (n*i)/k
    end = (n*(i+1))/k-1
    print i, (start, end)
```

    0 (0, 1938)
    1 (1939, 3878)
    2 (3879, 5817)
    3 (5818, 7757)
    4 (7758, 9697)
    5 (9698, 11636)
    6 (11637, 13576)
    7 (13577, 15515)
    8 (15516, 17455)
    9 (17456, 19395)
    

Let us familiarize ourselves with array slicing with SFrame. To extract a continuous slice from an SFrame, use colon in square brackets. For instance, the following cell extracts rows 0 to 9 of `train_valid_shuffled`. Notice that the first index (0) is included in the slice but the last index (10) is omitted.


```python
train_valid_shuffled[0:10] # rows 0 to 9
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">id</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">date</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">price</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">bedrooms</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">bathrooms</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_living</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_lot</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">floors</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">waterfront</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2780400035</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-05-05 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">665000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2800.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5900</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1703050500</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2015-03-21 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">645000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2490.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5978</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5700002325</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-06-05 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">640000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1.75</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2340.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4206</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0475000510</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-11-18 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">594000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1320.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5000</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0844001052</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2015-01-28 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">365000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1904.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8200</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2781280290</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2015-04-27 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">305000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1610.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3516</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2214800630</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-11-05 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">239950.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.25</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1560.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8280</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2114700540</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-10-21 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">366000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2.5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1320.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4320</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2596400050</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2014-07-30 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">375000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1960.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7955</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4140900050</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2015-01-26 00:00:00+00:00</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">440000.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1.75</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2180.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">10200</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
    </tr>
</table>
<table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">view</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">condition</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">grade</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_above</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_basement</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">yr_built</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">yr_renovated</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">zipcode</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">lat</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1660</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1140</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1963</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98115</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.68093246</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">9</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2490</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2003</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98074</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.62984888</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1170</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1170</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1917</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98144</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.57587004</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1090</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">230</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1920</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98107</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.66737217</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1904</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1999</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98010</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.31068733</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1610</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2006</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98055</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.44911017</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1560</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1979</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98001</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.33933392</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">6</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">660</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">660</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1918</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98106</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.53271982</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">7</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1260</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">700</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1963</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98177</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.76407345</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2000</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">180</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1966</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">98028</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">47.76382378</td>
    </tr>
</table>
<table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">long</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_living15</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">sqft_lot15</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.28583258</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2580.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5900.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.02177564</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2710.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">6629.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.28796</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1360.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4725.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.36472902</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1700.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5000.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.0012452</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1560.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">12426.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.1878086</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1610.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3056.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.25864364</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1920.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8120.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.34716948</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1190.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4200.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.36361517</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1850.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">8219.0</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-122.27022456</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2590.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">10445.0</td>
    </tr>
</table>
[10 rows x 21 columns]<br/>
</div>



Now let us extract individual segments with array slicing. Consider the scenario where we group the houses in the `train_valid_shuffled` dataframe into k=10 segments of roughly equal size, with starting and ending indices computed as above.
Extract the fourth segment (segment 3) and assign it to a variable called `validation4`.


```python
# 3 (5818, 7757)
validation4 = train_valid_shuffled[5818:7758]
```

To verify that we have the right elements extracted, run the following cell, which computes the average price of the fourth segment. When rounded to nearest whole number, the average should be $536,234.


```python
print int(round(validation4['price'].mean(), 0))
```

    536234
    

After designating one of the k segments as the validation set, we train a model using the rest of the data. To choose the remainder, we slice (0:start) and (end+1:n) of the data and paste them together. SFrame has `append()` method that pastes together two disjoint sets of rows originating from a common dataset. For instance, the following cell pastes together the first and last two rows of the `train_valid_shuffled` dataframe.


```python
n = len(train_valid_shuffled)
first_two = train_valid_shuffled[0:2]
last_two = train_valid_shuffled[n-2:n]
print first_two.append(last_two)
```

    +------------+---------------------------+-----------+----------+-----------+
    |     id     |            date           |   price   | bedrooms | bathrooms |
    +------------+---------------------------+-----------+----------+-----------+
    | 2780400035 | 2014-05-05 00:00:00+00:00 |  665000.0 |   4.0    |    2.5    |
    | 1703050500 | 2015-03-21 00:00:00+00:00 |  645000.0 |   3.0    |    2.5    |
    | 4139480190 | 2014-09-16 00:00:00+00:00 | 1153000.0 |   3.0    |    3.25   |
    | 7237300290 | 2015-03-26 00:00:00+00:00 |  338000.0 |   5.0    |    2.5    |
    +------------+---------------------------+-----------+----------+-----------+
    +-------------+----------+--------+------------+------+-----------+-------+------------+
    | sqft_living | sqft_lot | floors | waterfront | view | condition | grade | sqft_above |
    +-------------+----------+--------+------------+------+-----------+-------+------------+
    |    2800.0   |   5900   |   1    |     0      |  0   |     3     |   8   |    1660    |
    |    2490.0   |   5978   |   2    |     0      |  0   |     3     |   9   |    2490    |
    |    3780.0   |  10623   |   1    |     0      |  1   |     3     |   11  |    2650    |
    |    2400.0   |   4496   |   2    |     0      |  0   |     3     |   7   |    2400    |
    +-------------+----------+--------+------------+------+-----------+-------+------------+
    +---------------+----------+--------------+---------+-------------+
    | sqft_basement | yr_built | yr_renovated | zipcode |     lat     |
    +---------------+----------+--------------+---------+-------------+
    |      1140     |   1963   |      0       |  98115  | 47.68093246 |
    |       0       |   2003   |      0       |  98074  | 47.62984888 |
    |      1130     |   1999   |      0       |  98006  | 47.55061236 |
    |       0       |   2004   |      0       |  98042  | 47.36923712 |
    +---------------+----------+--------------+---------+-------------+
    +---------------+---------------+-----+
    |      long     | sqft_living15 | ... |
    +---------------+---------------+-----+
    | -122.28583258 |     2580.0    | ... |
    | -122.02177564 |     2710.0    | ... |
    | -122.10144844 |     3850.0    | ... |
    | -122.12606473 |     1880.0    | ... |
    +---------------+---------------+-----+
    [4 rows x 21 columns]
    
    

Extract the remainder of the data after *excluding* fourth segment (segment 3) and assign the subset to `train4`.


```python
n = len(train_valid_shuffled)
part1 = train_valid_shuffled[0:5818]
part2 = train_valid_shuffled[7758:n]
train4 = part1.append(part2)
```

To verify that we have the right elements extracted, run the following cell, which computes the average price of the data with fourth segment excluded. When rounded to nearest whole number, the average should be $539,450.


```python
print int(round(train4['price'].mean(), 0))
```

    539450
    

Now we are ready to implement k-fold cross-validation. Write a function that computes k validation errors by designating each of the k segments as the validation set. It accepts as parameters (i) `k`, (ii) `l2_penalty`, (iii) dataframe, (iv) name of output column (e.g. `price`) and (v) list of feature names. The function returns the average validation error using k segments as validation sets.

* For each i in [0, 1, ..., k-1]:
  * Compute starting and ending indices of segment i and call 'start' and 'end'
  * Form validation set by taking a slice (start:end+1) from the data.
  * Form training set by appending slice (end+1:n) to the end of slice (0:start).
  * Train a linear model using training set just formed, with a given l2_penalty
  * Compute validation error using validation set just formed


```python
def k_fold_cross_validation(k, l2_penalty, data, output_name, features_list):
    n = len(data)
    validation_error_sum = 0
    
    #Compute starting and ending indices of segment i and call 'start' and 'end'
    for i in xrange(k):
        start = (n*i)/k
        end = (n*(i+1))/k-1
        
        #Form validation set by taking a slice (start:end+1) from the data.
        validation_data = data[start:end+1]
        
        #Form training set by appending slice (end+1:n) to the end of slice (0:start).
        part1 = data[0:start]
        part2 = data[end+1:n]
        train_data = part1.append(part2)
        
        #Train a linear model using training set just formed, with a given l2_penalty
        model = graphlab.linear_regression.create(train_data, 
                                                  target = output_name, 
                                                  features = features_list, 
                                                  l2_penalty=l2_penalty, 
                                                  validation_set = None, verbose=False)
        
        #Compute validation error using validation set just formed
        predictions = model.predict(validation_data)
        residuals = predictions - validation_data[output_name]
        RSS = (residuals*residuals).sum()
        validation_error_sum = validation_error_sum + RSS
    validation_error_avg = validation_error_sum/k
    return validation_error_avg        
```

Once we have a function to compute the average validation error for a model, we can write a loop to find the model that minimizes the average validation error. Write a loop that does the following:
* We will again be aiming to fit a 15th-order polynomial model using the `sqft_living` input
* For `l2_penalty` in [10^1, 10^1.5, 10^2, 10^2.5, ..., 10^7] (to get this in Python, you can use this Numpy function: `np.logspace(1, 7, num=13)`.)
    * Run 10-fold cross-validation with `l2_penalty`
* Report which L2 penalty produced the lowest average validation error.

Note: since the degree of the polynomial is now fixed to 15, to make things faster, you should generate polynomial features in advance and re-use them throughout the loop. Make sure to use `train_valid_shuffled` when generating polynomial features!


```python
import numpy as np

# Function to find the model that minimizes the average validation error
avg_vali_error = np.zeros((13,1))
i=0 #counter
poly_data = polynomial_sframe(train_valid_shuffled['sqft_living'], 15)
my_features = poly_data.column_names()
poly_data['price'] = train_valid_shuffled['price'] # add price to the data since it's the target
for l2_penalty in  np.logspace(1, 7, num=13):
    avg_vali_error[i] = k_fold_cross_validation(10, l2_penalty,
                                                poly_data,output_name = 'price', 
                                                features_list = my_features)
    i = i+1
print avg_vali_error.min()
```

    1.21192264451e+14
    

***QUIZ QUESTIONS:  What is the best value for the L2 penalty according to 10-fold validation?***

You may find it useful to plot the k-fold cross-validation errors you have obtained to better understand the behavior of the method.  


```python
# Plot the l2_penalty values in the x axis and the cross-validation error in the y axis.
# Using plt.xscale('log') will make your plot more intuitive.
plt.plot(np.logspace(1, 7, num=13), avg_vali_error, 'k-')
plt.xlabel('$\L2_{penalty}$')
plt.ylabel('average validation error')
plt.xscale('log')
plt.yscale('log')
```


![png](output_67_0.png)


Once you found the best value for the L2 penalty using cross-validation, it is important to retrain a final model on all of the training data using this value of `l2_penalty`.  This way, your final model will be trained on the entire dataset.


```python
poly_data = polynomial_sframe(train_valid_shuffled['sqft_living'], 15)
my_features = poly_data.column_names()
poly_data['price'] = train_valid_shuffled['price'] # add price to the data since it's the target
model_l2p_1000 = graphlab.linear_regression.create(poly_data, 
                                                   target = 'price', 
                                                   features = my_features, 
                                                   l2_penalty = 10**3, 
                                                   validation_set = None, verbose=False)
```

***QUIZ QUESTION: Using the best L2 penalty found above, train a model using all training data. What is the RSS on the TEST data of the model you learn with this L2 penalty? ***


```python
predictions = model_l2p_1000.predict(test)
residuals = predictions - test['price']
RSS = (residuals*residuals).sum()
print RSS
```

    2.52897427447e+14
    
