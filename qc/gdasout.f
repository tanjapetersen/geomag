	program gdasout
c
c  Program to convert the IAGA2002 files from GDAS 
c  back to normal XYZF IAGA2002 files for a day 
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)
c
c  It reads a gdas output pmin file (HDZF), e.g. api20150101pmin.min, in the api (or other stn) sub-c  directory and 
c  writes an XYZF pmin file with the header from api_header.txt in sub-directory new.
c 
c  NOTE: Our file from gdas did not have a station name in its name, if that is normal
c  one of us could modify gdasout.f to read such a file (the station name is a parameter
c  and would be added to the output file).
c
c  compiles with f77
 
	implicit none

	integer i, j, iday, ih, im, comment 
	real*4 d,h,x,y,z,f,rad
	character*2 yr, mth, day
	character*3 stn,ucstn
	character*4 ton,toff
	character*7 del
	character*19 fileout
	character*29 datetime
	character*70 line
	
	call getarg(1,stn)
	call getarg(2,yr)
	call getarg(3,mth)
	call getarg(4,day)
	fileout = stn//'20'//yr//mth//day//'pmin.min'
	open(unit=4,file =  stn // '/'//fileout)
        open(5,file='/home/tanjap/geomag/core/'//stn//'_header.txt')	
        open(unit=14,file =  'new/'//fileout)
!  First read comment lines from stn_header.txt
	do i = 1,100
	   read(5,'(a70)', end=100) line
           write(14,'(a70)') line
	end do
  100   continue
	comment = 1
!  Then read comment lines on GDAS output and ignore them
	do while (comment .ne. 0)
	   read(4,'(a70)') line
           if(line(:1) .ne. ' ') comment = 0
	end do
!  This should fail (comment = 0) on line starting with DATE,
        
!  Reading now simple free format read, one line per minute
 1400	format(a30,4f10.2)
	do i = 0, 23
	   do j = 0, 59
!	      read(4,1400) datetime, x, y, z, f
	      read(4,'(a70)') line
	      read(line(31:40),'(f10.2)') h     ! h in nT
	      read(line(41:50),'(f10.2)') d     ! d in arc min
	      read(line(51:60),'(f10.2)') z     ! z in nT   No CHANGE
	      read(line(61:70),'(f10.2)') f     ! f in nT   No CHANGE
		       if((h.lt. 99000.).and.(d.lt.99000.)) then
			  rad = d/60. * 3.14159/180.
                          x = h * cos(rad)
                          y = h * sin(rad)
		       else
			  x = 99999.
			  y = 99999.
		       end if
	      write(14,1400) line(:30), x,y,z,f
           end do
	end do
      end
