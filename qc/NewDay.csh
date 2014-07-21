#!/bin/csh 

# NewDay.csh to send a modified file to Edinburgh GIN
# Operates on Daily pmin.min files
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is 2-digit day

if ($#argv == 0) then
  echo "Call as  NewDay.csh stn yr mth day"
  stop
endif

set fmino = '/amp/magobs/'$1/$1/$1'20'$2$3$4'pmin.min'
echo $fmino
/home/tanjap/geomag/core/mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk
#/home/tanjap/process/mpack -s $fmino $fmino t.petersen@gns.cri.nz
## the unix mailing program "mpack" needs to be in the process/ directory!!:
#mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk
## If email gets rejected cc it to the e_gin support desk:
#mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk emailsupport@smxemail.com

# Stop here







