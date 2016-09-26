
# Kaggle - Facebook recruiting


```python
import numpy as np
import pandas as pd
import os
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
import time
import seaborn as sns 
import os
%matplotlib inline
os.chdir('E:\\Google Drive\\kaggle\\03-facebook\\data')
```

## Part 1 - Loading data
This will include sampling the data to 1M rows in case we want to do anything computationally tricky.


```python
df_train = pd.read_csv("train.csv")
df_test = pd.read_csv("test.csv")
df_train.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>row_id</th>
      <th>x</th>
      <th>y</th>
      <th>accuracy</th>
      <th>time</th>
      <th>place_id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0</td>
      <td>0.7941</td>
      <td>9.0809</td>
      <td>54</td>
      <td>470702</td>
      <td>8523065625</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>5.9567</td>
      <td>4.7968</td>
      <td>13</td>
      <td>186555</td>
      <td>1757726713</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2</td>
      <td>8.3078</td>
      <td>7.0407</td>
      <td>74</td>
      <td>322648</td>
      <td>1137537235</td>
    </tr>
    <tr>
      <th>3</th>
      <td>3</td>
      <td>7.3665</td>
      <td>2.5165</td>
      <td>65</td>
      <td>704587</td>
      <td>6567393236</td>
    </tr>
    <tr>
      <th>4</th>
      <td>4</td>
      <td>4.0961</td>
      <td>1.1307</td>
      <td>31</td>
      <td>472130</td>
      <td>7440663949</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Sample them for quicker visualisations
df_train_sample = df_train.sample(n=1000000)
df_test_sample = df_test.sample(n=1000000)
```

## Part 2 - Quick visualisations
Let's start with some basic histograms, showing the distribution of accuracy and time.


```python
counts1, bins1 = np.histogram(df_train["accuracy"], bins=50)
binsc1 = bins1[:-1] + np.diff(bins1)/2.

counts2, bins2 = np.histogram(df_test["accuracy"], bins=50)
binsc2 = bins2[:-1] + np.diff(bins2)/2.

plt.figure(0, figsize=(14,4))

plt.subplot(121)
plt.bar(binsc1, counts1/(counts1.sum()*1.0), width=np.diff(bins1)[0])
plt.grid(True)
plt.xlabel("Accuracy")
plt.ylabel("Fraction")
plt.title("Train")

plt.subplot(122)
plt.bar(binsc2, counts2/(counts2.sum()*1.0), width=np.diff(bins2)[0])
plt.grid(True)
plt.xlabel("Accuracy")
plt.ylabel("Fraction")
plt.title("Test")

plt.show()
```


![png](output_6_0.png)


Accuracy has some interesting structure, but is relatively consistent across train/test.  
Check time distributions:


```python
current_palette = sns.color_palette()

counts1, bins1 = np.histogram(df_train["time"], bins=50)
binsc1 = bins1[:-1] + np.diff(bins1)/2.

counts2, bins2 = np.histogram(df_test["time"], bins=50)
binsc2 = bins2[:-1] + np.diff(bins2)/2.

plt.figure(1, figsize=(12,3))

plt.subplot(121)
plt.bar(binsc1, counts1/(counts1.sum()*1.0), width=np.diff(bins1)[0], color=current_palette[0])
plt.grid(True)
plt.xlabel("Time")
plt.ylabel("Fraction")
plt.title("Train")

plt.subplot(122)
plt.bar(binsc2, counts2/(counts2.sum()*1.0), width=np.diff(bins2)[0], color=current_palette[1])
plt.grid(True)
plt.xlabel("Time")
plt.ylabel("Fraction")
plt.title("Test")

plt.show()
```


![png](output_8_0.png)



```python
plt.figure(2, figsize=(12,3))
plt.bar(binsc1, counts1/(counts1.sum()*1.0), width=np.diff(bins1)[0], color=current_palette[0], label="Train")
plt.bar(binsc2, counts2/(counts2.sum()*1.0), width=np.diff(bins2)[0], color=current_palette[1], label="Test")
plt.grid(True)
plt.xlabel("Time")
plt.ylabel("Fraction")
plt.title("Test")
plt.legend()
plt.show()
```


![png](output_9_0.png)



The two dips of time in training set are curious, if looking at counts per unit time they might need to be normalised.  
Another thing we can look at is how frequently different locations appear.


