#!/bin/csh 

# Script to send off bimonthly K-index files
# $1 is to be obs 3 letter code
# $2 is a or b for appropriate 1/2 month
# NOTE: GetHour1w_N.csh will do K-indices with files labled hour 02 (3rd hour of day)
# NOTE: Script has to run after 16:24 NZDT (to make sure first 3 hours of the current UT day are processed, because those hours are needed to calculate the last K-index of the previous day)

# Dates are '3 days ago', but actually run immediately (Days 1 & 16)
  set tstamp = `date -u --date='3 days ago'`
  set yr  = `date -u --date="$tstamp" +%y`
  set mth =   `date -u --date="$tstamp" +%m`

#set filename

  set kfile = $1$yr$mth$2.k
  cd /amp/magobs/$1

if( -e kbimonth.$1) then
  set lines = `wc -l < kbimonth.$1`
   echo $kfile $lines
   if( $lines < 100 ) then
     mail -s $kfile t.hurst@gns.cri.nz < kbimonth.$1
     mail -s $kfile t.petersen@gns.cri.nz < kbimonth.$1
    # mail -s $kfile kp_index@gfz-potsdam.de < kbimonth.$1
    # mail -s $kfile F.Caratori.Tontini@gns.cri.nz < kbimonth.$1
      mail -s $kfile A.Benson@gns.cri.nz < kbimonth.$1
      mail -s $kfile m.thornton@gns.cri.nz < kbimonth.$1
    # mail -s $kfile michel.menvielle@latmos.ipsl.fr < kbimonth.$1
    # mail -s $kfile kisgi@latmos.ipsl.fr < kbimonth.$1
      mv kbimonth.$1 $kfile
   else
      echo 'File too long' | mail -s kbimonth.$1 t.hurst@gns.cri.nz 
      echo 'File too long' | mail -s kbimonth.$1 t.petersen@gns.cri.nz 
   endif
else
   echo 'Does not exist' | mail -s kbimonth.$1 t.hurst@gns.cri.nz 
   echo 'Does not exist' | mail -s kbimonth.$1 t.petersen@gns.cri.nz 
endif


