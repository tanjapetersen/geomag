#!/bin/csh 

#
# NOW SENDS THE sec File to avoid problems
# # Get one hour of magnetic data from ftp.geonet.org.nz 
# This version for all stations
# $1 is 3 letter code (lower case) for station
# $2 is NOW (for current date/time) or 2-digit year, 
# If $2 is not NOW then $3 is month, $4 day, $5 hr, all 2-digit
# LAST CHANGE - now sends data direct to web server
# ********* shows new code sections,   #### lines can go

set source_machine = ftp.geonet.org.nz

# ********* 
if ($#argv == 0) then
   echo "Call  GetHour1.csh stn NOW    for current processing"
   echo "or    GetHour1.csh stn yr mth day hr YES (all 2-digit, only add YES if you want to send to Zurich) for reruns"
   stop
endif
if ( $2 == 'NOW' ) then
# ********* 
set year  = `date -u --date='1 hours ago' +%Y`
set yr  = `date -u --date='1 hours ago' +%y`
set mth = `date -u --date='1 hours ago' +%m`
set doy =   `date -u --date='1 hours ago' +%j`
set day =   `date -u --date='1 hours ago' +%d`
set hr =    `date -u --date='1 hours ago' +%H`
set ymd  = $year-$mth-$day" + "$hr" hours" 

set yearp = `date -u --date='25 hours ago' +%Y`
set yrp  = `date -u --date='25 hours ago' +%y`
set mthp = `date -u --date='25 hours ago' +%m`
set dayp = `date -u --date='25 hours ago' +%d`

set yrpp  = `date -u --date='49 hours ago' +%y`
set mthpp = `date -u --date='49 hours ago' +%m`
set daypp = `date -u --date='49 hours ago' +%d`

set yrq  =  `date -u --date='2 hours ago' +%y`
set mthq =  `date -u --date='2 hours ago' +%m`
set dayq =  `date -u --date='2 hours ago' +%d`
set hrq =   `date -u --date='2 hours ago' +%H`

# ********* 
else
   set year = 20$2
   set yr = $2
   set ymd  = "20$2-$3-$4 + $5 hours" 
   echo Running GetHour1.csh now for 
   echo `date +"%Y-%m-%d %H:%M"  -u -d "$ymd"`
   set epoch = `date -u -d "$ymd" +%s`
   set mth = `date -ud @$epoch +%m`
   set doy = `date -ud @$epoch +%j`
   set day = `date -ud @$epoch +%d`
   set  hr = `date -ud @$epoch +%H`
   #echo $mth $doy $day $hr

   @ e1 = $epoch - 3600
   set yrq =  `date -ud @$e1 +%y`
   set mthq = `date -ud @$e1 +%m`
   set dayq = `date -ud @$e1 +%d`
   set hrq =  `date -ud @$e1 +%H`
  # echo $yrq $mthq $dayq $hrq

   @ e24 = $epoch - 86400
   set yearp =  `date -ud @$e24 +%Y`
   set yrp  =   `date -ud @$e24 +%y`
   set mthp =   `date -ud @$e24 +%m`
   set dayp =   `date -ud @$e24 +%d`
  # echo $yearp $yrp $mthp $dayp

   @ e48 = $e24 - 86400
   set yrpp  =   `date -ud @$e48 +%y`
   set mthpp =   `date -ud @$e48 +%m`
   set daypp =   `date -ud @$e48 +%d`
   #echo $yrpp $mthpp $daypp
endif

#  Set default directories and filenames, etc
#  Use eyr as default, but replace if needed
set fge_end = "00.00.fge-eyrewell.txt"
set gsm_end = "00.00.westmelton.raw"
set ben_end = "00.00.fge-benmore.raw"
set st1 = ey1
if ( $1 == "sba" ) then
   set fge_end = "00.00.fge-scottbase.txt"
   set gsm_end = "00.00.gsm-scottbase.raw"
   set st1 = sb1
#  Next two lines to make filenames for ionosonde cleaning
   set st2 = sb2
   set st4 = sb4
endif
if ( $1 == "api" ) then
   set fge_end = "00.00.fge-apia.txt"
   set gsm_end = "00.00.gsm-apia.raw"
   set st1 = ap1
endif
  #echo $st1 $fge_end $gsm_end 

set day_dir = $year.$doy
set fge_file = $year.$doy.$hr$fge_end
set gsm_file = $year.$doy.$hr$gsm_end
set ben_file = $year.$doy.$hr$ben_end
set st3 = `echo $1 | cut -c1,2`c
set stc = $st3'/'$yr$mth$day'.'$st3
set stcp = $st3'/'$yrp$mthp$dayp'.'$st3
#echo 'stc is '$stc' & stcp is '$stcp 


#  Create filenames for seconds and minutes files
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino
   set fseci = $1$year$mth$day$hr'00psec.tmp'
   set fseco = $1$year$mth$day$hr'00psec.sec'
   set fsecd = $1'/'$1$year$mth$day'psec.sec'
#  Next lines temporary files to work web-server
   set fsect = $1$year$mth$day'_'$hr'psec.sec'
   set fsecz = $1$year$mth$day'_'$hr'psec.sec.gz'
   set fsecg = $1$year$mth$day$hr'00psec.sec.gz'
   cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fseco

   set plot = $1'plotfile.txt'
   set plott = $1'plotfile.tmp'
   mv $plot $plott
   cat $fmini $plott > $plot

cd /amp/magobs/eyr

#   Send these files to web server
#
/home/tanjap/geomag/core/gin_upload.sh -d -u imo:fjks4395  $fsecz http://app.geomag.bgs.ac.uk/GINFileUpload/Cache
#/home/tanjap/geomag/core/gin_upload.sh -d -u imo:fjks4395  $fseco http://app.geomag.bgs.ac.uk/GINFileUpload/Cache

