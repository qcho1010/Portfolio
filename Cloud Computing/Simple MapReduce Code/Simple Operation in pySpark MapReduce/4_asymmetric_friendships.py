#!/usr/bin/python
# -*- coding: utf-8 -*-.

import MapReduce
import sys

"""
Friend count in the Simple Python MapReduce Framework
"""
# The relationship "friend" is often symmetric, meaning that 
# if I am your friend, you are my friend. 
# Implement a MapReduce algorithm to check whether this property holds. 
# Generate a list of all non-symmetric friend relationships.

# Map Input
# Each input record is a 2 element list [personA, personB]
# where personA is a string representing the name of a person 
# and personB is a string representing the name of one of personA's friends. 
# Note that it may or may not be the case that the personA is a friend of personB.

# Reduce Output
# The output should be all pairs (friend, person) such that 
# (person, friend) appears in the dataset but (friend, person) does not.
# mr = MapReduce.MapReduce()

# =============================
# Do not modify above this line

def mapper(record):
    # key: person name
    # value: person befriended
    key = record[0] 
    value = record[1]
    mr.emit_intermediate(key, value)
    mr.emit_intermediate(value, key)
    

def reducer(key, list_of_values):
    # key: person name
    # list_of_values: list of names related in one way with key
    # ex) reduce("john", (keith, mike, ...,joseph))
	temp = []
    for name in list_of_values:
        if name not in temp: # if john is not in temp list 
            if list_of_values.count(name) < 2: # if the total count name john is 1 then output that pair
                mr.emit((key, name))

				
# Do not modify below this line
# =============================
if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)