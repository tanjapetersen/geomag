#!/bin/bash
# comp_magnchanges.sh <date_surveyinitial> <date_surveyfinal> <refstat>
# Compute magnetic changes between initial survey and final survey 
#
# Lauriane Chardot, GNS Science, Taupo, New Zealand
# email: l.chardot@gns.cri.nz
# March 2011 


# Get user input
survey1=$1
survey2=$2
refstat=$3

mkdir -p ../processing/${survey1}_${survey2}/

# Define files
infile1=../data/${survey1}/survey/WImagn_${survey1}_surveymedian_ref${refstat}_withcoords.dat
#infile2=../data/${survey2}/survey/WImagn_${survey2}_surveymedian_ref${refstat}_withcoords.dat
#infile2=../data/${survey2}/survey/WImagn_${survey2}_surveymedian_refAJp_withcoords.dat
#infile2=../data/${survey2}/survey/edited_Tanja/WImagn_${survey2}_surveymedian_ref${refstat}_withcoords.dat
infile2=../data/${survey2}/survey/edited_Tanja/WImagn_${survey2}_surveymedian_ref${refstat}_withcoords.dat
outfile=../processing/${survey1}_${survey2}/WImagnchanges_${survey1}_${survey2}_ref${refstat}.dat

#############################################

# Remove header from files 
awk 'FNR>1{print}' $infile1 > infile1.tmp
awk 'FNR>1{print}' $infile2 > infile2.tmp

# Create a station list with stations common to the 2 surveys
awk '{print $3}' infile1.tmp > 1statlist.tmp
awk '{print $3}' infile2.tmp > 2statlist.tmp
sort 1statlist.tmp > 1statlist_sort.tmp
sort 2statlist.tmp > 2statlist_sort.tmp
comm -12 1statlist_sort.tmp 2statlist_sort.tmp > statlist.tmp

#awk '{print $4}' infile1.tmp > 2survey.tmp

# Check if file exists
if [ -e 1survey.tmp ]; then
	rm 1survey.tmp
	touch 1survey.tmp
fi
if [ -e 2survey.tmp ]; then
	rm 2survey.tmp
	touch 2survey.tmp
fi

# Only consider stations for survey2 if they were measured in survey1
while read line
do
	awk '/\<'$line'\>/ {print $0}' infile1.tmp >> 1survey.tmp
	awk '/\<'$line'\>/ {print $3, $4}' infile2.tmp >> 2survey.tmp
done < statlist.tmp

# Create output file: magnetic field difference between survey2 and survey1
echo "#Lat Long MagneticSite Diff(nT)" > $outfile	
paste 1survey.tmp 2survey.tmp > tot.tmp
awk '{print $1, $2, $3, $6-$4}' tot.tmp >> $outfile  
# subtracting the difference of 80nT measured at Aj in 2016 vs 2017:
#awk '{print $1, $2, $3, $6-$4-80}' tot.tmp >> $outfile 

# Clean directory
#rm *tmp
