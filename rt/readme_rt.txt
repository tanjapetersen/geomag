NOTE: More details are in the GeoNet wiki "EYR to Potsdam at near real-time".

Near Real-Time Documentation
Tony Hurst 25 March 2019

RealHour.csh

The main program is the Unix shell script RealHour.csh, which is called as a cron job 5 minutes after the start of each hour. It first sets a number of variables based on the initial date and time, then sets up the input file names. It also sets a counter (leno, stored in a file identified with the start date and hour of  this instance of RealHour.csh) to 0, indicating that no data has yet been sent.
The script then starts looping, with the end of loop condition being a day (of month) two days after the current day). In fact, nearly always the loop will stop much earlier when 3600 lines have been read from both the X and Y single component files.
The loop starts by FTPing the two files from ftp.geonet.org.nz to the /amp/magobs/eyr/rt/in directory and counting the number of lines in each. If the smaller of these is larger than leno, then the Fortran program realsec.f is called, to write new lines of IAGA-2002 format data to a daily 1-second data file, followed by sendday.f which calculates 1-minute averages, and the script then sends an IAGA-2002 format file of this 1-minute data, including header, to Potsdam.
If all the 3600 second data points for the hour have been read, the script finishes, otherwise it increases leno to len (the current number of lines that have been written), sleeps for 3 minutes, then restarts the loop. 
realsecs.f	(compile with f95)
This program reads the input .csv files, based on hour1aE.f.  Some constants relating to Apia and Scott Base have been left in here in case they are needed in the future. Note that xbias, ybias and zbias are hard-wired, and need to be changed if the bias switches on the fluxgate driver are altered.
The program has 8 Command Line parameters, namely
station  (e.g. eyr) ; 4-digit year ; 2-digit month ; 2-digit day of month ;
3-digit day of year ; 2-digit hour ; previous shorter file length (leno) ; shorter file length (len)
First the constants file is read, either from ~tanjap/geomag/core or from a test location, and the appropriate time is used for the constants. 
Then the X and Y .csv files are read, for the lines starting at leno+1 until len.  The RealHour.csh script sets the default directory as /amp/magobs/rt/eyr, the input files are read from sub-directory in, and the output file is written to sub-directory sec.  
Note that because the seconds time value in a .csv file is a real of variable length, it is necessary to locate the LFX or LFY label to correctly read the data value.
The X and Y are in sensor coordinates, the constants are used to convert these to geographic coordinates, and these number are then added to the daily 1-second file, in IAGA-2002 format, but without a header. This file is of the form /amp/magobs/eyr/rt/sec/eyr20190324psec.dat.

sendday.f
This program reads the current version of the daily 1-second data, and the previous days file, so as to produce a daily file of 1-minute average values. The last 60 seconds of the previous day are needed for calculating the 0000UT average value, and the last average calculated is for the last minute for which the following 45 seconds of data is available.  The output file (without header) is of the form /amp/magobs/eyr/rt/min/eyr20190324pmin.tmp, the final file to go to Potsdam is created by attaching a header to get a file in the IAGA-2002 format named /amp/magobs/eyr/rt/min/eyr20190324pmin.min.

filerem.csh
Removes old files. Once IÃ¢€™ve deleted various files manually, we will need to alter this version and put it into TanjaÃ¢€™s crontab, to delete all old files. Maybe leave main second and minute files for 3 weeks, as sometimes they have come through better than the regular processing. Any intermediate files to go after 2 weeks.
