# -*- coding: utf-8 -*-
"""
Created on Sat Jan 30 20:29:37 2016

@author: Kyu
"""

import numpy as np

def incgroup_prepost(row):
    if type(row) == float and np.isnan(row):
        return 0
    elif row == "$15,000-$17,499" or row == "$10,000-$12,499" or row == "$5,000-$9,999" or row == "$17,500-$19,999" or row == "Under $5,000":
        return 1
    elif row == "$27,500-$29,999" or row == "$25,000-$27,499" or row == "$20,000-$22,499" or row == "$22,500-$24,999":
        return 2
    elif row == "$35,000-$39,999" or row == "$30,000-$34,999":
        return 3
    elif row == "$45,000-$49,999" or row == "$40,000-$44,999":
        return 4
    elif row == "$50,000-$54,999" or row == "$55,000-$59,999":
        return 5
    elif row == "$60,000-$64,999" or row == "$65,000-$69,999":
        return 6
    elif row == "$70,000-$74,999" or row == "$75,000-$79,999":
        return 7
    elif row == "$80,000-$89,999":
        return 8
    elif row == "$90,000-$99,999":
        return 9
    elif row == "$100,000-$109,999":
        return 10
    elif row == "$110,000-$124,999" or row == "$125,000-$149,999":
        return 11
    elif row == "$150,000-$174,999" or row == "$175,000-$249,999":
        return 15
    elif row == "$250,000 Or More":
        return 25
		
