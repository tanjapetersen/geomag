#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 11 16:00:18 2019

@author: obrien

Script to get geomag data from gmail account with criteria
 - only get data if email is from correct sender
 - unread 
 - datafile < 3 days old based on filename
 
"""

import sys, os, glob, warnings, re
import smtplib, email, imaplib
import time, datetime
import numpy as np

#--- get file data file from email ---#
email_account = 'Geomagdata@gmail.com'
username = 'geomagdata'
pswrd = 'G30m@gAPI'

mail = imaplib.IMAP4_SSL('imap.gmail.com')
mail.login(username, pswrd)
mail.select("inbox") # connect to inbox.

#--- get emails only from sender ---#
resp, items = mail.search(None, '(UNSEEN FROM "g.obrien@gns.cri.nz")')
if len(items) > 0:
    try:
        items = items[0].split()
        latest = items[-1] # latest

        #--- get latest email ---#
        result, data = mail.fetch(latest, '(RFC822)') #'BODYSTRUCTURE')
        
        msg = email.message_from_bytes(data[0][1])
        for part in msg.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            
            #--- add hour to file name ---#
            hour_now = datetime.datetime.now().hour
            filename = part.get_filename()
            filedate = re.findall(r'\d+',filename)[0]+str(hour_now)
            newfilename = 'api'+filedate+'pmin.min'
            
            #--- only keep if < 3 days old ---#
            now = datetime.datetime.now()
            keepif = datetime.timedelta(days=3) # < 3 days ago
            if datetime.datetime.strptime(re.findall(r'\d+',
                                                     newfilename)[0],
                                                     '%Y%m%d%H') > now-keepif:
                magdata = part.get_payload(decode=True)
                magdata = magdata.splitlines()[21:]
                headers = magdata.pop(0)
                magdata = np.array(magdata)
                magdata = np.append(headers, magdata)
                np.save(os.path.join('../Data', newfilename),
                        magdata)
                           
                print('---> New geomagdata hour file for %s'%filedate)
            # --- write binary for small file size ? ---#
            
            mail.store(latest, '+FLAGS', '\Seen') # flags as read
            mail.expunge()
    except:
        print('---> no new geomagdata emails')
                
mail.close()
mail.logout()