```python
# Check how how frequently different locations appear
df_placecounts = df_train["place_id"].value_counts()

counts, bins = np.histogram(df_placecounts.values, bins=50)
binsc = bins[:-1] + np.diff(bins)/2.

plt.figure(3, figsize=(12,6))
plt.bar(binsc, counts/(counts.sum()*1.0), width=np.diff(bins)[0])
plt.grid(True)
plt.xlabel("Number of place occurances")
plt.ylabel("Fraction")
plt.title("Train")
plt.show()
```


![png](output_11_0.png)


OK, so most places appear around 100 times.  
Let's see if accuracy changes with "time" at all:


```python
 # Check if accuracy of signal corresponds with time
plt.figure(4, figsize=(12,10))

plt.subplot(211)
plt.scatter(df_train_sample["time"], df_train_sample["accuracy"], s=1, c='k', lw=0, alpha=0.1)
plt.xlabel("Time")
plt.ylabel("Accuracy")
plt.xlim(df_train_sample["time"].min(), df_train_sample["time"].max())
plt.ylim(df_train_sample["accuracy"].min(), df_train_sample["accuracy"].max())
plt.title("Train")

plt.subplot(212)
plt.scatter(df_test_sample["time"], df_test_sample["accuracy"], s=1, c='k', lw=0, alpha=0.1)
plt.xlabel("Time")
plt.ylabel("Accuracy")
plt.xlim(df_test_sample["time"].min(), df_test_sample["time"].max())
plt.ylim(df_test_sample["accuracy"].min(), df_test_sample["accuracy"].max())
plt.title("Test")

plt.show()
```


![png](output_13_0.png)


Not really - but we can see the two time dips in the training plot, and this emphases that accuracy is somewhat perfentially banded.  
What about if the accuracy varies with location?


```python
# Does the accuracy vary with location?  Check within 100x100m spots
df_train_sample["xround"] = df_train_sample["x"].round(decimals=1)
df_train_sample["yround"] = df_train_sample["y"].round(decimals=1)
df_groupxy = df_train_sample.groupby(["xround", "yround"]).agg({"accuracy":[np.mean, np.std]})
df_groupxy.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th colspan="2" halign="left">accuracy</th>
    </tr>
    <tr>
      <th></th>
      <th></th>
      <th>mean</th>
      <th>std</th>
    </tr>
    <tr>
      <th>xround</th>
      <th>yround</th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="5" valign="top">0</th>
      <th>0.0</th>
      <td>47.000000</td>
      <td>27.849596</td>
    </tr>
    <tr>
      <th>0.1</th>
      <td>96.105263</td>
      <td>167.946869</td>
    </tr>
    <tr>
      <th>0.2</th>
      <td>84.545455</td>
      <td>108.877241</td>
    </tr>
    <tr>
      <th>0.3</th>
      <td>129.541667</td>
      <td>178.145026</td>
    </tr>
    <tr>
      <th>0.4</th>
      <td>57.625000</td>
      <td>40.754634</td>
    </tr>
  </tbody>
</table>
</div>




```python
idx = np.asarray(list(df_groupxy.index.values))
plt.figure(5, figsize=(14,6))

plt.subplot(121)
plt.scatter(idx[:,0], idx[:,1], s=20, c=df_groupxy["accuracy", "mean"], marker='s', lw=0, cmap=plt.cm.viridis)
plt.colorbar().set_label("Mean accuracy")
plt.grid(True)
plt.xlabel("X")
plt.ylabel("Y")
plt.xlim(0,10)
plt.ylim(0,10)

plt.subplot(122)
plt.scatter(idx[:,0], idx[:,1], s=20, c=df_groupxy["accuracy", "std"], marker='s', lw=0, cmap=plt.cm.viridis)
plt.colorbar().set_label("Std accuracy")
plt.grid(True)
plt.xlabel("X")
plt.ylabel("Y")
plt.xlim(0,10)
plt.ylim(0,10)

