	program splineblv
!  Program reads the files hstnyy.csv, dstnyy.csv, zstnyy.csv and fstnyy.csv
!  then produces the 1st part of a .blv file.
!  Then reads stnyyyy.spl that provides the equivalent spline fits for 
!  the four components. Finally it reads delfyy.stn for dailt deltaF values.
!  The constants needed are read in on the command line. 
!
!  Call as splineblv stn year hmean fmean hdiff ddiff zdiff fdiff	
!  hmean & fmean are yearly averages 
!  hdiff, ddiff, zdiff and fdiff are (approximate) baseline values
!  !  For more than one reading per day, takes average
!  NEW FORMAT from 2010 onwards 

	implicit none
	integer i,j,doy,iyr,iyear,imth,iday,if,fmean,hmean,ddeg,idummy
	integer*2 dn(366),hn(366),zn(366),fn(366)
	real hdiff,ddiff,zdiff,fdiff
	real d(366),h(366),z(366),s(366),f(366),hh,dd,zz,ff
	real rd1,rd2,rd3,rd4,fdif
	real hin,zin,dmin,din,fin,ffix
	character*3 obs,obsuc	
	character*4 year
	character*6 af
	character*10 del,ad,ah,as,az			! Format now 1x,f9.2
	character*94 line,linei(744),lineo(744)
