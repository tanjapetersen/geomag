	program hour1test
c   This program reads 1 sec .csv files from fluxgate and proton
c   All stations have 1 second gsm recording.
c   For West Melton (EYR) also reads the seperate Summerhill single-axis 
c   fluxgate .csv file, to correct Z and F.
c   Remove dud Proton Mag readings and try and despike.
c   All readings not present are 99999.
c   For simplicity, this program no longer reads parameters from header of input
c   fge data file to compare with header.eyr etc.
c   MUST compile with f95 (not f77) as uses case statement
!
c   Arguments are stn yyyy.doy hr, e.g. eyr 2009.356 11 
c
!   Header terms in case statement are:
c   xcoil,ycoil,zcoil (~30000) 
c   xres,yres,zres (~60) 
c   step
c   xbias,ybias,zbias (~0x6f,y=0) hex code for number of bias steps
c   zoffset (38000)  extra zbias in nT
c   e0,e1,e2,e3,e4
c   Others (scale, zpolarity, etc.) are not used 
c
c   
!   Constants from constant.eyr (.sba & .api) file
! 
!   xb  Add to calculated x
!   zb  Add to calculated z
!   ddeg   Declination (whole degrees) at Y null
!   dmin   Declination (minute part (real)) at Y null
!   xts,xte  X Temperature Coefficients (nt/degree C) sensor & electronics
!   zts,zte  Z Temperature Coefficients (nt/degree C) sensor & electronics
!   fcor    Difference between Continuous Proton F & Absolute Proton F reading
!   bfact   Multiplicative factor for Benmore line correction (only for eyr)
!   tfact   Scale multiplier for temperature measurements
c   Features of this version
!
	implicit none
	integer*2 i,ihr,ih,iyr,mth,day,im,is,doy 
	integer*2 j,k,iend,g,q
	integer*2 bh,bm,bs,bo		! Benmore time
	integer*2 iyc, imc, idc ! 	! constant file year,month & day
	integer*2 h16,h1			! decoding hex numbers
	integer*4 iymd, iymdc
	integer*2 xbias,ybias,zbias
        integer*2 start                 ! for reading .csv
        integer*2 ii(1:15)                 ! For trimmed median
	real*4 st, dt, xr, yr, zr, xc, yc, zc, fc, ic, ben, f, v, mrad
        real*4 q330c                    ! .csv Q330 const / mV
	real*4 med, mdiff(3),odiff            ! Spike removal
	real*4 ddata(0:3599,1:12)	
	real*4 mdata(0:3599,1:4)
	real*4 ddeg,dmin,xb,zb, xts,xte,zts,zte, fcalc,ftol 
	real*4 ddeg2, dmin2, xb2, zb2, xts2, xte2, zts2, zte2 
	real*4 xcoil,ycoil,zcoil,xres,yres,zres,hc,xcorr,dminute
	real*4 xcalc,ycalc,zcalc,step,scale,zoffset
	real*4 fcor,fcor2,bfact,bfact2,bmax, tfact
        character*2 hrstr,daystr,mthstr,yrstr,gq
        character*3 stc,st1,ste,stf,stn
        character*7 hstr,dstr,zstr
        character*8 yearday		! e.g. 2005.074
        character*12 fileo 		! e.g. 2005.074.eyr
        character*14 etext
        character*21 filehead
        character*35 filex,filey,filez,filef,fileq,filed,files,filesum
!       character*44 fileb,filef, fileg
        character*46 ad
        character*62 line
        character*130 linef,lineo(744)

        common /a/ ddata,ii
        
!   Next few lines are to set up output file name and header
!   using year, doy, hr
	call getarg(2,yearday)
	yrstr = yearday(3:4)
	read(yearday(6:8),'(i3)') doy
	read(yrstr,'(i2)') iyr
	write(*,*) yrstr, '  ',doy,' ',iyr
	call getarg(3,hrstr)
	read(hrstr,'(i2)') ihr
	write(hrstr,'(i2.2)') ihr
	
!  Get station name, make up file extensions
!  These file extensions are for Mid 2015, i.e. may not work for old data 
	call getarg(1,stn)
	stc = stn(1:2) // 'c'
	st1 = stn(1:2) // '1'
	ste = stn(1:2) // 'e'
	stf = stn(1:2) // 'f'
!
!  Constants for spike removal, difference from median
        mdiff(1) = 500.         ! x
        mdiff(2) = 500.         ! y
        mdiff(3) = 500.         ! z
        odiff = 5.              ! f
