#!/bin/csh 

#get one hour of magnetic data from ftp.geonet.org.nz 
# $1 is 3 letter code (lower case) for station
# $2 is NOW (for current date/time) or 2-digit year, 
# If $2 is not NOW then $3 is month, $4 day, $5 hr, all 2-digit
# ********* shows new code sections,   #### lines can go

set source_machine = ftp.geonet.org.nz

# ********* 
if ($#argv == 0) then
   echo "Call  GetHour1.csh stn NOW    for current processing"
   echo "or    GetHour1.csh stn yr mth day hr   (all 2-digit) for reruns"
   stop
endif
if ( $2 == 'NOW' ) then
# ********* 
set year  = `date -u --date='1 hours ago' +%Y`
set yr  = `date -u --date='1 hours ago' +%y`
########set month = `date -u --date='1 hours ago' +%b`
set mth = `date -u --date='1 hours ago' +%m`
set doy =   `date -u --date='1 hours ago' +%j`
########set doyp =   `date -u --date='25 hours ago' +%j`
set day =   `date -u --date='1 hours ago' +%d`
######## set dow =   `date -u --date='1 hours ago' +%w`
set hr =    `date -u --date='1 hours ago' +%H`

set yearp = `date -u --date='25 hours ago' +%Y`
set yrp  = `date -u --date='25 hours ago' +%y`
set mthp = `date -u --date='25 hours ago' +%m`
set dayp = `date -u --date='25 hours ago' +%d`

set yrpp  = `date -u --date='49 hours ago' +%y`
set mthpp = `date -u --date='49 hours ago' +%m`
set daypp = `date -u --date='49 hours ago' +%d`

#######set yearq = `date -u --date='2 hours ago' +%Y`
set yrq  =  `date -u --date='2 hours ago' +%y`
set mthq =  `date -u --date='2 hours ago' +%m`
set dayq =  `date -u --date='2 hours ago' +%d`
set hrq =   `date -u --date='2 hours ago' +%H`

# ********* 
else
   set ymd  = "20$2-$3-$4 + $5 hours" 
   echo `date +"%Y-%m-%d %H:%M"  -u -d "$ymd"`
   set epoch = `date -u -d "$ymd" +%s`
   set mth = `date -ud @$epoch +%m`
   set doy = `date -ud @$epoch +%j`
   set day = `date -ud @$epoch +%d`
   set  hr = `date -ud @$epoch +%H`
   echo $mth $doy $day $hr

   @ e1 = $epoch - 3600
   set yrq =  `date -ud @$e1 +%y`
   set mthq = `date -ud @$e1 +%m`
   set dayq = `date -ud @$e1 +%d`
   set hrq =  `date -ud @$e1 +%H`
   echo $yrq $mthq $dayq $hrq

   @ e24 = $epoch - 86400
   set yearp =  `date -ud @$e24 +%Y`
   set yrp  =   `date -ud @$e24 +%y`
   set mthp =   `date -ud @$e24 +%m`
   set dayp =   `date -ud @$e24 +%d`
   echo $yearp $yrp $mthp $dayp

   @ e48 = $e24 - 86400
   set yrpp  =   `date -ud @$e48 +%y`
   set mthpp =   `date -ud @$e48 +%m`
   set daypp =   `date -ud @$e48 +%d`
   echo $yrpp $mthpp $daypp

endif


# ********* 

set source_machine = ftp.geonet.org.nz

set year  = `date -u --date='1 hours ago' +%Y`
set yr  = `date -u --date='1 hours ago' +%y`
set month = `date -u --date='1 hours ago' +%b`
set mth = `date -u --date='1 hours ago' +%m`
set doy =   `date -u --date='1 hours ago' +%j`
#set doyp =   `date -u --date='25 hours ago' +%j`
set day =   `date -u --date='1 hours ago' +%d`
set dow =   `date -u --date='1 hours ago' +%w`
set hr =    `date -u --date='1 hours ago' +%H`

set yearp = `date -u --date='25 hours ago' +%Y`
set yrp  = `date -u --date='25 hours ago' +%y`
set mthp = `date -u --date='25 hours ago' +%m`
set dayp = `date -u --date='25 hours ago' +%d`

set yrpp  = `date -u --date='49 hours ago' +%y`
set mthpp = `date -u --date='49 hours ago' +%m`
set daypp = `date -u --date='49 hours ago' +%d`

set yearq = `date -u --date='2 hours ago' +%Y`
set yrq  =  `date -u --date='2 hours ago' +%y`
set mthq =  `date -u --date='2 hours ago' +%m`
set dayq =  `date -u --date='2 hours ago' +%d`
set hrq =   `date -u --date='2 hours ago' +%H`


#set default directories and filenames, etc

set fge_end = "00.00.fge-eyrewell.txt"
set gsm_end = "00.00.westmelton.raw"
set st1 = ey1
if ( $1 == "sba" ) then
   set fge_end = "00.00.fge-scottbase.txt"
   set gsm_end = "00.00.gsm-scottbase.txt"
   set st1 = sb1
#  set st2 = sb2
#  set st4 = sb4
endif
  echo $st1 $fge_end $gsm_end 

set day_dir = $year.$doy
set fge_file = $year.$doy.$hr$fge_end
set gsm_file = $year.$doy.$hr$gsm_end
if ($1 == "eyr") then
   set ben_end = "00.00.fge-benmore.raw"
   set ben_file = $year.$doy.$hr$ben_end
endif
#set be2_file = $year.$doy.$hr$be2_end
#set tmp_file = $year.$doy.$hr$tmp_end
set st3 = `echo $1 | cut -c1,2`c
set stc = $st3'/'$yr$mth$day'.'$st3
set stcp = $st3'/'$yrp$mthp$dayp'.'$st3
echo 'stc is '$stc' & stcp is '$stcp 

cd /amp/magobs/$1/data


echo $year $doy $month $day_dir $fge_file
echo
echo ftp starts at `date --rfc-3339='ns'`
#do the ftp
ftp -inv $source_machine << endftp1
  user anonymous t.hurst 
  cd geomag
  cd $year
  cd $day_dir
  get $fge_file 
  get $gsm_file 
  get $ben_file 
endftp1
echo ftp ends at `date --rfc-3339='ns'`
echo

# Scott Base does not need Benmore File
if ( $1 == "sba" ) then
   rm $ben_file 
endif

#  Count lines in data files
set len_fge = `wc -l $fge_file`
set len_fge = `echo $len_fge | cut -d' ' -f1 `
set len_gsm = `wc -l $gsm_file`
set len_gsm = `echo $len_gsm | cut -d' ' -f1 `
echo fge file has $len_fge lines, gsm file has $len_gsm lines


#  Return to main station directory
cd ..

#  New program to write hourly processed files

/home/tanjap/geomag/core/hour1w $1 $day_dir $hr 

# Next lines are based on reading the ey1 or .sb1 files produced by hour1s

  set nhour = $yr$mth$day$hr'.'$st1
  set lhour = $yrq$mthq$dayq$hrq'.'$st1
  echo 'Prepare to run sendone' $nhour '  ' $lhour

#if ( $1 == "sba" ) then
#   set xhour = $yr$mth$day$hr'.'$st2
#   set yhour = $yr$mth$day$hr'.'$st4
#   cleansb1 sba $nhour 
#   echo 'Cleaning ' $nhour
#   mv $st3/$nhour $st3/$yhour
#   mv $st3/$xhour $st3/$nhour
#endif

/home/tanjap/geomag/core/onesecond $1 $nhour 
/home/tanjap/geomag/core/sendone $1 $nhour $lhour
#if ( $1 == "eyr" ) then
#/home/hurst/process/sendonet $1 $nhour $lhour
#endif

  echo 'Finished sendone'
# New bit here
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino
   set fseci = $1$year$mth$day$hr'00psec.tmp'
   set fseco = $1$year$mth$day$hr'00psec.sec'
   set fsecg = $1$year$mth$day$hr'00psec.sec.gz'
   cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fseco

   set plot = $1'plotfile.txt'
   set plott = $1'plotfile.tmp'
   mv $plot $plott
   cat $fmini $plott > $plot

if ( $1 == "eyr" ) then
   set isgi_machine = ftp-isgi.latmos.ipsl.fr
   ftp -v $isgi_machine << endftp2
   cd minute_data
   cd Eyrewell
   put $fmino
endftp2

#  Next lines are to put data for University of Oulu (Finland) in ftp
   cp $fmino /amp/ftp/pub/hurst/oulu
   set fminp = eyr$yearp$mthp$dayp$hr'00pmin.min'
   echo Removing $fminp
   rm /amp/ftp/pub/hurst/oulu/$fminp
endif

   gzip $fmino
   gzip $fseco
   /home/tanjap/geomag/core/mpack -s $fming $fming e_gin@mail.nmh.ac.uk
   /home/tanjap/geomag/core/mpack -s $fsecg $fsecg e_gin@mail.nmh.ac.uk

#  Now start writing Daily IAGA-2002 Files

if ( $hr == '00' ) then
#   mv  $1$yearp$mthp$dayp'pmin.min' $1
#  set fmind = $1$year$mth$day'pmin.min'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmind
else
   mv $fmind temp.min
   cat temp.min $fmini > $fmind
endif


#  Shift files to hourly sub-directory
   rm $fmini
   rm $fseci
   mv $fming hourly 
   mv $fsecg hourly 

#  After first 3 hours of a day are done, do K-index for previous day

   if($hr == '02') then
      set stk = $yrp$mthp$dayp'k.'$1
      echo kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day
      /home/tanjap/geomag/core/kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day
# e-mail k-indices
      mail -s $stk t.hurst@gns.cri.nz < klatest.$1
      mail -s $stk T.Petersen@gns.cri.nz < klatest.$1
      echo "K-index posted"
      if ( $1 == "eyr" ) then
         mail -s $stk michel.menvielle@latmos.ipsl.fr < klatest.$1
         mail -s $stk kisgi@latmos.ipsl.fr < klatest.$1
      endif
      mv klatest.$1 kfiles/$stk 
   endif

#  Next bit checks battery voltage
set vfile = /amp/magobs/$1/$st3/volt
echo $vfile
#set V = `echo $vfile | gawk '{print $1}'`
set V = `gawk '{print $1}' < $vfile `
echo "Volts*100 = "$V

#  Plote.csh $1

#  Every 6 hours send low voltage warning
foreach hr6 (00 06 12 18)
   if ($hr6 == $hr && $V < 1260) then
      if ($V > 0) then
	set V = `gawk '{print $1/100.}' < $vfile `
      	echo $hr $hr6 $V
      	set mess = $1' only '$V' Volts'
      	mail -s "$mess" "t.hurst@gns.cri.nz" < $vfile
      	mail -s "$mess" "m.chadwick@gns.cri.nz" < $vfile
        mail -s "$mess" "t.petersen@gns.cri.nz" < $vfile
      endif
   endif
end
