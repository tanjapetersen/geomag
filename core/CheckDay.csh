#!/bin/csh

# Check that data files are complete at end of day 
# Check each .txt file in data subdirectory i
# Redo ftp if they are too short.
# Then do: 
# HaveDay1an.csh
# This only fixes problems if files have reached FTP server
# 18 Mar 2015 Changed gsm-scottbase.txt to gsm-scottbase.raw

set year  = `date -u --date='24 hours ago' +%Y`
set yr  =   `date -u --date='24 hours ago' +%y`
set month = `date -u --date='24 hours ago' +%b`
set mth =   `date -u --date='24 hours ago' +%m`
set day =   `date -u --date='24 hours ago' +%d`
set doy =   `date -u --date='24 hours ago' +%j`

cd /amp/magobs

#set default filenames, etc
set start = $year.$doy.
set fge_api_end = "00.00.fge-apia.txt"
set gsm_api_end = "00.00.gsm-apia.raw"
set fge_eyr_end = "00.00.fge-eyrewell.txt"
set fge_sba_end = "00.00.fge-scottbase.txt"
set gsm_eyr_end = "00.00.westmelton.raw"
set gsm_sba_end = "00.00.gsm-scottbase.raw"
#set gsm_sba_end = "00.00.gsm-scottbase.txt"
set fge_ben_raw = "00.00.fge-benmore.raw"

set AOK = 1
set EOK = 1
set SOK = 1

# checking file completeness
echo Checking files for completness...

foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

   set af = `wc -l api/data/$start$hr$fge_api_end | cut -d' ' -f1 ` 
   if ($af < 3620) then
      set AOK = 0
     /home/tanjap/geomag/core/FtpFile.csh api $year $year.$doy $hr$fge_api_end ## not really needed because GetHour1.csh will be getting data from ftp-server
   endif
   set ag = `wc -l api/data/$start$hr$gsm_api_end | cut -d' ' -f1 ` 
   if ($ag < 3595) then
      set AOK = 0
      /home/tanjap/geomag/core/FtpFile.csh api $year $year.$doy $hr$gsm_api_end ## not really needed because GetHour1.csh will be getting data from ftp-server
   endif
   set bb = `wc -l eyr/data/$start$hr$fge_ben_raw | cut -d' ' -f1 ` 
   if ($bb < 3595) then
      set EOK = 0
     /home/tanjap/geomag/core/FtpFile.csh eyr $year $year.$doy $hr$fge_ben_raw
   endif
   set ef = `wc -l eyr/data/$start$hr$fge_eyr_end | cut -d' ' -f1 ` 
   if ($ef < 3620) then
      set EOK = 0
     /home/tanjap/geomag/core/FtpFile.csh eyr $year $year.$doy $hr$fge_eyr_end
   endif
   set eg = `wc -l eyr/data/$start$hr$gsm_eyr_end | cut -d' ' -f1 ` 
   if ($eg <  725) then
      set EOK = 0
     /home/tanjap/geomag/core/FtpFile.csh eyr $year $year.$doy $hr$gsm_eyr_end
   endif
   set sf = `wc -l sba/data/$start$hr$fge_sba_end | cut -d' ' -f1 ` 
   if ($sf < 3620) then
      set SOK = 0
      /home/tanjap/geomag/core/FtpFile.csh sba $year $year.$doy $hr$fge_sba_end
   endif
   set sg = `wc -l sba/data/$start$hr$gsm_sba_end | cut -d' ' -f1 ` 
   if ($sg <  725) then
      set SOK = 0
     /home/tanjap/geomag/core/FtpFile.csh sba $year $year.$doy $hr$gsm_sba_end
   endif
end
 echo File completeness check done ...

foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)

wc -l api/data/$start$hr$fge_api_end | cut -d' ' -f1 >> fa
wc -l api/data/$start$hr$gsm_api_end | cut -d' ' -f1 >> ga
wc -l eyr/data/$start$hr$fge_eyr_end | cut -d' ' -f1 >> fe
wc -l eyr/data/$start$hr$gsm_eyr_end | cut -d' ' -f1 >> ge
wc -l eyr/data/$start$hr$fge_ben_raw | cut -d' ' -f1 >> bb 
wc -l sba/data/$start$hr$fge_sba_end | cut -d' ' -f1 >> fs
wc -l sba/data/$start$hr$gsm_sba_end | cut -d' ' -f1 >> gs 

end

# Now add up numbers of lines, then delete fe etc

gawk '{ lines += $1} END { print "FGE API (87000) = " lines " lines"}' fa > cfile
gawk '{ lines += $1} END { print "GSM API (86400) = " lines " lines"}' ga >> cfile
gawk '{ lines += $1} END { print "FGE EYR (87024) = " lines " lines"}' fe >> cfile
gawk '{ lines += $1} END { print "GSM EYR (86400) = " lines " lines"}' ge >> cfile
gawk '{ lines += $1} END { print "FGE SBA (87024) = " lines " lines"}' fs >> cfile
gawk '{ lines += $1} END { print "GSM SBA (86400) = " lines " lines"}' gs >> cfile
gawk '{ lines += $1} END { print "B Basalt(86400) = " lines " lines"}' bb >> cfile

set fal = `gawk '{ lines += $1} END { print lines }' fa `
set gal = `gawk '{ lines += $1} END { print lines }' ga `
set fel = `gawk '{ lines += $1} END { print lines }' fe `
set gel = `gawk '{ lines += $1} END { print lines }' ge `
set fsl = `gawk '{ lines += $1} END { print lines }' fs `
set gsl = `gawk '{ lines += $1} END { print lines }' gs `
set bbl = `gawk '{ lines += $1} END { print lines }' bb `

set send = 0
# Following lines represent 5 min gap for critical files, 30 min (33.3 min = 2000 lines) for others
if( $fal < 86700 ) set send = 1
if( $fel < 86724 ) set send = 1
if( $fsl < 86724 ) set send = 1
if( $gal < 84400 ) set send = 1
if( $gel < 84400 ) set send = 1
if( $gsl < 84400 ) set send = 1
if( $bbl < 86100 ) set send = 1

rm fa
rm ga
rm fe
rm ge
rm fs
rm gs
rm bb

#  TEST LINE set send = 1
if ($send == 1) then
   set message = 'Magnetic File Problem - '$year.$doy' = '$year' '$mth' '$day 
endif

if ($AOK == 0) then
#  Note: before folding the station specific programs back into one it was:
#  /home/tanjap/geomag/core/HaveDay1az.csh api $yr $mth $day
   /home/tanjap/geomag/core/HaveDay1an.csh api $yr $mth $day
#   set send = 1
   set message = ` echo $message "Api was short "`
endif
if ($EOK == 0) then
#  Note: before folding the station specific programs back into one it was:
# /home/tanjap/geomag/core/HaveDay1w.csh eyr $yr $mth $day
   /home/tanjap/geomag/core/HaveDay1an.csh eyr $yr $mth $day
#   set send = 1
   set message = ` echo $message "Eyrewell was short "`
endif
if ($SOK == 0) then
#  Note: before folding the station specific programs back into one it was:
# /home/tanjap/geomag/core/HaveDay1.csh eyr $yr $mth $day
   /home/tanjap/geomag/core/HaveDay1an.csh sba $yr $mth $day
#   set send = 1
   set message = ` echo $message "Scott Base was short "`
endif

if ( $send == 1 ) then
   mail -s "$message" "t.hurst@gns.cri.nz" < cfile
   mail -s "$message" "T.Petersen@gns.cri.nz" < cfile
   mail -s "$message" "m.chadwick@gns.cri.nz" < cfile
endif


