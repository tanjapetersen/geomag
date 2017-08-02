#!/bin/bash
# create_finalmagn_withcoords.sh
# Prepare file for GMT (add coordinates)
#	usage: ./create_finalmagn_withcoords.sh <surveydate> <refstat>
# ex: ./create_finalmagn_withcoords.sh 20120608 AJp
#
# Lauriane Chardot, GNS Science, Taupo, New Zealand
# email: l.chardot@gns.cri.nz
# January 2016
# 


# Get user input
surveydate=$1
refstat=$2


# Assign files
infile=../data/${surveydate}/survey/WImagn_${surveydate}_surveymedian_ref${refstat}.dat
outfile=../data/${surveydate}/survey/WImagn_${surveydate}_surveymedian_ref${refstat}_withcoords.dat
locfile=../data/magn_pegs/MagnPeg_Loc.txt


# Define station name
awk 'FNR>1{print}' $infile > infile.tmp
awk 'FNR>1{print}' $locfile > locfile.tmp


# If measurement at the top of a peg (e.g. Ma_t), then assign the same coordinates to the site as when measured at the base
awk '{print $1}' infile.tmp > 1statlist.tmp
cp locfile.tmp locfile1.tmp
while read line
do
  if [[ "$line" == *_t ]]; then
    basestat=${line%_t}
    coords=`awk '/\<'$basestat'\>/ {print $1, $2}' locfile1.tmp`
    echo $coords $line >> locfile.tmp
  fi
done < 1statlist.tmp


# Create a station list with stations common to the 2 surveys
awk '{print $3}' locfile.tmp > 2statlist.tmp
sort 1statlist.tmp > 1statlist_sort.tmp
sort 2statlist.tmp > 2statlist_sort.tmp
comm -12 1statlist_sort.tmp 2statlist_sort.tmp > statlist.tmp

# Delete existing files and create new ones
if [ -e statloc.tmp ]; then
	rm statloc.tmp
fi
touch statloc.tmp

if [ -e magn.tmp ]; then
	rm magn.tmp
fi
touch magn.tmp


# Fill tmp output files with coordinates for each station and averaged magnetic value for each station
while read line
do
   awk '/\<'$line'\>/ {print $0}' locfile.tmp >> statloc.tmp 
   awk '/\<'$line'\>/ {print $0}' infile.tmp >> magn.tmp 
done < statlist.tmp


# Create output file with averaged value for each station
echo "#Lat(WGS84) Long(WGS84) MagneticPeg nT(relative to ${refstat})" > $outfile
paste statloc.tmp magn.tmp | awk '{print $1, $2, $3, $5}' >> $outfile


# Clean directory
#rm *tmp





