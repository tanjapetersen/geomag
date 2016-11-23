#!/bin/csh 
# Sends Hour File to Edinburgh
# Parameters sta yr mth day hr s        (s means seconds)
# MUST BE IN SAME DIRECTORY AS FILE
# SHOULD SEND zipped files also

#cd qd/

if( $6 == 's') then
   set filein = $1'20'$2$3$4$5'00psec.sec'
   set file   = $1'20'$2$3$4$5'00psec.sec.gz'
else
   set filein = $1'20'$2$3$4$5'00pmin.min'
   set file   = $1'20'$2$3$4$5'00pmin.min.gz'
endif

# Zip file if not already zipped
gzip $filein 
/home/tanjap/geomag/core/mpack -s $file $file e_gin@mail.nmh.ac.uk
gunzip $file

echo File $file sent

