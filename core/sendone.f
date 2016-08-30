	program sendone
!   This program reads hourly data files, and calculates the .min file to 
!   send to intermagnet, and writes an hour towards both .eyx and .eyt files,
!   Takes one parameter for station name (3 letter code, lower case),
!   second & third parameters are current and previous input files 
!   Equivalent of Jan3005.eyr is eyr050130.eyr 
!   File has extra minute at start, to enable 0000 reading to be calculated
!   19 point filter on 5 second readings to give minute values 
!   Null out 0 and very small values when producing minute values
!   Designed for x,y,z  outputs
!
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(-60:3599,1:7)
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
! Parameters for 5-sec rounding for 1-minute values (Gaussian):	
        C(0) = 0.00229315 
        C(1) = 0.00531440 
        C(2) = 0.01115655
        C(3) = 0.02121585 
        C(4) = 0.03654680 
        C(5) = 0.05702885 
        C(6) = 0.08061140 
        C(7) = 0.10321785 
        C(8) = 0.11972085 
        C(9) = 0.12578865
	do i = 10,18
	   C(i) = C(18-i)
	end do
! Parameters for 1-sec rounding for 1-minute values (Gaussian):	
        S(0) = 0.00045933
	S(1) = 0.00054772
	S(2) = 0.00065055
	S(3) = 0.00076964
	S(4) = 0.00090693
	S(5) = 0.00106449
	S(6) = 0.00124449
	S(7) = 0.00144918
	S(8) = 0.00168089
	S(9) = 0.00194194
        S(10) = 0.00223468
	S(11) = 0.00256140
	S(12) = 0.00292430
	S(13) = 0.00332543
	S(14) = 0.00376666
	S(15) = 0.00424959
	S(16) = 0.00477552
	S(17) = 0.00534535
	S(18) = 0.00595955
	S(19) = 0.00661811
        S(20) = 0.00732042
	S(21) = 0.00806530
	S(22) = 0.00885090
	S(23) = 0.00967467
	S(24) = 0.01053338
	S(25) = 0.01142303
	S(26) = 0.01233892
	S(27) = 0.01327563
	S(28) = 0.01422707
	S(29) = 0.01518651
        S(30) = 0.01614667
	S(31) = 0.01709976
	S(32) = 0.01803763
	S(33) = 0.01895183
	S(34) = 0.01983377
	S(35) = 0.02067480
	S(36) = 0.02146643
	S(37) = 0.02220039
	S(38) = 0.02286881
	S(39) = 0.02346437
	S(40) = 0.02398040
        S(41) = 0.02441104
	S(42) = 0.02475132
	S(43) = 0.02499727
	S(44) = 0.02514602
	S(45) = 0.02519580
	do i = 46,90
	   S(i) = S(90-i)
	end do
 
