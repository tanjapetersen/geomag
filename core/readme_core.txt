This is all I need for the daily processing of APIA:

[tanjap@tawa core]% ll
total 220
drwxrwxr-x 2 tanjap tanjap  4096 Nov 27 10:43 .
drwxrwxr-x 3 tanjap tanjap  4096 Nov 27 10:26 ..
-rw-rw-r-- 1 tanjap tanjap  1562 Nov 27 10:31 api_header.txt
-rw-rw-r-- 1 tanjap tanjap  1562 Nov 27 10:31 apis_header.txt
-rw-rw-r-- 1 tanjap tanjap    78 Nov 27 10:32 constants.api
-rwxrwxr-x 1 tanjap tanjap  5487 Nov 27 10:40 GetHour1a.csh
-rwxrwxr-x 1 tanjap tanjap 36705 Nov 27 10:35 hour1a
-rw-rw-r-- 1 tanjap tanjap 18954 Nov 27 10:33 hour1a.f
-rwxrwxr-x 1 tanjap tanjap 30681 Nov 27 10:35 kindext
-rw-rw-r-- 1 tanjap tanjap 15331 Nov 27 10:28 kindext.f
-rwxrwxr-x 1 tanjap tanjap 31275 Nov 27 10:31 mpack
-rwxrwxr-x 1 tanjap tanjap 15822 Nov 27 10:35 onesecond
-rw-rw-r-- 1 tanjap tanjap  2875 Nov 27 10:27 onesecond.f
-rwxrwxr-x 1 tanjap tanjap 22023 Nov 27 10:35 sendone
-rw-rw-r-- 1 tanjap tanjap  7642 Nov 27 10:28 sendone.f

apis_header.txt -- is the header for the seconds files

I changed the path for the constants. files in hour1a.f and did a F77 hour1a.f -o hour1a I needed to change the paths in GetHour1a.csh from Tony to my space.

!!!!!!!!!!!!!!! GetHour1a.csh -- /amp/ftp/pub/hurst/ ... University of Oulu bit still needs to be changed. Do they still want the plots???? => contact the person; Ray created a home directory on the ftp server for me: /amp/ftp/pub/tanjap/ I now can create subdirectories from Spinx & Ralley

[tanjap@tawa core]% crontab -l
25 * * * * /home/tanjap/geomag/core/GetHour1a.csh api 1> geomag/core/GetHour_api.log 2> /dev/null

=> it runs GetHour1a.csh 25 minutes past every hour and writes a log file.

===============================================================

This is all I need for the daily processing of SCOTT BASE:

-rw-rw-r-- 1 tanjap tanjap  5176 Feb 11 10:02 constants.sba
-rwxrwxr-- 1 tanjap tanjap  6310 Feb 11 10:15 GetHour1.csh
-rw-r--r-- 1 tanjap tanjap  2187 Feb 11 10:35 GetHour_sba.log
-rwxrwxr-x 1 tanjap tanjap 36626 Feb 11 10:02 hour1s
-rw-rw-r-- 1 tanjap tanjap 18565 Feb 11 10:02 hour1s.f
-rwxrwxr-x 1 tanjap tanjap 30681 Nov 27 10:35 kindext
-rw-rw-r-- 1 tanjap tanjap 15331 Nov 27 10:28 kindext.f
-rwxrwxr-x 1 tanjap tanjap 31275 Nov 27 10:31 mpack
-rwxrwxr-x 1 tanjap tanjap 15822 Nov 27 10:35 onesecond
-rw-rw-r-- 1 tanjap tanjap  2875 Nov 27 10:27 onesecond.f
-rw-rw-r-- 1 tanjap tanjap  1491 Feb 11 10:06 sba_header.txt
-rw-rw-r-- 1 tanjap tanjap  1490 Feb 11 10:06 sbas_header.txt
-rwxrwxr-x 1 tanjap tanjap 22023 Nov 27 10:35 sendone
-rw-rw-r-- 1 tanjap tanjap  7642 Nov 27 10:28 sendone.f

From these programs & files GetHour1.csh, hour1s.f, constants.sba, sba_header.txt, sbas_header.txt and cleansb1.f are the only programs I needed to add to the programs that are also used for API. 

GetHour1.csh needed to get changed during the process of moving the SBA daily processing over from Tony's to my space; the things that needed to be changed were only paths, e.g. ~hurst/process/hour1s needed to be changed to ~tanjap/geomag/core/hour1s 
I also changed the path for the constants. files in hour1s.f and did a F77 hour1s.f -o hour1s

!!!!!!!!!!!!! GetHour1.csh -- /amp/ftp/pub/hurst/ ... University of Oulu bit still needs to be changed. This is only a placeholder so that the setup is the same as for API. 

!!!!!!!!!!!!! Still need to change the cleansb1.f program, compile it and un-comment the corresponding part in GetHour1.csh  

SBA needed to be added to the crontab job, so that crontab now looks like this:

[tanjap@tawa core]% crontab -l
25 * * * * /home/tanjap/geomag/core/GetHour1a.csh api 1> geomag/core/GetHour_api.log 2> /dev/null
35 * * * * /home/tanjap/geomag/core/GetHour1.csh sba 1> geomag/core/GetHour_sba.log 2> /dev/null

=> it runs GetHour1.csh 35 minutes past every hour and writes a log file.

====================================================================

Another thing I do need for API & SBA:

CheckDay.csh  -- checks later if the files were complete and if not it gets the files from the ftp-site and runs the HaveDay scripts, so following additional fiels are needed for this:
               
