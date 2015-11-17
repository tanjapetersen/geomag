#!/bin/csh 

# Variation of Ksend.csh. This sends the bimonthly K-index files to me 8 hours prior to submission (submission is on 1. & 16. day of each month at 16:40 NZDT).
# $1 is to be obs 3 letter code
# $2 is a or b for appropriate 1/2 month
# NOTE: GetHour1w_N.csh will do K-indices with files labled hour 02 (3rd hour of day)
# NOTE: Script has to run after 16:24 NZDT (to make sure first 3 hours of the current UT day are processed, because those hours are needed to calculate the last K-index of the previous day)

# Dates are '3 days ago', but actually run immediately (Days 1 & 16)
  set yr  = `date -u --date='3 days ago' +%y`
  set mth =   `date -u --date='3 days ago' +%m`

#set filename

  set kfile = $1$yr$mth$2.k
  cd /amp/magobs/$1

  echo $kfile 
  mail -s $kfile t.petersen@gns.cri.nz < kbimonth.$1
  mail -s $kfile tanimeer@yahoo.com < kbimonth.$1
  #mv kbimonth.$1 $kfile

