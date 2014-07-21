	program doadjust
c
c  Program to adjust IAGA2002 files for a series of days 
c  when adjustment is in form d (min) hzf (nT)
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd year (4-digit), 3rd first doy, 4th last doy 
c  Converts XY to DH, makes correction, then converts back to XY
c  Adjusted files now are Quasi-definitive !!!
c  Should not alter any 99999 values 
	implicit none

	integer i, j, k, iyr, idoy, imth, iday, fd, ld, comment 
	real*4 x,y,z,f,d,h,delD,delH,delZ,delF
	character*2 yr, mth, day
	character*3 stn,fdoy,ldoy
	character*4 year
	character*11 splfile
	character*19 fileout
	character*29 datetime
	character*70 line
	
	if(iargc() .lt. 1) then
	   print *,'Call doadjust stn yyyy {doys doyf}'
	   call exit
	end if
	call getarg(1,stn)
	call getarg(2,year)
	yr = year(3:4)
	if(iargc() .lt. 3) then
	   fdoy = '001'
	   ldoy = '366'
	else
	   call getarg(3,fdoy)
	   call getarg(4,ldoy)
	end if
	read(fdoy,'(i3)') fd
	read(ldoy,'(i3)') ld
	splfile = stn//year//'.spl'
	open(unit=3,file = splfile)

	do k = 1, 366
!       Components in .spl file are H D Z F
	   read(3,*,end=100) iyr, imth, iday, idoy, delH,delD,delZ,delF 
!	   print *,idoy, delH, delD, delZ,delF
	   if((idoy .ge. fd) .and. (idoy .le. ld)) then
	      write(mth,'(i2)') imth
	      write(day,'(i2)') iday
	      if(mth(1:1).eq.' ') mth(1:1) = '0'
	      if(day(1:1).eq.' ') day(1:1) = '0'
!	   call dayofyear(yr,k,mth,day,j)
	      fileout = stn//year//mth//day//'pmin.min'
	      open(unit=4,file =  stn // '/'//fileout)
	      open(unit=14,file =  'new/'//fileout)
              
c SBA baseline adjustments (maybe can be simplified later)

c Process is done by hour1s (called by GetHour1.csh)
c which uses constants from /home/hurst/process/constants.sba
c Spline fit was made on differences between output
c (actually .sbx type files) and absolutes, so we don't need
c to worry about any aspect of baselines 
c
	      print *, delH,delD,delZ,delF

	      comment = 1
!  First read comment lines and write them out
	      do while (comment .ne. 0)
	         read(4,'(a70)') line
		 if(line(2:10) .eq. 'Data Type') line(25:40) = 'Quasi-definitive'
	         write(14,'(a70)') line
	         if (line(:1) .ne. ' ') comment = 0
	      end do
!  This should fail (comment = 0) on line starting with DATE,
!  which will be copied. The data should then immediately follow

!  Reading now simple free format read, one line per minute
 1400	format(a30,4f10.2)
	      do i = 0, 23
	         do j = 0, 59
!	            read(4,1400) datetime, x, y, z, f
	            read(4,'(a70)') line
	            read(line(31:40),'(f10.2)') x
	            read(line(41:50),'(f10.2)') y
	            read(line(51:60),'(f10.2)') z
	            read(line(61:70),'(f10.2)') f
!  Now convert x,y,z,f to d,h,z,f
	            if((x .lt. 99900.).and.(y .lt. 99900.)) then
		       d = atan2(y,x) * 60 * 180 / 3.1415926535 + delD
	               h = sqrt(x*x + y*y) + delH	
	               x = h * cos(d*3.1415926535/(60.*180.))
	               y = h * sin(d*3.1415926535/(60.*180.))
		    end if
	            if(z .lt. 99900.) z = z + delZ
	            if(f .lt. 99900.)f = f + delF
	            write(14,1400) line(:30), x,y,z,f
                 end do		!  for j
	      end do		!  for i
	   end if
	end do
  100   end

	subroutine dayofyear(yr,doy,mth,day,j)
	integer*4 i, j, yr, mth, day, doy, dimth(12)
c  j +ve, yr,mth,day to doy
c  j -ve, yr,doy to mth,day
	do i = 1,12
	   dimth(i) =31
	end do
	dimth(2) = 28
	dimth(4) = 30
	dimth(6) = 30
	dimth(9) = 30
	dimth(11) = 30
	if(mod(yr,4) .EQ. 0) dimth(2) = 29
	if(j .GT. 0) then
	   doy = day
	   if(mth .GT. 1) then
	      do i=1,mth-1
	         doy = doy + dimth(i)
	      end do
	   end if
	else
	   i = doy
	   mth = 1
	   do while(i .GT. 0)
	      i = i - dimth(mth)
	      mth = mth + 1
	   end do
	   mth = mth - 1
	   day = i + dimth(mth)
	end if
	end 

