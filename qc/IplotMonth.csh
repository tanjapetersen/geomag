#!/bin/csh  

# IPlotMonth.csh  A4 Plot of Monthly Ionosonde symmetric corrections
# -----------------------------------------------------
#   Use as  IPlotMonth 13 07 {Year & Month}     
#
set Y = $1
set M = $2
set H = 0
set MAX = 32
set MIN = -1 
set LMIN = `echo $MAX | gawk '{print -0.9*$1}'`
set YSCALE = `echo $MAX | gawk '{print 18./$1}'`
echo $MAX $MIN $LMIN $YSCALE
gmtset HEADER_FONT_SIZE = 30
set PROJ="-Jx0.40/$YSCALE"
set LIMITS="-R-30./30./$MIN/$MAX"
set ANOT="-B3"
# -P for portrait  
set FLAGS=" -V"
echo $MAX $MIN $LMIN $LIMITS
set P = $1$2's.ps' 
set Y = `echo $1 | gawk '{print substr($1,6,2)}'`
echo  $M 20$2

# Colours go red - green - blue 150/100/100=brown
set RR = 255
set GG = 0
set B = 0

psbasemap  ${LIMITS} ${PROJ}  ${FLAGS} -B3/1  -K -U/-1.5/-1.5/$1$2 -X3.0 -Y2.0 > $P
foreach Day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
#   @ d = $Day
   set d = `echo $Day | gawk '{print substr($1,1,2)}'`
   set dd = `echo $Day | gawk '{print substr($1,2,1)}'`
   echo dd $dd
   set R = `echo $RR $dd | gawk '{print $1-8*$2}'`
   echo R $R
   set G = `echo $GG $dd | gawk '{print $1+8*$2}'`
   echo G $G
   set C = $1$2$Day'.sym' 
   echo  $d $dd $R $G
  gawk -v x=$d ' {print $1, $2/3. + x }' $C > temp.sym
  psxy temp.sym ${LIMITS} ${PROJ}  ${FLAGS}  -H1  -K -M">" -O -W4/$R/$G/$B   >> $P
end



# This final one is a repeat, just to close .ps file

psxy temp.sym ${LIMITS} ${PROJ}  ${FLAGS}  -H1  -M">" -O -W4   >> $P

