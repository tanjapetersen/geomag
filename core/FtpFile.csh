#!/bin/csh 

#get one hour of magnetic data from ftp.geonet.org.nz 
# $1 is the station name, e.g. api
# $2 is Year.DoY
# $3 is hour and rest of file name.

set source_machine = ftp.geonet.org.nz
cd /amp/magobs/$1/data
echo Trying to get missing file from ftp-server...
echo $1$3.$4
#echo ftp starts at `date --rfc-3339='ns'`
#do the ftp
ftp -inv $source_machine << endftp
  user anonymous t.petersen@gns.cri.nz 
  cd geomag
  cd $2
  cd $3
  get $3.$4 
endftp
#echo ftp ends at `date --rfc-3339='ns'`
echo

