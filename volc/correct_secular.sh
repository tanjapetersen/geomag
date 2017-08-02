#!/bin/bash
# correct_secular.sh
# Correct for secular variations by computing magnetic values of each peg relative to a reference station
#	usage: ./correct_secular.sh <surveydate> <refstat>
# ex: ./correct_secular.sh 20120608 AJp
#
# Lauriane Chardot, GNS Science, Taupo, New Zealand
# email: l.chardot@gns.cri.nz
# December 2014
# 

# Get user input
surveydate=$1
refstat=$2

# Assign files
infile=../data/${surveydate}/survey/WImagn_${surveydate}_surveymedian.dat
outfile=../data/${surveydate}/survey/WImagn_${surveydate}_surveymedian_ref${refstat}.dat

# Remove header from files 
awk 'FNR>1{print}' $infile > infile.tmp

# Remove reference station value from each station and create output file (with header)
ref=`awk '/'${refstat}'/ {print $2}' infile.tmp`

echo "#MagneticPeg nT(relative to '${refstat}')" > $outfile
awk -v val="$ref" '{print $1, $2-val}' infile.tmp >> $outfile

# Clean directory
#rm *.tmp