plt.tight_layout()
plt.show()
```


![png](output_16_0.png)


No major structure here.

## Part 3 - Exploring places and times
For the next parts, I've created a list of the top places (by check in counts), and chosen the top 20 to investigate further.


```python
# Get a list of the top 20 places for future reference
df_topplaces = df_placecounts.iloc[0:20]
l_topplaces = list(df_topplaces.index)
print(l_topplaces)
```

    [8772469670, 1623394281, 1308450003, 4823777529, 9586338177, 9129780742, 9544215131, 5351837004, 4638096372, 8610202964, 6051554924, 7363774279, 8607353836, 8336299754, 5204012807, 7230349735, 7985287621, 4371034975, 4993591840, 7348940462]
    


```python
# Check if any of the top places have time correlated visits
plt.figure(6, figsize=(14,10))
for i in range(len(l_topplaces)):
    place = l_topplaces[i]

    df_place = df_train[df_train["place_id"]==place]

    counts, bins = np.histogram(df_place["time"], bins=50, range=[df_train["time"].min(), df_train["time"].max()])
    binsc = bins[:-1] + np.diff(bins)/2.
    
    plt.subplot(5,4,i+1)
    plt.bar(binsc, counts/(counts.sum()*1.0), width=np.diff(bins)[0])
    plt.xlim(df_train["time"].min(), df_train["time"].max())
    plt.grid(True)
    plt.xlabel("Time")
    plt.ylabel("Fraction")
    plt.gca().get_xaxis().set_ticks([])
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_20_0.png)


Well, some places are visited at certain time periods for sure, but can't do much else until we disentangle time.  

The time interval in train goes from 1 - 800,000, presumably we can modulo these times to view cyclic nature (hours of days, days of week, etc).  
The best guess is seconds or minutes, which would equate to the training spanning 9 or 555 days respectively.


```python
# Try to infer time
plt.figure(7, figsize=(14,10))
for i in range(len(l_topplaces)):
    place = l_topplaces[i]

    df_place = df_train[df_train["place_id"]==place]

    # Try % 3600*24 to see daily trend assuming it's in seconds
    # Try %   60*24 if minutes
    counts, bins = np.histogram(df_place["time"]%(60*24), bins=50)
    binsc = bins[:-1] + np.diff(bins)/2.
    
    plt.subplot(5,4,i+1)
    plt.bar(binsc, counts/(counts.sum()*1.0), width=np.diff(bins)[0])
    plt.grid(True)
    plt.xlabel("Time")
    plt.ylabel("Fraction")
    plt.gca().get_xaxis().set_ticks([])
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_22_0.png)


Minutes looks pretty promising.  
This means we have ~555 days in train and ~140 in test.  
From this, we can look at day of week to identify trends (weekends), day (to find longer term seasonality).  
The next step is to add some columns representing our new time.  
Getting this exactly right (within the minute, so that "hours" are defined by clock hours, which probably correlate better with place visits) will probably be crucial later on, but as a first it doesn't matter if we're out by a bit.


```python
# Add some columns to make calculations easier
df_train["hour"] = (df_train["time"]%(60*24))/60.
df_train["dayofweek"] = np.ceil((df_train["time"]%(60*24*7))/(60.*24))
df_train["dayofyear"] = np.ceil((df_train["time"]%(60*24*365))/(60.*24))
df_train.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>row_id</th>
      <th>x</th>
      <th>y</th>
      <th>accuracy</th>
      <th>time</th>
      <th>place_id</th>
      <th>hour</th>
      <th>dayofweek</th>
      <th>dayofyear</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0</td>
      <td>0.7941</td>
      <td>9.0809</td>
      <td>54</td>
      <td>470702</td>
      <td>8523065625</td>
      <td>21.033333</td>
      <td>5</td>
      <td>327</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>5.9567</td>
      <td>4.7968</td>
      <td>13</td>
      <td>186555</td>
      <td>1757726713</td>
      <td>13.250000</td>
      <td>4</td>
      <td>130</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2</td>
      <td>8.3078</td>
      <td>7.0407</td>
      <td>74</td>
      <td>322648</td>
      <td>1137537235</td>
      <td>1.466667</td>
      <td>1</td>
      <td>225</td>
    </tr>
    <tr>
      <th>3</th>
      <td>3</td>
      <td>7.3665</td>
      <td>2.5165</td>
      <td>65</td>
      <td>704587</td>
      <td>6567393236</td>
      <td>7.116667</td>
      <td>7</td>
      <td>125</td>
    </tr>
    <tr>
      <th>4</th>
      <td>4</td>
      <td>4.0961</td>
      <td>1.1307</td>
      <td>31</td>
      <td>472130</td>
      <td>7440663949</td>
      <td>20.833333</td>
      <td>6</td>
      <td>328</td>
    </tr>
  </tbody>
</table>
</div>




