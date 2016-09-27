#!/usr/bin/env python
import sys

#key_inp = []
#for line in sys.stdin:
#       line = line.strip()
#       if not "ABC" in line:
#               continue
#       key_value = line.split(",")
#       key_inp.append(key_value[0].split(" "))

#key_fin = reduce(lambda x, y: x+y,key_inp)        
#print key_fin
key_fin = ['Almost_Show', 'Hourly_Cooking', 'Hot_Show', 'Baked_Games', 'Dumb_Talking', 'PostModern_Games', 'Surreal_News', 'Loud_Show', 'Cold_News', 'Almost_Games', 'Hourly_Talking', 'Hot_Games', 'Baked_News', 'Dumb_Show', 'PostModern_News', 'Surreal_Sports', 'Loud_Games', 'Cold_Sports', 'Almost_News', 'Hourly_Show']
for line in sys.stdin:
        line = line.strip()
        key_value = line.split(",")
        key_in = key_value[0].split(" ")
        if (''.join(key_in)) in key_fin:
                value_in = key_value[1]
                print('%s\t%s' % (key_in[0], value_in))


