#!/bin/csh 

# Script to send off bimonthly K-index files
# $1 is to be obs 3 letter code
# $2 is a or b for appropriate 1/2 month
# NOTE - GetHour1w.csh will do K-indices with 02 files
# So this has to run after 0424 for NZDT 
# ANOTHER NOTE - This version for /amp/magobs data

# Dates are '3 days ago', but actually run immediately (Days 1 & 16)
  set yr  = `date -u --date='3 days ago' +%y`
  set mth =   `date -u --date='3 days ago' +%m`

#set filename

  set kfile = $1$yr$mth$2.k
  cd /amp/magobs/$1

  echo $kfile 
  mail -s $kfile t.hurst@gns.cri.nz < kbimonth.$1
  mail -s $kfile t.petersen@gns.cri.nz < kbimonth.$1
  mail -s $kfile kp_index@gfz-potsdam.de < kbimonth.$1
  mail -s $kfile michel.menvielle@latmos.ipsl.fr < kbimonth.$1
  mail -s $kfile kisgi@latmos.ipsl.fr < kbimonth.$1
  mv kbimonth.$1 $kfile