```python
df_train_sample["hour"] = (df_train_sample["time"]%(60*24))/60.
df_train_sample["dayofweek"] = np.ceil((df_train_sample["time"]%(60*24*7))/(60.*24))
df_train_sample["dayofyear"] = np.ceil((df_train_sample["time"]%(60*24*365))/(60.*24))
```

Look at the aggregate number of visits per weekday for the top 20 locations, this should show weekends, hopefully.


```python
# Check the top 20 locations again for any weekly trends
plt.figure(8, figsize=(14,10))
for i in range(20):
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]

    # Group by weekday
    df_groupday = df_place.groupby("dayofweek").agg("count")

    plt.subplot(5,4,i+1)
    plt.bar(df_groupday.index.values-0.5, df_groupday["time"], width=1)
    plt.grid(True)
    plt.xlabel("Day")
    plt.ylabel("Count")
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_27_0.png)



Some appear to have weekend-like behvaiour... what about looking at day of year.


```python
plt.figure(9, figsize=(14,10))
for i in range(20):
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]

    # Add some colums
    df_place = df_place[df_place["time"]<(60*24*365)] # Restrict to 1 year so the counts don't double up
    df_groupday = df_place.groupby("dayofyear").agg("count")

    plt.subplot(5,4,i+1)
    plt.bar(df_groupday.index.values-0.5, df_groupday["time"], width=1)
    plt.grid(True)
    plt.xlabel("Day of year")
    plt.ylabel("Count")
    plt.xlim(0,365)
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_29_0.png)


Somewhat weird trends, looks like some of the top places only opened up business part way through.
The next interesting thing is to look at the distribution of (x,y) points for a given location:


```python
# Check the 2d distribution of (x,y) for the top 20 places
plt.figure(10, figsize=(14,16))
cmapm = plt.cm.viridis
cmapm.set_bad("0.5",1.)

for i in range(len(l_topplaces)):
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]
    counts, binsX, binsY = np.histogram2d(df_place["x"], df_place["y"], bins=100)
    extent = [binsX.min(),binsX.max(),binsY.min(),binsY.max()]

    plt.subplot(5,4,i+1)
    plt.imshow(np.log10(counts.T),
               interpolation='none',
               origin='lower',
               extent=extent,
               aspect="auto",
               cmap=cmapm)
    plt.grid(True, c='0.6', lw=0.5)
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("pid: " + str(place))

plt.tight_layout()
plt.show()
```


![png](output_31_0.png)


The distributions are different for different locations, but many span a huge x-range relative to the y-range (maybe roads are aligned this way?)  
Let's re-visit the accuracy to see if it changes we get further away from the presumed centroid location:


```python
# See if the accuracy varies with distance from centroid point
plt.figure(11, figsize=(14,16))

for i in range(len(l_topplaces)):
    plt.subplot(5,4,i+1)
    plt.gca().set_axis_bgcolor("0.5")
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]
    plt.scatter(df_place["x"], df_place["y"], s=10, c=df_place["accuracy"], lw=0, cmap=plt.cm.viridis)
    plt.grid(True, c='0.6', lw=0.5)
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_33_0.png)


Nope, not really. What about time variance per location?


```python
# See if the time varies with distance from centroid point
plt.figure(12, figsize=(14,16))

for i in range(len(l_topplaces)):
    plt.subplot(5,4,i+1)
    plt.gca().set_axis_bgcolor("0.5")
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]
    plt.scatter(df_place["x"], df_place["y"], s=10, c=df_place["hour"], lw=0, cmap=plt.cm.viridis)
    plt.grid(True, c='0.6', lw=0.5)
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("pid: " + str(place))
    
plt.tight_layout()
plt.show()
```


![png](output_35_0.png)


This certainly shows different places are preferentially visited at different hours.  
This will be useful for predictions, since for a given "hour" the list of probably places will be reduced.  
Let's pick an arbitrary place, and see if it's shape is discernible over the background noise.


```python
# Pick a place, and see if it's shape profile stands out against background noise (i.e., every other point)
i = 11
place = l_topplaces[i]
df_place = df_train[df_train["place_id"]==place]
xmin, xmax = df_place["x"].min(), df_place["x"].max()
ymin, ymax = df_place["y"].min(), df_place["y"].max()
df_noise = df_train[(df_train["x"]>xmin) &
                    (df_train["x"]<xmax) &
                    (df_train["y"]>ymin) &
                    (df_train["y"]<ymax)]

