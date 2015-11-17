#!/bin/csh 

##### This version is for API & manual processing ####################
# This is the version you can alter for 
# manual processing (qc/ directory).
# Processes an old day of magnetic data.
# It requires downloading missing data from 
# ftp server, BEFORE running this script.
# Does send minute files to Edinburgh but NOT ZURICH.
# SENDING to Edinburgh - careful when you use 
# script for several days/months.  
# Does second files as well as minute files
#
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is 2-digit day

if ($#argv == 0) then
  echo "Call as  HaveDay1a.csh api yr mth day"
  stop
endif

echo Running HaveDay1a.csh now ...

set st3 = `echo $1 | cut -c1,2`c
set fge_end = "00.00.fge-eyrewell.txt"
set gsm_end = "00.00.gsm-eyrewell.txt"
set st1 = ey1
if ( $1 == "sba" ) then
   set fge_end = "00.00.fge-scottbase.txt"
   set gsm_end = "00.00.gsm-scottbase.txt"
   set st1 = sb1
endif
if ( $1 == "api" ) then
   set fge_end = "00.00.fge-apia.txt"
   set gsm_end = "00.00.gsm-apia.raw"
   set st1 = ap1
endif
echo $st1 $fge_end $gsm_end 

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
   
   #set st2 = `echo $1 | cut -c1,2`
   #set st3 = `echo $1 | cut -c1,2`c
   #set sts = `echo $1 | cut -c1,2`s
   set stt = `echo $1 | cut -c1,2`t
   set stx = `echo $1 | cut -c1,2`x
   #set stb = $st3'/'$yr$mth$day'.'$st2'b'
   #set stc = $st3'/'$yr$mth$day'.'$st3
   #set stf = $st3'/'$yr$mth$day'.'$st2'f'
   #set sto = $st3'/'$yr$mth$day'.'$st2'co'
   set str = $yr$mth$day'.'
   set eyk = $yr$mth$day'k.'$1

#  Delete output files
   cd /amp/magobs/$1/$1
   echo $str

   rm $str$1
   rm $str$stt
   rm $str$stx

   cd /amp/magobs/$1

#  Rename previous .stc file
#   mv $stc $sto

foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

   set ymd = "20$2-$3-$4 + $hr hours"
   set hr  = `date -u -d "$ymd" +%H`
   echo  `date +"%Y-%m-%d %H:%M"   -u -d "$ymd"` 

   set epoch  = `date -u -d "$ymd" +%s`
   @ epoch = $epoch - 3600
   set utc = "UTC 1970-01-01 "$epoch" secs"
   echo $utc 

   set yearq =   `date -ud @$epoch +%Y`
   set yrq =   `date -ud @$epoch +%y`
   set mthq =   `date -ud @$epoch +%m`
   set dayq =   `date -ud @$epoch +%d`
   set hrq =   `date -ud @$epoch +%H`
   echo $yearq-$mthq-$dayq $hrq

   set fge_file = $year.$doy.$hr$fge_end
   set gsm_file = $year.$doy.$hr$gsm_end


#  Write hourly processed files

   /home/tanjap/geomag/core/hour1a $1 $day_dir $hr 

# Next lines are based on reading the ey1, sb1 or ap1 files produced by hour1a

   set nhour = $yr$mth$day$hr'.'$st1
   set lhour = $yrq$mthq$dayq$hrq'.'$st1
   echo 'Prepare to run sendone' $nhour '  ' $lhour

   /home/tanjap/geomag/core/onesecond $1 $nhour $lhour
   /home/tanjap/geomag/core/sendone $1 $nhour $lhour

   echo 'Finished sendone'
# New bit here
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino

# Comment all this if you DON'T want to send to ETH, Zurich:
#  Send minute files to ETH, Zurich
#if ( $1 == "api" ) then
#  echo Connecting to Keeling ...
#  set eth_machine = keeling@koblizek.ethz.ch
#  sftp -v $eth_machine << endftp3
#  cd magdata/minute/API
#  put $fmino
#endftp3
#endif


# To SEND hourly minute files to Edinburgh (also in line further down!!!):
  echo Sending hourly minute files to Edinburgh ...
  gzip $fmino
 /home/tanjap/geomag/core/mpack -s $fming $fming e_gin@mail.nmh.ac.uk

#  Now start writing Daily IAGA-2002 Files
 
   if ( $hr == '00' ) then
      cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmind
   else
      mv $fmind temp.min
      cat temp.min $fmini > $fmind
   endif


   rm $fmini
   mv $fming hourly
   set fseci = $1$year$mth$day$hr'00psec.tmp'
   set fseco = $1$year$mth$day$hr'00psec.sec'
   set fsecg = $1$year$mth$day$hr'00psec.sec.gz'
   cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fseco
   
gzip $fseco

# To SEND hourly second files to Edinburgh:
   /home/tanjap/geomag/core/mpack -s $fsecg $fsecg e_gin@mail.nmh.ac.uk
   rm $fseci
   mv $fsecg hourly

end

# For now, stop here

