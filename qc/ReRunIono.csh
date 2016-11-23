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

cat $yr$mth$day"00.sb4" $yr$mth$day'01.sb4' $yr$mth$day'02.sb4' $yr$mth$day'03.sb4' $yr$mth$day'04.sb4' $yr$mth$day'05.sb4' $yr$mth$day'06.sb4' $yr$mth$day'07.sb4' $yr$mth$day'08.sb4' $yr$mth$day'09.sb4' $yr$mth$day'10.sb4' $yr$mth$day'11.sb4' $yr$mth$day'12.sb4' $yr$mth$day'13.sb4' $yr$mth$day'14.sb4' $yr$mth$day'15.sb4' $yr$mth$day'16.sb4' $yr$mth$day'17.sb4' $yr$mth$day'18.sb4' $yr$mth$day'19.sb4' $yr$mth$day'20.sb4' $yr$mth$day'21.sb4' $yr$mth$day'22.sb4' $yr$mth$day'23.sb4' > $yr$mth$day'.sbn'

# Now run checksb1ex to see what ionosonde effect is
cd ..
#/home/tanjap/geomag/core/checksb1ex sba $yr$mth$day

# Output:  e.g. 140706.sbv in /amp/magobs/sba/sbc/
