#!/usr/bin/python
# -*- coding: utf-8 -*-.

import MapReduce
import sys

"""
Matrix multiplication in the Simple Python MapReduce Framework
"""
# Assume you have two matrices A and B in a sparse matrix format, 
# where each record is of the form i, j, value. 
# Design a MapReduce algorithm to compute the matrix multiplication A x B

# Map Input
# The input to the map function will be a row of a matrix represented as a list. 
# Each list will be of the form [matrix, i, j, value] 
# where matrix is a string and i, j, and value are integers.

# The first item, matrix, is a string that identifies which matrix the record originates from.
# This field has two possible values: "a" indicates that 
# the record is from matrix A and "b" indicates that the record is from matrix B.

# Reduce Output
# The output from the reduce function will also be a row of the result matrix represented as a tuple. 
# Each tuple will be of the form (i, j, value) where each element is an integer.

mr = MapReduce.MapReduce()

# =============================
# Do not modify above this line

# A has dimensions L x M
# B has dimensions M x N
N = 5
L = 5

def mapper(record): #  [matrix, i, j, value] 
    # key: row, column
    # value: value
    matrix = record[0]
    row = record[1] 
    column = record[2]
    value = record[3]
    if matrix == 'a':
        for k in range(N):
            mr.emit_intermediate((row, k), (value, column))           
    elif matrix == 'b':
        for i in range(L):
            mr.emit_intermediate((i, column), (value,row))
    

def reducer(key, list_of_values):
    # key: (row, column)
    # list_of_values: (row/column, value)
    
    # Dictionary of tuples. Each tuple will
    # represent (accumulatedValue,state)
    # Since the accumulated value will be 0
    # if either value of the matrix is non-existent
    # , it checks if the value(i,j) exists, then if the second
    # exists, and then it computes the value.
    # It's 0 in other case.
    products = {
        0: (0,0),
        1: (0,0),
        2: (0,0),
        3: (0,0),
        4: (0,0)
    }

    row = key[0]
    column = key[1]


    for pair in list_of_values:  
        if products[pair[1]][1] == 0:
            products[pair[1]] = (pair[0], 1)            
        elif products[pair[1]][1] == 1:
            temp = products[pair[1]][0]
            products[pair[1]] = (pair[0] * temp, 2)

    total = 0

    for element in products.itervalues():
        itemValue = element[0]
        index = element[1]
        if index == 2:
            total += itemValue

    mr.emit((row, column, total))

                

# Do not modify below this line
# =============================
if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)