	program exactiagav
c  NOTE: this version now has correct polarity and correction for Y.
c  Program to make Fs - Fv exactly zero or a certain value
c  in IAGA2002 files for a whole day 
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit), 5th value for Fs - Fv
c  Main change in z, also opposite 50% change in y makes it smoother
 
	implicit none

	integer i, j, iday, ih, im, comment,i999 
	real*4 x,y,z,f,fv,fs,df,v
	character*2 yr, mth, day
	character*3 stn
	character*4 ton,toff
	character*7 del,val
	character*19 fileout
	character*29 datetime
	character*70 line
	
	call getarg(1,stn)
	call getarg(2,yr)
	call getarg(3,mth)
	call getarg(4,day)
	call getarg(5,val)
	read(val,'(f7.0)') v		! Convert character to real
	fileout = stn//'20'//yr//mth//day//'pmin.min'
	open(unit=4,file =  stn // '/'//fileout)
	open(unit=14,file =  'new/'//fileout)

	comment = 1
!  First read comment lines and write them out
	do while (comment .ne. 0)
	   read(4,'(a70)') line
	   write(14,'(a70)') line
	   if (line(:1) .ne. ' ') comment = 0
	end do
!  This should fail (comment = 0) on line starting with DATE,
!  which will be copied. The data should then immediately follow

!  Reading now simple free format read, one line per minute
 1400	format(a30,6f10.2)
	do i = 0, 23
	   do j = 0, 59
!	      read(4,1400) datetime, x, y, z, f
	      read(4,'(a70)') line
	      read(line(31:40),'(f10.2)') x
	      read(line(41:50),'(f10.2)') y
	      read(line(51:60),'(f10.2)') z
	      read(line(61:70),'(f10.2)') f
	      fv = 0
	      i999 = 0
	      if(x.lt. 99000.) then
		 fv = x * x 
	      else
		 x = 99999.
		 i999 = 1
	      end if
	      if(y.lt. 99000.) then
		 fv =  fv + y * y 
	      else
		 y = 99999.
		 i999 = 1
	      end if
	      if(z.lt. 99000.) then
		 fv = fv + z * z 
		 fv = sqrt(fv)
	      else
		 z = 99999.
		 i999 = 1
	      end if
	      if(f.lt. 99000.) then
		 fs = f 
	      else
		 f = 99999.
		 i999 = 1
	      end if
	      if(i999.le. 0) then
		 df = fs - fv
		 z = z - 1.0 * df - v		! z -ve, therefore +v reduces absolute value
		 y = y + 0.5 * df
		 fv = sqrt(x * x + y * y + z * z)
	      end if
	      write(14,1400) line(:30),x, y, z, f
!	      write(14,1400) line(:30),x, y, z, f, df, fs-fv
           end do
	end do
      end
