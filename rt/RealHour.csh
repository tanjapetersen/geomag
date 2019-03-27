#!/bin/csh 

# Tony Hurst, Feb 2019
# POTSDAM VERSION
# Start this program about 5 minutes after a whole hour (doesn't work at <5 minutes!)
# to check data arrival from real-time (rt) files in ftp.geonet.org.nz 
# for this hour. Keeps running until all file present, or 1 day later

set source_machine = ftp.geonet.org.nz

set year  = `date -u --date='now' +%Y`		# Todays year
set yearp  = `date -u --date='1 day ago' +%Y`	# Yesterdays year (for 0000UT)
set yr  = `date -u --date='now' +%y`
# set month = `date -u --date='now' +%b`
set mth = `date -u --date='now' +%m`
set mthp = `date -u --date='1 day ago' +%m`
set doy =   `date -u --date='now' +%j`
set day =   `date -u --date='now' +%d`
set dayp =   `date -u --date='1 day ago' +%d`
set hr =    `date -u --date='now' +%H`
set min =    `date -u --date='now' +%M`

# set default directories and filenames, etc

set filetime = $year.$doy.$hr.'NZ_'
set end1 = 'EYWM_50_LFX.csv' 		# X data file
set end2 = 'EYWM_50_LFY.csv' 		# Y data file

set day_dir = $year.$doy

cd /amp/magobs/eyr/rt/in/

# Does yymmddhh.pst exist? If not, write in 0
#
if( -f $yr$mth$day$hr.pst ) then
# Do nothing
else
  echo 0 > $yr$mth$day$hr.pst  
endif
set hrn = -1	# Cannot possibly match
set minn = $min
# Now start looping, condition is 24 hours later
# but should stop soon after one hour
while (($hrn != $hr) || ( $minn > $min))
    
# ftp the desired files onto gns machine 
   echo XXX $year $mth $day $day_dir $hr $min $hrn $minn
   echo YYY $yearp   $mthp $dayp    
   echo
   echo ftp starts at `date --rfc-3339='ns'`
#do the ftp
   ftp -in $source_machine   <<endftp1 
     user anonymous tanjap 
     cd geomag
     cd rt
     cd $year
     cd $day_dir
     get $filetime$end1  
     get $filetime$end2  
     bye 
endftp1

   echo ftp ends at `date --rfc-3339='ns'`
   echo
   set len1 = `wc -l $filetime$end1`
   set len1 = `echo $len1 | cut -d' ' -f1 `
   set len2 = `wc -l $filetime$end2`
   set len2 = `echo $len2 | cut -d' ' -f1 `

   set len = $len1
   if( $len2 < $len ) set len = $len2

# Get previous $len
   set leno = `cat $yr$mth$day$hr.pst`
   echo $len1 $len2 SMALLER IS $len, OLDER IS $leno   
   if( $len > $leno ) then
      echo $len > $yr$mth$day$hr.pst  
#   Call fortran program to process seconds from leno+1 to len
      echo AT $year $mth $day  $doy $hr
      /home/tanjap/geomag/rt/realsecs eyr $year $mth $day $doy $hr $leno $len
      echo 'Fortran done 1'
      echo sendmin starts at `date --rfc-3339='ns'`
      /home/tanjap/geomag/rt/sendday eyr $year$mth$day $yearp$mthp$dayp
      echo sendmin ends at `date --rfc-3339='ns'`
      cat /home/tanjap/geomag/core/eyr_header.txt /amp/magobs/eyr/rt/min/eyr$year$mth$day'pmin.tmp' > /amp/magobs/eyr/rt/min/eyr$year$mth$day'pmin.min'
      curl --upload-file /amp/magobs/eyr/rt/min/eyr$year$mth$day'pmin.min' ftp://ftp.gfz-potsdam.de/pub/incoming/obs_niemegk/kp_index/eyr/
      echo File Sent 
   endif
   echo 'Fortran done 2'
   if ( $len > 3599) stop
   sleep 3m
end     

