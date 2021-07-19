#!/bin/csh 

# NewDay.csh to send a modified file to Edinburgh GIN
# Operates on Daily pmin.min files
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is 2-digit day
# The unix mailing program "mpack" needs to be in the core/ directory!!

if ($#argv == 0) then
  echo "Call as  NewDay.csh stn yr mth day"
  stop
endif

set fmino = '/amp/magobs/'$1/$1/$1'20'$2$3$4'pmin.min'
##Use 'mpack email' sending method:
### if you want to send a new quasi-definitive file:
##set fmino = '/amp/magobs/'$1'/qd/'$1'20'$2$3$4'pmin.min'
echo $fmino
#date
#/home/tanjap/geomag/core/mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk
#/home/tanjap/geomag/core/mpack -s $fmino $fmino m.thornton@gns.cri.nz
mailx -a $fmino $fmino e_gin@mail.nmh.ac.uk < /dev/null
echo `date`

## Use 'web upload' sending method. Still needs testing!:
## Send the pmin file to web server after zipping it together with psec.sec file:
set fseco = '/amp/magobs/'$1/$1/$1'20'$2$3$4'psec.sec'
echo $fseco
zip minsec.zip $fmino $fseco
 /home/tanjap/geomag/core/gin_upload.sh -d -u imo:fjks4395 minsec.zip http://app.geomag.bgs.ac.uk/GINFileUpload/Cache
### DOES NOT WORK: /home/tanjap/geomag/core/gin_upload.sh -d -u imo:fjks4395 minsec.zip https://imag-data.bgs.ac.uk/GIN_V1/GINForms2
echo $fmino minute file and $fseco second file sent

### for sending daily 1-second files from e.g /amp/magobs/sba/sba/ folder:
#set fseco = '/amp/magobs/'$1/$1/$1'20'$2$3$4'psec.sec'
#gzip $fseco
#set fsecgz = '/amp/magobs/'$1/$1/$1'20'$2$3$4'psec.sec.gz'
#echo $fsecgz
#/home/tanjap/geomag/core/mpack -s $fsecgz $fsecgz e_gin@mail.nmh.ac.uk


## If email gets rejected cc it to the e_gin support desk:
#mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk emailsupport@smxemail.com

# Stop here
