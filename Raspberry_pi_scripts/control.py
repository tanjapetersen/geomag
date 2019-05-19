#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 15 15:25:45 2019

control script to run half past the hour
 - simply run clean_datastore.py, getemaildata.py and plotgeomagdata.py
 in order
 - use subprocess to flush memory
 
@author: obrien
"""

import subprocess, time
#from urllib import request

print('---> Updating...')
print('Date and Time: ', time.ctime(), ' - time zone:', time.tzname[0])


#--- display cool asci art ---#

attempts = 100
retry = True
while retry:
    for i in list(range(attempts)): # sometime nothing is returned but we are connected!
        try:
            #resp = request.urlopen('http://python.org/')
            con = str(subprocess.Popen([r'/sbin/iwgetid'], stdout=subprocess.PIPE,
                       shell=True).communicate())
            print('---> Internet connection:%s'%con)
            if con == "(b'', None)":
                raise Exception('Internet connection not found')
            else:
                retry = False
                break

        except:
            #urllib.error.URLError
            #print('Internet connection not found')
            print('---> trying again in 5 seconds...')
            time.sleep(5)
            if i == max(list(range(attempts))):
                retry = False
            

con = str(subprocess.Popen([r'/sbin/iwgetid'], stdout=subprocess.PIPE,
                   shell=True).communicate())
print('---> Internet connection:%s'%con)
        
try:
    subprocess.check_call(["python3", "/home/pi/Scripts/clean_datastore.py"])
    time.sleep(1)
except:
    pass

#--- get email data only keeps data if < 3 days old ---#
try:
    subprocess.check_call(["python3", "/home/pi/Scripts/getemaildata.py"])
    time.sleep(1)
except:
    pass

try:
    subprocess.check_call(["python3", "/home/pi/Scripts/plotgeomagdata.py"])
    time.sleep(1)
except:
    pass
