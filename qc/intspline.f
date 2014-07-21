	program intspline
c
c  Reads spline files and makes a daily interpolation file 
c  1st arg stn, 2nd yr
 
	implicit none

	integer days,iyr,mth,day,doy
	real*4 daily(4,366)
	character*3 stn
	character*4 year
	
	call getarg(1,stn)
	call getarg(2,year)

	read(year,'(i4)') iyr
	call dayofyear(iyr,doy,12,31,1)
	days = doy					! 365 or 366 days

	call readspline(1,stn,year,days,daily)
	call readspline(2,stn,year,days,daily)
	call readspline(3,stn,year,days,daily)
	call readspline(4,stn,year,days,daily)

	open(unit=12,file=stn//year//'.spl')
	do doy = 1, days
	   call dayofyear(iyr,doy,mth,day,-1)
	   write(12,'(i5,3i4,4f8.2)') iyr, mth, day, doy, daily(1,doy),
     &		daily(2,doy),daily(3,doy),daily(4,doy) 
	end do
	end

	subroutine readspline(icpt,stn,year,days,daily)

	integer icpt
	integer yr,iyr,doy,doyp,days
	real*4 val,valp,x,daily(4,366)
	character*1 cpt
	character*3 stn
	character*4 year, acpt
!	character*8 date

	acpt = 'HDZF'
	cpt = acpt(icpt:icpt)
	read(year,'(i4)') iyr
!	call dayofyear(iyr,doy,12,31,1)
!	days = doy					! 365 or 366 days
	open(unit=4,file=cpt//'_spline'//year//'.'//stn)
!  Reading list of dates and values
	call read1line(iyr,doy,val)			! 1st line of file
	do i = 1, days
	   if(doy .lt. i) then		! read until we pass current day of year
	      do while (doy .lt. i)
		 doyp = doy
		 valp = val
		 call read1line(iyr,doy,val)
	      end do
	      x = valp + (val - valp) * (i - doyp)/(doy-doyp)
!	      print *, i, x, '  ', doy, doyp, val, valp
	   else
	      x = valp + (val - valp) * (i - doyp)/(doy-doyp)
!	      print *,i, x
	   end if
	   print *, i, x, '  ', doy, doyp, val, valp
	   daily(icpt,i) = x
	end do 
 1000   end

	subroutine read1line(iyr,doy,val)
	integer yr,iyr,mth,day,doy,ldoy,days
	real*4 val
	character*8 date

	read(4,*,end=1000) date, val
	read(date(1:4),'(i4)') yr
	read(date(5:6),'(i2)') mth
	read(date(7:8),'(i2)') day
!	print *, yr, mth, day
	if(yr .lt. iyr) then
	   call dayofyear(yr,doy,12,31,1)
	   ldoy = doy
	   call dayofyear(yr,doy,mth,day,1)
	   doy = doy - ldoy 
	else 
	   if(yr .gt. iyr) then
	      call dayofyear(iyr,doy,12,31,1)
	      lday = doy
	      call dayofyear(yr,doy,mth,day,1)
	      doy = doy + lday 
	   else
	      call dayofyear(yr,doy,mth,day,1)
	   end if
	end if
	print *, yr, mth, day, doy
	return
 1000   doy = 1000
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