!  Trimmed median, make sure close to symmetrical
        do i = 1, 11
           ii(i) = i + 2
        end do
        ii(12) = 2
        ii(13) = 14
        ii(14) = 15
        ii(15) = 1

	q330c = 0.000002384       ! Q330 counts to mV
        tfact = 200.0             ! Correct for eyr & sba
	select case (stn)
	   case('api') 
	      tfact = 100
              filehead = yearday//'.'//hrstr//'.NZ_APIM_5'
              xbias = 223
              ybias =   0
              zbias = 133
	      xcoil = 38386.
	      ycoil = 38543.
	      zcoil = 38329.
	      xres = 118.0
	      yres = 118.0
	      zres = 118.0
	      zoffset = 0.
	      step = 0.003922
	      ftol = 3.0
	      etext = '    Apia      '
           case('eyr') 
	      filehead = yearday//'.'//hrstr//'.NZ_EYWM_5'
	      filesum = 'data/'//yearday//'.'//hrstr//
     &                          '.NZ_SMHS_50_LFZ.csv'
              xbias = 143
              ybias =   0
              zbias = 109
              xcoil = 37683.
	      ycoil = 37968.
	      zcoil = 37618.
	      xres = 59.0
	      yres = 59.0
	      zres = 59.0
	      zoffset = 38000.
	      step = 0.003922
	      ftol = 3.0
	      etext = '    Eyrewell  '
	   case('sba')
	      filehead = yearday//'.'//hrstr//'.NZ_SBAM_5'
              xbias =  79
              ybias =   0
              zbias = 193
	      xcoil = 38296.
	      ycoil = 38367.
	      zcoil = 38023.
	      xres = 29.5
	      yres = 29.5
	      zres = 29.5
	      zoffset = 38000.
	      step = 0.003922
	      ftol = 15.0
	      etext = '  Scott Base   '
	end select

	      filex = 'data/'//filehead//'0_LFX.csv'
	      filey = 'data/'//filehead//'0_LFY.csv'
	      filez = 'data/'//filehead//'0_LFZ.csv'
	      filef = 'data/'//filehead//'1_LFF.csv'
	      fileq = 'data/'//filehead//'1_LEQ.csv'
	      filed = 'data/'//filehead//'0_LKD.csv'
	      files = 'data/'//filehead//'0_LKS.csv'