plt.figure(13, figsize=(8,4))
plt.subplot(121)
plt.gca().set_axis_bgcolor("0.5")
plt.scatter(df_noise["x"], df_noise["y"], s=10, c='k', lw=0, alpha=0.005)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("pid: " + str(place))
plt.xlim(xmin,xmax)
plt.ylim(ymin,ymax)
plt.grid(True, c='0.6', lw=0.5)

plt.subplot(122)
plt.gca().set_axis_bgcolor("0.5")
plt.scatter(df_noise["x"], df_noise["y"], s=10, c='k', lw=0, alpha=0.005)
plt.scatter(df_place["x"], df_place["y"], s=10, c=current_palette[5], lw=0, alpha=0.5)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("pid: " + str(place))
plt.xlim(xmin,xmax)
plt.ylim(ymin,ymax)
plt.grid(True, c='0.6', lw=0.5)

plt.tight_layout()
plt.show()

```


![png](output_37_0.png)


...not really. OK, let's revisit this x-axis stretching business by visualising these top 20 locations on a map.


```python
# Go back to the x-axis stretching, and visualise some location checkins on a map
plt.figure(14, figsize=(12,12))

for i in range(20):
    place = l_topplaces[i]
    df_place = df_train[df_train["place_id"]==place]
    plt.scatter(df_place["x"], df_place["y"], s=3, alpha=0.5, c=plt.cm.viridis(int(i*(255/20.))), lw=0)
    
plt.grid(True)
plt.xlabel("X")
plt.ylabel("Y")
plt.tight_layout()
plt.xlim(0,10)
plt.ylim(0,10)
plt.show()
```


![png](output_39_0.png)


This highlights the variance, looking suspiciously like streets. We can look at the standard deviations to illustrate this:


```python
# Check the stdev of x/y for each place
df_groupplace = df_train.groupby("place_id").agg({"time":"count", "x":"std", "y":"std"})
df_groupplace.sort_values(by="time", inplace=True, ascending=False)
df_groupplace.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>y</th>
      <th>x</th>
      <th>time</th>
    </tr>
    <tr>
      <th>place_id</th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>8772469670</th>
      <td>0.011544</td>
      <td>0.356140</td>
      <td>1849</td>
    </tr>
    <tr>
      <th>1623394281</th>
      <td>0.015712</td>
      <td>0.240642</td>
      <td>1802</td>
    </tr>
    <tr>
      <th>1308450003</th>
      <td>0.017662</td>
      <td>0.340147</td>
      <td>1757</td>
    </tr>
    <tr>
      <th>4823777529</th>
      <td>0.011860</td>
      <td>0.476614</td>
      <td>1738</td>
    </tr>
    <tr>
      <th>9586338177</th>
      <td>0.014817</td>
      <td>0.507308</td>
      <td>1718</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Density plot
gkde_stddevx = gaussian_kde(df_groupplace["x"][~df_groupplace["x"].isnull()].values)
gkde_stddevy = gaussian_kde(df_groupplace["y"][~df_groupplace["y"].isnull()].values)

# Compute the functions
rangeX = np.linspace(0, 3, 100)
x_density = gkde_stddevx(rangeX)
y_density = gkde_stddevy(rangeX)

plt.figure(15, figsize=(12,6))
plt.subplot(111)
plt.plot(rangeX, x_density, c=current_palette[0], ls="-", alpha=0.75)
plt.plot(rangeX, y_density, c=current_palette[1], ls="-", alpha=0.75)
plt.gca().fill_between(rangeX, 0, x_density, facecolor=current_palette[0], alpha=0.2)
plt.gca().fill_between(rangeX, 0, y_density, facecolor=current_palette[1], alpha=0.2)
plt.ylabel("Density")
plt.xlabel("Std dev")
plt.plot([], [], c=current_palette[0], alpha=0.2, linewidth=10, label="stddev x")
plt.plot([], [], c=current_palette[1], alpha=0.2, linewidth=10, label="stddev y")
plt.legend()
plt.grid(True)
```


![png](output_42_0.png)


That's pretty striking and will be useful later on.  
Back to time, what if the accuracy varies as a function of hour of day?


```python
# With the new found time features, we can re-check how accuracy varies with it:
plt.figure(19, figsize=(12,6))
plt.scatter(df_train_sample["hour"], df_train_sample["accuracy"], s=1, c='k', lw=0, alpha=0.05)
plt.xlabel("Hour")
plt.ylabel("Accuracy")
plt.xlim(df_train_sample["hour"].min(), df_train_sample["hour"].max())
plt.ylim(df_train_sample["accuracy"].min(), df_train_sample["accuracy"].max())
plt.title("Train")
plt.show()
```


![png](output_44_0.png)


Pretty consistent...

## Part 4 - Predictions pre-processing  
One method of determining which place a location might check in to is by looking at the density of points previously used to checkin.  
You could check each point against each density map, and take the maximum.


```python

