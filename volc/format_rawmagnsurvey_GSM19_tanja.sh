#!/bin/bash
# format_rawmagnsurvey_GSM19.sh <surveydate> <NZvsUTC>
# !!! works on Linux, not Mac (date doesn't behave the same)

# Get user input
surveydate=$1
NZvsUTC=$2


# Assign files

infile=../data/${surveydate}/survey/WImagn_${surveydate}_rawsurveyidentified_GSM19.dat
outfile=../data/${surveydate}/survey/WImagn_${surveydate}_surveyidentified.dat

dos2unix $infile


# Remove header from files 
awk 'FNR>1{print}' $infile > file1.tmp

# Format date
yyyy=`echo ${surveydate} | cut -c 1-4`
mm=`echo ${surveydate} | cut -c 5-6`
day=`echo ${surveydate} | cut -c 7-8`

# Format time (add spaces between hr, min & sec)
awk '{print $1}' file1.tmp > filetime.tmp
cut -b1-2 filetime.tmp > filehr.tmp
cut -b3-4 filetime.tmp > filemin.tmp
cut -b5-6 filetime.tmp > filesec.tmp
#paste filehr.tmp filemin.tmp filesec.tmp file1.tmp | awk '{print '${yyyy}'"-"'${mm}'"-"'${day}', $1":"$2":"$3}' > finaltime.tmp
paste filehr.tmp filemin.tmp filesec.tmp file1.tmp | awk '{print '${yyyy}'" "'${mm}'" "'${day}', $1" "$2" "$3}' > finaltime.tmp

# Convert to UTC date
# if output file exist: overwrite
#if [ -e finaltimeUTC.tmp ]; then
#	rm finaltimeUTC.tmp
#	touch finaltimeUTC.tmp
#fi
 
#while read line
#do
#	date -d"$line ${NZvsUTC} hours ago" +"%Y %m %d %H %M %S" >> finaltimeUTC.tmp 
#done < finaltime.tmp

## Create data file (with time and magnetic data) and add header
echo "#Year(UTC) Month(UTC) Day(UTC) Hour(UTC) Min(UTC) Sec(UTC) TotalMagneticField(nT) Site" > $outfile 
#paste finaltimeUTC.tmp file1.tmp | awk '{print $1, $2, $3, $4, $5,"00", $10, $11}' >> $outfile
paste finaltime.tmp file1.tmp | awk '{print $1, $2, $3, $4, $5, $6, $8, $10, $11}' >> $outfile 

# Clean directory
rm *.tmp

