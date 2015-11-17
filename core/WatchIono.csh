#!/bin/csh 

#get one hour of magnetic data from ftp.geonet.org.nz 
# Hard-wired for sba as station

# Get file for previous day 
# (can run from processing of last hour until 10 hours next day)

set yr  = `date -u --date='10 hours ago' +%y`
set mth = `date -u --date='10 hours ago' +%m`
set day =   `date -u --date='10 hours ago' +%d`

echo $yr $mth $day

cd /amp/magobs/sba/sbc

# Concat .sb1 files to daily 1-second file .sbd

cat $yr$mth$day"00.sb1" $yr$mth$day'01.sb1' $yr$mth$day'02.sb1' $yr$mth$day'03.sb1' $yr$mth$day'04.sb1' $yr$mth$day'05.sb1' $yr$mth$day'06.sb1' $yr$mth$day'07.sb1' $yr$mth$day'08.sb1' $yr$mth$day'09.sb1' $yr$mth$day'10.sb1' $yr$mth$day'11.sb1' $yr$mth$day'12.sb1' $yr$mth$day'13.sb1' $yr$mth$day'14.sb1' $yr$mth$day'15.sb1' $yr$mth$day'16.sb1' $yr$mth$day'17.sb1' $yr$mth$day'18.sb1' $yr$mth$day'19.sb1' $yr$mth$day'20.sb1' $yr$mth$day'21.sb1' $yr$mth$day'22.sb1' $yr$mth$day'23.sb1' > $yr$mth$day'.sbd'

# Now run checksb1ex to see what ionosonde effect is
cd ..
/home/tanjap/geomag/qc/checksb1ex sba $yr$mth$day
