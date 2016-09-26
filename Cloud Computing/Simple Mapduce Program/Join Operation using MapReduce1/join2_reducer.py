#!/usr/bin/env python
import sys

# --------------------------------------------------------------------------
#This reducer code will input a <word, value> input file, and join words together
# Note the input will come as a group of lines with same word (ie the key)
# As it reads words it will hold on to the value field
#
# It will keep track of current word and previous word, if word changes
#   then it will perform the 'join' on the set of held values by merely printing out 
#   the word and values.  In other words, there is no need to explicitly match keys b/c
#   Hadoop has already put them sequentially in the input 
#   
# At the end it will perform the last join
#
#
#  Note, there is NO error checking of the input, it is assumed to be correct, meaning
#   it has word with correct and matching entries, no extra spaces, etc.
#
#  see https://docs.python.org/2/tutorial/index.html for python tutorials
#
#  San Diego Supercomputer Center copyright
# --------------------------------------------------------------------------

last_show           = None
running_total      = 0  #count total views

for line in sys.stdin:
    line       = line.strip()       #strip out carriage return
    key_value  = line.split('\t')   #split line, into key and value, returns a list

    #note: for simple debugging use print statements, ie:  
    curr_show  = key_value[0]         #key is first item in list, indexed by 0
    try:
        value   = int(key_value[1])         #value is 2nd item
    except (RuntimeError, TypeError,ValueError, NameError):
        value = 0
    #-----------------------------------------------------
    # Check if its a new word and not the first line 
    #   (b/c for the first line the previous word is not applicable)
    #   if so then print out list of dates and counts
    #----------------------------------------------------
    if last_show == curr_show:
        running_total += value
    else:
        if last_show:             #if this key that was just read in
                                 #   is different, and the previous 
                                 #   (ie last) key is not empy,
                                 #   then output 
                                 #   the previous <key running-count>
            print( "{0}\t{1}".format(last_show, running_total) )
                                 # hadoop expects tab(ie '\t') 
                                 #    separation
        running_total = value    #reset values
        last_show = curr_show

if last_show == curr_show:
    print( "{0}\t{1}".format(last_show, running_total))


