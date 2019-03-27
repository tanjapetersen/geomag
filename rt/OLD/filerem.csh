#!/bin/csh 

# Run this script once per day to remove old files.
# in/*.csv over two weeks old
# /amp/ftp/pub/geomagnetism/*.out over two weeks old

set source_machine = ftp.geonet.org.nz

set year  = `date -u --date='14 days ago' +%Y`
set yr  =   `date -u --date='14 days ago' +%y`
set mth =   `date -u --date='14 days ago' +%m`
set doy =   `date -u --date='14 days ago' +%j`
set day =   `date -u --date='14 days ago' +%d`
set hr =   `date -u --date='14 days ago' +%l`

echo $yr $mth $doy $day 
#  set default directories and filenames, etc

#  filein deletes input file of Geonet rt
#  fileftp deletes /amp/ftp/pub/geomagnetism copy of output files
set filein = /amp/magobs/eyr/rt/in/$year.$doy.'*.csv'
set fileftp = /amp/ftp/pub/geomagnetism/eyr$yr$mth$day'*.out'
rm  $filein
rm -f $fileftp
