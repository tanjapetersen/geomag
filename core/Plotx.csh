#!/bin/csh -f
# Plot Magnetic Files from .eyx etc, with Benmore plotting option
# THIS LINE FOR PLOTTING LATEST DAY
# $1 gives sub-directory, $2 is B for plotting Benmore
# Plotx.csh eyr B
#
# NEXT TWO LINES IF OLDER DATA TO PLOT
# $2 $3 $4 are year(2-digit) month day of first day 
# $5 is number of days to plot (ONLY 1 OR 2), $6 is B for plotting Benmore
# Plotx.csh eyr 15 01 02 1 B
# Plotx.csh api 16 03 16 

# Then writes web page

#  Directory for current magnetic file area for station $1  
cd /amp/magobs/$1/$1

if ($#argv > 2) then
   set ymd = "20$2-$3-$4"
#  set year = `date -u -d "$ymd" +%Y`
   set yr = `date -u -d "$ymd" +%y`
   set mth = `date -u -d "$ymd" +%m`
   set day = `date -u -d "$ymd" +%d`
   set doy = `date -u -d "$ymd" +%j`
# Now calculate for starting day
   set epoch = `date -u -d "$ymd" +%s`
   @ opoch = $epoch + 86400 - $5 * 86400 
   set yrb = `date -ud @$opoch +%y`
   set mthb = `date -ud @$opoch +%m`
   set dayb = `date -ud @$opoch +%d`
   set doyb = `date -ud @$opoch +%j`
   @ npoch = $epoch + 86400
   set doye = `date -ud @$npoch +%j`
   set xscale =  `gawk -v d=$5 'BEGIN{print 8.0 / d}'`
   echo xscale = $xscale
else
#  set year = `date -u '+%Y'`
   set yr = `date -u '+%y'`
   set mth = `date -u '+%m'`
   set day = `date -u '+%d'`
   set doy = `date -u '+%j'`
   set yrb =  `date   --date='1 day ago' -u '+%y'`
   set mthb = `date   --date='1 day ago' -u '+%m'`
   set dayb = `date   --date='1 day ago' -u '+%d'`
   set doyb = `date   --date='1 day ago' -u '+%j'`
   set doye = `date   --date='+1 day' -u '+%j'`
   set xscale = 8.0
endif
   echo $yrb $yr $mthb $mth $dayb $day $doyb $doy $doye
#stop 

# These are 'eyr' values:
set yscale = 0.05
set blo = -20
set xlo = 19275
set ylo = 8210
set zlo = -53560
set flo = 57450
set mul = 1.0

if ($1 == 'sba') then
  set yscale = 0.0125
  set xlo = -10480
  set ylo = 5150
  set zlo = -65590
  set flo = 66200
  set mul = 4.0
endif
 
if ($1 == 'api') then
  set yscale = 0.025
  set xlo = 32500
  set ylo = 6850
  set zlo = -20120
  set flo = 38790
  set mul = 2.0
endif
 
set filex = `echo $1 | cut -c1,2`x
set filen = $yr$mth$day'.'$filex
set fileb = $yrb$mthb$dayb'.'$filex
echo $filen
if (($2 == "B") || ($6 == "B")) then
   set statmthps = $1$yrb$mthb$dayb'B.ps'
else
   set statmthps = $1$yrb$mthb$dayb'.ps'
endif
echo $statmthps


   set bhi =  `gawk -v x=$blo -v m=$mul 'BEGIN{printf("%9.2f",x+m*100.)}'`
   set bmid = `gawk -v x=$blo -v m=$mul 'BEGIN{printf("%9.2f",x+m*50.)}'`
   set xhi =  `gawk -v x=$xlo -v m=$mul 'BEGIN{printf("%9.2f",x+m*100.)}'`
   set xmid = `gawk -v x=$xlo -v m=$mul 'BEGIN{printf("%9.2f",x+m*50.)}'`
   set yhi =  `gawk -v x=$ylo -v m=$mul 'BEGIN{printf("%9.2f",x+m*100.)}'`
   set ymid = `gawk -v x=$ylo -v m=$mul 'BEGIN{printf("%9.2f",x+m*50.)}'`
   set zhi =  `gawk -v x=$zlo -v m=$mul 'BEGIN{print x+m*100.}'`
   set zmid = `gawk -v x=$zlo -v m=$mul 'BEGIN{print x+m*50.}'`
   set fhi =  `gawk -v x=$flo -v m=$mul 'BEGIN{printf("%9.2f",x+m*100.)}'`
   set fmid = `gawk -v x=$flo -v m=$mul 'BEGIN{printf("%9.2f",x+m*50.)}'`
   set ftxt = `gawk -v x=$flo -v m=$mul 'BEGIN{printf("%9.2f",x+m*09.)}'`  

# Setup GMT parameters
   gmtset PAPER_MEDIA a4
   gmtset MEASURE_UNIT cm
   set PROJ = "-Jx"$xscale"/"$yscale
   set FLAGS = "-P -V"
   set file = plot.ps

if (($2 == "B") || ($6 == "B")) then
#if ($2 == "B") then
   set LIMITS = "-R"$doyb"/"$doye"/"$blo"/"$bhi
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Ba1f1:"Magnetic Record":/a20f20WENs -K -X2.5 -Y22.0 > $statmthps
   set COLOUR = "-W1"			# black
   set label =  "B"
   gawk -v y=$doyb '{print y + $2/24. + $3/1440." " $10}' $fileb >! temp_b
   if ( -e $filen) then
      gawk -v y=$doy '{print y + $2/24. + $3/1440." " $10}' $filen >> temp_b
   endif
   psxy temp_b ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
   $doyb.01 $bmid 18 0 4 LM $label 
EOF

endif
  
   set timestamp = `date`

# X Component
   set LIMITS = "-R"$doyb"/"$doye"/"$xlo"/"$xhi
if (($2 == "B") || ($6 == "B")) then
#if ($2 == "B") then
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Bf1/a50f25WEsn -K -O -Y-5.0  >> $statmthps
else
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Ba1f1:"Magnetic Record":/a50f25WENs -K -X2.5 -Y20.5 > $statmthps
endif
   set COLOUR = "-W1/250/0/0"			# red
   set label =  "X"
#  rm -f temp_x
   gawk -v y=$doyb '{print y + $2/24. + $3/1440." " $4}' $fileb >! temp_x
   if ( -e $filen) then
      gawk -v y=$doy '{print y + $2/24. + $3/1440." " $4}' $filen >> temp_x
   endif
   psxy temp_x ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
   $doyb.01 $xmid 18 0 4 LM $label 
EOF

# Y Component
   set LIMITS = "-R"$doyb"/"$doye"/"$ylo"/"$yhi
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Bf1/a50f25WEsn -K -O -Y-5.0  >> $statmthps
   set COLOUR = "-W1/0/250/0"			# green
   set label =  "Y"
#  rm -f temp_y
   gawk -v y=$doyb '{print y + $2/24. + $3/1440." " $5}' $fileb >! temp_y
   if ( -e $filen) then
      gawk -v y=$doy '{print y + $2/24. + $3/1440." " $5}' $filen >> temp_y
   endif
   psxy temp_y ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
   $doyb.01 $ymid 18 0 4 LM $label 
EOF
#  psxy ${PROJ} ${LIMITS} ${FLAGS} ${TCOLOUR} ${COLOUR} -Sc0.1  -K -O  << EOF  >> $statmthps
#EOF

# Z Component
   set LIMITS = "-R"$doyb"/"$doye"/"$zlo"/"$zhi
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Ba1f1/a50f25WEsn -K -O -Y-5.0  >> $statmthps
   set COLOUR = "-W1/0/0/250"			# blue
   set label =  "Z"
#  rm -f temp_z
   gawk -v y=$doyb '{print y + $2/24. + $3/1440." " $6}' $fileb >! temp_z
   if ( -e $filen) then
      gawk -v y=$doy '{print y + $2/24. + $3/1440." " $6}' $filen >> temp_z
   endif
   psxy temp_z ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
      $doyb.01 $zmid 18 0 4 LM $label 
EOF

# Total Field 
   set LIMITZ = "-R"$doyb"/"$doye"/"$flo"/"$fhi
   set Zlabel = "F"
   psbasemap ${PROJ} ${LIMITZ} ${FLAGS} -Ba1f1:"UT Day":/a50f25WESn -K -O -Y-5.0  >> $statmthps
   set COLOUR = "-W1/0/0/250"			# blue

#  Now plot total field F from the Overhauser magnetometer

   gawk -v y=$doyb '{print y + $2/24. + $3/1440." " $7}' $fileb >! temp_f
   if ( -e $filen) then
      gawk -v y=$doy '{print y + $2/24. + $3/1440." " $7}' $filen >> temp_f
   endif
   psxy temp_f ${PROJ} ${LIMITZ} ${FLAGS} -G0 -Sx0.05 -W1/0/250/250 -K -O >> $statmthps
   pstext  ${PROJ} ${LIMITZ} ${FLAGS}   -O << EOF  >> $statmthps
      $doyb.01 $fmid 18 0 4 LM $Zlabel 
      $doyb.07 $ftxt 14 0 4 LM $timestamp 
EOF

   echo Start File Conversion
   ps2pdfwr $statmthps $1'plot.pdf'
   echo End File Conversion
   rm /amp/ftp/pub/tanjap/$1'plot.pdf'    
   cp $1'plot.pdf' /amp/ftp/pub/tanjap
   echo End Web Service

echo `date`
