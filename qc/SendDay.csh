#!/bin/csh 
# Sends Day File to Edinburgh
# Parameters sta yr mth day s        (s means seconds)
# MUST BE IN SAME DIRECTORY AS FILE
# SHOULD SEND zipped files also

#cd qd/

if( $5 == 's') then
   set filein = $1'20'$2$3$4'psec.sec'
   set file   = $1'20'$2$3$4'psec.sec.gz'
else
   set filein = $1'20'$2$3$4'pmin.min'
   set file   = $1'20'$2$3$4'pmin.min.gz'
endif

gzip $filein 
/home/tanjap/geomag/core/mpack -s $file $file e_gin@mail.nmh.ac.uk
gunzip $file

echo File $file sent

