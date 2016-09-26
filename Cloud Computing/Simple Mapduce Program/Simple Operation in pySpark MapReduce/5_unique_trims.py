#!/usr/bin/python
# -*- coding: utf-8 -*-.

import MapReduce
import sys

"""
Unique trimming in the Simple Python MapReduce Framework
"""
# Consider a set of key-value pairs where 
# each key is sequence id and each value is a string of nucleotides, 
# e.g., GCTTCCGAAATGCTCGAA....
# Write a MapReduce query to remove the last 10 characters 
# from each string of nucleotides, then remove any duplicates generated.

# Map Input
# Each input record is a 2 element list [sequence id, nucleotides] 
# where sequence id is a string representing a unique identifier 
# for the sequence and nucleotides is a string representing a sequence of nucleotides

# Reduce Output
# The output from the reduce function should be the unique trimmed nucleotide strings.

mr = MapReduce.MapReduce()

# =============================
# Do not modify above this line

def mapper(record):
    # key: id
    # value: nucleotide
    key = record[0] 
    value = record[1]
    trimmed = value[0:-10]
    mr.emit_intermediate(1, trimmed) # Since we don't need key to match, just return 1
    

def reducer(key, list_of_values):
    # key: person name
    # list_of_values: list of names related in one way with key

    #Sets automatically exclude duplicate terms
    temp = set()
    for sequence in list_of_values:        
        temp.add(sequence)    
            
    for uniqueSequence in temp:        
        mr.emit(uniqueSequence)
                

# Do not modify below this line
# =============================
if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)