#!/bin/csh 
# Run a whole year of SBA data through checksb1t to look at Ionosonde effec.
# Call as DoIono.csh 2014
#
echo Year $1 commenced
set yr = `echo $1 | gawk -F : '{print substr($1,3,2)}'` 

# Try 31 days in every month 


foreach mth (01 02 03 04 05 06 07 08 09 10 11 12) 
   foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31) 


cd /amp/magobs/sba/sbc
# Concat .sb1 files to daily 1-second file .sbd

      cat $yr$mth$day"00.sb1" $yr$mth$day'01.sb1' $yr$mth$day'02.sb1' $yr$mth$day'03.sb1' $yr$mth$day'04.sb1' $yr$mth$day'05.sb1' $yr$mth$day'06.sb1' $yr$mth$day'07.sb1' $yr$mth$day'08.sb1' $yr$mth$day'09.sb1' $yr$mth$day'10.sb1' $yr$mth$day'11.sb1' $yr$mth$day'12.sb1' $yr$mth$day'13.sb1' $yr$mth$day'14.sb1' $yr$mth$day'15.sb1' $yr$mth$day'16.sb1' $yr$mth$day'17.sb1' $yr$mth$day'18.sb1' $yr$mth$day'19.sb1' $yr$mth$day'20.sb1' $yr$mth$day'21.sb1' $yr$mth$day'22.sb1' $yr$mth$day'23.sb1' > $yr$mth$day'.sbd'


# Now run checksb1t to see what ionosonde effect is
      cd ..
      /home/hurst/process/checksb1t sba $yr$mth$day
   end
end
echo Finished
