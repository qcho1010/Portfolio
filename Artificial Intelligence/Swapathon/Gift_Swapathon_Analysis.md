
# Gift Swapathon
**Kyu Cho**  
**12/05/16**  

## Challenges
You are given the numbers of gifts each child is swapping and, for each child, a ranked list of the $M$ gifts to be
swapped. The rankings range from $1$ to $M^{[1]}$, with lower numbers representing higher preference.  
You must assign the gifts to the children such that you minimize the sum of the rankings for the assigned gifts$^{[2]}$
(per the receiving child), subject to the following constraints:
1. Each gift must be assigned to exactly one child.
2. Each child must be assigned the same number of gifts they donate to the swapathon.
3. No child can be assigned a gift such that their ranking is greater than $0.75 \times M$.

**Important** the sum of the rankings should be the lowest value that is possible for the given input file.  

## Data


### Input format  
- Plain text tab-delimited file with $N + 1$ rows, where $N =$ *number of children*, and $M + 2$ columns, where $M =$ *total number of gifts* to be swapped.  
- The first row will be a header row including gift IDs and the first column will be a header column including each child’s ID.  
- The second column will contain the number of gifts the given child is contributing.  
- Each entry will have exactly one string (with no white space).  
- Each row contains a ranking of the child’s preference, where $1$ indicates highest preference and $M$ indicates lowest.  
    + (Each rank is represented and no ties are allowed.) 
    
### Output format
- The output should be a plain text tab-delimited file.  
- It should begin with *AllScores* $=x$, where $x$ is the sum of the preference rankings for the assigned gifts.  
- This should be followed by $N + 1$ rows, each consisting of $M + 2$ columns.  
- The first row should be a header row with the gift IDs, in the same order as the input file.  
- The first two columns should consist of each child’s ID and number of gifts contributed, in the same order as the input file.  
- All other entries should be zero, unless the particular gift is assigned to the given child.  
    + In this case, the child’s preference rating for the gift should be given instead of zero. 

## Constants
- $M =$ *total number of gifts to be swapped*
- $N =$ *number of children*
- $C_{i} =$*number of donated gift(s) for child($i$)*

## Variables
- $r_{ij}$ where $i=1$ upto $N$ and $j=1$ upto $M =$ *the preference rankings for the assigned gift($j$) to child($i$)*
- $m_{ij}$  where $i=1$ upto $N$ and $j=1$ upto $M =$ *contains binary variable*
    + $1$ if child($i$) received gift($j$), $0$ otherwise  

## Objective Function

$minimize(x)$ where $x = \sum_{i=1}^N \sum_{j=1}^M r_{ij} =$  *sum of the preference rankings for the assigned gift($j$) to child($i$)*


## Contrains  
1. Each gift must be assigned to exactly one child
    - $\sum_{i}^N m_{ij} == 1$ for $\forall j$ upto $M$
2. Each child must be assigned the same number of gifts they donate to the swapathon
    - $\sum_{j}^M m_{ij} == C_i$ for $\forall i$ upto $N$
3. No child can be assigned a gift such that their ranking is greater than 0.75 * M
    - $m_{ij} \times r_{ij} \leq 0.75 \times M$ for $\forall i$ upto $N$ and $\forall j$ upto $M$

# Summary of Algorithm
My main focus is to minimize the searching time without losing the optimum solution.

**A_Star Search Algorithm**  
- A_star seach was great way to start.  It estimate the approximated solution to prune lots of branches. However, It stil takes quite a long time to even search the 10 children and 50 gifts.  But the main algorithm here is to estimate the future solution to guide the next move.  

**Branch and Bound Algorithm**
- Branch and Bounb (B&B) is also great way to prunning the tree.  It relexes the solution and compare with the current solution to prune branches.  The key idea from this algorithm is relexation.  However, It still takes quite a long time to large data. 

**Hungarian Algorithm**  
- Hungarian algorithm is a great method to solve the assignment problem in polynomial time. The key step from the algorithm is call "row/column reduction" which nails down the optimum path.  However, it is very specialized in the situation where each child has only one gift assigned, whereas this project requires multiple assignments.  

## My Approach - Optimality

My approach is to combine all the key idea from each algorithm.  Estimation prunning from A_star search, relaxation prunning from B&B algorithm and row/colume reduction from Hungarian algorithm.  Which reduce the significant amount of computation time; yet still finding the optimum solution.  

## Compilation and Usage Instructions

- I've develop this program in Ubuntu 16.4 with python 2.7.  
- To compile the progem,
    + Goto the Project folder in console
    + run following command **python swapathon.py**
    + make sure to have python *numpy* library
        + If you don't have *numpy* library, run follwoing command
            + **sudo pip install numpy**

# Project Analysis

## What I have learned 
 
1. The important aspects of algorithmic thinking. 
    + I've researched, learned, and reproduce four different popular searching algorithms. 
        + As I was reproducing the popular algorithms such as 'Dijkstra algorithm', 'A_star algorithm', 'Branch and Bound', and 'Hungarian algorithm', It improves my algorithmic thinking techniques and teaches me viewing the approaches in many different ways which eventually allows me to develop at least three of my owned algorithms which is a hybrid method of each of powerful searching algorithms. 
2. Each algorithms has it's own unique ways and key characteristics of pruning the search space to solve the problem. 
    + 'A_star algorithm' estimates the future value and prune the search space that is far worse than the estimated future value. This algorithm gives faster computation time than searching with no pruning with resulting the optimal solution; yet It was still slow and not satisfying my need. 
    + 'Branch and Bound' does relaxation and compare with incumbent solution to prune the search space; with same reason as 'A_star search' it was not satisfying my need. 
    + 'Hungarian algorithm' does solve the problem in polynomial time; however, It is very specialized in solving the task assignment problem; whereas, other algorithms can be used in many different application.  So I was more interested in pruning algorithm so It is more generalized algorithm that can be used in other types of problem as well. The key idea from 'Hungarian algorithm' is call 'row/column reduction' which I thought can be used to reduce the tons of search space. 
    + 'Hybrid method', after I've reproduce those algorithm and had full control of every algorithm to freely modify, delete, improve and develop and be able to combine all key idea from each algorithm to make it prunes more search space to reduce the computation time without losing the optimal solution.  That's how I've came up with this method.   

## Hybrid Method - Strengthes and Weaknesses

**Strengthes**
1. It's the combined algorithms of method that guarantees the optimal solution; thus, this approach also produce the optimal solution.
2. Much faster than conventional graph searching algorithm.  
3. Users can define their own tunning parameter call 'eta' to control the pruning power.  
    + which gives users more flexibility of pruning depending on their limited time.  
    + eta = prunning power (integer value between 0 to 10) default is 3.
    + eta=0 most aggressive prunning, least accurate, fastest
    + eta=10 least aggressive prunning, most accurate, slowest
4. The algorithm itself is not strickly limited by the types of the problem unlike 'Hungarian algorithm'.  

**Weakness**
1. It is stil pruning method which means it can not be solved in polynomial time.  
2. 'eta' parameter is introducing another variable by passing the control to users.  
    + If 'eta' value does too aggressive pruning, It will not give the optimal solution.  

**Improvement**
1. Every input data has it's own perfect 'eta' parameter that produce the fastet and optimal solution, 'eta' value can be automatically defined as well.
2. Combining with other algorithms, if it's applicable.  
