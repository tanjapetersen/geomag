	program sendmin
!   This program reads a daily near real-time data file, and calculates the 
!   .min file to send to Potsdam
!   File has extra minute at start, to enable 0000 reading to be calculated
!   90 point filter on 1 second readings to give minute values 
!   Set 99999.99 for X & Y at 0000UT
!
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is, lastmin 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(-60:86399,1:2), d1, d2
	real*8 S(0:90), MC(1:2)	
	real*4 mdata(0:1439,1:2),tdata(0:1439,1:3),tmpd,tmph
	real*4 ddeg,dmin,xbias,zbias,xts,xte,zts,zte,fcalc,fcorr 
	real*4 ddeg2, dmin2, xbias2, zbias2, xts2, xte2, zts2, zte2 
	character*2 hrstr,daystr,mthstr,yrstr
	character*3 dir, stc, stn, stnt, stnx, doys
	character*6 fstr
	character*7 hstr,dstr,zstr
	character*8 filed, filel        ! e.g. 20191231
	character*10 adate		! e.g. 2005-07-04
	character*12 fileo,filen	! 
	character*34 filef, fileg
	character*36 mcodes, UMCODES
	character*62 line
	character*110 linef,lineo(744)

	UMCODES = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'
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
	call getarg(2,filed)	                ! e.g. 20191231	
 	call getarg(3,filel)	
!   Open rt daily file of 1-sec data
	open(10,file= '/amp/magobs/eyr/rt/sec/'//stn//filed//'psec.dat')
!   Open previous days  data
	open(11,file= '/amp/magobs/eyr/rt/sec/'//stn//filel//'psec.dat')
!	open(20,file= '/home/hurst/potsdam/'//stn// filed // 'pmin.tmp')
	open(21,file= '/amp/magobs/eyr/rt/min/'//stn//filed//'pmin.tmp')
	read(filed(1:4),'(i4)') iyr
	read(filed(5:6),'(i2)') mth
	read(filed(7:8),'(i2)') day
!	adate = '20' // filen(1:2) // '-' //filen(3:4)//'-'//
!     &                  filen(5:6)
!	write(doys,'(i3.3)') doy
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(3i4,1x,2f9.2,f10.2,f9.2,3f7.2)

!  In data(,) lines -60:-1 are last minute of previous day
!             lines 0:86399 are current day
!  Read last minute of last hours file. Lines 3541-3600

	do i = -60,86399		! 
           data(i,1) = 99999.99
           data(i,2) = 99999.99
        enddo                   ! Any missed readings will be 99999.99

	do i = 0,86399		! read all, but only last minute wanted
	   read(11,10000,end=50) adate,ih,im,is,doy,d1,d2
           if((ih .eq. 23).and.(im .eq. 59)) then
 	      data(-60+is,1) = d1
 	      data(-60+is,2) = d2
           endif
	end do

   50   continue
10000   format(a10,3(1x,i2),4x,i4,3x,2(f10.2)) 
	do i =   0,86399		! 
	   read(10,10000,end=100) adate,ih,im,is,doy,d1,d2
!	   write(33,3000) ih,im,is,d1,d2
 	   data(ih*3600+im*60+is,1) = d1
 	   data(ih*3600+im*60+is,2) = d2
        end do
!       ih = 24         ! If reaches end, do whole day
  100	lastmin = ih * 60 + im
        if(is .lt. 45) lastmin = lastmin -1   ! Needs 45 secs after
!                                               minute to do average
        print *, ' Last minute is  ', lastmin
c   Clear output array
	do i = 0,23
	   do j = 0,59
	      mdata(i*60+j,1) = 0.0
	      mdata(i*60+j,2) = 0.0
	   end do
	end do
c   Output Processing of One Hour starts here
c   
 2000   format(3i3,6f9.1)
	
c   Minute averages using filter around exact minute (and * 10,(*100 for D))
	do i = 0,23
!	   print *, 'hour is   ',i
           do j = 0,59
              if((i*60+j .gt. lastmin)) goto 200
	      ih = i
	      im = j 
	      do k = 1,2
	         MC(k) = 0.0
	      end do
	      do k=0,90
	         if(data(i*3600+j*60+k-45,1) .lt. 90000.) then
		    mdata(i*60+j,1) = mdata(i*60+j,1) + 
     &                          S(k) * data(i*3600+60*j+k-45,1)
		    MC(1) = MC(1) + S(k)
	         end if 
	         if(data(i*3600+j*60+k-45,2) .lt. 90000.) then
		    mdata(i*60+j,2) = mdata(i*60+j,2) + 
     &                          S(k) * data(i*3600+60*j+k-45,2)
		    MC(2) = MC(2) + S(k)
	         end if 
	      end do		! for k
!  Correct for missed values (could give strange answers)
	      do k = 1,2
	         if(MC(k).gt. 0.001) then
                    mdata(i*60+j,k) = mdata(i*60+j,k)/MC(k)
	            write(39,*) i, j, k, MC(K)
	         else
		    mdata(i*60+j,k) = 99999.00
	         end if
	      end do
!             if((i .eq. 0) .and. (j .eq. 0)) then begin
!               mdata(0,1) = 99999.00
!               mdata(0,2) = 99999.00
!             endif
!   Write IAGA-2002 Format File
 2002	format(a10,i3.2,':',i2.2,':00.000',i4.3,3x,4(1x,f9.2))
!	      write(20,2002) adate,ih,im,doy,mdata(i*60+j,1), 
!     &             mdata(i*60+j,2),99999.00,99999.00
	      write(21,2002) adate,ih,im,doy,mdata(i*60+j,1), 
     &             mdata(i*60+j,2),99999.00,99999.00


	   end do		! for j
	end do		! for i
  200   continue
	end