# Try some KDEs, if we can define the density where check-ins are likely, maybe we can assign points based on this
# They will also be time variant
i = 11
place = l_topplaces[i]
df_place = df_train[df_train["place_id"]==place]
xmin, xmax = df_place["x"].min(), df_place["x"].max()
ymin, ymax = df_place["y"].min(), df_place["y"].max()

# Calculate the KDE
res = 200 # resolution
gkde_place = gaussian_kde(np.asarray((df_place["x"], df_place["y"])))
x_flat = np.linspace(xmin, xmax, res)
y_flat = np.linspace(ymin, ymax, res)
x, y = np.meshgrid(x_flat,y_flat)
grid_coords = np.append(x.reshape(-1,1),y.reshape(-1,1),axis=1)
z = gkde_place(grid_coords.T)
z = z.reshape(res,res)

# Plot
extent = [xmin,xmax,ymin,ymax]
plt.figure(20, figsize=(12,6))

# KDE only
plt.subplot(121)
plt.imshow(z[::-1,:],
           extent=extent,
           aspect="auto",
           cmap=plt.cm.viridis,
           interpolation="bilinear")
plt.grid(False)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("pid: " + str(place))
plt.xlim(xmin,xmax)
plt.ylim(ymin,ymax)

# Overplot the points
plt.subplot(122)
plt.imshow(z[::-1,:],
           extent=extent,
           aspect="auto",
           cmap=plt.cm.viridis,
           interpolation="bilinear")
plt.colorbar().set_label("density")
plt.scatter(df_place["x"], df_place["y"], s=10, c='k', lw=0, alpha=0.5)
plt.grid(False)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("pid: " + str(place))
plt.xlim(xmin,xmax)
plt.ylim(ymin,ymax)

plt.tight_layout()
plt.show()
```


![png](output_47_0.png)



```python
# Try some more
pids = [0,8,9,10,11,14] # A few places
kdes = []
plt.figure(21, figsize=(14,5))
for i in range(len(pids)):
    place = l_topplaces[pids[i]]
    df_place = df_train[df_train["place_id"]==place]
    xmin, xmax = df_place["x"].min(), df_place["x"].max()
    ymin, ymax = df_place["y"].min(), df_place["y"].max()

    # Calculate the KDE
    res = 50 # resolution
    gkde_place = gaussian_kde(np.asarray((df_place["x"], df_place["y"])))
    kdes.append(gkde_place) # Keep these KDEs for later
    x_flat = np.linspace(xmin, xmax, res)
    y_flat = np.linspace(ymin, ymax, res)
    x, y = np.meshgrid(x_flat,y_flat)
    grid_coords = np.append(x.reshape(-1,1),y.reshape(-1,1),axis=1)
    z = gkde_place(grid_coords.T)
    z = z.reshape(res,res)

    # Plot
    extent = [xmin,xmax,ymin,ymax]
    
    # KDE only
    plt.subplot(2,6,i+1)
    plt.imshow(z[::-1,:],
               extent=extent,
               aspect="auto",
               cmap=plt.cm.viridis,
               interpolation="bilinear")
    plt.grid(False)
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("pid: " + str(place))
    plt.xlim(xmin,xmax)
    plt.ylim(ymin,ymax)

    # Overplot the points
    plt.subplot(2,6,i+7)
    plt.imshow(z[::-1,:],
               extent=extent,
               aspect="auto",
               cmap=plt.cm.viridis,
               interpolation="bilinear")
    plt.scatter(df_place["x"], df_place["y"], s=5, c='k', lw=0, alpha=0.5)
    plt.grid(False)
    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("pid: " + str(place))
    plt.xlim(xmin,xmax)
    plt.ylim(ymin,ymax)

plt.tight_layout()
plt.show()
```


![png](output_48_0.png)


Next steps?  
- Could try using KDEs of each place to get a metric for each (x,y) location indicating how close to the place it is  
- Play with time offset to try and get more precise definition of hours  
- Use time to eliminate certain places from being possible at given hours  
- Find out what accuracy does  


```python

```
