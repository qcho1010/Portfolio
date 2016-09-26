
# Hierarchical Clustering

**Hierarchical clustering** refers to a class of clustering methods that seek to build a **hierarchy** of clusters, in which some clusters contain others. In this assignment, we will explore a top-down approach, recursively bipartitioning the data using k-means.

**Note to Amazon EC2 users**: To conserve memory, make sure to stop all the other notebooks before running this notebook.

## Import packages

The following code block will check if you have the correct version of GraphLab Create. Any version later than 1.8.5 will do. To upgrade, read [this page](https://turi.com/download/upgrade-graphlab-create.html).


```python
import graphlab
import matplotlib.pyplot as plt
import numpy as np
import sys
import os
import time
from scipy.sparse import csr_matrix
from sklearn.cluster import KMeans
from sklearn.metrics import pairwise_distances
%matplotlib inline

'''Check GraphLab Create version'''
from distutils.version import StrictVersion
assert (StrictVersion(graphlab.version) >= StrictVersion('1.8.5')), 'GraphLab Create must be version 1.8.5 or later.'

import os
os.chdir('C:\Users\Kyu\Documents\python\data')
```

## Load the Wikipedia dataset


```python
wiki = graphlab.SFrame('people_wiki.gl/')
```

    [INFO] graphlab.cython.cy_server: GraphLab Create v2.1 started. Logging: C:\Users\Kyu\AppData\Local\Temp\graphlab_server_1472334296.log.0
    INFO:graphlab.cython.cy_server:GraphLab Create v2.1 started. Logging: C:\Users\Kyu\AppData\Local\Temp\graphlab_server_1472334296.log.0
    

    This non-commercial license of GraphLab Create for academic use is assigned to chok20734@gmail.com and will expire on October 03, 2016.
    

As we did in previous assignments, let's extract the TF-IDF features:


```python
wiki['tf_idf'] = graphlab.text_analytics.tf_idf(wiki['text'])
```

To run k-means on this dataset, we should convert the data matrix into a sparse matrix.


```python
from em_utilities import sframe_to_scipy # converter

# This will take about a minute or two.
tf_idf, map_index_to_word = sframe_to_scipy(wiki, 'tf_idf')
```

To be consistent with the k-means assignment, let's normalize all vectors to have unit norm.


```python
from sklearn.preprocessing import normalize
tf_idf = normalize(tf_idf)
```

## Bipartition the Wikipedia dataset using k-means

Recall our workflow for clustering text data with k-means:

1. Load the dataframe containing a dataset, such as the Wikipedia text dataset.
2. Extract the data matrix from the dataframe.
3. Run k-means on the data matrix with some value of k.
4. Visualize the clustering results using the centroids, cluster assignments, and the original dataframe. We keep the original dataframe around because the data matrix does not keep auxiliary information (in the case of the text dataset, the title of each article).

Let us modify the workflow to perform bipartitioning:

1. Load the dataframe containing a dataset, such as the Wikipedia text dataset.
2. Extract the data matrix from the dataframe.
3. Run k-means on the data matrix with k=2.
4. Divide the data matrix into two parts using the cluster assignments.
5. Divide the dataframe into two parts, again using the cluster assignments. This step is necessary to allow for visualization.
6. Visualize the bipartition of data.

We'd like to be able to repeat Steps 3-6 multiple times to produce a **hierarchy** of clusters such as the following:
```
                      (root)
                         |
            +------------+-------------+
            |                          |
         Cluster                    Cluster
     +------+-----+             +------+-----+
     |            |             |            |
   Cluster     Cluster       Cluster      Cluster
```
Each **parent cluster** is bipartitioned to produce two **child clusters**. At the very top is the **root cluster**, which consists of the entire dataset.

Now we write a wrapper function to bipartition a given cluster using k-means. There are three variables that together comprise the cluster:

* `dataframe`: a subset of the original dataframe that correspond to member rows of the cluster
* `matrix`: same set of rows, stored in sparse matrix format
* `centroid`: the centroid of the cluster (not applicable for the root cluster)

Rather than passing around the three variables separately, we package them into a Python dictionary. The wrapper function takes a single dictionary (representing a parent cluster) and returns two dictionaries (representing the child clusters).


```python
def bipartition(cluster, maxiter=400, num_runs=4, seed=None):
    '''cluster: should be a dictionary containing the following keys
                * dataframe: original dataframe
                * matrix:    same data, in matrix format
                * centroid:  centroid for this particular cluster'''
    
    data_matrix = cluster['matrix']
    dataframe   = cluster['dataframe']
    
    # Run k-means on the data matrix with k=2. We use scikit-learn here to simplify workflow.
    kmeans_model = KMeans(n_clusters=2, max_iter=maxiter, n_init=num_runs, random_state=seed, n_jobs=-1)    
    kmeans_model.fit(data_matrix)
    centroids, cluster_assignment = kmeans_model.cluster_centers_, kmeans_model.labels_
    
    # Divide the data matrix into two parts using the cluster assignments.
    data_matrix_left_child, data_matrix_right_child = data_matrix[cluster_assignment==0], \
                                                      data_matrix[cluster_assignment==1]
    
    # Divide the dataframe into two parts, again using the cluster assignments.
    cluster_assignment_sa = graphlab.SArray(cluster_assignment) # minor format conversion
    dataframe_left_child, dataframe_right_child     = dataframe[cluster_assignment_sa==0], \
                                                      dataframe[cluster_assignment_sa==1]
        
    
    # Package relevant variables for the child clusters
    cluster_left_child  = {'matrix': data_matrix_left_child,
                           'dataframe': dataframe_left_child,
                           'centroid': centroids[0]}
    cluster_right_child = {'matrix': data_matrix_right_child,
                           'dataframe': dataframe_right_child,
                           'centroid': centroids[1]}
    
    return (cluster_left_child, cluster_right_child)
```

The following cell performs bipartitioning of the Wikipedia dataset. Allow 20-60 seconds to finish.

Note. For the purpose of the assignment, we set an explicit seed (`seed=1`) to produce identical outputs for every run. In pratical applications, you might want to use different random seeds for all runs.


```python
wiki_data = {'matrix': tf_idf, 'dataframe': wiki} # no 'centroid' for the root cluster
left_child, right_child = bipartition(wiki_data, maxiter=100, num_runs=8, seed=1)
```

Let's examine the contents of one of the two clusters, which we call the `left_child`, referring to the tree visualization above.


```python
left_child
```




    {'centroid': array([  0.00000000e+00,   8.57526623e-06,   0.00000000e+00, ...,
              1.38560691e-04,   6.46049863e-05,   2.26551103e-05]),
     'dataframe': Columns:
     	URI	str
     	name	str
     	text	str
     	tf_idf	dict
     
     Rows: Unknown
     
     Data:
     +-------------------------------+-------------------------------+
     |              URI              |              name             |
     +-------------------------------+-------------------------------+
     | <http://dbpedia.org/resour... |         Digby Morrell         |
     | <http://dbpedia.org/resour... | Paddy Dunne (Gaelic footba... |
     | <http://dbpedia.org/resour... |         Ceiron Thomas         |
     | <http://dbpedia.org/resour... |          Adel Sellimi         |
     | <http://dbpedia.org/resour... |          Vic Stasiuk          |
     | <http://dbpedia.org/resour... |          Leon Hapgood         |
     | <http://dbpedia.org/resour... |           Dom Flora           |
     | <http://dbpedia.org/resour... |           Bob Reece           |
     | <http://dbpedia.org/resour... | Bob Adams (American football) |
     | <http://dbpedia.org/resour... |           Marc Logan          |
     +-------------------------------+-------------------------------+
     +-------------------------------+-------------------------------+
     |              text             |             tf_idf            |
     +-------------------------------+-------------------------------+
     | digby morrell born 10 octo... | {'since': 1.45537671730804... |
     | paddy dunne was a gaelic f... | {'all': 3.2862224869824943... |
     | ceiron thomas born 23 octo... | {'thomas': 19.921640781374... |
     | adel sellimi arabic was bo... | {'coach': 5.44426411898705... |
     | victor john stasiuk born m... | {'leagues': 3.892260543300... |
     | leon duane hapgood born 7 ... | {'albion': 5.6732894101834... |
     | dominick a dom flora born ... | {'all': 1.6431112434912472... |
     | robert scott reece born ja... | {'leagues': 3.892260543300... |
     | robert bruce bob adams bor... | {'coach': 8.16639617848058... |
     | marc anthony logan born ma... | {'cincinnati': 4.392081929... |
     +-------------------------------+-------------------------------+
     [? rows x 4 columns]
     Note: Only the head of the SFrame is printed. This SFrame is lazily evaluated.
     You can use sf.materialize() to force materialization.,
     'matrix': <11510x547979 sparse matrix of type '<type 'numpy.float64'>'
     	with 1885831 stored elements in Compressed Sparse Row format>}



And here is the content of the other cluster we named `right_child`.


```python
right_child
```




    {'centroid': array([  3.00882137e-06,   0.00000000e+00,   2.88868244e-06, ...,
              1.10291526e-04,   9.00609890e-05,   2.03703564e-05]),
     'dataframe': Columns:
     	URI	str
     	name	str
     	text	str
     	tf_idf	dict
     
     Rows: Unknown
     
     Data:
     +-------------------------------+---------------------+
     |              URI              |         name        |
     +-------------------------------+---------------------+
     | <http://dbpedia.org/resour... |    Alfred J. Lewy   |
     | <http://dbpedia.org/resour... |    Harpdog Brown    |
     | <http://dbpedia.org/resour... | Franz Rottensteiner |
     | <http://dbpedia.org/resour... |        G-Enka       |
     | <http://dbpedia.org/resour... |    Sam Henderson    |
     | <http://dbpedia.org/resour... |    Aaron LaCrate    |
     | <http://dbpedia.org/resour... |   Trevor Ferguson   |
     | <http://dbpedia.org/resour... |     Grant Nelson    |
     | <http://dbpedia.org/resour... |     Cathy Caruth    |
     | <http://dbpedia.org/resour... |     Sophie Crumb    |
     +-------------------------------+---------------------+
     +-------------------------------+-------------------------------+
     |              text             |             tf_idf            |
     +-------------------------------+-------------------------------+
     | alfred j lewy aka sandy le... | {'precise': 6.443200606955... |
     | harpdog brown is a singer ... | {'just': 2.700729968710864... |
     | franz rottensteiner born i... | {'all': 1.6431112434912472... |
     | henry krvits born 30 decem... | {'legendary': 4.2808562943... |
     | sam henderson born october... | {'now': 1.96695239252401, ... |
     | aaron lacrate is an americ... | {'exclusive': 10.455187230... |
     | trevor ferguson aka john f... | {'taxi': 6.052021456094502... |
     | grant nelson born 27 april... | {'houston': 3.935505942157... |
     | cathy caruth born 1955 is ... | {'phenomenon': 5.750053426... |
     | sophia violet sophie crumb... | {'zwigoff': 20.58669641733... |
     +-------------------------------+-------------------------------+
     [? rows x 4 columns]
     Note: Only the head of the SFrame is printed. This SFrame is lazily evaluated.
     You can use sf.materialize() to force materialization.,
     'matrix': <47561x547979 sparse matrix of type '<type 'numpy.float64'>'
     	with 8493452 stored elements in Compressed Sparse Row format>}



## Visualize the bipartition

We provide you with a modified version of the visualization function from the k-means assignment. For each cluster, we print the top 5 words with highest TF-IDF weights in the centroid and display excerpts for the 8 nearest neighbors of the centroid.


```python
def display_single_tf_idf_cluster(cluster, map_index_to_word):
    '''map_index_to_word: SFrame specifying the mapping betweeen words and column indices'''
    
    wiki_subset   = cluster['dataframe']
    tf_idf_subset = cluster['matrix']
    centroid      = cluster['centroid']
    
    # Print top 5 words with largest TF-IDF weights in the cluster
    idx = centroid.argsort()[::-1]
    for i in xrange(5):
        print('{0:s}:{1:.3f}'.format(map_index_to_word['category'][idx[i]], centroid[idx[i]])),
    print('')
    
    # Compute distances from the centroid to all data points in the cluster.
    distances = pairwise_distances(tf_idf_subset, [centroid], metric='euclidean').flatten()
    # compute nearest neighbors of the centroid within the cluster.
    nearest_neighbors = distances.argsort()
    # For 8 nearest neighbors, print the title as well as first 180 characters of text.
    # Wrap the text at 80-character mark.
    for i in xrange(8):
        text = ' '.join(wiki_subset[nearest_neighbors[i]]['text'].split(None, 25)[0:25])
        print('* {0:50s} {1:.5f}\n  {2:s}\n  {3:s}'.format(wiki_subset[nearest_neighbors[i]]['name'],
              distances[nearest_neighbors[i]], text[:90], text[90:180] if len(text) > 90 else ''))
    print('')
```

Let's visualize the two child clusters:


```python
display_single_tf_idf_cluster(left_child, map_index_to_word)
```

    league:0.040 season:0.036 team:0.029 football:0.029 played:0.028 
    * Todd Williams                                      0.95468
      todd michael williams born february 13 1971 in syracuse new york is a former major league 
      baseball relief pitcher he attended east syracuseminoa high school
    * Gord Sherven                                       0.95622
      gordon r sherven born august 21 1963 in gravelbourg saskatchewan and raised in mankota sas
      katchewan is a retired canadian professional ice hockey forward who played
    * Justin Knoedler                                    0.95639
      justin joseph knoedler born july 17 1980 in springfield illinois is a former major league 
      baseball catcherknoedler was originally drafted by the st louis cardinals
    * Chris Day                                          0.95648
      christopher nicholas chris day born 28 july 1975 is an english professional footballer who
       plays as a goalkeeper for stevenageday started his career at tottenham
    * Tony Smith (footballer, born 1957)                 0.95653
      anthony tony smith born 20 february 1957 is a former footballer who played as a central de
      fender in the football league in the 1970s and
    * Ashley Prescott                                    0.95761
      ashley prescott born 11 september 1972 is a former australian rules footballer he played w
      ith the richmond and fremantle football clubs in the afl between
    * Leslie Lea                                         0.95802
      leslie lea born 5 october 1942 in manchester is an english former professional footballer 
      he played as a midfielderlea began his professional career with blackpool
    * Tommy Anderson (footballer)                        0.95818
      thomas cowan tommy anderson born 24 september 1934 in haddington is a scottish former prof
      essional footballer he played as a forward and was noted for
    
    


```python
display_single_tf_idf_cluster(right_child, map_index_to_word)
```

    she:0.025 her:0.017 music:0.012 he:0.011 university:0.011 
    * Anita Kunz                                         0.97401
      anita e kunz oc born 1956 is a canadianborn artist and illustratorkunz has lived in london
       new york and toronto contributing to magazines and working
    * Janet Jackson                                      0.97472
      janet damita jo jackson born may 16 1966 is an american singer songwriter and actress know
      n for a series of sonically innovative socially conscious and
    * Madonna (entertainer)                              0.97475
      madonna louise ciccone tkoni born august 16 1958 is an american singer songwriter actress 
      and businesswoman she achieved popularity by pushing the boundaries of lyrical
    * %C3%81ine Hyland                                   0.97536
      ine hyland ne donlon is emeritus professor of education and former vicepresident of univer
      sity college cork ireland she was born in 1942 in athboy co
    * Jane Fonda                                         0.97621
      jane fonda born lady jayne seymour fonda december 21 1937 is an american actress writer po
      litical activist former fashion model and fitness guru she is
    * Christine Robertson                                0.97643
      christine mary robertson born 5 october 1948 is an australian politician and former austra
      lian labor party member of the new south wales legislative council serving
    * Pat Studdy-Clift                                   0.97643
      pat studdyclift is an australian author specialising in historical fiction and nonfictionb
      orn in 1925 she lived in gunnedah until she was sent to a boarding
    * Alexandra Potter                                   0.97646
      alexandra potter born 1970 is a british author of romantic comediesborn in bradford yorksh
      ire england and educated at liverpool university gaining an honors degree in
    
    

The left cluster consists of athletes, whereas the right cluster consists of non-athletes. So far, we have a single-level hierarchy consisting of two clusters, as follows:

```
                                           Wikipedia
                                               +
                                               |
                    +--------------------------+--------------------+
                    |                                               |
                    +                                               +
                 Athletes                                      Non-athletes
```

Is this hierarchy good enough? **When building a hierarchy of clusters, we must keep our particular application in mind.** For instance, we might want to build a **directory** for Wikipedia articles. A good directory would let you quickly narrow down your search to a small set of related articles. The categories of athletes and non-athletes are too general to facilitate efficient search. For this reason, we decide to build another level into our hierarchy of clusters with the goal of getting more specific cluster structure at the lower level. To that end, we subdivide both the `athletes` and `non-athletes` clusters.

## Perform recursive bipartitioning

### Cluster of athletes

To help identify the clusters we've built so far, let's give them easy-to-read aliases:


```python
athletes = left_child
non_athletes = right_child
```

Using the bipartition function, we produce two child clusters of the athlete cluster:


```python
# Bipartition the cluster of athletes
left_child_athletes, right_child_athletes = bipartition(athletes, maxiter=100, num_runs=8, seed=1)
```

The left child cluster mainly consists of baseball players:


```python
display_single_tf_idf_cluster(left_child_athletes, map_index_to_word)
```

    baseball:0.111 league:0.103 major:0.051 games:0.046 season:0.045 
    * Steve Springer                                     0.89344
      steven michael springer born february 11 1961 is an american former professional baseball 
      player who appeared in major league baseball as a third baseman and
    * Dave Ford                                          0.89598
      david alan ford born december 29 1956 is a former major league baseball pitcher for the ba
      ltimore orioles born in cleveland ohio ford attended lincolnwest
    * Todd Williams                                      0.89823
      todd michael williams born february 13 1971 in syracuse new york is a former major league 
      baseball relief pitcher he attended east syracuseminoa high school
    * Justin Knoedler                                    0.90097
      justin joseph knoedler born july 17 1980 in springfield illinois is a former major league 
      baseball catcherknoedler was originally drafted by the st louis cardinals
    * Kevin Nicholson (baseball)                         0.90607
      kevin ronald nicholson born march 29 1976 is a canadian baseball shortstop he played part 
      of the 2000 season for the san diego padres of
    * Joe Strong                                         0.90638
      joseph benjamin strong born september 9 1962 in fairfield california is a former major lea
      gue baseball pitcher who played for the florida marlins from 2000
    * James Baldwin (baseball)                           0.90674
      james j baldwin jr born july 15 1971 is a former major league baseball pitcher he batted a
      nd threw righthanded in his 11season career he
    * James Garcia                                       0.90729
      james robert garcia born february 3 1980 is an american former professional baseball pitch
      er who played in the san francisco giants minor league system as
    
    

On the other hand, the right child cluster is a mix of football players and ice hockey players:


```python
display_single_tf_idf_cluster(right_child_athletes, map_index_to_word)
```

    season:0.034 football:0.033 team:0.031 league:0.029 played:0.027 
    * Gord Sherven                                       0.95562
      gordon r sherven born august 21 1963 in gravelbourg saskatchewan and raised in mankota sas
      katchewan is a retired canadian professional ice hockey forward who played
    * Ashley Prescott                                    0.95656
      ashley prescott born 11 september 1972 is a former australian rules footballer he played w
      ith the richmond and fremantle football clubs in the afl between
    * Chris Day                                          0.95656
      christopher nicholas chris day born 28 july 1975 is an english professional footballer who
       plays as a goalkeeper for stevenageday started his career at tottenham
    * Jason Roberts (footballer)                         0.95658
      jason andre davis roberts mbe born 25 january 1978 is a former professional footballer and
       now a football punditborn in park royal london roberts was
    * Todd Curley                                        0.95743
      todd curley born 14 january 1973 is a former australian rules footballer who played for co
      llingwood and the western bulldogs in the australian football league
    * Tony Smith (footballer, born 1957)                 0.95801
      anthony tony smith born 20 february 1957 is a former footballer who played as a central de
      fender in the football league in the 1970s and
    * Sol Campbell                                       0.95802
      sulzeer jeremiah sol campbell born 18 september 1974 is a former england international foo
      tballer a central defender he had a 19year career playing in the
    * Richard Ambrose                                    0.95924
      richard ambrose born 10 june 1972 is a former australian rules footballer who played with 
      the sydney swans in the australian football league afl he
    
    

**Note**. Concerning use of "football"

The occurrences of the word "football" above refer to [association football](https://en.wikipedia.org/wiki/Association_football). This sports is also known as "soccer" in United States (to avoid confusion with [American football](https://en.wikipedia.org/wiki/American_football)). We will use "football" throughout when discussing topic representation.

Our hierarchy of clusters now looks like this:
```
                                           Wikipedia
                                               +
                                               |
                    +--------------------------+--------------------+
                    |                                               |
                    +                                               +
                 Athletes                                      Non-athletes
                    +
                    |
        +-----------+--------+
        |                    |
        |                    +
        +                 football/
     baseball            ice hockey
```

Should we keep subdividing the clusters? If so, which cluster should we subdivide? To answer this question, we again think about our application. Since we organize our directory by topics, it would be nice to have topics that are about as coarse as each other. For instance, if one cluster is about baseball, we expect some other clusters about football, basketball, volleyball, and so forth. That is, **we would like to achieve similar level of granularity for all clusters.**

Notice that the right child cluster is more coarse than the left child cluster. The right cluster posseses a greater variety of topics than the left (ice hockey/football vs. baseball). So the right child cluster should be subdivided further to produce finer child clusters.

Let's give the clusters aliases as well:


```python
baseball            = left_child_athletes
ice_hockey_football = right_child_athletes
```

### Cluster of ice hockey players and football players

In answering the following quiz question, take a look at the topics represented in the top documents (those closest to the centroid), as well as the list of words with highest TF-IDF weights.

**Quiz Question**. Bipartition the cluster of ice hockey and football players. Which of the two child clusters should be futher subdivided?

Right

**Note**. To achieve consistent results, use the arguments `maxiter=100, num_runs=8, seed=1` when calling the `bipartition` function.

1. The left child cluster
2. The right child cluster


```python
left_child_athletes, right_child_athletes = bipartition(ice_hockey_football, maxiter=100, num_runs=8, seed=1)
```


```python
display_single_tf_idf_cluster(left_child_athletes, map_index_to_word)
```

    football:0.048 season:0.043 league:0.041 played:0.036 coach:0.034 
    * Todd Curley                                        0.94582
      todd curley born 14 january 1973 is a former australian rules footballer who played for co
      llingwood and the western bulldogs in the australian football league
    * Tony Smith (footballer, born 1957)                 0.94609
      anthony tony smith born 20 february 1957 is a former footballer who played as a central de
      fender in the football league in the 1970s and
    * Chris Day                                          0.94626
      christopher nicholas chris day born 28 july 1975 is an english professional footballer who
       plays as a goalkeeper for stevenageday started his career at tottenham
    * Jason Roberts (footballer)                         0.94635
      jason andre davis roberts mbe born 25 january 1978 is a former professional footballer and
       now a football punditborn in park royal london roberts was
    * Ashley Prescott                                    0.94635
      ashley prescott born 11 september 1972 is a former australian rules footballer he played w
      ith the richmond and fremantle football clubs in the afl between
    * David Hamilton (footballer)                        0.94928
      david hamilton born 7 november 1960 is an english former professional association football
       player who played as a midfielder he won caps for the england
    * Richard Ambrose                                    0.94944
      richard ambrose born 10 june 1972 is a former australian rules footballer who played with 
      the sydney swans in the australian football league afl he
    * Neil Grayson                                       0.94960
      neil grayson born 1 november 1964 in york is an english footballer who last played as a st
      riker for sutton towngraysons first club was local
    
    


```python
display_single_tf_idf_cluster(right_child_athletes, map_index_to_word)
```

    championships:0.045 tour:0.044 championship:0.035 world:0.031 won:0.031 
    * Alessandra Aguilar                                 0.93847
      alessandra aguilar born 1 july 1978 in lugo is a spanish longdistance runner who specialis
      es in marathon running she represented her country in the event
    * Heather Samuel                                     0.93964
      heather barbara samuel born 6 july 1970 is a retired sprinter from antigua and barbuda who
       specialized in the 100 and 200 metres in 1990
    * Viola Kibiwot                                      0.94006
      viola jelagat kibiwot born december 22 1983 in keiyo district is a runner from kenya who s
      pecialises in the 1500 metres kibiwot won her first
    * Ayelech Worku                                      0.94022
      ayelech worku born june 12 1979 is an ethiopian longdistance runner most known for winning
       two world championships bronze medals on the 5000 metres she
    * Krisztina Papp                                     0.94068
      krisztina papp born 17 december 1982 in eger is a hungarian long distance runner she is th
      e national indoor record holder over 5000 mpapp began
    * Petra Lammert                                      0.94209
      petra lammert born 3 march 1984 in freudenstadt badenwrttemberg is a former german shot pu
      tter and current bobsledder she was the 2009 european indoor champion
    * Morhad Amdouni                                     0.94210
      morhad amdouni born 21 january 1988 in portovecchio is a french middle and longdistance ru
      nner he was european junior champion in track and cross country
    * Brian Davis (golfer)                               0.94360
      brian lester davis born 2 august 1974 is an english professional golferdavis was born in l
      ondon he turned professional in 1994 and became a member
    
    

**Caution**. The granularity criteria is an imperfect heuristic and must be taken with a grain of salt. It takes a lot of manual intervention to obtain a good hierarchy of clusters.

* **If a cluster is highly mixed, the top articles and words may not convey the full picture of the cluster.** Thus, we may be misled if we judge the purity of clusters solely by their top documents and words. 
* **Many interesting topics are hidden somewhere inside the clusters but do not appear in the visualization.** We may need to subdivide further to discover new topics. For instance, subdividing the `ice_hockey_football` cluster led to the appearance of golf.

**Quiz Question**. Which diagram best describes the hierarchy right after splitting the `ice_hockey_football` cluster? Refer to the quiz form for the diagrams.

### Cluster of non-athletes

Now let us subdivide the cluster of non-athletes.


```python
# Bipartition the cluster of non-athletes
left_child_non_athletes, right_child_non_athletes = bipartition(non_athletes, maxiter=100, num_runs=8, seed=1)
```


```python
display_single_tf_idf_cluster(left_child_non_athletes, map_index_to_word)
```

    university:0.016 he:0.013 she:0.013 law:0.012 served:0.012 
    * Barry Sullivan (lawyer)                            0.97227
      barry sullivan is a chicago lawyer and as of july 1 2009 the cooney conway chair in advoca
      cy at loyola university chicago school of law
    * Kayee Griffin                                      0.97444
      kayee frances griffin born 6 february 1950 is an australian politician and former australi
      an labor party member of the new south wales legislative council serving
    * Christine Robertson                                0.97450
      christine mary robertson born 5 october 1948 is an australian politician and former austra
      lian labor party member of the new south wales legislative council serving
    * James A. Joseph                                    0.97464
      james a joseph born 1935 is an american former diplomatjoseph is professor of the practice
       of public policy studies at duke university and founder of
    * David Anderson (British Columbia politician)       0.97492
      david a anderson pc oc born august 16 1937 in victoria british columbia is a former canadi
      an cabinet minister educated at victoria college in victoria
    * Mary Ellen Coster Williams                         0.97594
      mary ellen coster williams born april 3 1953 is a judge of the united states court of fede
      ral claims appointed to that court in 2003
    * Sven Erik Holmes                                   0.97600
      sven erik holmes is a former federal judge and currently the vice chairman legal risk and 
      regulatory and chief legal officer for kpmg llp a
    * Andrew Fois                                        0.97652
      andrew fois is an attorney living and working in washington dc as of april 9 2012 he will 
      be serving as the deputy attorney general
    
    


```python
display_single_tf_idf_cluster(right_child_non_athletes, map_index_to_word)
```

    she:0.039 her:0.030 music:0.023 film:0.021 album:0.015 
    * Madonna (entertainer)                              0.96092
      madonna louise ciccone tkoni born august 16 1958 is an american singer songwriter actress 
      and businesswoman she achieved popularity by pushing the boundaries of lyrical
    * Janet Jackson                                      0.96153
      janet damita jo jackson born may 16 1966 is an american singer songwriter and actress know
      n for a series of sonically innovative socially conscious and
    * Cher                                               0.96540
      cher r born cherilyn sarkisian may 20 1946 is an american singer actress and television ho
      st described as embodying female autonomy in a maledominated industry
    * Laura Smith                                        0.96600
      laura smith is a canadian folk singersongwriter she is best known for her 1995 single shad
      e of your love one of the years biggest hits
    * Natashia Williams                                  0.96677
      natashia williamsblach born august 2 1978 is an american actress and former wonderbra camp
      aign model who is perhaps best known for her role as shane
    * Anita Kunz                                         0.96716
      anita e kunz oc born 1956 is a canadianborn artist and illustratorkunz has lived in london
       new york and toronto contributing to magazines and working
    * Maggie Smith                                       0.96747
      dame margaret natalie maggie smith ch dbe born 28 december 1934 is an english actress she 
      made her stage debut in 1952 and has had
    * Lizzie West                                        0.96752
      lizzie west born in brooklyn ny on july 21 1973 is a singersongwriter her music can be des
      cribed as a blend of many genres including
    
    

The first cluster consists of scholars, politicians, and government officials whereas the second consists of musicians, artists, and actors. Run the following code cell to make convenient aliases for the clusters.


```python
scholars_politicians_etc = left_child_non_athletes
musicians_artists_etc = right_child_non_athletes
```

**Quiz Question**. Let us bipartition the clusters `scholars_politicians_etc` and `musicians_artists_etc`. Which diagram best describes the resulting hierarchy of clusters for the non-athletes? Refer to the quiz for the diagrams.

**Note**. Use `maxiter=100, num_runs=8, seed=1` for consistency of output.


```python

```