!
	if(iargc() .lt. 1) then
	   print *,'Call splineblv stn year hmean fmean hdiff ddiff zdiff fdiff'	
	   call exit
	end if
 	call getarg(1,obs)
	call getarg(2,year)
	call getarg(3,del)
	read(del,'(i5)') hmean
	call getarg(4,del)
	read(del,'(i5)') fmean
	call getarg(5,del)
	read(del,*) hdiff
	call getarg(6,del)
	read(del,*) ddiff
	call getarg(7,del)
	read(del,*) zdiff
	call getarg(8,del)
	read(del,*) fdiff
	print *, 'H F ', hmean, fmean, hdiff, ddiff, zdiff, fdiff
	do i = 1,3
	   obsuc(i:i) = obs(i:i)
	   if(ichar(obs(i:i)) .gt. 96) obsuc(i:i)= char(ichar(obs(i:i))-32)
	end do
	print *, obsuc, '  HDZ'
	read(year,'(i4)') iyear
	open(20,file= obs // year //'.blv')
 	write(20,2010) hmean,fmean,obsuc,year
 2010   format('HDZF',2i6,' ', a3, 1x, a4)
	
	do i = 1,366
	   hn(i) = 0
	   h(i) = 0.0
	   dn(i) = 0
	   d(i) = 0.0
	   zn(i) = 0
	   z(i) = 0.0
	   fn(i) = 0
	   f(i) = 0.0
	end do
 
	j = +1			! imth,iday to doy
	
	open(10,file= 'h'//obs//year(3:4)//'.csv')
	do i = 1, 300
	   read(10,'(a94)',end=100) line
	   read(line,'(i2,1x,i2,1x,i4)') iday,imth,iyear
	   read(line(12:94),*) hin
 	   print *, iyear,imth,iday,hin
	   call dayofyear(iyear,doy,imth,iday,j)
	   h(doy) = h(doy) + hin			
	   hn(doy) = hn(doy) + 1
	end do
  100	print *, 'H done'
	open(10,file= 'd'//obs//year(3:4)//'.csv')
	do i = 1, 300
	   read(10,'(a94)',end=200) line
	   read(line,'(i2,1x,i2,1x,i4)') iday,imth,iyear
	   read(line(12:94),*) din
 	   print *, iyear,imth,iday,din
	   call dayofyear(iyear,doy,imth,iday,j)
	   d(doy) = d(doy) + din			
	   dn(doy) = dn(doy) + 1
	end do
  200	print *, 'D done'
	open(10,file= 'z'//obs//year(3:4)//'.csv')
	do i = 1, 300
	   read(10,'(a94)',end=300) line
	   read(line,'(i2,1x,i2,1x,i4)') iday,imth,iyear
	   read(line(12:94),*) zin
 	   print *, iyear,imth,iday,zin
	   call dayofyear(iyear,doy,imth,iday,j)
	   z(doy) = z(doy) + zin			
	   zn(doy) = zn(doy) + 1
	end do
  300	print *, 'Z done'
	open(10,file= 'f'//obs//year(3:4)//'.csv')
	do i = 1, 300
	   read(10,'(a94)',end=400) line
	   read(line,'(i2,1x,i2,1x,i4)') iday,imth,iyear
	   read(line(12:94),*) fin
 	   print *, iyear,imth,iday,fin
	   call dayofyear(iyear,doy,imth,iday,j)
	   f(doy) = f(doy) + fin			
	   fn(doy) = fn(doy) + 1
	end do
  400	print *, 'F done'
  	do i = 1, 366
	   if((dn(i)+fn(i)+hn(i)).ge.1) then
	      if(dn(i).ge.1) then 
	         write(ad,'(1x,sp,f9.2)') 
     &                     d(i)/dn(i)+ddiff
	      else
	         ad = '  99999.00'
	      end if
!	      print *,hn(i),zn(i),z(i),zdiff
	      if(hn(i).ge.1) then 
	         write(ah,'(1x,sp,f9.2)') h(i)/hn(i)+hdiff
	      else
	         ah = '  99999.00'
	      end if
	      if(zn(i).ge.1) then 
	         write(az,'(1x,sp,f9.2)') z(i)/zn(i)+zdiff  
	      else
	         az = '  99999.00'
	      end if
	      if((fn(i).ge.1).and.(abs(f(i)).lt. 2000.)) then 
	         write(as,'(1x,sp,f9.2)') f(i)/fn(i)+fdiff
	      else
	         as = '  99999.00'
	      end if
	print *, i,ah,ad,az,as
	write(20,2000) i,ah,ad,az,as
	   end if
	end do
 2000	format(i3.3,4a10)
!
!  Now start second part. These files are read into same arrays as first part

	open(11,file= obs // year // '.spl')
	open(12,file='delf' // year(3:4) // '.' // obs)
	write(20,2002) '*'
 2002	format(a1)
	do i = 1, 366				
	   d(i) = 0.0
	   f(i) = 10000.0
	end do
	do i = 1, 366				
	   read(12,*,end=500) j,fdif
	   f(i) = fdif
	end do
  500   write(*,*) 'hdiff etc ', hdiff, zdiff
	do i = 1, 366				
	   read(11,*,end=600) iyear,imth,iday,doy,hh,dd,zz,ff
!  	   call dayofyear(iyear,doy,imth,iday,j)
	   d(doy) = ddiff+dd
	   h(doy) = hdiff+hh
	   z(doy) = zdiff+zz
	   s(doy) = fdiff+ff			
	   write(26,*) iday,imth,iyr,doy,hh,zz,d(doy),h(doy),
     &                z(doy),s(doy),f(doy)
	end do
  600	do i = 1, doy				! 366 for leap year, else 365
!	   write(18,*) d(i), h(i), z(i), s(i), f(i)
	   if(abs(f(i)) .gt. 2000.) f(i) = 999.00
!	   write(*,'(i3.3,4f10.2)') i,h(i),d(i),z(i),s(i),f(i)
! SEEMS TO BE WRONG POLARITY FOR s, FIXED HERE   NOW REVERSED AGAIN
	   write(20,2001) i,h(i),d(i),z(i),s(i),f(i),' c'
	end do
 2001	format(i3.3,sp,4(1x,f9.2),1x,f7.2,a2)
	write(20,2002) '*'
  	end
 
	subroutine dayofyear(yr,doy,mth,day,j)
	integer i, j, yr, mth, day, doy, dimth(12)
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
	   mth = 1
	   do while(doy .GT. 0)
	      doy = doy - dimth(mth)
	      mth = mth + 1
	   end do
	   mth = mth - 1
	   day = doy + dimth(mth)
	end if
	end 



