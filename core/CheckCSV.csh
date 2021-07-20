#!/bin/csh

# Check that data files are complete at end of day 
# Check each hourly .csv file in data subdirectory  
# If they are too short, < 3595 for critical, < 3525 for others,
# then do GetDay1csv.csh for that station, i.e. do whole day if any hour too short
# Only send e-mails if problems not fixed
#
# This only fixes problems if files have reached FTP server
# csv version May 2019
#
set year  = `date -u --date='24 hours ago' +%Y`
set yr  =   `date -u --date='24 hours ago' +%y`
set month = `date -u --date='24 hours ago' +%b`
set mth =   `date -u --date='24 hours ago' +%m`
set day =   `date -u --date='24 hours ago' +%d`
set doy =   `date -u --date='24 hours ago' +%j`

cd /amp/magobs

#set defaults
set send = 0
set AOK = 1
set EOK = 1
set SOK = 1

set m1 = 3595		# Minimum number for critical files (x,y,z & Benmore for Eyrewell)
set m2 = 3525		# Minimum number for non-critical files (all others)

# checking file completeness, checking each hour
echo Checking files for completness...

foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
   set start = $year.$doy.$hr.NZ_
   set apx = $start"APIM_50_LFX.csv"
   set apy = $start"APIM_50_LFY.csv"
   set apz = $start"APIM_50_LFZ.csv"
   set apd = $start"APIM_50_LKD.csv"
   set aps = $start"APIM_50_LKS.csv"
   set apq = $start"APIM_51_LEQ.csv"
   set apf = $start"APIM_51_LFF.csv"
   set epx = $start"EYWM_50_LFX.csv"
   set epy = $start"EYWM_50_LFY.csv"
   set epz = $start"EYWM_50_LFZ.csv"
   set epd = $start"EYWM_50_LKD.csv"
   set eps = $start"EYWM_50_LKS.csv"
   set epq = $start"EYWM_51_LEQ.csv"
   set epf = $start"EYWM_51_LFF.csv"
   set spx = $start"SBAM_50_LFX.csv"
   set spy = $start"SBAM_50_LFY.csv"
   set spz = $start"SBAM_50_LFZ.csv"
   set spd = $start"SBAM_50_LKD.csv"
   set sps = $start"SBAM_50_LKS.csv"
   set spq = $start"SBAM_51_LEQ.csv"
   set spf = $start"SBAM_51_LFF.csv"
   set bpz = $start"SMHS_50_LFZ.csv"

   set ex = `wc -l eyr/data/$epx | cut -d' ' -f1 ` 
   if ($ex < $m1) then
      set EOK = 0
   endif
   set ey = `wc -l eyr/data/$epy | cut -d' ' -f1 ` 
   if ($ey < $m1) then
      set EOK = 0
   endif
   set ez = `wc -l eyr/data/$epz | cut -d' ' -f1 ` 
   if ($ez < $m1) then
      set EOK = 0
   endif
   set ed = `wc -l eyr/data/$epd | cut -d' ' -f1 ` 
   if ($ed < $m2) then
      set EOK = 0
   endif
   set es = `wc -l eyr/data/$eps | cut -d' ' -f1 ` 
   if ($es < $m2) then
      set EOK = 0
   endif
   set eq = `wc -l eyr/data/$epq | cut -d' ' -f1 ` 
   if ($eq < $m2) then
      set EOK = 0
   endif
   set ef = `wc -l eyr/data/$epf | cut -d' ' -f1 ` 
   if ($ef < $m2) then
      set EOK = 0
   endif
   set bz = `wc -l eyr/data/$bpz | cut -d' ' -f1 ` 
   if ($bz < $m1) then
      set EOK = 0
   endif
#   echo $ex $ey $ez $ed $es $eq $ef $bz '  '$EOK
#
   set sx = `wc -l sba/data/$spx | cut -d' ' -f1 ` 
   if ($sx < $m1) then
      set SOK = 0
   endif
   set sy = `wc -l sba/data/$spy | cut -d' ' -f1 ` 
   if ($sy < $m1) then
      set SOK = 0
   endif
   set sz = `wc -l sba/data/$spz | cut -d' ' -f1 ` 
   if ($sz < $m1) then
      set SOK = 0
   endif
   set sd = `wc -l sba/data/$spd | cut -d' ' -f1 ` 
   if ($sd < $m2) then
      set SOK = 0
   endif
   set ss = `wc -l sba/data/$sps | cut -d' ' -f1 ` 
   if ($ss < $m2) then
      set SOK = 0
   endif
   set sq = `wc -l sba/data/$spq | cut -d' ' -f1 ` 
   if ($sq < $m2) then
      set SOK = 0
   endif
   set sf = `wc -l sba/data/$spf | cut -d' ' -f1 ` 
   if ($sf < $m2) then
      set SOK = 0
   endif
