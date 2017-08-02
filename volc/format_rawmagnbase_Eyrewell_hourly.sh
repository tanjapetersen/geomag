#!/bin/bash
# format_rawmagnbase_Eyrewell.sh
# Format Eyrewell data to be used for diurnal corrections (assumes that hourly files are stored under ~/work/research/white_island/magnetics/data/<surveydate>/base/raw)
#	usage: ./format_rawmagnbase_Eyrewell.sh <surveydate>
# ex: ./format_rawmagnbase_Eyrewell.sh 20120608
#
# Lauriane Chardot, GNS Science, Taupo, New Zealand
# email: l.chardot@gns.cri.nz
# January 2016


# Get user input
surveydate=$1

# Define output file
outfile=../data/${surveydate}/base/WImagn_${surveydate}_base.dat

# Create header
echo "#Year(UTC) Month(UTC) Day(UTC) Hour(UTC) Min(UTC) Sec(UTC) TotalMagneticField(nT)" > $outfile 

# Format data
ls ../data/${surveydate}/base/raw/20*fge-eyrewell.txt > filelist.tmp # list all the files in the directory
while read line
do
	sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' $line > file.tmp # remove empty lines at the end of the file
	awk 'FNR==4{print $0}' file.tmp | cut -b6-15 > date.tmp # extract date from header
	tmpdate=`sed 's/\// /g' date.tmp` # replace "/" delimiter by " "
	awk -v val="$tmpdate" 'FNR>25{print val, $1, $2, $3, $12}' file.tmp >> $outfile # only select data of interest and add date   
done < filelist.tmp

# Clean directory
#rm *.tmp 

 


