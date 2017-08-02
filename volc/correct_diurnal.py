#!/usr/bin/env python
'''
CORRECT_DIURNAL
Correct survey data from diurnal variations using base station
Base station data spline interpolated for survey measurements timestamp

NOTE: assumption that there is a station name at the end of the every measurement (infile1)

Usage: correct_diurnal.py <surveydate>
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
#import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt
################################################################################


################################################################################
# I/O
################################################################################
# USER INPUT
surveydate = str(sys.argv[1])

# INPUT
infile1 = '../data/' + surveydate + '/base/WImagn_' + surveydate + '_base.dat'
infile2 = '../data/' + surveydate + '/survey/WImagn_' + surveydate + '_surveyidentified.dat'

# OUTPUT
outfile = '../data/' + surveydate + '/survey/WImagn_' + surveydate + '_surveyidentifiedcorr.dat'
################################################################################

################################################################################
# READ INPUT FILES
################################################################################
#------------------------------
# FILE1 (BASE)
fid1 = open(infile1,'r')
a1 = fid1.readlines()
fid1.close()
counter = 0
dst1 = []
base = []
for line in a1:
    if counter!= 0: # if not header
        y,m,d,h,mn,ss,dd = string.split(line)
        dst1.append(dt.datetime(int(y),int(m),int(d),int(h),int(mn),int(ss)))
        base.append(float(dd))
    counter += 1

t1 = date2num(dst1) # datetime object to ordinal

#------------------------------
# FILE2 (CAMPAIGN DATA)
fid2 = open(infile2,'r')
a2 = fid2.readlines()
fid2.close()
counter = 0
dst2 = []
data = []
stat = []
for line in a2:
    if counter!= 0: # if not header
         y,m,d,h,mn,ss,dd,st = string.split(line)
         dst2.append(dt.datetime(int(y),int(m),int(d),int(h),int(mn),int(ss)))
         data.append(float(dd))
         stat.append(st)
    counter += 1

t2 = date2num(dst2) # datetime object to ordinal
data = np.array(data)
################################################################################

################################################################################
# INTERPOLATE BASE to DATA TIMESTAMP
################################################################################
# create spline on BASE
tck = interpolate.splrep(t1,base)

# V1: if base is continuously recording during survey (i.e., start before and ends after) 
# interpolate base to data timestamp using spline
#base2 = interpolate.splev(t2,tck) 

# V2: if base isn't continuously recording during survey (i.e., start after and/or ends before)
# only interpolate base for time t1 comprised within t2
# if outside t2 (i.e., base stops before end of survey for example, use last recorded value)
t2_interp = t2[(t2>=min(t1)) & (t2<=max(t1))] # define new t2 range
base2_interp = interpolate.splev(t2_interp,tck)

t2_small = len(t2[(t2<min(t1))])
base2_small = np.array([base[0]] * t2_small) 
t2_high = len(t2[(t2>max(t1))])
base2_high = np.array([base[len(base)-1]] * t2_high)

base2_1 = np.concatenate([base2_small,base2_interp])
base2 = np.concatenate([base2_1,base2_high])


#------------------------------
# PLOT
#------------------------------
# show interpolation
plt.figure()
# plot base
plt.plot_date(dst1,base,'.k')
# plot interpolated base at survey timestamp
plt.plot_date(dst2,base2,'or')
plt.ylabel('nT')
plt.title('Base (black), Base spline interpolated to data timestamp (red)')
#plt.show()
plt.savefig('../figures/' + surveydate + '/base.png')
#------------------------------

################################################################################
# APPLY BASE CORRECTION
################################################################################
# make correction relative to first data point
corrval = base2-base2[0]
# apply correction
data_corr = data - corrval


#------------------------------
# PLOT
#------------------------------
# show interpolation
plt.figure()
# plot data
plt.plot_date(dst2,data,'.k')
# plot corrected data
plt.plot_date(dst2,data_corr,'or')
plt.ylabel('nT')
plt.title('Raw (black), Corrected (red)')
#plt.show()
plt.savefig('../figures/' + surveydate + '/correct_diurnal.png')
#------------------------------

################################################################################
# SAVE CORRECTED DATA
################################################################################
fidout = open(outfile,'w')
# write header
hdr = '#Year(UTC) Month(UTC) Day(UTC) Hour(UTC) Min(UTC) Sec(UTC) CorrectedMagneticData(nT) Station\n'
fidout.write(hdr)   
# write data
for i in np.arange(0,len(dst2)):
    outstr = dt.datetime.strftime(dst2[i],'%Y %m %d %H %M %S ') + str(data_corr[i]) + ' ' + str(stat[i]) + '\n'
    fidout.write(outstr)     
fidout.close()

print 'DONE!'
