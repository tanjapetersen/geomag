#!/bin/csh 

# Script to run kindextt with single parameter
# Hard-wired for EYREWELL (West Melton)
# # Needs to calculate day before and day after
# $1 is to be YYMMDD
# Not clear in manual that 20190101 is valid date format, but it works 
set ymd = "20$1"
#echo $ymd
set yr = `date -d "$ymd" +%y`
set mth = `date -d "$ymd" +%m`
set day = `date -d "$ymd" +%d`
set d2 = `echo $yr$mth$day`
set yr = `date -d "$ymd + 1 day" +%y`
set mth = `date -d "$ymd + 1 day" +%m`
set day = `date -d "$ymd + 1 day" +%d`
set d3 = `echo $yr$mth$day`
set yr = `date -d "$ymd - 1 day" +%y`
set mth = `date -d "$ymd - 1 day" +%m`
set day = `date -d "$ymd - 1 day" +%d`
set d1 = `echo $yr$mth$day`
echo $d1 $d2 $d3 
/home/hurst/ktest/kindextt eyr $d1 $d2 $d3
#  Finished
