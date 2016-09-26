

```python
import graphlab
```

# Load Data


```python
image_train = graphlab.SFrame('image_train_data/')
image_test = graphlab.SFrame('image_test_data/')
```


```python
# Transfering features to next model, create 'deep_features' column
deep_learning_model = graphlab.load_model('http://s3.amazonaws.com/GraphLab-Datasets/deeplearning/imagenet_model_iter45')
image_train['deep_features'] = deep_learning_model.extract_features(image_train)

```

    PROGRESS: Downloading http://s3.amazonaws.com/GraphLab-Datasets/deeplearning/imagenet_model_iter45/dir_archive.ini to C:/Users/Kyu/AppData/Local/Temp/graphlab-Kyu/228/6a100dbe-7b4b-4dd0-819d-a0b48d7f4950.ini
    PROGRESS: Downloading http://s3.amazonaws.com/GraphLab-Datasets/deeplearning/imagenet_model_iter45/objects.bin to C:/Users/Kyu/AppData/Local/Temp/graphlab-Kyu/228/94bcbe63-4048-420c-a60b-f6535149d26c.bin
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
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.242871761322,<br>1.09545373917, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[73.0, 77.0, 58.0, 71.0,<br>68.0, 50.0, 77.0, 69.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">33</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.525087952614, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[7.0, 5.0, 8.0, 7.0, 5.0,<br>8.0, 5.0, 4.0, 6.0, 7.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">cat</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.566015958786, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[169.0, 122.0, 65.0,<br>131.0, 108.0, 75.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">70</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.12979578972, 0.0, 0.0,<br>0.778194487095, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[154.0, 179.0, 152.0,<br>159.0, 183.0, 157.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">90</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.71786928177, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[216.0, 195.0, 180.0,<br>201.0, 178.0, 160.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">97</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[1.57818555832, 0.0, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[33.0, 44.0, 27.0, 29.0,<br>44.0, 31.0, 32.0, 45.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">107</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">dog</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0,<br>0.220677852631, 0.0,  ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[97.0, 51.0, 31.0, 104.0,<br>58.0, 38.0, 107.0, 61.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">121</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.23753464222, 0.0,<br>0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[93.0, 96.0, 88.0, 102.0,<br>106.0, 97.0, 117.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">136</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">automobile</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.0, 0.0, 0.0, 0.0, 0.0,<br>0.0, 7.5737862587, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[35.0, 59.0, 53.0, 36.0,<br>56.0, 56.0, 42.0, 62.0, ...</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">138</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">Height: 32 Width: 32</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">bird</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[0.658935725689, 0.0,<br>0.0, 0.0, 0.0, 0.0, ...</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">[205.0, 193.0, 195.0,<br>200.0, 187.0, 193.0, ...</td>
    </tr>
</table>
[10 rows x 5 columns]<br/>
</div>



# Build KNN Model


```python
knn_model = graphlab.nearest_neighbors.create(image_train,
                                              features=['deep_features'],
                                             label='id')
```

    PROGRESS: Starting brute force nearest neighbors model training.
    

## Retriving Cat


```python
# Let's find similar images to this cat picture.
graphlab.canvas.set_target('ipynb')
cat = image_train[18:19]
cat['image'].show()
```




```python
knn_model.query(cat)
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 29.003ms     |
    PROGRESS: | Done         |         | 100         | 148.337ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">query_label</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">reference_label</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">distance</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">rank</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">384</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0.0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">1</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">6910</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36.9403137951</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">2</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39777</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.4634888975</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">3</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36870</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.7559623119</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">4</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">0</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41734</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.7866014148</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">5</td>
    </tr>
</table>
[5 rows x 4 columns]<br/>
</div>




```python
# This function will match the 'id' in image_train with 'reference_lebel' in query_result
def get_images_from_ids(query_result):
    return image_train.filter_by(query_result['reference_label'],'id')
```


```python
cat_neighbors = get_images_from_ids(knn_model.query(cat))
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 9.001ms      |
    PROGRESS: | Done         |         | 100         | 154.927ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    


```python
cat_neighbors['image'].show()
```



## Retriving Car


```python
car = image_train[8:9]
car['image'].show()
```




```python
# Short cut of the previous commend
get_images_from_ids(knn_model.query(car))['image'].show()
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 22.001ms     |
    PROGRESS: | Done         |         | 100         | 151.528ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    



## Create lambda to find and show nearest neighbor images


```python
show_neighbors = lambda i: get_images_from_ids(knn_model.query(image_train[i:i+1]))['image'].show()
```


```python
show_neighbors(1)
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 28.494ms     |
    PROGRESS: | Done         |         | 100         | 141.812ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    




```python
show_neighbors(8)
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 30.001ms     |
    PROGRESS: | Done         |         | 100         | 142.009ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    




```python
show_neighbors(26)
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.0498753   | 34.002ms     |
    PROGRESS: | Done         |         | 100         | 137.007ms    |
    PROGRESS: +--------------+---------+-------------+--------------+
    



# Problem Solving

##1. Computing Summary Statistics of the Data


```python
image_train['label'].sketch_summary()
```




    
    +------------------+-------+----------+
    |       item       | value | is exact |
    +------------------+-------+----------+
    |      Length      |  2005 |   Yes    |
    | # Missing Values |   0   |   Yes    |
    | # unique values  |   4   |    No    |
    +------------------+-------+----------+
    
    Most frequent items:
    +-------+------------+-----+-----+------+
    | value | automobile | cat | dog | bird |
    +-------+------------+-----+-----+------+
    | count |    509     | 509 | 509 | 478  |
    +-------+------------+-----+-----+------+
    



##2. Creating Category-Specific Image Retrieval Models

### Subset Training Data Set


```python
dog = image_train[image_train['label']=='dog']
cat = image_train[image_train['label']=='cat']
automobile = image_train[image_train['label']=='automobile']
bird = image_train[image_train['label']=='bird']
```

### Bulid Model


```python
dog_model = graphlab.nearest_neighbors.create(dog,features=['deep_features'],label='id')
cat_model = graphlab.nearest_neighbors.create(cat,features=['deep_features'],label='id')
automobile_model = graphlab.nearest_neighbors.create(automobile,features=['deep_features'],label='id')
bird_model = graphlab.nearest_neighbors.create(bird,features=['deep_features'],label='id')
```

    PROGRESS: Starting brute force nearest neighbors model training.
    PROGRESS: Starting brute force nearest neighbors model training.
    PROGRESS: Starting brute force nearest neighbors model training.
    PROGRESS: Starting brute force nearest neighbors model training.
    

### Prediction


```python
test = image_test[0:1]
test['image'].show()
```




```python
# This function will match the 'id' in image_train with 'reference_lebel' in query_result
def get_images_from_ids(query_result):
    return image_train.filter_by(query_result['reference_label'],'id')
```


```python
get_images_from_ids(cat_model.query(test))['image'].show()
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.196464    | 5ms          |
    PROGRESS: | Done         |         | 100         | 43.003ms     |
    PROGRESS: +--------------+---------+-------------+--------------+
    




```python
get_images_from_ids(dog_model.query(test))['image'].show()
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.196464    | 8.001ms      |
    PROGRESS: | Done         |         | 100         | 43.003ms     |
    PROGRESS: +--------------+---------+-------------+--------------+
    



##3. A simple example of nearest-neighbors classification


```python
cat_model.query(test)['distance'].mean()
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.196464    | 4.999ms      |
    PROGRESS: | Done         |         | 100         | 35.001ms     |
    PROGRESS: +--------------+---------+-------------+--------------+
    




    36.15573070978294




```python
dog_model.query(test)['distance'].mean()
```

    PROGRESS: Starting pairwise querying.
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | Query points | # Pairs | % Complete. | Elapsed Time |
    PROGRESS: +--------------+---------+-------------+--------------+
    PROGRESS: | 0            | 1       | 0.196464    | 6.999ms      |
    PROGRESS: | Done         |         | 100         | 36.001ms     |
    PROGRESS: +--------------+---------+-------------+--------------+
    




    37.77071136184157



##4. Computing nearest neighbors accuracy using SFrame operations

### Subset Testing Data Set


```python
image_test_dog = image_test[image_test['label']=='dog']
image_test_cat = image_test[image_test['label']=='cat']
image_test_automobile = image_test[image_test['label']=='automobile']
image_test_bird = image_test[image_test['label']=='bird']
```

### Build Models


```python
# finds 1 neighbor of entire dog images by using cat_model
dog_dog_neighbors = dog_model.query(image_test_dog, k=1)
dog_cat_neighbors = cat_model.query(image_test_dog, k=1)
dog_automobile_neighbors = automobile_model.query(image_test_dog, k=1)
dog_bird_neighbors = bird_model.query(image_test_dog, k=1)
```


```python
dog_distances = graphlab.SFrame(dog_distances)
dog_distances['dog-dog'] = dog_dog_neighbors['distance']
dog_distances['dog-cat'] = dog_cat_neighbors['distance']
dog_distances['dog-automobile'] = dog_automobile_neighbors['distance']
dog_distances['dog-bird'] = dog_bird_neighbors['distance']
dog_distances
```




<div style="max-height:1000px;max-width:1500px;overflow:auto;"><table frame="box" rules="cols">
    <tr>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">dog-dog</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">dog-cat</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">dog-automobile</th>
        <th style="padding-left: 1em; padding-right: 1em; text-align: center">dog-bird</th>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">33.4773590373</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36.4196077068</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.9579761457</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.7538647304</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">32.8458495684</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.8353268874</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">46.0021331807</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.3382958925</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">35.0397073189</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">36.9763410854</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">42.9462290692</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.6157590853</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">33.9010327697</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">34.5750072914</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.6866060048</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">37.0892269954</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">37.4849250909</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">34.778824791</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.2269664935</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.272288694</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">34.945165344</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">35.1171578292</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">40.5845117698</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.1462089236</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.0957278345</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">40.6095830913</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">45.1067352961</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">40.523040106</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">37.7696131032</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">39.9036867306</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.3221140974</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.1947918393</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">35.1089144603</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">38.0674700168</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">41.8244654995</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">40.1567131661</td>
    </tr>
    <tr>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">43.2422832585</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">42.7258732951</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">45.4976929401</td>
        <td style="padding-left: 1em; padding-right: 1em; text-align: center; vertical-align: top">45.5597962603</td>
    </tr>
</table>
[1000 rows x 4 columns]<br/>Note: Only the head of the SFrame is printed.<br/>You can use print_rows(num_rows=m, num_columns=n) to print more rows and columns.
</div>



### Prediction


```python
# This function is to check if dog-dog value is the cloest distance than others combination
def is_dog_correct(row):
    if row['dog-dog'] < row['dog-cat'] and  row['dog-dog'] < row['dog-automobile'] and row['dog-dog'] < row['dog-bird']:
        return 1
    else:
        return 0
```


```python
# 678 values are correct
dog_distances.apply(is_dog_correct).sum()
```




    678L




```python
len(dog_distances)
```




    1000


