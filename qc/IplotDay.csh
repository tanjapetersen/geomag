#!/bin/csh -f
# IPlotDay.csh    Plot one day of SBA Z  showing Ionosonde effect
# Using .sym, the version that can cope with early Ionosondes
# IPlotDay.csh $1 $2 $3
# $1 $2 $3 are year(2-digit), month & day  

# Run in directory where the .dps files are 
# If elsewhere, change line below
#cd /amp/magobs/sba/iono/

set filen = $1$2$3'.dps'
echo $filen


#set Y = $1
#set M = $2
#set H = 0
set MAX = 97
set MIN = -1 
set LMIN = `echo $MAX | gawk '{print -0.9*$1}'`
set YSCALE = `echo $MAX | gawk '{print 24./$1}'`
echo $MAX $MIN $LMIN $YSCALE
gmtset HEADER_FONT_SIZE = 30
set PROJ="-Jx0.30/$YSCALE"
set LIMITS="-R-30./30./$MIN/$MAX"
set ANOT="-B3"
# -P for portrait  
set FLAGS=" -V -P"
echo $MAX $MIN $LMIN $LIMITS
set P = $1$2$3's.ps' 
#set Y = `echo $1 | gawk '{print substr($1,6,2)}'`
#echo  $M 20$2

psbasemap  ${LIMITS} ${PROJ}  ${FLAGS} -B3/3  -K -U/-1.5/-1.5/$1$2 -X1.5 -Y2.0 > $P
   pwd
   set C = $1$2$3'.dps' 
  gawk   '{print $2, $1 + $3/5. }' $C > temp.sym
  psxy temp.sym ${LIMITS} ${PROJ}  ${FLAGS}  -H1  -K -M">" -O -W4/255/0/0   >> $P



# This final one is a repeat, just to close .ps file

psxy temp.sym ${LIMITS} ${PROJ}  ${FLAGS}  -H1  -M">" -O -W4   >> $P
