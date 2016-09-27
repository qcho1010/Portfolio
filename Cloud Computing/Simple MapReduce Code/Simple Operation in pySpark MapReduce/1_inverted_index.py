#!/usr/bin/python
# -*- coding: utf-8 -*-. 

# Mapper Input
# The input is a 2-element list: [document_id, text], 
# where document_id is a string representing a document identifier and text is a string representing the text of the document.
# The document text may have words in upper or lower case and may contain punctuation. 
# You should treat each token as if it was a valid word; that is, you can just use value.split() to tokenize the string.

# Reducer Output
# The output should be a (word, document ID list) tuple where word is a String and document ID list is a list of Strings.

import MapReduce
import sys

"""
Inverted index in the Simple Python MapReduce Framework
"""

mr = MapReduce.MapReduce()

# =============================
# Do not modify above this line

def mapper(record): # Accepting recode array [document_id, text],
    # key: document identifier
    # value: document contents
    key = record[0] # document_id
    value = record[1] # text
    words = value.split() # tokenizing every single words from the document
    for w in words:
      mr.emit_intermediate(w, key) 
      
def reducer(key, list_of_values):
    # key: word
    # value: list of documents where the word appears
    # ex) reduce("history", (12,41,123,...,121))
	s = set()
    for v in list_of_values:
      s.add(v)
    mr.emit((key, [k for k in s])) # Building key value pair, outputting (word, document ID list) 

# Do not modify below this line
# =============================
if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
