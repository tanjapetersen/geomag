#!/bin/csh 

# Script checks on the ionosonde effect
# Hard-wired for sba as station

#  Get file for previous day 
# (can run from processing of last hour until 10 hours next day)

set yr  = `date -u --date='10 hours ago' +%y`
set mth = `date -u --date='10 hours ago' +%m`
set day =   `date -u --date='10 hours ago' +%d`

echo $yr $mth $day

cd /amp/magobs/sba/sbc

# Concat .sb1 files to daily 1-second file .sbd

cat $yr$mth$day"00.sb1" $yr$mth$day'01.sb1' $yr$mth$day'02.sb1' $yr$mth$day'03.sb1' $yr$mth$day'04.sb1' $yr$mth$day'05.sb1' $yr$mth$day'06.sb1' $yr$mth$day'07.sb1' $yr$mth$day'08.sb1' $yr$mth$day'09.sb1' $yr$mth$day'10.sb1' $yr$mth$day'11.sb1' $yr$mth$day'12.sb1' $yr$mth$day'13.sb1' $yr$mth$day'14.sb1' $yr$mth$day'15.sb1' $yr$mth$day'16.sb1' $yr$mth$day'17.sb1' $yr$mth$day'18.sb1' $yr$mth$day'19.sb1' $yr$mth$day'20.sb1' $yr$mth$day'21.sb1' $yr$mth$day'22.sb1' $yr$mth$day'23.sb1' > $yr$mth$day'.sbd'

# Now run checksbnew3 to see what ionosonde effect is
# Directory now /amp/magobs/sba
cd ..
#/home/tanjap/geomag/core/checksbnew sba $yr$mth$day
#cp sbc/$yr$mth$day'.ipn' iono.dat
/home/tanjap/geomag/core/checksbnew3 sba $yr$mth$day
cp iono/$yr$mth$day'.sym' iono/iono.sym

# Now rerun day with that days best fit cleaning, now using explicit file name, # e.g. 170220.sym
# /home/tanjap/geomag/core/HaveDay1an.csh sba $yr $mth $day
# /home/tanjap/geomag/core/HaveDay1as.csh sba $yr $mth $day
/home/tanjap/geomag/core/HaveDay1csv.csh sba $yr $mth $day