#
   set ax = `wc -l api/data/$apx | cut -d' ' -f1 ` 
   if ($ax < $m1) then
      set AOK = 0
   endif
   set ay = `wc -l api/data/$apy | cut -d' ' -f1 ` 
   if ($ay < $m1) then
      set AOK = 0
   endif
   set az = `wc -l api/data/$apz | cut -d' ' -f1 ` 
   if ($az < $m1) then
      set AOK = 0
   endif
   set ad = `wc -l api/data/$apd | cut -d' ' -f1 ` 
   if ($ad < $m2) then
      set AOK = 0
   endif
   set as = `wc -l api/data/$aps | cut -d' ' -f1 ` 
   if ($as < $m2) then
      set AOK = 0
   endif
   set aq = `wc -l api/data/$apq | cut -d' ' -f1 ` 
   if ($aq < $m2) then
      set AOK = 0
   endif
   set af = `wc -l api/data/$apf | cut -d' ' -f1 ` 
   if ($af < $m2) then
      set AOK = 0
   endif

end
 echo File completeness check done ...
if ($EOK == 0) then
   echo eyr $yr $mth $day
   /home/tanjap/geomag/core/GetDay1csv.csh eyr $yr $mth $day
#  /home/tanjap/geomag/qc/NewDay.csh eyr $yr $mth $day
#  /home/tanjap/geomag/qc/NewDay_sec.csh eyr $yr $mth $day
   set send = 1
endif
if ($SOK == 0) then
   /home/tanjap/geomag/core/GetDay1csv.csh sba $yr $mth $day
#  /home/tanjap/geomag/qc/NewDay.csh sba $yr $mth $day
#  /home/tanjap/geomag/qc/NewDay_sec.csh sba $yr $mth $day
   set send = 1
endif
if ($AOK == 0) then
   /home/tanjap/geomag/core/GetDay1csv.csh api $yr $mth $day
#  /home/tanjap/geomag/qc/NewDay.csh api $yr $mth $day   
#  /home/tanjap/geomag/qc/NewDay_sec.csh api $yr $mth $day   
   set send = 1
endif
#  Now calculate daily numbers for each file after required GetDay1csv.csh, 
#  and list all (daily) file lengths if send = 1
#
if ($send == 1) then
   foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
      set start = $year.$doy.$hr.NZ_
      set apx = $start"APIM_50_LFX.csv"
      set apy = $start"APIM_50_LFY.csv"
      set apz = $start"APIM_50_LFZ.csv"
      set apd = $start"APIM_50_LKD.csv"
      set aps = $start"APIM_50_LKS.csv"
      set apq = $start"APIM_51_LEQ.csv"
      set apf = $start"APIM_51_LFF.csv"
      set epx = $start"EYWM_50_LFX.csv"
      set epy = $start"EYWM_50_LFY.csv"
      set epz = $start"EYWM_50_LFZ.csv"
      set epd = $start"EYWM_50_LKD.csv"
      set eps = $start"EYWM_50_LKS.csv"
      set epq = $start"EYWM_51_LEQ.csv"
      set epf = $start"EYWM_51_LFF.csv"
      set spx = $start"SBAM_50_LFX.csv"
      set spy = $start"SBAM_50_LFY.csv"
      set spz = $start"SBAM_50_LFZ.csv"
      set spd = $start"SBAM_50_LKD.csv"
      set sps = $start"SBAM_50_LKS.csv"
      set spq = $start"SBAM_51_LEQ.csv"
      set spf = $start"SBAM_51_LFF.csv"
      set bpz = $start"SMHS_50_LFZ.csv"

      wc -l eyr/data/$epx | cut -d' ' -f1 >> fex
      wc -l eyr/data/$epy | cut -d' ' -f1 >> fey
      wc -l eyr/data/$epz | cut -d' ' -f1 >> fez
      wc -l eyr/data/$epd | cut -d' ' -f1 >> fed
      wc -l eyr/data/$eps | cut -d' ' -f1 >> fes
      wc -l eyr/data/$epq | cut -d' ' -f1 >> feq
      wc -l eyr/data/$epf | cut -d' ' -f1 >> fef
      wc -l eyr/data/$bpz | cut -d' ' -f1 >> fbz
      wc -l sba/data/$spx | cut -d' ' -f1 >> fsx
      wc -l sba/data/$spy | cut -d' ' -f1 >> fsy
      wc -l sba/data/$spz | cut -d' ' -f1 >> fsz
      wc -l sba/data/$spd | cut -d' ' -f1 >> fsd
      wc -l sba/data/$sps | cut -d' ' -f1 >> fss
      wc -l sba/data/$spq | cut -d' ' -f1 >> fsq
      wc -l sba/data/$spf | cut -d' ' -f1 >> fsf
      wc -l api/data/$apx | cut -d' ' -f1 >> fax
      wc -l api/data/$apy | cut -d' ' -f1 >> fay
      wc -l api/data/$apz | cut -d' ' -f1 >> faz
      wc -l api/data/$apd | cut -d' ' -f1 >> fad
      wc -l api/data/$aps | cut -d' ' -f1 >> fas
      wc -l api/data/$apq | cut -d' ' -f1 >> faq
      wc -l api/data/$apf | cut -d' ' -f1 >> faf
   end
