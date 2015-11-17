#!/bin/csh 
# Sends Day File to Edinburgh
# Parameters sta yr mth day 
# MUST BE IN SAME DIRECTORY AS FILE

cd qd/

set filein = $1'20'$2$3$4'pmin.min'
set file   = $1'20'$2$3$4'pmin.min.gz'

gzip $filein 
/home/tanjap/geomag/core/mpack -s $file $file e_gin@mail.nmh.ac.uk
gunzip $file

echo File $file sent