!	print *, filef,fileg
	i = -1
	call dayofyear(iyr,doy,mth,day,i)
	write(daystr,'(i2.2)') day
	write(mthstr,'(i2.2)') mth
	fileo = yrstr//mthstr//daystr//hrstr//'.' // st1
	iymd = 10000*iyr+100*mth+day
	print *, doy, iyr
	print *,'Yr',iyr,'; Mth',mth,'; Day ',day,'; ',daystr,' ',
     &      yrstr, '  ',iymd,'  hour ',ihr,'   ', yrstr//mthstr//daystr
	open(unit=14,file = '/home/tanjap/geomag/core/constants.'//stn)

!   Now we have date of data, look in constants file for last date before this
!   Read first line of constants file
	read(14,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
	iymdc = 10000*iyc+100*imc+idc
	if(iymdc .gt. iymd) call exit
	iend = 0
	do while (iend .lt. 1)     ! read another line of constants file
	   read(14,*,end=140) idc,imc,iyc,xb2,ddeg2,dmin2,zb2,
     &                        xts2,xte2,zts2,zte2,fcor2,bfact2
	   iymdc = 10000*iyc+100*imc+idc
	   if(iymdc .gt. iymd) then     ! Leave loop
              iend = 1
           else                 ! Update constants
	      xb = xb2
	      ddeg = ddeg2
	      dmin = dmin2
	      zb = zb2
	      xts = xts2
	      xte = xte2
	      zts = zts2
	      zte = zte2
 	      fcor = fcor2
	      bfact = bfact2
           end if
	end do
  140	continue
 	write(*,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
	print *, ' fcor = ',fcor
	mrad = 3437.747			! minutes/radian
!	
	write(*,*) 'Writing ', fileo  ! .ap1, .ey1 or .sb1 1-second output file
	open(20,file= stc//'/' // fileo)
!     .ape, eye or sbe is error file
	open(21,file= stc//'/' // yearday//'.'//ste,access='append')
	open(25,file= stc//'/' // 'test')
!	write(21,*) yearday,' ',ihr
	open(10,file=filex)
!	open(11,file=fileg)
!       if ( stn .eq. 'eyr' ) open(12,file=fileb)	! Benmore correction

!   Format for lines that are not free format
 1200	format(27x,3(i2,1x),4x,f9.4)

        bmax = 99.9 ! bmax set to not overflow and look right on benmore plots
!   Set up default values for missed readings
	do i = 0,3599		! Fill array with null readings
	   do k = 3,10
	      ddata(i,k) = 99999.
	   end do ! for k
	   ddata(i,1) = 0.	! Temperature etc null is 0
	   ddata(i,2) = 0.
	   ddata(i,9) = 0.      ! Null Benmore if not eyr
           if ( stn .eq. 'eyr' ) ddata(i,9) = bmax
	   ddata(i,11) = 0.
	   ddata(i,12) = 0.
	end do    ! for i

!  If Eyrewell, read Benmore Correction File ( .csv version)
        if ( stn .eq. 'eyr' ) then
	   open(10,file=filesum)
	   do i = 0,3599		! For 1 hour of 1 sec readings
	      read(10,'(a80)',end=111) line
	      read(line(15:16),'(i2)') im
	      read(line(18:19),'(i2)') is
              start = index(line(1:52),'LFZ')    !Read in right place
              read(line(start+4:start+10),*) ben
              ben = ben * q330c
              ddata(i,9) = ben/0.073
              if(abs(ben) .gt. 99.9) ben = bmax	 !Only if major reading problem 
	   end do
  111	   close(10)
        end if
	open(10,file=filef)          ! Read Total field from Proton
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=121) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           j = 60 * im + is
           start = index(line(1:52),'LFF')    !Read in right place
           read(line(start+4:start+10),*) f
           ddata(j,10) = f * 0.01
	end do
  121	close(10)
	open(10,file=filed)          ! Read Driver Temperature
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=131) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           j = 60 * im + is
           start = index(line(1:52),'LKD')    !Read in right place
           read(line(start+4:start+10),*) dt
           ddata(j,1) = dt /419430.4 * tfact - 273 
	end do
  131	close(10)
	open(10,file=files)          ! Read Sensor Temperature
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=141) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           j = 60 * im + is
           start = index(line(1:52),'LKS')    !Read in right place
           read(line(start+4:start+10),*) st
           ddata(j,2) = st /419430.4 * tfact - 273 
	end do
  141	close(10)
	open(10,file=filex)          ! Read X field from Fluxgate
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=151) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           j = 60 * im + is
           start = index(line(1:52),'LFX')    !Read in right place
           read(line(start+4:start+10),*) xr
           ddata(j,3) = xr * q330c  
	end do
  151	close(10)
	open(10,file=filey)          ! Read Y field from Fluxgate
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=161) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           start = index(line(1:52),'LFY')    !Read in right place
           read(line(start+4:start+10),*) yr
           j = 60 * im + is
           ddata(i,4) = yr * q330c  
	end do
  161	close(10)
	open(10,file=filez)          ! Read Z field from Fluxgate
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=171) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           start = index(line(1:52),'LFZ')    !Read in right place
           read(line(start+4:start+10),*) zr
           j = 60 * im + is
           ddata(j,5) = zr * q330c  
	end do
  171	close(10)
	open(10,file=fileq)          ! Read Proton quality data
	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,'(a80)',end=181) line
	   read(line(15:16),'(i2)') im
	   read(line(18:19),'(i2)') is
           start = index(line(1:52),'LEQ')    !Read in right place
           read(line(start+4:start+10),*) q
           j = 60 * im + is
           ddata(j,12) = q 
	end do
  181	close(10)
        do i = 1,3599		! 
	   if(ddata(i,9) .gt. 999.0) then
              if((ddata(i-1,9).lt.999.0).and.(ddata(i+1,9).lt.999.0)) 
     &                ddata(i,9) = (ddata(i-1,9)+ddata(i+1,9))/2.0 ! Interpolates missed data
           end if
	end do
	do j = 0,3599
	   im = j/60 
	   is = j - 60*im 
	   write(43,3001)ihr,im,is,ddata(j,3),ddata(j,4),ddata(j,5),
     &          ddata(j,6),ddata(j,7),ddata(j,10),ddata(j,1),ddata(j,2)
     &          ,ddata(j,9),ddata(j,12)
           ddata(j,3) = xcoil*ddata(j,3)/xres + step * xcoil * xbias
           ddata(j,4) = ycoil*ddata(j,4)/yres + step * ycoil * ybias
           ddata(j,5) = -(zcoil*ddata(j,5)/zres + step * zcoil * 
     &                    zbias + zoffset)
 	   write(44,3001)ihr,im,is,ddata(j,3),ddata(j,4),ddata(j,5),
     &          ddata(j,6),ddata(j,7),ddata(j,10),ddata(j,1),ddata(j,2)
     &          ,ddata(j,9),ddata(j,12)
           xcorr = ddata(j,3) + xb + xte * ddata(j,1) + xts * ddata(j,2)
           dminute = atan2(ddata(j,4),xcorr)*mrad + ddeg*60 + dmin
           hc = sqrt(xcorr*xcorr + ddata(j,2)*ddata(j,2))
           ddata(j,6) = hc * cos(dminute/mrad)
           ddata(j,7) = hc * sin(dminute/mrad)
           ddata(j,8) = ddata(j,5) + zb + zte * ddata(j,1) + 
     &                                    zts * ddata(j,2)
           ddata(j,8) = ddata(j,8) + bfact * ddata(j,9)  
           ddata(j,10) = ddata(j,10)-0.931 * bfact * ddata(j,9) + fcor 
