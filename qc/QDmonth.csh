#!/bin/csh 

# QDmonth.csh to produce a QD file 
# with option to send it to Edinburgh GIN
# Operates on Daily pmin.min files in /eyr, 
# with QD files put in /qd
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year, $3 is 2-digit mth, $4 is GO
# if file to be sent to Edinburgh

if ($#argv == 0) then
  echo "Call as  NewDay.csh stn yr mth {GO}"
  stop
endif

cd /amp/magobs/$1

set ymd = "20$2-$3-$4"
set ym = "20$2$3"

foreach day (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
   set pmin = $1'20'$2$3$day'pmin.min'
   if(-e $1/$pmin) then 
#     echo $pmin
      set dd = `gawk -v d=$ym$day '{if($1==d) print $2 }' < D_spline.txt`
      set hh = `gawk -v d=$ym$day '{if($1==d) print $2 }' < H_spline.txt`
      set zz = `gawk -v d=$ym$day '{if($1==d) print $2 }' < Z_spline.txt`
      set ff = `gawk -v d=$ym$day '{if($1==d) print $2 }' < F_spline.txt`
      echo $dd $hh $zz $ff
      /home/tanjap/geomag/qc/adjiaga $1 $2 $3 $4 $dd $hh $zz $ff

      set fmino = '/amp/magobs/'$1/qd/$1'20'$2$3$day'pmin.min'
      echo $fmino
      if($4 == 'GO') /home/tanjap/geomag/core/mpack -s $fmino $fmino e_gin@mail.nmh.ac.uk
   endif
end
# End







