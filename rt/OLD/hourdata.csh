#!/bin/csh 

# Tony Hurst, Nov 2017
# Start this program about 5 minutes after a whole hour (doesn't work at <5 minutes!)
# to check data arrival from real-time (rt) files in ftp.geonet.org.nz 
# for this hour. Keeps running until all file present, or 1 day later
# Later introduce $1 as 3 letter code (lower case) for station

set source_machine = ftp.geonet.org.nz

set year  = `date -u --date='now' +%Y`
set yr  = `date -u --date='now' +%y`
set month = `date -u --date='now' +%b`
set mth = `date -u --date='now' +%m`
set doy =   `date -u --date='now' +%j`
set day =   `date -u --date='now' +%d`
set hr =    `date -u --date='now' +%H`
set min =    `date -u --date='now' +%M`

# set default directories and filenames, etc

set filetime = $year.$doy.$hr.'NZ_'
set end1 = 'EYWM_50_LFX.csv' 
set end2 = 'EYWM_50_LFY.csv' 
set end3 = 'EYWM_50_LFZ.csv' 
set end4 = 'EYWM_51_LFF.csv' 
set end5 = 'EYWM_51_LEQ.csv' 
set end6 = 'SMHS_50_LFZ.csv' 

set day_dir = $year.$doy

cd /amp/magobs/eyr/rt/in/

# Does yymmddhh.lst exist? If not, write in 0
#
if( -f $yr$mth$day$hr.lst ) then
# Do nothing
else
  echo 0 > $yr$mth$day$hr.lst  
endif
set hrn = -1	# Cannot possibly match
set minn = $min
# Now start looping, condition is 24 hours later
# but should stop soon after one hour
while (($hrn != $hr) || ( $minn > $min))
    
# ftp the desired files onto gns machine 
   echo XXX $year $doy $month $day_dir $hr $min $hrn $minn
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
     get $filetime$end3  
     get $filetime$end4  
     get $filetime$end5  
     get $filetime$end6 
     bye 
endftp1

   echo ftp ends at `date --rfc-3339='ns'`
   echo
   set len1 = `wc -l $filetime$end1`
   set len1 = `echo $len1 | cut -d' ' -f1 `
   set len2 = `wc -l $filetime$end2`
   set len2 = `echo $len2 | cut -d' ' -f1 `
   set len3 = `wc -l $filetime$end3`
   set len3 = `echo $len3 | cut -d' ' -f1 `
   set len4 = `wc -l $filetime$end4`
   set len4 = `echo $len4 | cut -d' ' -f1 `
   set len5 = `wc -l $filetime$end5`
   set len5 = `echo $len5 | cut -d' ' -f1 `
   set len6 = `wc -l $filetime$end6`
   set len6 = `echo $len6 | cut -d' ' -f1 `

   set len = $len1
   if( $len2 < $len ) set len = $len2
   if( $len3 < $len ) set len = $len3
   if( $len4 < $len ) set len = $len4
   if( $len5 < $len ) set len = $len5
   if( $len6 < $len ) set len = $len6

# Get previous $len
   set leno = `cat $yr$mth$day$hr.lst`
   echo $len1 $len2 $len3 $len4 $len5 $len6 SMALLEST IS $len, OLDER IS $leno   
   if( $len > $leno ) then
      echo $len > $yr$mth$day$hr.lst  
#   Call fortran program to process seconds from leno+1 to len
      echo AT $year $mth $day  $doy $hr
      /home/tanjap/geomag/rt/moreseconds eyr $year $mth $day $doy $hr $leno $len
   endif
   if ( $len > 3599) stop
   sleep 5m
   set hrn =    `date -u --date='now' +%H`
   set minn =    `date -u --date='now' +%M`
   echo 'minn = ' $minn 'min = ' $min 
end     
#  Return to main station directory
cd ..

