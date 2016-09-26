
# Regression Week 3: Assessing Fit (polynomial regression)

In this notebook you will compare different regression models in order to assess which model fits best. We will be using polynomial regression as a means to examine this topic. In particular you will:
* Write a function to take an SArray and a degree and return an SFrame where each column is the SArray to a polynomial value up to the total degree e.g. degree = 3 then column 1 is the SArray column 2 is the SArray squared and column 3 is the SArray cubed
* Use matplotlib to visualize polynomial regressions
* Use matplotlib to visualize the same polynomial degree on different subsets of the data
* Use a validation set to select a polynomial degree
* Assess the final fit using test data

We will continue to use the House data from previous notebooks.

# Fire up graphlab create


```python
import graphlab
import os
os.chdir('C:\Users\Kyu\Documents\python\data')
```

Next we're going to write a polynomial function that takes an SArray and a maximal degree and returns an SFrame with columns containing the SArray to all the powers up to the maximal degree.

The easiest way to apply a power to an SArray is to use the .apply() and lambda x: functions. 
For example to take the example array and compute the third power we can do as follows: (note running this cell the first time may take longer than expected since it loads graphlab)


```python
tmp = graphlab.SArray([1., 2., 3.])
tmp_cubed = tmp.apply(lambda x: x**3)
print tmp
print tmp_cubed
```

    [INFO] [1;32m1452600270 : INFO:     (initialize_globals_from_environment:282): Setting configuration variable GRAPHLAB_FILEIO_ALTERNATIVE_SSL_CERT_FILE to C:\Users\Kyu\AppData\Local\Dato\Dato Launcher\lib\site-packages\certifi\cacert.pem
    [0m[1;32m1452600270 : INFO:     (initialize_globals_from_environment:282): Setting configuration variable GRAPHLAB_FILEIO_ALTERNATIVE_SSL_CERT_DIR to 
    [0mThis non-commercial license of GraphLab Create is assigned to chok20734@gmail.com and will expire on October 03, 2016. For commercial licensing options, visit https://dato.com/buy/.
    
    [INFO] Start server at: ipc:///tmp/graphlab_server-3976 - Server binary: C:\Users\Kyu\AppData\Local\Dato\Dato Launcher\lib\site-packages\graphlab\unity_server.exe - Server log: C:\Users\Kyu\AppData\Local\Temp\graphlab_server_1452600270.log.0
    [INFO] GraphLab Server Version: 1.7.1
    

    [1.0, 2.0, 3.0]
    [1.0, 8.0, 27.0]
    

We can create an empty SFrame using graphlab.SFrame() and then add any columns to it with ex_sframe['column_name'] = value. For example we create an empty SFrame and make the column 'power_1' to be the first power of tmp (i.e. tmp itself).


```python
ex_sframe = graphlab.SFrame()
ex_sframe['power_1'] = tmp
print ex_sframe
```

    +---------+
    | power_1 |
    +---------+
    |   1.0   |
    |   2.0   |
    |   3.0   |
    +---------+
    [3 rows x 1 columns]
    
    

# Polynomial_sframe function

Using the hints above complete the following function to create an SFrame consisting of the powers of an SArray up to a specific degree:


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

To test your function consider the smaller tmp variable and what you would expect the outcome of the following call:


```python
print polynomial_sframe(tmp, 3)
```

    +---------+---------+---------+
    | power_1 | power_2 | power_3 |
    +---------+---------+---------+
    |   1.0   |   1.0   |   1.0   |
    |   2.0   |   4.0   |   8.0   |
    |   3.0   |   9.0   |   27.0  |
    +---------+---------+---------+
    [3 rows x 3 columns]
    
    

# Visualizing polynomial regression

Let's use matplotlib to visualize what a polynomial regression looks like on some real data.


```python
sales = graphlab.SFrame('kc_house_data.gl/')
```

As in Week 3, we will use the sqft_living variable. For plotting purposes (connecting the dots), you'll need to sort by the values of sqft_living. For houses with identical square footage, we break the tie by their prices.


```python
sales = sales.sort(['sqft_living', 'price'])
```

Let's start with a degree 1 polynomial using 'sqft_living' (i.e. a line) to predict 'price' and plot what it looks like.


```python
poly1_data = polynomial_sframe(sales['sqft_living'], 1)
poly1_data['price'] = sales['price'] # add price to the data since it's the target
```

NOTE: for all the models in this notebook use validation_set = None to ensure that all results are consistent across users.


```python
model1 = graphlab.linear_regression.create(poly1_data, 
                                           target = 'price', 
                                           features = ['power_1'], 
                                           validation_set = None)
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 21613
    PROGRESS: Number of features          : 1
    PROGRESS: Number of unpacked features : 1
    PROGRESS: Number of coefficients    : 2
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 1.014060     | 4362074.696077     | 261440.790724 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    


```python
#let's take a look at the weights before we plot
model1.get("coefficients")
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">name</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">index</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">value</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">(intercept)</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">None</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">-43579.0852515</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">power_1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">None</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">280.622770886</td>
    </tr>
</table>
[2 rows x 3 columns]<br/>
</div>




```python
import matplotlib.pyplot as plt
%matplotlib inline
```


```python
plt.plot(poly1_data['power_1'],poly1_data['price'],'.',
        poly1_data['power_1'], model1.predict(poly1_data),'-')
```




    [<matplotlib.lines.Line2D at 0x1fafe6a0>,
     <matplotlib.lines.Line2D at 0x1fa18c88>]




![png](output_24_1.png)


Let's unpack that plt.plot() command. The first pair of SArrays we passed are the 1st power of sqft and the actual price we then ask it to print these as dots '.'. The next pair we pass is the 1st power of sqft and the predicted values from the linear model. We ask these to be plotted as a line '-'. 

We can see, not surprisingly, that the predicted values all fall on a line, specifically the one with slope 280 and intercept -43579. What if we wanted to plot a second degree polynomial?


```python
poly2_data = polynomial_sframe(sales['sqft_living'], 2)
my_features = poly2_data.column_names() # get the name of the features
poly2_data['price'] = sales['price'] # add price to the data since it's the target
model2 = graphlab.linear_regression.create(poly2_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 21613
    PROGRESS: Number of features          : 2
    PROGRESS: Number of unpacked features : 2
    PROGRESS: Number of coefficients    : 3
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.013000     | 5913020.984255     | 250948.368758 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    


```python
model2.get("coefficients")
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">name</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">index</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">value</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">(intercept)</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">None</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">199222.496445</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">power_1</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">None</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">67.9940640677</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">power_2</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">None</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0.0385812312789</td>
    </tr>
</table>
[3 rows x 3 columns]<br/>
</div>




```python
plt.plot(poly2_data['power_1'],poly2_data['price'],'.',
        poly2_data['power_1'], model2.predict(poly2_data),'-')
```




    [<matplotlib.lines.Line2D at 0x1fe48320>,
     <matplotlib.lines.Line2D at 0x1fed2b70>]




![png](output_28_1.png)


The resulting model looks like half a parabola. Try on your own to see what the cubic looks like:


```python
poly3_data = polynomial_sframe(sales['sqft_living'], 3)
my_features = poly3_data.column_names() # get the name of the features
poly3_data['price'] = sales['price'] # add price to the data since it's the target
model3 = graphlab.linear_regression.create(poly3_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model3.get("coefficients").print_rows(num_rows = 4)
plt.plot(poly3_data['power_1'],poly3_data['price'],'.',
        poly3_data['power_1'], model3.predict(poly3_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 21613
    PROGRESS: Number of features          : 3
    PROGRESS: Number of unpacked features : 3
    PROGRESS: Number of coefficients    : 4
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015000     | 3261066.736007     | 249261.286346 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+-------------------+
    |     name    | index |       value       |
    +-------------+-------+-------------------+
    | (intercept) |  None |   336788.117952   |
    |   power_1   |  None |   -90.1476236119  |
    |   power_2   |  None |   0.087036715081  |
    |   power_3   |  None | -3.8398521196e-06 |
    +-------------+-------+-------------------+
    [4 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x208132e8>,
     <matplotlib.lines.Line2D at 0x208134e0>]




![png](output_30_2.png)


Now try a 15th degree polynomial:


```python
poly15_data = polynomial_sframe(sales['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = sales['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 21613
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.027048     | 2662308.584338     | 245690.511190 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   73619.7520939    |
    |   power_1   |  None |   410.287462577    |
    |   power_2   |  None |  -0.230450714462   |
    |   power_3   |  None | 7.58840542566e-05  |
    |   power_4   |  None | -5.6570180279e-09  |
    |   power_5   |  None | -4.57028130736e-13 |
    |   power_6   |  None |  2.6636020695e-17  |
    |   power_7   |  None | 3.38584768945e-21  |
    |   power_8   |  None | 1.14723103963e-25  |
    |   power_9   |  None | -4.65293584577e-30 |
    |   power_10  |  None | -8.68796201973e-34 |
    |   power_11  |  None | -6.30994295642e-38 |
    |   power_12  |  None | -2.70390383947e-42 |
    |   power_13  |  None | -1.21241981722e-47 |
    |   power_14  |  None | 1.11397452903e-50  |
    |   power_15  |  None | 1.39881690782e-54  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x20b92c18>,
     <matplotlib.lines.Line2D at 0x20b92e10>]




![png](output_32_2.png)


What do you think of the 15th degree polynomial? Do you think this is appropriate? If we were to change the data do you think you'd get pretty much the same curve? Let's take a look.

# Changing the data and re-learning

We're going to split the sales data into four subsets of roughly equal size. Then you will estimate a 15th degree polynomial model on all four subsets of the data. Print the coefficients (you should use .print_rows(num_rows = 16) to view all of them) and plot the resulting fit (as we did above). The quiz will ask you some questions about these results.

To split the sales data into four subsets, we perform the following steps:
* First split sales into 2 subsets with `.random_split(0.5, seed=0)`. 
* Next split the resulting subsets into 2 more subsets each. Use `.random_split(0.5, seed=0)`.

We set `seed=0` in these steps so that different users get consistent results.
You should end up with 4 subsets (`set_1`, `set_2`, `set_3`, `set_4`) of approximately equal size. 


```python
train, test = sales.random_split(0.5, seed=0)
set_1, set_2 = train.random_split(0.5, seed=0)
set_3, set_4 = test.random_split(0.5, seed=0)
```

Fit a 15th degree polynomial on set_1, set_2, set_3, and set_4 using sqft_living to predict prices. Print the coefficients and make a plot of the resulting model.

###Set 1


```python
poly15_data = polynomial_sframe(set_1['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_1['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 5404
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.018066     | 2195218.932304     | 248858.822200 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   223312.750248    |
    |   power_1   |  None |    118.08612759    |
    |   power_2   |  None |  -0.0473482011355  |
    |   power_3   |  None | 3.25310342469e-05  |
    |   power_4   |  None | -3.32372152549e-09 |
    |   power_5   |  None | -9.75830458034e-14 |
    |   power_6   |  None | 1.15440303443e-17  |
    |   power_7   |  None | 1.05145869407e-21  |
    |   power_8   |  None | 3.46049616538e-26  |
    |   power_9   |  None | -1.09654454139e-30 |
    |   power_10  |  None | -2.42031812102e-34 |
    |   power_11  |  None | -1.99601206811e-38 |
    |   power_12  |  None | -1.07709903807e-42 |
    |   power_13  |  None | -2.72862818125e-47 |
    |   power_14  |  None | 2.44782693211e-51  |
    |   power_15  |  None | 5.01975232842e-55  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x2125b908>,
     <matplotlib.lines.Line2D at 0x2082dda0>]




![png](output_39_2.png)


## Set 2


```python
poly15_data = polynomial_sframe(set_2['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_2['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 5398
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015055     | 2069212.978548     | 234840.067186 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   89836.5077365    |
    |   power_1   |  None |   319.806946757    |
    |   power_2   |  None |  -0.103315397038   |
    |   power_3   |  None | 1.06682476072e-05  |
    |   power_4   |  None | 5.75577097658e-09  |
    |   power_5   |  None | -2.54663464607e-13 |
    |   power_6   |  None | -1.09641345075e-16 |
    |   power_7   |  None | -6.3645844169e-21  |
    |   power_8   |  None | 5.52560417024e-25  |
    |   power_9   |  None | 1.35082038963e-28  |
    |   power_10  |  None | 1.18408188238e-32  |
    |   power_11  |  None | 1.98348000623e-37  |
    |   power_12  |  None | -9.92533590338e-41 |
    |   power_13  |  None | -1.60834847049e-44 |
    |   power_14  |  None | -9.1200602411e-49  |
    |   power_15  |  None | 1.68636658308e-52  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x211217f0>,
     <matplotlib.lines.Line2D at 0x1fd10940>]




![png](output_41_2.png)


## Set 3


```python
poly15_data = polynomial_sframe(set_2['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_2['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 5398
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015001     | 2069212.978548     | 234840.067186 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   89836.5077365    |
    |   power_1   |  None |   319.806946757    |
    |   power_2   |  None |  -0.103315397038   |
    |   power_3   |  None | 1.06682476072e-05  |
    |   power_4   |  None | 5.75577097658e-09  |
    |   power_5   |  None | -2.54663464607e-13 |
    |   power_6   |  None | -1.09641345075e-16 |
    |   power_7   |  None | -6.3645844169e-21  |
    |   power_8   |  None | 5.52560417024e-25  |
    |   power_9   |  None | 1.35082038963e-28  |
    |   power_10  |  None | 1.18408188238e-32  |
    |   power_11  |  None | 1.98348000623e-37  |
    |   power_12  |  None | -9.92533590338e-41 |
    |   power_13  |  None | -1.60834847049e-44 |
    |   power_14  |  None | -9.1200602411e-49  |
    |   power_15  |  None | 1.68636658308e-52  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x21953fd0>,
     <matplotlib.lines.Line2D at 0x21964208>]




![png](output_43_2.png)


## Set 4


```python
poly15_data = polynomial_sframe(set_2['sqft_living'], 15)
my_features = poly15_data.column_names() # get the name of the features
poly15_data['price'] = set_2['price'] # add price to the data since it's the target
model15 = graphlab.linear_regression.create(poly15_data, 
                                           target = 'price', 
                                           features = my_features, 
                                           validation_set = None)
model15.get("coefficients").print_rows(num_rows = 16)
plt.plot(poly15_data['power_1'],poly15_data['price'],'.',
        poly15_data['power_1'], model15.predict(poly15_data),'-')
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 5398
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.017010     | 2069212.978548     | 234840.067186 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    +-------------+-------+--------------------+
    |     name    | index |       value        |
    +-------------+-------+--------------------+
    | (intercept) |  None |   89836.5077365    |
    |   power_1   |  None |   319.806946757    |
    |   power_2   |  None |  -0.103315397038   |
    |   power_3   |  None | 1.06682476072e-05  |
    |   power_4   |  None | 5.75577097658e-09  |
    |   power_5   |  None | -2.54663464607e-13 |
    |   power_6   |  None | -1.09641345075e-16 |
    |   power_7   |  None | -6.3645844169e-21  |
    |   power_8   |  None | 5.52560417024e-25  |
    |   power_9   |  None | 1.35082038963e-28  |
    |   power_10  |  None | 1.18408188238e-32  |
    |   power_11  |  None | 1.98348000623e-37  |
    |   power_12  |  None | -9.92533590338e-41 |
    |   power_13  |  None | -1.60834847049e-44 |
    |   power_14  |  None | -9.1200602411e-49  |
    |   power_15  |  None | 1.68636658308e-52  |
    +-------------+-------+--------------------+
    [16 rows x 3 columns]
    
    




    [<matplotlib.lines.Line2D at 0x219e4240>,
     <matplotlib.lines.Line2D at 0x219e4438>]




![png](output_45_2.png)


Some questions you will be asked on your quiz:

**Quiz Question: Is the sign (positive or negative) for power_15 the same in all four models?**

**Quiz Question: (True/False) the plotted fitted lines look the same in all four plots**

# Selecting a Polynomial Degree

Whenever we have a "magic" parameter like the degree of the polynomial there is one well-known way to select these parameters: validation set. (We will explore another approach in week 4).

We split the sales dataset 3-way into training set, test set, and validation set as follows:

* Split our sales data into 2 sets: `training_and_validation` and `testing`. Use `random_split(0.9, seed=1)`.
* Further split our training data into two sets: `training` and `validation`. Use `random_split(0.5, seed=1)`.

Again, we set `seed=1` to obtain consistent results for different users.


```python
training_and_validation, testing = sales.random_split(0.9, seed=1)
training, validation = training_and_validation.random_split(0.5, seed=1)
```

Next you should write a loop that does the following:
* For degree in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] (to get this in python type range(1, 15+1))
    * Build an SFrame of polynomial data of train_data['sqft_living'] at the current degree
    * hint: my_features = poly_data.column_names() gives you a list e.g. ['power_1', 'power_2', 'power_3'] which you might find useful for graphlab.linear_regression.create( features = my_features)
    * Add train_data['price'] to the polynomial SFrame
    * Learn a polynomial regression model to sqft vs price with that degree on TRAIN data
    * Compute the RSS on VALIDATION data (here you will want to use .predict()) for that degree and you will need to make a polynmial SFrame using validation data.
* Report which degree had the lowest RSS on validation data (remember python indexes from 0)

(Note you can turn off the print out of linear_regression.create() with verbose = False)


```python
from math import sqrt
RSS = []

for degree in range(1,16):
    poly_data = polynomial_sframe(training['sqft_living'], degree)
    my_features = poly_data.column_names()
    poly_data['price'] = training['price']
    model = graphlab.linear_regression.create(poly_data, 
                                              target = 'price', 
                                              features = my_features, 
                                              validation_set = None)
    validation_poly = polynomial_sframe(validation['sqft_living'], degree)
    predictions = model.predict(validation_poly)
    
    # Calculating RSS
    errors = validation['price'] - predictions
    errors_sq = errors**2
    sum_errors_sq = sum(errors_sq)
    RSS.append(sqrt(sum_errors_sq))
    
minRss = min(RSS)
index = RSS.index(minRss)
print "--------------------"
print str(index+1)

```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 1
    PROGRESS: Number of unpacked features : 1
    PROGRESS: Number of coefficients    : 2
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.002999     | 4274505.747987     | 262315.114947 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 2
    PROGRESS: Number of unpacked features : 2
    PROGRESS: Number of coefficients    : 3
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.000000     | 4869005.244131     | 255076.149120 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 3
    PROGRESS: Number of unpacked features : 3
    PROGRESS: Number of coefficients    : 4
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015626     | 3271232.649557     | 249640.623557 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 4
    PROGRESS: Number of unpacked features : 4
    PROGRESS: Number of coefficients    : 5
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015625     | 2676547.198434     | 248689.572032 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 5
    PROGRESS: Number of unpacked features : 5
    PROGRESS: Number of coefficients    : 6
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015620     | 2330678.377343     | 248281.665797 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 6
    PROGRESS: Number of unpacked features : 6
    PROGRESS: Number of coefficients    : 7
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015625     | 2344070.143277     | 247280.891725 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 7
    PROGRESS: Number of unpacked features : 7
    PROGRESS: Number of coefficients    : 8
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015625     | 2452711.310595     | 246772.313122 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 8
    PROGRESS: Number of unpacked features : 8
    PROGRESS: Number of coefficients    : 9
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.000000     | 2504989.234017     | 246671.859042 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 9
    PROGRESS: Number of unpacked features : 9
    PROGRESS: Number of coefficients    : 10
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015626     | 2525802.177255     | 246663.399621 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 10
    PROGRESS: Number of unpacked features : 10
    PROGRESS: Number of coefficients    : 11
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015619     | 2532693.511979     | 246670.636994 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 11
    PROGRESS: Number of unpacked features : 11
    PROGRESS: Number of coefficients    : 12
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.015625     | 2534201.088399     | 246675.476971 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 12
    PROGRESS: Number of unpacked features : 12
    PROGRESS: Number of coefficients    : 13
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.023003     | 2534257.195242     | 246676.033273 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 13
    PROGRESS: Number of unpacked features : 13
    PROGRESS: Number of coefficients    : 14
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.024003     | 2534342.869094     | 246674.389430 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 14
    PROGRESS: Number of unpacked features : 14
    PROGRESS: Number of coefficients    : 15
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.026002     | 2534786.244130     | 246672.360649 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 15
    PROGRESS: Number of unpacked features : 15
    PROGRESS: Number of coefficients    : 16
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.037002     | 2535496.382162     | 246670.782977 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    --------------------
    6
    

**Quiz Question: Which degree (1, 2, …, 15) had the lowest RSS on Validation data?**

Now that you have chosen the degree of your polynomial using validation data, compute the RSS of this model on TEST data. Report the RSS on your quiz.


```python
poly_data = polynomial_sframe(training['sqft_living'],6)
my_features = poly_data.column_names()
poly_data['price'] = training['price']
model = graphlab.linear_regression.create(poly_data, 
                                          target = 'price', 
                                          features = my_features, 
                                          validation_set = None)

test_poly_data = polynomial_sframe(testing['sqft_living'], 6)
predictions = model.predict(test_poly_data)

# RSS
errors = testing['price'] - predictions
errors_sq = errors**2
sum_errors_sq = sum(errors_sq)
RSS_test = sum_errors_sq
RSS_test
```

    PROGRESS: Linear regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 9761
    PROGRESS: Number of features          : 6
    PROGRESS: Number of unpacked features : 6
    PROGRESS: Number of coefficients    : 7
    PROGRESS: Starting Newton Method
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | Iteration | Passes   | Elapsed Time | Training-max_error | Training-rmse |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: | 1         | 2        | 0.000000     | 2344070.143277     | 247280.891725 |
    PROGRESS: +-----------+----------+--------------+--------------------+---------------+
    PROGRESS: SUCCESS: Optimal solution found.
    PROGRESS:
    




    125529337848195.64



**Quiz Question: what is the RSS on TEST data for the model with the degree selected from Validation data?**


```python
125529337848195.64
```
