	program one second
!   This program reads hourly data files, and just sends the actual
!   one-second readings calculates the .min file to intermagnet
!   Takes one parameter for station name (3 letter code, lower case),
!   second parameter is current input files 
!   Equivalent of Jan3005.eyr is eyr050130.eyr 
!   Designed for x,y,z  outputs
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(0:3599,1:7)
	real*8 C(0:18), S(0:90), MC(1:4)	
	real*4 mdata(0:1439,1:4),tdata(0:1439,1:3),tmpd,tmph
	real*4 ddeg,dmin,xbias,zbias,xts,xte,zts,zte,fcalc,fcorr 
	real*4 ddeg2, dmin2, xbias2, zbias2, xts2, xte2, zts2, zte2 
	character*2 hrstr,daystr,mthstr,yrstr
	character*3 dir, stc, stn, stnt, stnx, doys
	character*6 fstr
	character*7 hstr,dstr,zstr
	character*10 adate		! e.g. 2005-07-04
	character*12 fileo,filel,filen	! 
	character*34 filef, fileg
	character*36 mcodes, UMCODES
	character*62 line
	character*110 linef,lineo(744)

	UMCODES = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'
	
!   Next few lines are to set up output file name and header
	
	call getarg(1,stn) 	! abc Station Code
	stc = stn(1:2)//'c'
	call getarg(2,filen)		
	open(10,file= stc//'/'// filen)
	open(20,file= stn //'20'// filen(1:8) // '00psec.tmp')
	read(filen(1:2),'(i2)') iyr
	iyr = iyr+2000
	read(filen(3:4),'(i2)') mth
	read(filen(5:6),'(i2)') day
	read(filen(7:8),'(i2)') ihr
	adate = '20' // filen(1:2) // '-' //filen(3:4)//'-'//
     &                  filen(5:6)
	call dayofyear(iyr,doy,mth,day)
	write(doys,'(i3.3)') doy
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(3i4,1x,2f9.2,f10.2,f9.2,3f7.2)
 2003	format(a10,i3.2,':',i2.2,':',i2.2,'.000',i4.3,3x,4(1x,f9.2))

!  In data(,) lines 0:3599 are current hour
	print *,'ihr = ',ihr
	do i = 0,3599		! assumes no extra readings
	   read(10,*,end=100) ih,im,is,data(i,1),data(i,2),
     &       data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
	     j = ih*3600+im*60+is	
!   Write IAGA-2002 Format File
	   write(20,2003) adate,ih,im,is,doy,data(i,1),
     &     data(i,2),data(i,3),data(i,4)
 	   write(33,3000) ih,im,is,data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
	   if (i+3600*ihr .ne. j) write(*,*)" Time Problem ",ih,im,i
     &     ,is, i+3600*ihr, j, data(i,1)
 	end do
  100	continue
	end



	subroutine dayofyear(yr,doy,mth,day)
	integer*4 i, yr, mth, day, doy, dimth(12)
c  yr,mth,day to doy
	do i = 1,12
	   dimth(i) =31
	end do
	dimth(2) = 28
	dimth(4) = 30
	dimth(6) = 30
	dimth(9) = 30
	dimth(11) = 30
	if(mod(yr,4) .EQ. 0) dimth(2) = 29
	doy = day
	   if(mth .GT. 1) then
	      do i=1,mth-1
	         doy = doy + dimth(i)
	      end do
	   end if
	end 
