#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 15 15:13:07 2019

remove old data (> 3 days) files from data store
based on file creation time (i.e. does not look at data)

@author: obrien
"""

import os, time, glob

days = 4.

store = '/home/pi/Data'

now = time.time()

datafiles = glob.glob(os.path.join(store, '*.npy'))

i = 1
for df in datafiles:
    creation_time = os.path.getctime(df)
    if (now - creation_time) / (24. * 3600.) >= days:   
        os.unlink(df)
        print(i, '{} removed'.format(df))
        i += 1
