#!/bin/csh 
# Call script as e.g. doHaveDay1.csh sba 2013 03 (for March 2013)
# This script runs HaveDay1an.csh for a series of days in the chosen year. 

#cd /scratch/GEOMAG/{$1}{$2}/new/
#cd /scratch/GEOMAG/{$1}2014/new/

echo Working in directory `pwd`...

# Get correct number of days in every month!!

set yr = `echo $2 | gawk -F : '{print substr($1,3,2)}'` 

set mth = $3

if ($mth == 01) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
  /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 02) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28) 
#foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29) 
  /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 03) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 04) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 05) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 06) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 07) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
  /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 08) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 09) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 10) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 11) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif

if ($mth == 12) then
foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 
 /home/tanjap/geomag/core/HaveDay1an.csh $1 $yr $mth $day 
end
endif




