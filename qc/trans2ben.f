	program trans2ben
c
c  Program to make a fge-benmore.raw file from Transpower Benmore data 
c  supplied by Noel Sheppard 
c  1st arg is filename, 2nd is year, 3rd is month
c  Input file must NOT go into next month, split it instead
c
	implicit none

	integer i, j, k, im, yr, mth, day, doy
	integer*2 hr, hrp, min, sec, mod, check
	real*4 ben
	character*2 yrstr, mthstr, hrstr
	character*3 stn, doystr
	character*20 filein, fileout
	character*35 l1,l2,l3,l4,d(8640)
	
	call getarg(1,filein)		
	call getarg(2,yrstr)
	read(yrstr,'(i2)') yr
	call getarg(3,mthstr)
	read(mthstr,'(i2)') mth
	open(unit=4,file = filein)
!  Read First Line
	read(4,*) day, hr, min, sec, ben
	call dayofyear(yr,doy,mth,day,+1)
	write(doystr,'(i3.3)') doy
	write(hrstr,'(i2.2)') hr
	fileout = '20'//yrstr//'.'//doystr//'.'//hrstr//'00.00.fge'
	open(14, file = fileout//'-benmore.raw')
 1400	format(26x,3i3,5x,f11.7)
!  Formula for Summerhill with old sensor (Oct 13), - 0.09 * Transpower
	write(14,1400) hr, min, sec, -0.0066 * ben 
!  Formula for Summerhill with new sensor (Nov 13), - Transpower/26. -3.65
c	write(14,1400) hr, min, sec, -0.0028 * ben -0.27
	hrp = hr
!  Now read .prn file. Each new hour needs a new output file
	do i = 1, 1000000
	   read(4,*,end = 100) day, hr, min, sec, ben
	   if(hrp .ne. hr) then			! New hour starts
	      close(14)
	      call dayofyear(yr,doy,mth,day,+1)
	      write(doystr,'(i3.3)') doy
	      write(hrstr,'(i2.2)') hr
	      fileout = '20'//yrstr//'.'//doystr//'.'//hrstr//'00.00.fge'
	      open(14, file = fileout//'-benmore.raw')
	   end if
	   write(14,1400) hr, min, sec, -0.0028 * ben -0.27
	   hrp = hr
	end do
100	continue

c	print *, yr, mth, day, hr, min, sec, fileout
c
      end


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

