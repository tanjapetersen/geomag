#!/usr/bin/env python
'''
COMP_FINAlMAGNVALUE
Compute final magnetic value (median) and errors (25th and 75th percentiles) for each peg  (assumed several measurements at each peg)

Usage: comp_finalmagnvalue.py <surveydate>
	<surveydate> is the date in UTC of the end of the survey
December 20, 2014
'''

################################################################################
# IMPORT MODULES
################################################################################
import sys
import numpy as np
import string
from scipy import interpolate
import datetime as dt
from matplotlib.dates import date2num, num2date
import matplotlib.pyplot as plt
################################################################################


################################################################################
# I/O
################################################################################
# USER INPUT
surveydate = str(sys.argv[1])

# INPUT
infile = '../data/' + surveydate + '/survey/WImagn_' + surveydate + '_surveyidentifiedcorr.dat'

# OUTPUT
outfile = '../data/' + surveydate + '/survey/WImagn_' + surveydate + '_surveymedian.dat'
################################################################################

################################################################################
# READ INPUT FILES
################################################################################

#------------------------------
# FILE1 (CAMPAIGN DATA)
fid = open(infile,'r')
a = fid.readlines()
fid.close()
counter = 0
magn = {}
stat = []
for line in a:
    # if not header
    if counter!= 0:
         # timestamp
         y,m,d,h,mn,ss,dd,st = string.split(line)
         #data.append(float(dd))
         if st in stat: 
		  old_magn=magn[st]
		  magn[st]=old_magn + [float(dd)]
	 else:
		  stat.append(st)
		  datastat=[]
		  datastat.append(float(dd))
                  magn[st]=datastat
    counter += 1

################################################################################
# COMPUTE STATISTICS
################################################################################

stat_stats={}
statis=[]
i=0
for station in stat:
	 #statis=[]
	 magn_2plot=np.array(magn[station])
         med=np.median(magn_2plot)
        # perc25=np.percentile(magn_2plot,25)
        # perc75=np.percentile(magn_2plot,75)
        # statis=[med,perc25,perc75]
         statis=[med]
         stat_stats[station]=statis
         print str(station)+' has values '+str(magn_2plot)+' and median '+str(statis)
	 ## Plot histogram
	 #i+=1
	 #plt.figure(i)
	 #numBins=2*len(magn_2plot)**(1/3) # Rice rule
	 #numBins=5
         #plt.hist(magn_2plot,numBins)
         #plt.xlabel(['Value for'+station])
         #plt.ylabel('Frequency')
         #plt.show()


################################################################################
# SAVE CORRECTED DATA
################################################################################
fidout = open(outfile,'w')
# Write header
hdr = '#Station FinalMagneticData(nT)\n'
fidout.write(hdr)   
# Write data
for station in stat:
   outstr =  str(station) + ' ' + str(stat_stats[station][0]) + '\n'
   fidout.write(outstr)     
fidout.close()

print 'DONE!'
