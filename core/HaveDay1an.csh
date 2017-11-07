#!/bin/csh 

##### This version is for API, EYR & SBA
# Process an old day of magnetic data.
# This script together with a ftp-downloading 
# script (FtpFile.csh) is automatically called 
# by CheckDay.csh if data is missing.
# Does second files as well as minute files.
#
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is 2-digit day

if ($#argv == 0) then
  echo "Call as  HaveDay1an.csh api yr mth day"
  stop
endif

echo Running HaveDay1an.csh now ...


   set ymd = "20$2-$3-$4"
   set year  = `date -u -d "$ymd" +%Y`
   set yr  = `date -u -d "$ymd" +%y`
   set month  = `date -u -d "$ymd" +%b`
   set mth  = `date -u -d "$ymd" +%m`
   set doy  = `date -u -d "$ymd" +%j`
   set day  = `date -u -d "$ymd" +%d`
   set epoch  = `date -u -d "$ymd" +%s`
   @ epoch = $epoch + 86400
   set doyp =   `date -ud @$epoch +%j`
   set day_dir = $year.$doy
   set new_dir = $year.$doyp
 
   set stt = `echo $1 | cut -c1,2`t
   set stx = `echo $1 | cut -c1,2`x

   set str = $yr$mth$day'.'
   set eyk = $yr$mth$day'k.'$1

#  Delete output files
   cd /amp/magobs/$1/$1
  # echo $str
   echo

   rm $str$1
   rm $str$stt
   rm $str$stx

   cd /amp/magobs/$1

echo "HaveDay1.csh is calling GetHour1.csh NOW for every hour of the day...."
foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

#  Write hourly processed files
#  GetHour1.csh stn yr mth day hr 
  /home/tanjap/geomag/core/GetHour1am.csh $1 $2 $3 $4 $hr 
end
echo "HaveDay1.csh is done for now."
echo
# For now, stop here

