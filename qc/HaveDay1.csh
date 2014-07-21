#!/bin/csh 

##### This version is for SBA ###############################################
# HaveDay1.csh like LateDay1.csh but no FTP. 
# Now does second files as well as minute files
# Process an old day of magnetic data from ftp.geonet.org.nz 
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is 2-digit day
# Special version: $5 is the cleaning delay [sec]

if ($#argv == 0) then
  echo "Call as  HaveDay1.csh stn yr mth day"
  stop
endif

set st3 = `echo $1 | cut -c1,2`c
set fge_end = "00.00.fge-eyrewell.txt"
set gsm_end = "00.00.gsm-eyrewell.txt"
set st1 = ey1
if ( $1 == "sba" ) then
   set fge_end = "00.00.fge-scottbase.txt"
   set gsm_end = "00.00.gsm-scottbase.txt"
   set st1 = sb1
   set st22 = sb2
   set st4 = sb4
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
   set st2 = `echo $1 | cut -c1,2`
   set st3 = `echo $1 | cut -c1,2`c
   set sts = `echo $1 | cut -c1,2`s
   set stt = `echo $1 | cut -c1,2`t
   set stx = `echo $1 | cut -c1,2`x
   set stb = $st3'/'$yr$mth$day'.'$st2'b'
   set stc = $st3'/'$yr$mth$day'.'$st3
   set stf = $st3'/'$yr$mth$day'.'$st2'f'
   set sto = $st3'/'$yr$mth$day'.'$st2'co'
   set str = $yr$mth$day'.'
   set eyk = $yr$mth$day'k.'$1

#  New bit here, delete output files
   cd /amp/magobs/$1/$1
   echo $str
   rm $str$1
   rm $str$stt
   rm $str$stx

   cd /amp/magobs/$1

#  Rename previous .stc file
   mv $stc $sto


foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

   set ymd = "20$2-$3-$4 + $hr hours"
   set hr  = `date -u -d "$ymd" +%H`
   echo  `date +"%Y-%m-%d %H:%M"   -u -d "$ymd"` 

   set epoch  = `date -u -d "$ymd" +%s`
   @ epoch = $epoch - 3600
   set utc = "UTC 1970-01-01 "$epoch" secs"
   #echo $utc 

   set yearq =   `date -ud @$epoch +%Y`
   set yrq =   `date -ud @$epoch +%y`
   set mthq =   `date -ud @$epoch +%m`
   set dayq =   `date -ud @$epoch +%d`
   set hrq =   `date -ud @$epoch +%H`
   echo $yearq-$mthq-$dayq $hrq

   set fge_file = $year.$doy.$hr$fge_end
   set gsm_file = $year.$doy.$hr$gsm_end


#  New program to write hourly processed files

   /home/tanjap/geomag/core/hour1s $1 $day_dir $hr 

# Next lines are based on reading the ey1 or .sb1 files produced by hour1s

   set nhour = $yr$mth$day$hr'.'$st1
   set lhour = $yrq$mthq$dayq$hrq'.'$st1
   echo 'Prepare to run sendone' $nhour '  ' $lhour

#  Next lines clean effect of ionosonde at SBA from .sb1 file
#  put in "sba" instead of "noclean" to activate cleaning!!!
# cleansb1a_pro is the cleaning program specifically for manual processing
   if ( $1 == "sba" ) then
      set xhour = $yr$mth$day$hr'.'$st22
      set yhour = $yr$mth$day$hr'.'$st4
      echo 'Cleaning ' $nhour $xhour $yhour
      /home/tanjap/geomag/core/cleansb1a_pro sba $nhour $5
      mv $st3/$nhour $st3/$yhour
      mv $st3/$xhour $st3/$nhour
   endif
  /home/tanjap/geomag/core/onesecond $1 $nhour $lhour
  /home/tanjap/geomag/core/sendone $1 $nhour $lhour

   echo 'Finished sendone'
# New bit here
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino
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
   /home/tanjap/geomag/core/mpack -s $fsecg $fsecg e_gin@mail.nmh.ac.uk
   rm $fseci
   mv $fsecg hourly

end

# For now, stop here

