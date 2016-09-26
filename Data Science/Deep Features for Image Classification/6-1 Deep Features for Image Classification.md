

```python
import graphlab
```

# Load Data


```python
image_train = graphlab.SFrame('image_train_data/')
image_test = graphlab.SFrame('image_test_data/')
```

    [INFO] This non-commercial license of GraphLab Create is assigned to chok20734@gmail.com and will expire on October 03, 2016. For commercial licensing options, visit https://dato.com/buy/.
    
    [INFO] Start server at: ipc:///tmp/graphlab_server-8156 - Server binary: C:\Users\Kyu\AppData\Local\Dato\Dato Launcher\lib\site-packages\graphlab\unity_server.exe - Server log: C:\Users\Kyu\AppData\Local\Temp\graphlab_server_1446725709.log.0
    [INFO] GraphLab Server Version: 1.6.1
    

#Explore Data


```python
graphlab.canvas.set_target('ipynb')
```


```python
image_train['image'].show()
```




```python
image_train.head()
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">id</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">image</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">label</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">deep_features</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">image_array</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">24</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.242871880531,<br>1.09545278549, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[73.0, 77.0, 58.0, 71.0,<br>68.0, 50.0, 77.0, 69.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">33</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.525087535381, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[7.0, 5.0, 8.0, 7.0, 5.0,<br>8.0, 5.0, 4.0, 6.0, 7.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.566015660763, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[169.0, 122.0, 65.0,<br>131.0, 108.0, 75.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">70</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.1297955513, 0.0, 0.0,<br>0.778193771839, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[154.0, 179.0, 152.0,<br>159.0, 183.0, 157.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">90</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.71787023544, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[216.0, 195.0, 180.0,<br>201.0, 178.0, 160.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">97</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.57818543911, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[33.0, 44.0, 27.0, 29.0,<br>44.0, 31.0, 32.0, 45.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">107</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0,<br>0.220678329468, 0.0,  ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[97.0, 51.0, 31.0, 104.0,<br>58.0, 38.0, 107.0, 61.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">121</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.237534105778,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[93.0, 96.0, 88.0, 102.0,<br>106.0, 97.0, 117.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">136</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0, 0.0, 0.0, 0.0,<br>0.0, 7.57378196716, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[35.0, 59.0, 53.0, 36.0,<br>56.0, 56.0, 42.0, 62.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">138</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.658935904503, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[205.0, 193.0, 195.0,<br>200.0, 187.0, 193.0, ...</td>
    </tr>
</table>
[10 rows x 5 columns]<br/>
</div>



# Build Logistic Model with Raw Data


```python
raw_pixel_model = graphlab.logistic_classifier.create(image_train,
                                                      target='label',
                                              features=['image_array'])
