#!/bin/csh 

# IAGAnull.csh to produce an IAGA2002 format day file with null values (a whole day with null values for all components XYZ & F)
# $1 is 3 letter code (lower case) for station
# $2 is 2-digit year,$3 is 2-digit mth,$4 is 2-digit day,$5 s for secs, else min

if ($#argv == 0) then
  echo "Call as  IAGAnull.csh stn yr mth day s   (s only if for secs)"
  stop
endif

# Calculate Day of Year

set ymd = "20$2-$3-$4"
set doy = `date -u -d "$ymd" +%j`

if ($5 == 's') then
   set file = $1"20"$2$3$4"psec.sec"
   foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
      foreach min (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)
         foreach sec (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)

            echo $ymd" "$hr":"$min":"$sec".000 "$doy"     99999.00  99999.00  99999.00  99999.00" >> data.lst
         end
      end
   end
   cat /home/tanjap/geomag/core/$1s_header.txt data.lst > $file
else
   set file = $1"20"$2$3$4"pmin.min"
   foreach hr (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
      foreach min (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)

         echo $ymd" "$hr":"$min":00.000 "$doy"     99999.00  99999.00  99999.00  99999.00" >> data.lst
      end
   end
   cat /home/tanjap/geomag/core/$1_header.txt data.lst > $file
endif
rm data.lst
echo "Finished"