-rwxrwxr-x 1 tanjap tanjap  5713 Feb 12 10:10 CheckDay.csh                                      
-rwxrwxr-- 1 tanjap tanjap   459 Feb 12 10:12 FtpFile.csh                                     
-rwxrwxr-x 1 tanjap tanjap  3994 Feb 12 10:11 HaveDay1az.csh
-rwxrwxr-x 1 tanjap tanjap  4288 Feb 12 10:29 HaveDay1.csh
-rwxrwxr-x 1 tanjap tanjap  4184 Feb 12 10:11 HaveDay1w.csh
-rw-rw-r-- 1 tanjap tanjap 18658 Feb 12 12:06 hour1w.f
-rw-rw-r-- 1 tanjap tanjap  2435 Feb 12 14:32 constants.eyr 
-rw-rw-r-- 1 tanjap tanjap  1491 Feb 12 14:31 eyr_header.txt 
-rw-rw-r-- 1 tanjap tanjap  1491 Feb 12 14:32 eyrs_header.txt


I needed to change my ftp login identification in FtpFile.csh and I needed to change paths from Tony to my space in the HaveDay scripts. Also changed the path for the constants files in hour1w.f and did a F77 hour1w.f -o hour1w

HaveDay1az.csh  -- for Apia
HaveDay1.csh --- for SBA Watch out for ionosonde cleaning!!! See if its switched on ("sba") or switched off ("noclean")!!!
HaveDay1w.csh  --- for EYR at West Melton


The crontab now looks like this:
[tanjap@tawa core]% crontab -l
25 * * * * /home/tanjap/geomag/core/GetHour1a.csh api 1> geomag/core/GetHour_api.log 2> /dev/null
35 * * * * /home/tanjap/geomag/core/GetHour1.csh sba 1> geomag/core/GetHour_sba.log 2> /dev/null
42 13 * * * /home/tanjap/geomag/core/CheckDay.csh 1> geomag/core/CheckDay.log 2> /dev/null

=> CheckDay.csh runs 42 minutes after 13:00 every day

!!!! The HaveDay scripts are also being used by the manual processing - this causes a problem!!! This needs to be changed!!! Instead we need an individual CheckDay for each station: if data should be removed and fresh data retrieved from ftp and then newly processed!!!! => Tony & i changed that so that there is a NOW vs. for a specific day option (GetHour1a.csh stn NOW - for current processing. If you re-run HaveDay1az.csh for a specific day it calls GetHour1a.csh stn yr mth day hr). The GetHour1a.csh NOW option is being run via crontab every 25 minutes past the hour.

The GetHour1a.csh crontab now looks like this:
25 * * * * /home/tanjap/geomag/core/GetHour1a.csh api NOW 1> geomag/core/GetHour_api.log 2> /dev/null


=========================

Ionosonde cleaning added for SBA:

-rw-rw-r-- 1 tanjap tanjap 2920 Mar  3 10:16 cleansb1a.f

% f77 cleansb1a.f -o cleansb1a

This file compensates for the ionosonde signal and currently gets called by 
HaveDay1.csh (via CheckDay.csh !!!) and GetHour1.csh

The file uses /amp/magobs/sba/iono.dat as parameter file!!!


==========================

This is all I need for the daily processing of EYR (at West Melton since Dec 2013):

[tanjap@tawa core]% ll
-rwxrwxr-x 1 tanjap tanjap 36705 Apr  8 09:52 hour1w
-rw-rw-r-- 1 tanjap tanjap 18729 Apr  8 09:52 hour1w.f
-rwxrwxr-x 1 tanjap tanjap 5981 Jul  8 09:22 GetHour1w.csh
-rwxrwxr-x 1 tanjap tanjap 31275 Nov 27  2013 mpack
-rwxrwxr-x 1 tanjap tanjap 15822 Nov 27  2013 onesecond
-rwxrwxr-x 1 tanjap tanjap 22023 Nov 27  2013 sendone
-rw-rw-r-- 1 tanjap tanjap 7642 Nov 27  2013 sendone.f
-rw-rw-r-- 1 tanjap tanjap 2875 Nov 27  2013 onesecond.f
-rw-rw-r-- 1 tanjap tanjap 2576 Jul 16 15:18 constants.eyr
-rw-rw-r-- 1 tanjap tanjap 1491 Feb 12 14:31 eyr_header.txt
-rw-rw-r-- 1 tanjap tanjap 1491 Feb 12 14:32 eyrs_header.txt
-rwxrwxr-x 1 tanjap tanjap 30681 Nov 27 10:35 kindext
-rw-rw-r-- 1 tanjap tanjap 15331 Nov 27 10:28 kindext.f


eyrs_header.txt -- is the header for the seconds files

I changed the path for the constants. files in hour1w.f and did a F77 hour1w.f -o hour1w 
I needed to change the paths in GetHour1w.csh from Tony to my space.

!!!!!!!!!!!!!!! GetHour1w.csh -- /amp/ftp/pub/hurst/ ... University of Oulu bit still needs to be changed. Do they still want the plots???? => contact the person; Ray created a home directory on the ftp server for me: /amp/ftp/pub/tanjap/ I now can create subdirectories from Spinx & Ralley

[tanjap@tawa core]% crontab -l
25 * * * * /home/tanjap/geomag/core/GetHour1w.csh eyr 1> geomag/core/GetHour_eyr.log 2> /dev/null

=> it runs GetHour1w.csh 25 minutes past every hour and writes a log file.
