MapReduce assignment
====================
MapReduce-like python framework exercises.

Inverted index
---------------------

Create an Inverted index. Given a set of 
documents, an inverted index is a dictionary 
where each word is associated with a list of 
the document identifiers in which that word 
appears.

### Mapper Input

The input is a 2 element list: 
[document_id, text], where document_id is a 
string representing a document identifier 
and text is a string representing the text 
of the document. The document text may have 
words in upper or lower case and may contain 
punctuation. You should treat each token 
as if it was a valid word; that is, you can just use value.split() to tokenize the string.

### Reducer output

The output should be a (word, document ID list) tuple where word is a String and document ID list is a list of Strings.

### Testing
You can test your solution to this problem using books.json:

        python inverted_index.py books.json


Relational join
----------------

Consider the following query:

SELECT * 
FROM Orders, LineItem 
WHERE Order.order_id = LineItem.order_id
Your MapReduce query should produce the 
same result as this SQL query executed 
against an appropriate database.

### Mapper Input

Each input record is a list of strings 
representing a tuple in the database. Each
 list element corresponds to a different 
 attribute of the table
The first item (index 0) in each record is a
 string that identifies the table the record originates from. This field has two 
 possible values:

"line_item" indicates that the record is a line item.
"order" indicates that the record is an order.
The second element (index 1) in each record is the order_id.

LineItem records have 17 attributes including the identifier string.

Order records have 10 elements including the identifier string.

### Reducer output

The output should be a joined record: a 
single list of length 27 that contains the 
attributes from the order record followed by 
the fields from the line item record. Each 
list element should be a string.

You can test your solution to this problem 
using records.json:

$ python join.py records.json
You can can compare your solution with join.json.


Social network
---------------
Consider a simple social network dataset 
consisting of a set of key-value pairs (
person, friend) representing a friend 
relationship between two people. Describe a 
MapReduce algorithm to count the number of 
friends for each person.

### Mapper Input

Each input record is a 2 element list 
[personA, personB] where personA is a string 
representing the name of a person and 
personB is a string representing the name of 
one of personA's friends. Note that it may 
or may not be the case that the personA is a 
friend of personB.

### Reducer output

The output should be a pair 
(person, friend_count) where person is a 
string and friend_count is an integer 
indicating the number of friends associated 
with person.

### Test

You can test your solution to this problem 
using friends.json:

$ python friend_count.py friends.json
You can verify your solution by comparing 
your result with the file friend_count.json.

Friend relationship
--------------------

Implement a MapReduce 
algorithm to check whether this property 
holds. Generate a list of all non-symmetric 
friend relationships.

### Mapper Input

Each input record is a 2 element list 
[personA, personB] where personA is a string 
representing the name of a person and 
personB is a string representing the name of 
one of personA's friends. Note that it may 
or may not be the case that the personA is a 
friend of personB.

### Reduce Output

The output should be the full symmetric 
relation. For every pair (person, friend), 
you will emit BOTH (person, friend) AND 
(friend, person). However, be aware that 
(friend, person) may already appear in the 
dataset, so you may produce duplicates if 
you are not careful.

### Test

You can test your solution to this problem 
using friends.json:

$ python asymmetric_friendships.py friends.json
You can verify your solution by comparing your result with the file asymmetric_friendships.json.


Nucleotides
------------

Consider a set of key-value pairs where each 
key is sequence id and each value is a 
string of nucleotides, e.g., 
GCTTCCGAAATGCTCGAA....

Write a MapReduce query to remove the last 
10 characters from each string of 
nucleotides, then remove any duplicates 
generated.

### Map Input
Each input record is a 2 element list 
[sequence id, nucleotides] where sequence id 
is a string representing a unique identifier 
for the sequence and nucleotides is a string 
representing a sequence of nucleotides

### Reduce Output
The output from the reduce function should 
be the unique trimmed nucleotide strings.


### Test
You can test your solution to this problem 
using dna.json:

$ python unique_trims.py dna.json
You can verify your solution by comparing 
your result with the file unique_trims.json.


Sparse matrices
-----------------

Assume you have two matrices A and B in a 
sparse matrix format, where each record is 
of the form i, j, value. Design a MapReduce 
algorithm to compute the matrix 
multiplication A x B

### Map Input
The input to the map function will be a row 
of a matrix represented as a list. Each list 
will be of the form [matrix, i, j, value] 
where matrix is a string and i, j, and value 
are integers.


The first item, matrix, is a string that 
identifies which matrix the record 
originates from. This field has two possible 
values: "a" indicates that the record is 
from matrix A and "b" indicates that the 
record is from matrix B

### Reduce Output
The output from the reduce function will 
also be a row of the result matrix 
represented as a tuple. Each tuple will be 
of the form (i, j, value) where each element 
is an integer.


### Test

You can test your solution to this problem 
using matrix.json:

$ python multiply.py matrix.json
You can verify your solution by comparing 
your result with the file multiply.json.