!   Next few lines are to set up output file name and header
	
	call getarg(1,stn) 	! abc Station Code
	stc  = stn(1:2) // 'c'
	stnt = stn(1:2) // 't'
	stnx = stn(1:2) // 'x'
	call getarg(2,filen)		
	call getarg(3,filel)		
	open(10,file= stc//'/'// filen)
	open(11,file= stc//'/'// filel)
	open(20,file= stn //'20'// filen(1:8) // '00pmin.tmp')
!	open(21,file= stn//'/'//filen(1:6)//'.'// stn,access='append')
	open(22,file= stn//'/'//filen(1:6)//'.'//stnt,access='append')
	open(23,file= stn//'/'//filen(1:6)//'.'//stnx,access='append')
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

!  In data(,) lines -60:-1 are last minute of previous hour
!             lines 0:3599 are current hour
!  Read last minute of last hours file. Lines 3541-3600

	do i = 0,3539		! 3540 dummy readings
 	   read(11,*,end=50) ih
	end do
	do i = -60,-1		! 60 readings during 59th minute
	   read(11,*,end=50) ih,im,is,data(i,1),data(i,2),
     &       data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
	     j = im*60+is	
 	   write(33,3000) ih,im,is,data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
	   if (i+3600 .ne. j) write(*,*)" Time Problem ",ih,im,i
     &     ,is, j, data(i,1)
 	end do

   50   continue
	print *,'ihr = ',ihr
	do i = 0,3599		! assumes no extra readings
	   read(10,*,end=100) ih,im,is,data(i,1),data(i,2),
     &       data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
	     j = ih*3600+im*60+is	
 	   write(33,3000) ih,im,is,data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
	   if (i+3600*ihr .ne. j) write(*,*)" Time Problem ",ih,im,i
     &     ,is, i+3600*ihr, j, data(i,1)
 	end do
  100	continue

c   Clear output array
	do i = 0,59
	   mdata(i,1) = 0.0
	   mdata(i,2) = 0.0
	   mdata(i,3) = 0.0
	   mdata(i,4) = 0.0
	   tdata(i,1) = 0.0
	   tdata(i,2) = 0.0
	   tdata(i,3) = 0.0
	end do
c   Output Processing of One Hour starts here
c   
 2000   format(3i3,6f9.1)
	fcorr = 2.0		! Constant for matching F to X*X+Z*Z
	
c   Minute averages using filter around exact minute (and * 10,(*100 for D))
	do i = 0,59
	   ih = ihr
	   im = i 
	   do k = 1,4
	      MC(k) = 0.0
	   end do
	   do j=0,90
	      if(data(i*60+j-45,1) .lt. 90000.) then
		 mdata(i,1) = mdata(i,1) + 
     &                          S(j) * data(i*60+j-45,1)
		 MC(1) = MC(1) + S(j)
	      end if 
	      if(data(i*60+j-45,2) .lt. 90000.) then
		 mdata(i,2) = mdata(i,2) + 
     &                          S(j) * data(i*60+j-45,2)
		 MC(2) = MC(2) + S(j)
	      end if 
	      if(data(i*60+j-45,3) .lt. 90000.) then
		 mdata(i,3) = mdata(i,3) + 
     &                          S(j) * data(i*60+j-45,3)
		 MC(3) = MC(3) + S(j)
	      end if 
	      if(data(i*60+j-45,4) .lt. 90000.) then
		 mdata(i,4) = mdata(i,4) + 
     &                          S(j) * data(i*60+j-45,4)
		 MC(4) = MC(4) + S(j)
	      end if 
	      tdata(i,1) = tdata(i,1) + 
     &                               S(j) * data(i*60+j-45,5) 
	      tdata(i,2) = tdata(i,2) + 
     &                               S(j) * data(i*60+j-45,6) 
	      tdata(i,3) = tdata(i,3) + 
     &                               S(j) * data(i*60+j-45,7) 
	   end do		! for j
!  Correct for missed values (could give strange answers)
	   do k = 1,4
	      if(MC(k).gt. 0.001) then
                 mdata(i,k) = mdata(i,k)/MC(k)
	         write(39,*) k, MC(K)
	      else
		 mdata(i,k) = 99999.0
	      end if
	   end do
!   Write IAGA-2002 Format File
 2002	format(a10,i3.2,':',i2.2,':00.000',i4.3,3x,4(1x,f9.2))
	   write(20,2002) adate,ih,im,doy,mdata(i,1), mdata(i,2),mdata(i,3),mdata(i,4)

!  Write .eyx, .sbx file of magnetics and temperature, filtered minute values
	   write(23,'(3i4,4(1x,f9.2),2f6.1,f8.2)') day,
     &     ih,im,mdata(i,1),mdata(i,2),mdata(i,3),
     &     mdata(i,4),tdata(i,1),tdata(i,2),tdata(i,3)

!  Write .eyt, .sbt file of magnetics and temperature, filtered minute values
	   tmph = sqrt(mdata(i,1)*mdata(i,1)+mdata(i,2)*mdata(i,2))
	   tmpd = 60*180*atan2(mdata(i,2),mdata(i,1))/3.14159
	   write(22,'(3i4,4(1x,f9.2),2f6.1,f8.2)') day,
     &     ih,im,tmpd,tmph,mdata(i,3),
     &     mdata(i,4),tdata(i,1),tdata(i,2),tdata(i,3)
	end do		! for i

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
