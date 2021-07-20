#!/bin/csh 

# Get one hour of magnetic data from ftp.geonet.org.nz 
# This version for all stations STILL CHECKING
# $1 is 3 letter code (lower case) for station
# $2 is NOW (for current date/time) or 2-digit year, 
# If $2 is not NOW then $3 is month, $4 day, $5 hr, all 2-digit
# LAST CHANGE - Version for accessing .csv files, not .txt files
# ********* shows new code sections,   #### lines can go

set source_machine = ftp.geonet.org.nz

if ($#argv == 0) then
   echo "Call  GetHour1csv.csh stn NOW    for current processing"
   echo "or    GetHour1csv.csh stn yr mth day hr YES (all 2-digit, only add YES if you want to send to Zurich) for reruns"
   stop
endif
if ( $2 == 'NOW' ) then
 
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
set stnm = "EYWM"
set st1 = ey1
if ( $1 == "sba" ) then
   set stnm = "SBAM"
   set st1 = sb1
#  Next two lines to make filenames for ionosonde cleaning
   set st2 = sb2
   set st4 = sb4
endif
if ( $1 == "api" ) then
   set stnm = "APIM"
   set st1 = ap1
endif

set lfx_end = ".NZ_"$stnm"_50_LFX.csv"
set lfy_end = ".NZ_"$stnm"_50_LFY.csv"
set lfz_end = ".NZ_"$stnm"_50_LFZ.csv"
set lff_end = ".NZ_"$stnm"_51_LFF.csv"
set leq_end = ".NZ_"$stnm"_51_LEQ.csv"
set lkd_end = ".NZ_"$stnm"_50_LKD.csv"
set lks_end = ".NZ_"$stnm"_50_LKS.csv"
set sum_end = ".NZ_SMHS_50_LFZ.csv"



  #echo $st1 $fge_end $gsm_end 

set day_dir = $year.$doy
set lfx_file = $year.$doy.$hr$lfx_end
set lfy_file = $year.$doy.$hr$lfy_end
set lfz_file = $year.$doy.$hr$lfz_end
set lff_file = $year.$doy.$hr$lff_end
set leq_file = $year.$doy.$hr$leq_end
set lkd_file = $year.$doy.$hr$lkd_end
set lks_file = $year.$doy.$hr$lks_end
set sum_file = $year.$doy.$hr$sum_end
set st3 = `echo $1 | cut -c1,2`c
set stc = $st3'/'$yr$mth$day'.'$st3
set stcp = $st3'/'$yrp$mthp$dayp'.'$st3
#echo 'stc is '$stc' & stcp is '$stcp 

#  Go into the data subdirectory /amp/magobs/$1/data/
cd /amp/magobs/$1/data

echo ftp starts at `date --rfc-3339='ns'`

#  Get raw data from the GeoNet ftp site
ftp -v -in $source_machine << endftp1
  user anonymous t.petersen
  binary
  cd geomag
  cd rt
  cd $year
  cd $day_dir
  get $lfx_file
  get $lfy_file
  get $lfz_file
  get $lff_file
  get $leq_file
  get $lkd_file
  get $lks_file
  get $sum_file
endftp1
echo ftp ends at `date --rfc-3339='ns'`
echo


#  Check number of lines in each file
#
  set len_lfx = `wc -l $lfx_file `
  set len_lfx = `echo $len_lfx | cut -d' ' -f1 `
  set len_lfy = `wc -l $lfy_file `
  set len_lfy = `echo $len_lfy | cut -d' ' -f1 `
  echo lfx has $len_lfx lines, lfy has $len_lfy lines

# If not eyr, delete SMHS file
if( $1 != "eyr") then
   rm $sum_file
endif

#  Return from e.g. /amp/magobs/eyr/data/ to main station directory e.g. /amp/magobs/eyr/
cd ..

#  Run FORTRAN program hour1.f to create hourly processed files
echo Calling hour1test now...
echo Currently in sub-directory  `pwd` 
#/home/tanjap/geomag/core/hour1aE $1 $day_dir $hr 
/home/tanjap/geomag/core/hour1csv $1 $day_dir $hr 

##stop  # good place to stop for test run

#  Next lines are based on reading the .ap1/.ey1/.sb1 files produced by hour1a
  set nhour = $yr$mth$day$hr'.'$st1
  set lhour = $yrq$mthq$dayq$hrq'.'$st1
echo  
echo 'Prepare to run sendone' $nhour ' ' $lhour

#  Ionosonde cleaning for sba only
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
#
#  Create filenames for seconds and minutes files
   set fmini = $1$year$mth$day$hr'00pmin.tmp'
   set fmino = $1$year$mth$day$hr'00pmin.min'
   set fmind = $1'/'$1$year$mth$day'pmin.min'
   set fming = $1$year$mth$day$hr'00pmin.min.gz'
   cat /home/tanjap/geomag/core/$1_header.txt $fmini > $fmino
   set fseci = $1$year$mth$day$hr'00psec.tmp'
   set fseco = $1$year$mth$day$hr'0000psec.sec'
   set fsecg = $1$year$mth$day$hr'0000psec.sec.gz'
   set fsecd = $1'/'$1$year$mth$day'psec.sec'

#  Testing new cleaning
#  #
#if ( $1 == "sba" ) then
#  /home/tanjap/geomag/core/cleantmp sba $yr$mth$day$hr
#  mv $fseci $1$year$mth$day$hr'00psec.old'
#  mv $1$year$mth$day$hr'00psec.new' $fseci
#endif


cat /home/tanjap/geomag/core/$1s_header.txt $fseci > $fseco

   set plot = $1'plotfile.txt'
   set plott = $1'plotfile.tmp'
   mv $plot $plott
   cat $fmini $plott > $plot

#  Send minute files to ETH, Zurich
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

#  Send minute files to Craig Rodger, U of Otago
##  see readme_otago.txt for setting up key
if (( $2 == 'NOW' )||( $6 == "YES")) then
   if ( $1 == "eyr" ) then
      echo Connecting to U of Otago machine ...
      #set otago_machine = dudwllntscp@dudwlln-t.otago.ac.nz
      set otago_machine = dudwllntscp@auroraalert.otago.ac.nz
#     sftp -v $otago_machine << endftp4
      sftp $otago_machine << endftp4
      put $fmino
endftp4
   endif
endif


#  Send minute and second files to Edinburgh for their GIN-page
   echo Sending files to Edinburgh ...

#   Send these files to web server after zipping them together
zip minsec.zip $fmino $fseco
/home/tanjap/geomag/core/gin_upload.sh -d -u imo:fjks4395  minsec.zip http://app.geomag.bgs.ac.uk/GINFileUpload/Cache
echo $fmino minute file and $fseco second file sent
#
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
#  Delete temporary zip file
   rm minsec.zip
#  Shift files to hourly sub-directory
   rm $fmini
   rm $fseci
   gzip $fmino
   gzip $fseco
   mv $fming hourly 
   mv $fsecg hourly 

#  Send minute files to Apia
if (( $2 == 'NOW' )||( $6 == "YES")) then
   if ( $1 == "api" ) then
echo Sending files to Apia data display....
#/home/tanjap/geomag/core/mpack -s $fmind $fmind geomagdata@gmail.com 
mailx -a $fmind $fmind geomagdata@gmail.com < /dev/null
#/home/tanjap/geomag/core/mpack -s $fmind $fmind t.petersen@gns.cri.nz 
   endif
endif

##  Send hourly minute files to Postdam NOTE: The quasi-real time system in /home/tanjap/geomag/rt/ is sending files every ~10 minutes.
if (( $2 == 'NOW' )||( $6 == "YES")) then
   if ( $1 == "eyr" ) then
echo Sending files to Potsdam....
curl --upload-file $fmind ftp://ftp.gfz-potsdam.de/pub/incoming/obs_niemegk/kp_index/eyr/
 endif
endif



#  After first 3 hours of a day are done, do K-index for previous day
if ( $2 == 'NOW' ) then
   if($hr == '02') then
      set stk = $yrp$mthp$dayp'k.'$1
      echo kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day
      /home/tanjap/geomag/core/kindext $1 $yrpp$mthpp$daypp $yrp$mthp$dayp $yr$mth$day

# e-mail k-indices;
      mail -s $stk t.hurst@gns.cri.nz < klatest.$1
      mail -s $stk T.Petersen@gns.cri.nz < klatest.$1
      mail -s $stk M.Thornton@gns.cri.nz < klatest.$1
     # mail -s $stk F.Caratori.Tontini@gns.cri.nz < klatest.$1
     # mail -s $stk A.Benson@gns.cri.nz < klatest.$1
     # mail -s $stk g.obrien@gns.cri.nz < klatest.$1

      echo "K-index posted"
      mv klatest.$1 kfiles/$stk 
   endif
endif

echo Finished GetHour1.csh for 
   echo `date +"%Y-%m-%d %H:%M"  -u -d "$ymd"`
echo
#  Plot last 2 days files for Apia (puts .pdf onto ftp://ftp.gns.cri.nz/pub/tanjap/ & a .ps into /amp/magobs/api/api/
# $1 gives sub-directory, $2 is B for plotting Benmore
   /home/tanjap/geomag/core/Plotx.csh $1 B

