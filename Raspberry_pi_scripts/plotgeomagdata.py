#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 15 10:43:39 2019

@author: obrien

Script to display geomag (API) data
 - plots all data in data store ../Data/

matplotlib or plotly?
"""

import matplotlib as mpl
#mpl.use('Agg')
mpl.use('Qt5Agg')

import os, glob, re
import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as image

import subprocess

#mpl.rcParams['toolbar'] = 'None'
plt.close('all') # close previous figure
plt.style.use('bmh')
plt.ioff() # make non-interactive

store = r'/home/pi/Data'
datafiles = glob.glob(os.path.join(store, '*pmin.min.npy'))

#--- get screen dimensions, can be useful if maximise fig fails ---#
screen = str(subprocess.Popen(["xdpyinfo | grep dimensions"],
                          stdout=subprocess.PIPE, shell=True).communicate())
screen = re.findall(' \((.+ millimeters)\)', screen)[0]
width, height = screen.split()[0].split('x')
width = float(width)/25.4 # inches
height = float(height)/25.4

fig = plt.figure(num='Geomagnetic data display - refreshes every hour (X:30)',
                 figsize=(width, height))
ax1 = fig.add_subplot(511)
ax2 = fig.add_subplot(512, sharex=ax1)
ax3 = fig.add_subplot(513, sharex=ax1)
ax4 = fig.add_subplot(514, sharex=ax1)
ax5 = fig.add_subplot(515, sharex=ax1)

im = image.imread(r'/home/pi/Scripts/sunspot_ca.jpg')
#im[:,:,-1] = 0.5
#fig.figimage(im, 10, 10, alpha=0.3, zorder=3, )
axbg = fig.add_axes([0,0,1,1], frameon=False, xticks=[], yticks=[])
axbg.imshow(im, alpha=0.3, zorder=-1)
    
print(len(datafiles), ' files in datastore')

if len(datafiles) != 0:
    alldata = []
    alldt = []
    #allfdiff = []
    for f in datafiles:
        data = np.load(f)
        data = np.char.split(data)[1:]
        data = np.vstack(data)
        date = np.char.add(data[:,0], data[:,1])#.astype(str)
        dt = [datetime.datetime.strptime(d, '%Y-%m-%d%H:%M:%S.%f') for d in date.astype(str)]
         
        #fdiff = np.sqrt(np.square(data[:,3].astype(float)) +\
        #        np.square(data[:,4].astype(float)) +\
        #        np.square(data[:,5].astype(float))) - data[:,6].astype(float)
                
        alldata.append(data)
        alldt.append(dt)
        #allfdiff.append(fdiff)
        
    data = np.concatenate(alldata)
    #print(data.shape)
    dt, ui = np.unique(np.concatenate(alldt), return_index=True)
    #fdiff = np.concatenate(allfdiff)
    data = data[ui]
    #print(data.shape)
    
    x = data[:,3].astype(float)
    y = data[:,4].astype(float)
    z = data[:,5].astype(float)
    s = data[:,6].astype(float)
    
    x[x == 99999.0] = np.nan
    y[y == 99999.0] = np.nan
    z[z == 99999.0] = np.nan
    s[s == 99999.0] = np.nan
    
    #--- calculate fdiff ---#
    fdiff = np.sqrt(np.square(x) + np.square(y) + np.square(z)) - s
    
    ax1.plot(dt, x, marker='.', color='k', ls='', markersize=0.5)#lw=0.5)
    ax2.plot(dt, y, marker='.',color='k', ls='', markersize=0.5)#lw=0.5)
    ax3.plot(dt, z, marker='.',color='k', ls='', markersize=0.5)#lw=0.5)
    ax4.plot(dt, s, marker='.',color='k', ls='', markersize=0.5)#lw=0.5)
    ax5.plot(dt, fdiff, marker='.', color='b', ls='', markersize=0.5)#lw=0.5)
    if fdiff.max() > fdiff.mean()*10.:
        from scipy import signal
        ax5t = ax5.twinx()
        ax5t.plot(dt, signal.medfilt(fdiff, 21), color='g', lw=0.5)
        ax5t.set_ylabel('F despiked', color='g', fontsize=10)
        
    #--- add bar for current time ---#
    ax1.vlines(datetime.datetime.utcnow(), ymin=ax1.get_ylim()[0],
            ymax=ax1.get_ylim()[1], color='r', linewidth=0.5)
    ax2.vlines(datetime.datetime.utcnow(), ymin=ax2.get_ylim()[0],
            ymax=ax2.get_ylim()[1], color='r', linewidth=0.5)
    ax3.vlines(datetime.datetime.utcnow(), ymin=ax3.get_ylim()[0],
            ymax=ax3.get_ylim()[1], color='r', linewidth=0.5)
    ax4.vlines(datetime.datetime.utcnow(), ymin=ax4.get_ylim()[0],
            ymax=ax4.get_ylim()[1], color='r', linewidth=0.5)
    ax5.vlines(datetime.datetime.utcnow(), ymin=ax5.get_ylim()[0],
            ymax=ax5.get_ylim()[1], color='r', linewidth=0.5)

    ax1.grid(which='both', alpha=0.5, lw=0.25)
    ax2.grid(which='both', alpha=0.5, lw=0.25)
    ax3.grid(which='both', alpha=0.5, lw=0.25)
    ax4.grid(which='both', alpha=0.5, lw=0.25)
    ax5.grid(which='both', alpha=0.5, lw=0.25)
    
    plt.setp(ax1.get_xticklabels(), visible=False)
    plt.setp(ax2.get_xticklabels(), visible=False)
    plt.setp(ax3.get_xticklabels(), visible=False)
    plt.setp(ax4.get_xticklabels(), visible=False)
    
    fontsize = 10
    ax1.set_ylabel('X (nt)', fontsize=fontsize,)
    ax2.set_ylabel('Y (nt)', fontsize=fontsize,)
    ax3.set_ylabel('Z (nt)', fontsize=fontsize,)
    ax4.set_ylabel('S (scalar - nt)', fontsize=fontsize,)
    ax5.set_ylabel('F (difference - nt)', fontsize=fontsize, color='b')
    
    ax1.get_yaxis().set_label_coords(-0.08,0.5)
    ax2.get_yaxis().set_label_coords(-0.08,0.5)
    ax3.get_yaxis().set_label_coords(-0.08,0.5)
    ax4.get_yaxis().set_label_coords(-0.08,0.5)
    ax5.get_yaxis().set_label_coords(-0.08,0.5)
    
    #ax5.set_xlabel('Days from %s'%dt[0].date().isoformat() +\
    #               ' (jday %s)'%dt[0].strftime('%j') \
    #               + ' to %s'%dt[-1].date().isoformat() +\
    #               ' (jday %s)'%dt[-1].strftime('%j'),
    #               fontsize=10)
    ax5.set_xlabel('UTC days from %s'%min(dt).date().isoformat() +\
                   ' (jday %s)'%min(dt).strftime('%j') \
                   + ' to %s'%max(dt).date().isoformat() +\
                   ' (jday %s)'%max(dt).strftime('%j'),
                   fontsize=10)
    
    ax1.set_title('API (Apia, Western Samoa) \n Data type: adjusted, 1-minute data (UTC)')
    
    im = image.imread(r'/home/pi/Scripts/gnslogo.png')
    ax6 = fig.add_axes([0.91, 0.64, 0.08, 0.25], frameon=False,
                       xticks=[], yticks=[])
    ax6.grid(False)
    ax6.imshow(im, alpha=1)

    ax1.patch.set_alpha(0.9)
    ax2.patch.set_alpha(0.9)
    ax3.patch.set_alpha(0.9)
    ax4.patch.set_alpha(0.9)
    ax5.patch.set_alpha(0.9)
    
    #--- maximise figure i.e. to fit screen ---#
    wm = plt.get_current_fig_manager()
    wm.window.showMaximized()
    #wm.window.showFullScreen()
    plt.show()
else:
    plt.close()
    print('---> No data in data store (%s/*.pmin.npy)%s'%store)