#
# Reset all stations OK, and recheck lengths
   set Ac = 0
   set As = 0
   set Ec = 0
   set Es = 0
   set Sc = 0
   set Ss = 0
# Now add up numbers of lines, then decide what message to send

   gawk '{ lines += $1} END { print "X EYR (86400) = " lines " lines"}' fex > cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fex `
   if( $gey < 86280 ) set Ec = 1
   gawk '{ lines += $1} END { print "Y EYR (86400) = " lines " lines"}' fey >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fey `
   if( $gey < 86280 ) set Ec = 1
   gawk '{ lines += $1} END { print "Z EYR (86400) = " lines " lines"}' fez >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fez `
   if( $gey < 86280 ) set Ec = 1
   gawk '{ lines += $1} END { print "D EYR (86400) = " lines " lines"}' fed >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fed `
   if( $gey < 85000 ) set Es = 1
   gawk '{ lines += $1} END { print "S EYR (86400) = " lines " lines"}' fes >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fes `
   if( $gey < 85000 ) set Es = 1
   gawk '{ lines += $1} END { print "Q EYR (86400) = " lines " lines"}' feq >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' feq `
   if( $gey < 85000 ) set Es = 1
   gawk '{ lines += $1} END { print "F EYR (86400) = " lines " lines"}' fef >> cfile
   set gey = `gawk '{ lines += $1} END { print lines }' fef `
   if( $gey < 85000 ) set Es = 1
   gawk '{ lines += $1} END { print "Z BEN (86400) = " lines " lines"}' fbz >> cfile
   set gbz = `gawk '{ lines += $1} END { print lines }' fbz `
   if( $gbz < 86280 ) set Ec = 1
   gawk '{ lines += $1} END { print "X SBA (86400) = " lines " lines"}' fsx >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsx `
   if( $gsb < 86280 ) set Sc = 1
   gawk '{ lines += $1} END { print "Y SBA (86400) = " lines " lines"}' fsy >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsy `
   if( $gsb < 86280 ) set Sc = 1
   gawk '{ lines += $1} END { print "Z SBA (86400) = " lines " lines"}' fsz >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsz `
   if( $gsb < 86280 ) set Sc = 1
   gawk '{ lines += $1} END { print "D SBA (86400) = " lines " lines"}' fsd >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsd `
   if( $gsb < 85000 ) set Ss = 1
   gawk '{ lines += $1} END { print "S SBA (86400) = " lines " lines"}' fss >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fss `
   if( $gsb < 85000 ) set Ss = 1
   gawk '{ lines += $1} END { print "Q SBA (86400) = " lines " lines"}' fsq >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsq `
   if( $gsb < 85000 ) set Ss = 1
   gawk '{ lines += $1} END { print "F SBA (86400) = " lines " lines"}' fsf >> cfile
   set gsb = `gawk '{ lines += $1} END { print lines }' fsf `
   if( $gsb < 85000 ) set Ss = 1
   gawk '{ lines += $1} END { print "X API (86400) = " lines " lines"}' fax >> cfile
   gawk '{ lines += $1} END { print "Y API (86400) = " lines " lines"}' fay >> cfile
   gawk '{ lines += $1} END { print "Z API (86400) = " lines " lines"}' faz >> cfile
   gawk '{ lines += $1} END { print "D API (86400) = " lines " lines"}' fad >> cfile
   gawk '{ lines += $1} END { print "S API (86400) = " lines " lines"}' fas >> cfile
   gawk '{ lines += $1} END { print "Q API (86400) = " lines " lines"}' faq >> cfile
   gawk '{ lines += $1} END { print "F API (86400) = " lines " lines"}' faf >> cfile
   
   set se = 0
   if ( $Ec == 1 || $Es == 1 ) set se = 1
   if ( $Sc == 1 || $Ss == 1 ) set se = 1

   if ( $se == 1 ) then
      set message = 'Possible Magnetic File Problem - '$year.$doy' EYR critical '$Ec' sec. '$Es' SBA critical '$Sc' sec. '$Ss 
      mail -s "$message" "T.Petersen@gns.cri.nz" < cfile
      mail -s "$message" "t.hurst@gns.cri.nz" < cfile
      mail -s "$message" "a.benson@gns.cri.nz" < cfile
   else
      set message = 'No Magnetic File Problem - '$year.$doy 
#    mail -s "$message" "T.Petersen@gns.cri.nz" < cfile
#     mail -s "$message" "t.hurst@gns.cri.nz" < cfile
   endif
# Remove temporary files
   rm fex
   rm fey
   rm fez
   rm fed
   rm fes
   rm feq
   rm fef
   rm fbz
   rm fsx
   rm fsy
   rm fsz
   rm fsd
   rm fss
   rm fsq
   rm fsf
   rm fax
   rm fay
   rm faz
   rm fad
   rm fas
   rm faq
   rm faf
endif