!
	end do
 3001   format(3i3,3f12.5,2f11.3,f10.2,3f7.2,f6.1)
!  
!
!   Now processing raw data. 
!   Part I, basic sensitivity and offset
!


12100	format(a26,i3,2(1x,i2),6x,f9.2,4x,2i1)
 1100	format(26x,i3,2(1x,i2),6x,f7.0,4x,a2)
!	do i = 0,3599		! assumes no extra readings, could change
!	   read(11,1100,end=200) ad,ih,im,is,f
!	   read(11,1100,end=200,err=200) ih,im,is,f,gq
!           if(gq(2:) .eq. '.') then      ! Avoids problems if g=0
!              g = 0
!              read(gq(:1),'(i1)') q
!           else
!              read(gq(:1),'(i1)') g
!              read(gq(2:),'(i1)') q
!           end if 
!	   f = f/100.
!	   write (41,*) ih,im,is,f,g,q
C	   if((g .lt. 8) .or. (q .lt. 8)) write(21,*) ih, im, is, 
C     &                                                    f, g, q, v
! 	   write(*,*) ih, im, is, f, g, q, v
!	   j = im*60+is	
!	   if (i .ne. j) write(32,*)" GSM Time Problem ",ihr,im,is,i,j
!   Check for data on line
!	   if(f .gt. 1) then			! If f = 0, then will not correct it so never -ve
!   Constant of .931 based on effect of Z on F for 2006 Average values
!	      ddata(j,10) = f - 0.931 * bfact * ddata(j,9) + fcor
!	      ddata(j,11) = g
!	      ddata(j,12) = q
!  Next lines compare Fs with Fcalc
!
!	      if(ddata(j,10) .gt. 30000.) then
!	         fcalc = sqrt(ddata(j,6)*ddata(j,6)+ddata(j,8)*
!     &                         ddata(j,8)) 
!	         if(abs(ddata(j,10)-fcalc) .gt. ftol) write(21,*) 
!    &                   ih,im,is,ddata(j,10)-fcalc,g,q," Wrong Total"
!
!	         if ((ddata(j,11).lt.7.1).or.(ddata(j,12) .lt. 7.1)) 
!     &           write(21,*) ih,im,is,ddata(j,11),ddata(j,12),
!     &           " Poor Proton"
!	         if((abs(ddata(j,10)-fcalc) .gt. 2.0) .and.
!     &             ((ddata(j,11).lt.3.1).or.(ddata(j,12) .lt. 5.1)))
!     &           ddata(j,10) = 0.0
!	      else
!	            write(21,*) ih,im,is, "No GSM data"
!	      end if
!!	   end if
!	end do
!  200	   continue
 2000   format(3i3,3f11.3,f10.2,3f7.2,f7.3)
 2001   format(3i3,3f11.3,f10.2,3f7.2)
 2400   format(3i3,2(f12.3,f9.3,f14.3))
!
! Next bit should be to remove spikes. Different for fge & gsm
!
!  Look for spikes on fluxgate channels
!  If differs from median too much, replace by median
!  Different limits for each component, and can be set for each site
   	do j = 6,8             ! This routine now to despike Fluxgate 
 	   do i = 0,3599
!	      write(21,*) "XXX ",ihr,i,j,ddata(i,j)
 	      call median(i,j,med)
 	      if (abs(ddata(i,j) - med) .gt. mdiff(j-5)) then
 	         im = i/60
		 is = i - 60*im
		 write(21,2100) "FGE ",i,ihr,im,is,j,ddata(i,j),med
 	         ddata(i,j) = med
 	      end if
 	   end do
 	end do
 2100	format(a,5i4,2f12.2)
!  Look for spikes on overhauser channel
!  If differs from median too much, replace by median
 	   do i = 0,3599