```

    PROGRESS: Creating a validation set from 5 percent of training data. This may take a while.
              You can set ``validation_set=None`` to disable validation tracking.
    
    PROGRESS: Logistic regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 1924
    PROGRESS: Number of classes           : 4
    PROGRESS: Number of feature columns   : 1
    PROGRESS: Number of unpacked features : 3072
    PROGRESS: Number of coefficients    : 9219
    PROGRESS: Starting L-BFGS
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    PROGRESS: | Iteration | Passes   | Step size | Elapsed Time | Training-accuracy | Validation-accuracy |
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    PROGRESS: | 1         | 6        | 0.000015  | 2.189425     | 0.331081          | 0.345679            |
    PROGRESS: | 2         | 8        | 1.000000  | 2.646456     | 0.364345          | 0.333333            |
    PROGRESS: | 3         | 9        | 1.000000  | 2.945468     | 0.433992          | 0.358025            |
    PROGRESS: | 4         | 10       | 1.000000  | 3.248484     | 0.445426          | 0.419753            |
    PROGRESS: | 5         | 11       | 1.000000  | 3.562501     | 0.453742          | 0.407407            |
    PROGRESS: | 6         | 12       | 1.000000  | 3.867524     | 0.467775          | 0.432099            |
    PROGRESS: | 10        | 16       | 1.000000  | 5.014349     | 0.517672          | 0.407407            |
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    

# Prediction


```python
image_test[0:3]['image'].show()
```




```python
image_test[0:3]['label']
```




    dtype: str
    Rows: 3
    ['cat', 'automobile', 'cat']




```python
raw_pixel_model.predict(image_test[0:3])
```




    dtype: str
    Rows: 3
    ['bird', 'cat', 'bird']



#Evaluation


```python
raw_pixel_model.evaluate(image_test)
```




    {'accuracy': 0.47375, 'confusion_matrix': Columns:
     	target_label	str
     	predicted_label	str
     	count	int
     
     Rows: 16
     
     Data:
     +--------------+-----------------+-------+
     | target_label | predicted_label | count |
     +--------------+-----------------+-------+
     |     bird     |       dog       |  170  |
     |     dog      |       cat       |  247  |
     |     cat      |       cat       |  339  |
     |     bird     |    automobile   |  151  |
     |  automobile  |    automobile   |  639  |
     |     dog      |    automobile   |  111  |
     |     dog      |       dog       |  404  |
     |     cat      |       dog       |  287  |
     |  automobile  |       dog       |  102  |
     |  automobile  |       bird      |  105  |
     +--------------+-----------------+-------+
     [16 rows x 3 columns]
     Note: Only the head of the SFrame is printed.
     You can use print_rows(num_rows=m, num_columns=n) to print more rows and columns.}



##Can we improve the model using deep features?
With small data, training deep neural network isn't very effective, So we will use transfer learning by using full ImageNet dataset and build simple model.


```python
len(image_train)
```




    2005




```python
# Transfering features to next model, create 'deep_features' column
deep_learning_model = graphlab.load_model('http://s3.amazonaws.com/GraphLab-Datasets/deeplearning/imagenet_model_iter45')
image_train['deep_features'] = deep_learning_model.extract_features(image_train)
```

    PROGRESS: Images being resized.
    


```python
image_train.head()
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">id</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">image</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">label</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">deep_features</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">image_array</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">24</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.242871880531,<br>1.09545278549, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[73.0, 77.0, 58.0, 71.0,<br>68.0, 50.0, 77.0, 69.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">33</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.525087535381, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[7.0, 5.0, 8.0, 7.0, 5.0,<br>8.0, 5.0, 4.0, 6.0, 7.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.566015660763, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[169.0, 122.0, 65.0,<br>131.0, 108.0, 75.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">70</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.1297955513, 0.0, 0.0,<br>0.778193771839, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[154.0, 179.0, 152.0,<br>159.0, 183.0, 157.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">90</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.71787023544, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[216.0, 195.0, 180.0,<br>201.0, 178.0, 160.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">97</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.57818543911, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[33.0, 44.0, 27.0, 29.0,<br>44.0, 31.0, 32.0, 45.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">107</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0,<br>0.220678329468, 0.0,  ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[97.0, 51.0, 31.0, 104.0,<br>58.0, 38.0, 107.0, 61.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">121</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.237534105778,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[93.0, 96.0, 88.0, 102.0,<br>106.0, 97.0, 117.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">136</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0, 0.0, 0.0, 0.0,<br>0.0, 7.57378196716, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[35.0, 59.0, 53.0, 36.0,<br>56.0, 56.0, 42.0, 62.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">138</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.658935904503, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[205.0, 193.0, 195.0,<br>200.0, 187.0, 193.0, ...</td>
    </tr>
</table>
[10 rows x 5 columns]<br/>
</div>



# Build Logistic Model with Deep Features


```python
deep_features_model = graphlab.logistic_classifier.create(image_train,
                                                          target='label',
                                                         features=['deep_features'])
```

    PROGRESS: Creating a validation set from 5 percent of training data. This may take a while.
              You can set ``validation_set=None`` to disable validation tracking.
    
    PROGRESS: WARNING: Detected extremely low variance for feature(s) 'deep_features' because all entries are nearly the same.
    Proceeding with model training using all features. If the model does not provide results of adequate quality, exclude the above mentioned feature(s) from the input dataset.
    PROGRESS: Logistic regression:
    PROGRESS: --------------------------------------------------------
    PROGRESS: Number of examples          : 1917
    PROGRESS: Number of classes           : 4
    PROGRESS: Number of feature columns   : 1
    PROGRESS: Number of unpacked features : 4096
    PROGRESS: Number of coefficients    : 12291
    PROGRESS: Starting L-BFGS
    PROGRESS: --------------------------------------------------------
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    PROGRESS: | Iteration | Passes   | Step size | Elapsed Time | Training-accuracy | Validation-accuracy |
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    PROGRESS: | 1         | 5        | 0.000130  | 1.400652     | 0.752739          | 0.704545            |
    PROGRESS: | 2         | 9        | 0.250000  | 2.636977     | 0.764215          | 0.727273            |
    PROGRESS: | 3         | 10       | 0.250000  | 3.093754     | 0.768388          | 0.727273            |
    PROGRESS: | 4         | 11       | 0.250000  | 3.557657     | 0.776213          | 0.738636            |
    PROGRESS: | 5         | 12       | 0.250000  | 4.004689     | 0.781429          | 0.761364            |
    PROGRESS: | 6         | 13       | 0.250000  | 4.443714     | 0.791862          | 0.761364            |
    PROGRESS: | 10        | 17       | 0.250000  | 6.236416     | 0.865936          | 0.761364            |
    PROGRESS: +-----------+----------+-----------+--------------+-------------------+---------------------+
    

# Prediction


```python
image_test[0:3]['image'].show()
```




```python
deep_features_model.predict(image_test[0:3])
```




    dtype: str
    Rows: 3
    ['cat', 'automobile', 'cat']



# Evaluation


```python
deep_features_model.evaluate(image_test)
```




    {'accuracy': 0.787, 'confusion_matrix': Columns:
     	target_label	str
     	predicted_label	str
     	count	int
     
     Rows: 16
     
     Data:
     +--------------+-----------------+-------+
     | target_label | predicted_label | count |
     +--------------+-----------------+-------+
     |     dog      |    automobile   |   14  |
     |     bird     |       bird      |  788  |
     |  automobile  |       bird      |   24  |
     |  automobile  |       cat       |   13  |
     |  automobile  |    automobile   |  954  |
     |     bird     |    automobile   |   24  |
     |     dog      |       bird      |   39  |
     |     cat      |    automobile   |   37  |
     |     cat      |       cat       |  637  |
     |     bird     |       cat       |  115  |
     +--------------+-----------------+-------+
     [16 rows x 3 columns]
     Note: Only the head of the SFrame is printed.
     You can use print_rows(num_rows=m, num_columns=n) to print more rows and columns.}




```python

```
