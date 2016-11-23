#!/bin/csh -f
# Pinching features from RTD2web.csh to plot Apia Magnetic Files
# $1 gives sub-directory to get files from, $2 is label on graph
# Then writes web page

#  Directory for current magnetic input area for station $1  
cd /amp/magobs/$1

set year = `date -u '+%y'`
echo $year 
set yr = `date -u '+%Y'`
set mth = `date -u '+%m'`
set day = `date -u '+%d'`
set hr = `date  -u '+%H'`
set doyb = `date   --date='1 day ago' -u '+%j'`
set doye = `date   --date='+1 day' -u '+%j'`
echo $year $yr $mth $day $hr $doyb $doye 
#stop

 set xscale = 8.0
 set yscale = 0.04
 set xlo = 32570
 set ylo = 6850
 set zlo = -20125
 set flo = 38830

 set statmthps = $1'plot.ps'
 echo $statmthps
#EOF


   set xhi =  `gawk -v x=$xlo 'BEGIN{printf("%9.2f",x+120.)}'`
   set xmid = `gawk -v x=$xlo 'BEGIN{printf("%9.2f",x+60.)}'`
   set yhi =  `gawk -v x=$ylo 'BEGIN{printf("%9.2f",x+120.)}'`
   set ymid = `gawk -v x=$ylo 'BEGIN{printf("%9.2f",x+60.)}'`
   set zhi =  `gawk -v x=$zlo 'BEGIN{print x+120.}'`
   set zmid = `gawk -v x=$zlo 'BEGIN{print x+60.}'`
   set fhi =  `gawk -v x=$flo 'BEGIN{printf("%9.2f",x+120.)}'`
   set fmid = `gawk -v x=$flo 'BEGIN{printf("%9.2f",x+60.)}'`
   set ftxt = `gawk -v x=$flo 'BEGIN{printf("%9.2f",x+09.)}'`  

# Setup GMT parameters
   gmtset PAPER_MEDIA a4
   gmtset MEASURE_UNIT cm
   set PROJ = "-Jx"$xscale"/"$yscale
   set LIMITS = "-R"$doyb"/"$doye"/"$xlo"/"$xhi
   set FLAGS = "-P -V"
   set file = plot.ps
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Ba1f1:"Apia Magnetic Record":/a25f25WENs -K -V -X2.5 -Y20.5 > $statmthps

#   pstext  ${PROJ} ${LIMITS} ${FLAGS} -K  -O << EOF  >> $statmthps
#      $doyb.01 $nhi-10 18 0 4 LM  $2 
#EOF
  
   set filen = $1'plotfile.txt'
   set timestamp = `date`

# North Component
   set COLOUR = "-W1/250/0/0"			# red
   set label =  "X"
   rm -f temp_x
   gawk -v y=$yr '{print $3+substr($2,1,2)/24.+substr($2,4,2)/1440." " $4}' $filen >! temp_x
   psxy temp_x ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
   $doyb.01 $xmid 18 0 4 LM $label 
EOF

# East Component
   set LIMITS = "-R"$doyb"/"$doye"/"$ylo"/"$yhi
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Bf1/a25f25WEsn -K -O -Y-5.5  >> $statmthps
   set COLOUR = "-W1/0/250/0"			# green
   set label =  "Y"
   rm -f temp_y
   gawk -v y=$yr '{print $3+substr($2,1,2)/24.+substr($2,4,2)/1440." " $5}' $filen >! temp_y
   psxy temp_y ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
   $doyb.01 $ymid 18 0 4 LM $label 
EOF
#  psxy ${PROJ} ${LIMITS} ${FLAGS} ${TCOLOUR} ${COLOUR} -Sc0.1  -K -O  << EOF  >> $statmthps
#$doyb.5 $emid 0.01 
#EOF

# Vertical Component
   set LIMITS = "-R"$doyb"/"$doye"/"$zlo"/"$zhi
   psbasemap ${PROJ} ${LIMITS} ${FLAGS} -Ba1f1/a25f25WEsn -K -O -Y-5.5  >> $statmthps
   set COLOUR = "-W1/0/0/250"			# blue
   set label =  "Z"
   rm -f temp_z
   gawk -v y=$yr '{print $3+substr($2,1,2)/24.+substr($2,4,2)/1440." " $6}' $filen >! temp_z
   psxy temp_z ${PROJ} ${LIMITS} ${FLAGS} ${COLOUR} -Sc0.05  -K -O      >> $statmthps
   pstext  ${PROJ} ${LIMITS} ${FLAGS}   -K -O << EOF  >> $statmthps
      $doyb.01 $zmid 18 0 4 LM $label 
EOF

# Total Field (was Zenith Delay)
   set LIMITZ = "-R"$doyb"/"$doye"/"$flo"/"$fhi
   set Zlabel = "F"
   psbasemap ${PROJ} ${LIMITZ} ${FLAGS} -Ba1f1:"UT Day":/a25f25WESn -K -O -Y-5.5  >> $statmthps
   set COLOUR = "-W1/0/0/250"			# blue

#  Now plot total field F from the Overhauser magnetometer

   gawk -v y=$yr '{print $3+substr($2,1,2)/24.+substr($2,4,2)/1440." " $7}' $filen >! temp_f
   psxy temp_f ${PROJ} ${LIMITZ} ${FLAGS} -G0 -Sx0.05 -W1/0/250/250 -K -O >> $statmthps
   pstext  ${PROJ} ${LIMITZ} ${FLAGS}   -O << EOF  >> $statmthps
      $doyb.01 $fmid 18 0 4 LM $Zlabel 
      $doyb.07 $ftxt 14 0 4 LM $timestamp 
EOF

   echo Start File Conversion
   ps2pdfwr $statmthps $1'plot.pdf'
   echo End File Conversion
   rm /amp/ftp/pub/geomagnetism/$1'plot.pdf'    
   cp $1'plot.pdf' /amp/ftp/pub/geomagnetism
   echo End Web Service

echo `date`