!	      write(21,*) "XXX ",ihr,i,j,ddata(i,j)
 	      call mediano(i,med)
        write(42,*) i, med, ddata(i,10)
 	      if (abs(ddata(i,10) - med) .gt. odiff) then
 	         im = i/60
		 is = i - 60*im
		 write(21,2150) "GSM ",i,ihr,im,is,ddata(i,10),med
 	         ddata(i,10) = med
 	      end if
 	   end do
 2150	format(a,4i4,2f12.2)
!
!
c  Now write out 1 second readings, whether or not there is data there
	do j = 0,3599
	   im = j/60 
	   is = j - 60*im 
           if (j .eq. 0) then
	      write(20,2000)ihr,im,is,ddata(j,6),ddata(j,7),ddata(j,8), 
     &           ddata(j,10),ddata(j,2),ddata(j,1),ddata(j,9),bfact	! stores bfact on line
	   else
	      write(20,2001)ihr,im,is,ddata(j,6),ddata(j,7),ddata(j,8), 
     &           ddata(j,10),ddata(j,2),ddata(j,1),ddata(j,9)
	   end if
	end do
	end

	subroutine dayofyear(yr,doy,mth,day,j)
	integer*2 i, j, yr, mth, day, doy, dimth(12)
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
!   

	subroutine median(i,n,med)
!  This does median for fge components
	implicit none
	integer*2 i,j,k,n,ii(1:15)
	real*4 data(0:3599,1:12)
	real x(11), med	
C	common /a/ ddata	
	common /a/ data,ii
!   Does median of 11 values. Starts wirh 1-11, then uses 5 each side
!   until ending with 3589-3599
	if(i .lt. 5) then 
	   do j = 1,11 
	      x(j) = data(j-1,n)
	   end do
	else if (i .gt. 3594) then
	   do j = 3589,3599 
	      x(j-3588) = data(j,n)
	   end do
	else
	   do j = i-5,i+5 
	      x(j-i+6) = data(j,n)
	   end do
	end if
	k = 11
	call sort(x,k)
!	write(31,*) (x(k), k=1,11)
	med = x(6)
	end

	subroutine mediano(i,med)
!  This does median for total (gsm) now 1 second
!  Take 15 values, only use best 11

	implicit none
	integer*2 i,j,k,m,n,ii(1:15)
	real*4 data(0:3599,1:12)
	real f(11),x(15), y(15), med	
C	common /a/ ddata	
	common /a/ data,ii
!   Does median of 11 values. Starts wirh 1-11, then uses 5 each side
!   until ending with 3589-3599
	if(i .lt. 7) then 
	   do j = 1,15 
	      x(j) = data(j-1,10)
	      y(j) = data(j-1,11)
	   end do
	else if (i .gt. 3591) then
	   do j = 3585,3599 
	      x(j-3584) = data(j,10)
	      y(j-3584) = data(j,11)
	   end do
	else
	   do j = i-7,i+7 
	      x(j-i+8) = data(j,10)
	      y(j-i+8) = data(j,11)
	   end do
	end if
!  Now copy best values in tillwe have 11
        k = 0
        do m = 9,0,-1
           do j = 1,15
              if (y(ii(j)).eq.m) then
                 k = k + 1
                 f(k) = x(ii(j))
              end if         
              if(k.ge.11) exit
           end do ! for i
        if(k.ge.11) exit
        end do ! for m
!       print *, 'B  ',i,k
	k = 11
	call sort(f,k)
!	write(31,*) (x(k), k=1,11)
	med = f(6)
	end

      SUBROUTINE SORT (X, N)
C
C        ALGORITHM AS 304.8 APPL.STATIST. (1996), VOL.45, NO.3
C
C        Sorts the N values stored in array X in ascending order
C
      INTEGER*2 N
      REAL X(N)
C
      INTEGER I, J, INCR
      REAL TEMP
C
      INCR = 1
C
C        Loop : calculate the increment
C
   10 INCR = 3 * INCR + 1
      IF (INCR .LE. N) GOTO 10

C
C        Loop : Shell-Metzner sort
C
   20 INCR = INCR / 3
      I = INCR + 1
   30 IF (I .GT. N) GOTO 60
      TEMP = X(I)
      J = I
   40 IF (X(J - INCR) .LT. TEMP) GOTO 50
      X(J) = X(J - INCR)
      J = J - INCR
      IF (J .GT. INCR) GOTO 40
   50 X(J) = TEMP
      I = I + 1
      GOTO 30
   60 IF (INCR .GT. 1) GOTO 20
C
      RETURN
      END
C

