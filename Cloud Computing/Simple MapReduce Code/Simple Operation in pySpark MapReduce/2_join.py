#!/usr/bin/python
# -*- coding: utf-8 -*-.

import MapReduce
import sys

# Implement a relational join as a MapReduce query
# SELECT * 
# FROM Orders, LineItem 
# WHERE Order.order_id = LineItem.order_id
# mr = MapReduce.MapReduce()
# consider the two input tables, 
# Order and LineItem, as one big concatenated bag of records 
# that will be processed by the map function record by record.


# Map Input
# Each input record is a list of strings representing a tuple in the database. 
# Each list element corresponds to a different attribute of the table (different columns)

# The first item (index 0) in each record is a string that identifies the table the record originates from. 
# This field has two possible values:
# - "line_item" indicates that the record is a line item.
# - "order" indicates that the record is an order.

# The second element (index 1) in each record is the order_id.
# "line_item" records have 17 attributes including the identifier string.
# "order" records have 10 elements including the identifier string.

# Reduce Output
# The output should be a joined record: 
# a single list of length 27 that contains the attributes 
# from the order record followed by the fields from the line item record. 
# Each list element should be a string.

# =============================
# Do not modify above this line

def mapper(record): # Accepting list of strings
    # key: order_id
    # value: columns of record
    type = record[0] #type
    key = record[1]
    mr.emit_intermediate(key, record)
    
def reducer(key, list_of_values):
    # key: order_id
    # value: list of orders, lineitems with that key
    order = list_of_values[0] # save order ID
    for line_item in list_of_values[1:]: # Scanning entire array
      mr.emit(order + line_item)
    print (key, order + line_item)

# Do not modify below this line
# =============================
if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
