#!/bin/csh 

# Get one hour of magnetic data from ftp.geonet.org.nz 
# This version for all stations
# $1 is 3 letter code (lower case) for station
# $2 is NOW (for current date/time) or 2-digit year, 
# If $2 is not NOW then $3 is month, $4 day, $5 hr, all 2-digit
# **** shows new code sections,   #### lines can go

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
   echo Running GetHour1am.csh now for 
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

#  Go into the data subdirectory /amp/magobs/$1/data/
cd /amp/magobs/$1/data

echo $1$fge_file
echo ftp starts at `date --rfc-3339='ns'`

#  Get raw data from the GeoNet ftp site
ftp -in $source_machine << endftp1
  user anonymous t.petersen 
  cd geomag
  cd $year
  cd $day_dir
  get $fge_file 
  get $gsm_file 
  get $ben_file 
endftp1
echo ftp ends at `date --rfc-3339='ns'`
echo

#  If not eyr, delete ben_file
if( $1 != "eyr") then
   rm $ben_file
endif

#  Count lines in data files
echo Counting lines in the data files:
set len_fge = `wc -l $fge_file`
set len_fge = `echo $len_fge | cut -d' ' -f1 `
set len_gsm = `wc -l $gsm_file`
set len_gsm = `echo $len_gsm | cut -d' ' -f1 `
echo fge has $len_fge lines, gsm has $len_gsm lines

#  Return from e.g. /amp/magobs/eyr/data/ to main station directory e.g. /amp/magobs/eyr/
cd ..

#  Run FORTRAN program hour1.f to create hourly processed files
echo Calling hour1aE.f now...
/home/tanjap/geomag/core/hour1aE $1 $day_dir $hr 

#  Next lines are based on reading the .ap1/.ey1/.sb1 files produced by hour1a
  set nhour = $yr$mth$day$hr'.'$st1
  set lhour = $yrq$mthq$dayq$hrq'.'$st1
echo  
echo 'Prepare to run sendone' $nhour ' ' $lhour

#  Ionosonde cleaning for sba only using iono.sym
if ( $1 == "sba" ) then
  set xhour = $yr$mth$day$hr'.'$st2
  set yhour = $yr$mth$day$hr'.'$st4
  /home/tanjap/geomag/core/cleansbsym sba $nhour
  mv $st3/$nhour $st3/$yhour
  mv $st3/$xhour $st3/$nhour
endif

#  Run FORTRAN programs onesecond.f and sendone.f
/home/tanjap/geomag/core/onesecond $1 $nhour 
/home/tanjap/geomag/core/sendone $1 $nhour $lhour
  echo 'Finished sendone'
  echo

#  Create filenames for seconds and minutes files
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino
   set fseci = $1$year$mth$day$hr'00psec.tmp'
   set fseco = $1$year$mth$day$hr'00psec.sec'
   set fsecg = $1$year$mth$day$hr'00psec.sec.gz'
   set fsecd = $1'/'$1$year$mth$day'psec.sec'
#
   cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fseco

   set plot = $1'plotfile.txt'
   set plott = $1'plotfile.tmp'
   mv $plot $plott
   cat $fmini $plott > $plot

  Send minute files to ETH, Zurich
if (( $2 == 'NOW' )||( $6 == "YES")) then
   if ( $1 == "api" ) then
      echo Connecting to Keeling ...
      set eth_machine = keeling@koblizek.ethz.ch
#     sftp -v $eth_machine << endftp3
      sftp $eth_machine << endftp3
      cd magdata/minute/API
      put $fmino
endftp3
   endif
endif

#  Send minute and second files to Edinburgh for their GIN-page
   echo Sending files to Edinburgh ...
   gzip $fmino
   gzip $fseco
   /home/tanjap/geomag/core/mpack -s $fming $fming e_gin@mail.nmh.ac.uk
   /home/tanjap/geomag/core/mpack -s $fsecg $fsecg e_gin@mail.nmh.ac.uk

#  Now start writing Daily IAGA-2002 Files ("pmin & psec files") by adding headers 
echo Writing Daily IAGA-2002 Files...
if ( $hr == '00' ) then
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmind
   cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fsecd
else
   mv $fmind temp.min
   cat temp.min $fmini > $fmind
   mv $fsecd temp.sec
   cat temp.sec $fseci > $fsecd
endif
 
#  Shift files to hourly sub-directory
   rm $fmini
   rm $fseci
   mv $fming hourly 
   mv $fsecg hourly 

#  After first 3 hours of a day are done, do K-index for previous day
if ( $2 == 'NOW' ) then
   if($hr == '02') then
      set stk = $yrp$mthp$dayp'k.'$1
      echo kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day
      /home/tanjap/geomag/core/kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day

# e-mail k-indices; only the EYR K-index files are emailed to Paris
#      mail -s $stk t.hurst@gns.cri.nz < klatest.$1
#      mail -s $stk T.Petersen@gns.cri.nz < klatest.$1
#      echo "K-index posted"
      mv klatest.$1 kfiles/$stk 
   endif
endif

echo Finished GetHour1am.csh for 
   echo `date +"%Y-%m-%d %H:%M"  -u -d "$ymd"`
echo
#  Plot last 2 days files for Apia (puts .pdf onto ftp://ftp.gns.cri.nz/pub/tanjap/ & a .ps into /amp/magobs/api/api/
# $1 gives sub-directory, $2 is B for plotting Benmore
   /home/tanjap/geomag/core/Plotx.csh $1 B

