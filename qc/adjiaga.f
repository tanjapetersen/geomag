	program adjiaga
c
c  Program to make an arbitrary change to ALL 4 COMPONENTS 
c  in IAGA2002 files for a known time (or whole day) 
c  Reads from directory stn, writes to directory qd
c  Adjustment of whole day by H,D,Z,F from spline fit
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)
c  5th is delH, 6th is delD, 7th is delZ, 8th is delF 

 
	implicit none

	integer i, j, iday, ih, im, comment 
	integer*2 hron, hroff, minon, minoff
	real*4 d,h,x,y,z,f,delD,delH,delZ,delF
	real*4 D0,H0,Z0,F0
	character*2 yr, mth, day
	character*3 stn
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
	open(unit=14,file =  'qd/'//fileout)
	call getarg(5,del)
c	print *, del
	read(del,'(f8.0)') delH
	call getarg(6,del)
c	print *, del
	read(del,'(f8.0)'), delD
	call getarg(7,del)
c	print *, del
	read(del,'(f8.0)'), delZ
	call getarg(8,del)
c	print *, del
	read(del,'(f8.0)'), delF
	print *, delH,delD,delZ,delF

!  Now get difference between spline fit and value used for initial process
!  Note temperature coefficients have been incorporated into absonel program
	if(stn .eq. 'eyr') then
	   H0 = -88.0		! nT
	   D0 = 7.7		! minutes above 23 degrees
	   Z0 = 567.3
	   F0 = - 1.5
	else			! stn is sba, Scott Base
	   H0 = -640.0		! nT
	   D0 = 44.		! minutes above 154 degrees
	   Z0 = 850.0
	   F0 = -307.
	end if			! Does not cope with Apia

	delH = delH - H0
	delD = delD - D0
	delZ = delZ - Z0
	delF = delF - F0

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
 1400	format(a30,4f10.2)
	do i = 0, 23
	   do j = 0, 59
!	      read(4,1400) datetime, x, y, z, f
	      read(4,'(a70)') line
	      read(line(31:40),'(f10.2)') x
	      read(line(41:50),'(f10.2)') y
	      read(line(51:60),'(f10.2)') z
	      read(line(61:70),'(f10.2)') f
	      if((x.lt. 99990.).and.(y.lt. 99990.)) then
		 h = sqrt(x*x + y*y)				! nT
		 d = atan2(y,x)*60*180/3.1415926535		! arc minutes
		 h = h + delH
		 d = d + delD
		 x = h * Cos(d * 3.1415926535/(60.*180.))
		 y = h * Sin(d * 3.1415926535/(60.*180.))
	      end if
	      if(z.lt. 99990.) z = z + delZ			! nT
	      if(f.lt. 99990.) f = f + delF			! nT
	      write(14,1400) line(:30), x,y,z,f
           end do
	end do
      end
