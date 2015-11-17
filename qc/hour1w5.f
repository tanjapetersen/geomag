	program hour1w10
c   This program reads 1 sec fluxgate .txt files and 1 sec proton .txt files
c   For Eyrewell, reads the seperate Benmore file, to combine with other files
c   Remove dud Proton Mag readings and try and despike 
c   Need to read fge to get Benmore correction, therefore combine fge & gsm
c   into a single hourly file. All readings not present are 99999.
!   Read parameters from header of fge data and compare with header.eyr etc.
c   Currently above are hardwired
!   SPIKE REMOVAL NOW for fge
c   At Eyrewell, one correction matches Fs to Fcalc and to Fabs, whereas 
C   at Scott Base, just a standard correction is made, hence Fs-Fcalc
c   will change through the year.
!   Read switches and serial numbers only, other parameters won't change
!
c   Arguments are stn yyyy.doy hr, e.g. eyr 2009.356 11 
!
!
!   xcoil,ycoil,zcoil (~30000) 
!   xres,yres,zres (~60) 
!   step
!   xbias,ybias,zbias (~0x6f,y=0) hex code for number of bias steps
!   zoffset (38000)  extra zbias in nT
!   e0,e1,e2,e3,e4
!   Others (scale, zpolarity, etc.) are not used 
!
!   
!   Constants from constant.eyr (.sba) file
! 
!   xb  Add to calculated x
!   zb  Add to calculated z
!   ddeg   Declination (whole degrees) at Y null
!   dmin   Declination (minute part (real)) at Y null
!   xts,xte  X Temperature Coefficients (nt/degree C) sensor & electronics
!   zts,zte  Z Temperature Coefficients (nt/degree C) sensor & electronics
!   fcor    Difference between Continuous Proton F & Absolute Proton F reading
!   bfact   Multiplicative factor for Benmore line correction (only for eyr)
!
!   Features of this version
!
!   Voltage Detector (from gsm output) checking for dud battery. Output is in file    volt
!   Benmore line check. Output is in file  benmore
!
	implicit none
	integer*2 i,ihr,ih,iyr,mth,day,im,is,doy !,doyp,doyn,
	integer*2 j,k,g,q,iend
	integer*2 bh,bm,bs,bo		! Benmore time
	integer*2 iyc, imc, idc ! 	! constant file year,month & day
	integer*2 h16,h1,nv			! decoding hex numbers
	integer*4 iymd, iymdc
	integer*2 xbias,ybias,zbias,xbiasv,ybiasv,zbiasv
	real*4 st, dt, xr, yr, zr, xc, yc, zc, fc, ic, ben, f, v, mrad
	real*4 med
	real*4 ddata(0:3599,1:12)	
	real*4 mdata(0:3599,1:4)
	real*4 ddeg,dmin,xb,zb, xts,xte,zts,zte, fcalc,ftol 
	real*4 ddeg2, dmin2, xb2, zb2, xts2, xte2, zts2, zte2 
	real*4 xcoil,ycoil,zcoil,xres,yres,zres,hc,xcorr,dminute
	real*4 e0,e1,e2,e3,e4,xcalc,ycalc,zcalc,step,scale,zoffset
	real*4 fcor,fcor2,vav,bsum,bsumsq,bvar,bfact,bfact2	
!  vav, bsum etc. used to check battery voltage & benmore line OK
	character*2 hrstr,daystr,mthstr,yrstr,hexstr,xbhex,ybhex,zbhex
c	character*2 daynstr,mthnstr,yrnstr
	character*3 stc,st1,ste,stf,stn
	character*6 fstr,change
	character*7 hstr,dstr,zstr
	character*8 yearday,prevday		! e.g. 2005.074
	character*12 fileo,ferror !,filen		! e.g. 2005.074.eyr
	character*14 etext
	character*44 fileb,filef, fileg
	character*46 ad
	character*36 mcodes
	character*62 line
	character*130 linef,lineo(744)

	common /a/ ddata	
	
c   Next few lines are to set up output file name and header
	
	mcodes = 'JanFebMarAprMayJunJulAugSepOctNovDec'

	call getarg(3,hrstr)
	read(hrstr,'(i2)') ihr
	write(hrstr,'(i2.2)') ihr

!   This bit now does current day 
	call getarg(2,yearday)
	yrstr = yearday(3:4)
	read(yearday(6:8),'(i3)') doy
	read(yrstr,'(i2)') iyr
	write(*,*) yrstr, '  ',doy,' ',iyr
	i = -1
	
c  Get station name, make up file extensions

	call getarg(1,stn)
	stc = stn(1:2) // 'c'
	st1 = stn(1:2) // '1'
	ste = stn(1:2) // 'e'
	stf = stn(1:2) // 'f'
c	filen = yrnstr//mthnstr//daynstr//'.'//stf
	ben = 0.

	ybiasv = 0
!	Cannot use case stn, as f77 doesn't support case (character)
!       note also, may need to tidy termination of file names
!  Expected bias values are put in here also
	if(stn .eq.'eyr') then
	   filef = 'data/'//yearday//'.'//hrstr//'00.00.fge-eyrewell.txt'
	   fileg = 'data/'//yearday//'.'//hrstr//'00.00.westmelton.raw'
	   fileb = 'data/'//yearday//'.'//hrstr//'00.00.fge-benmore.raw'
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
	else
	   xcoil = 38296.
	   ycoil = 38367.
	   zcoil = 38023.
	   xres = 29.5
	   yres = 29.5
	   zres = 29.5
	   zoffset = 38000.
	   step = 0.003922
	   filef = 'data/'//yearday//'.'//hrstr//
     &             '00.00.fge-scottbase.txt'
	   fileg = 'data/'//yearday//'.'//hrstr//
     &             '00.00.gsm-scottbase.txt'
	   ftol = 15.0
	   etext = '  Scott Base   '
	end if
	if(stn .eq.'api') then
	   filef = 'data/'//yearday//'.'//hrstr//'00.00.fge-apia.txt'
	   fileg = 'data/'//yearday//'.'//hrstr//'00.00.gsm-apia.raw'
!	   fileb = 'data/'//yearday//'.'//hrstr//'00.00.fge-benmore.txt'
	   xcoil = 37683.
	   ycoil = 37968.
	   zcoil = 37618.
	   xres = 118.0
	   yres = 118.0
	   zres = 118.0
	   zoffset = 0.
	   step = 0.003922
	   ftol = 3.0
	   etext = '    Apia      '
	end if 
	write(*,*) filef,fileg
	write(*,*) yrstr, '  ',doy,' ',iyr
	call dayofyear(iyr,doy,mth,day,i)
	write(*,*) yrstr, '  ',doy,' ',iyr
	write(daystr,'(i2.2)') day
	write(mthstr,'(i2.2)') mth
	fileo = yrstr//mthstr//daystr//hrstr//'.' // st1
	iymd = 10000*iyr+100*mth+day
	print *, doy, iyr
	print *,'Yr',iyr,'; Mth',mth,'; Day ',day,'; ',daystr,' ',
     &      yrstr, '  ',iymd,'  hour ',ihr,'   ', yrstr//mthstr//daystr
	open(unit=14,file = '/home/tanjap/geomag/core/constants.'//stn)

c   Now we have date of data, look in constants file for last date before this
	read(14,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
c	write(*,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
	iymdc = 10000*iyc+100*imc+idc
	if(iymdc .gt. iymd) call exit
	iend = 0
	do while (iend .lt. 1) 	
	   read(14,*,end=140) idc,imc,iyc,xb2,ddeg2,dmin2,zb2,
     &                        xts2,xte2,zts2,zte2,fcor2,bfact2
c	   write(*,*) idc,imc,iyc,xb2,ddeg2,dmin2,zb2,xts2,xte2,
c     &			zts2,zte2,fcor2,bfact2
	   iymdc = 10000*iyc+100*imc+idc
	   if(iymdc .gt. iymd) goto 140
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
	end do
  140	continue
 	write(*,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
	print *, ' fcor = ',fcor
	mrad = 3437.747			! minutes/radian
!	
	write(*,*) 'Writing ', fileo
!	open(20,file= stc//'/' // fileo,access='append')
	open(20,file= stc//'/' // fileo)
	open(21,file= stc//'/' // yearday//'.'//ste,access='append')
	open(25,file= stc//'/' // 'test')
	open(32,file= stc//'/' // 'time')	! List time errors
	open(33,file= stc//'/' // 'volt')	! Voltage check, overwriting
	open(34,file= stc//'/' // 'benmore',access='append')	! Benmore Line check, overwriting
!     &           '    F    Sensor Elec. Benmore'
	write(21,*) 'Starting to Process ', yearday,' ',ihr
	open(10,file=filef)
	open(11,file=fileg)
        if ( stn .eq. 'eyr' ) open(12,file=fileb)	! Benmore correction
c   First read fge file, run through header
c   Read xbias, ybias,zbias,sensor,driver for now

	change = '      '
        call fluxgatecheck(stn,linef,xbias,ybias,zbias)
!	if(change .ne. '      ') print *, 'Change in ',change

!  In first version, short file will trigger rereading at end of UT day
!  In this version, output file will be full length, will need to check data
!
!	print *, xbias,' ',ybias,' ',zbias
!	print *, xcoil,' ',ycoil,' ',zcoil
!	print *, xres,' ',yres,' ',zres, step
!	print *, e0,' ',e1,' ',e2,' ',e3,' ',e4,' ',zoffset
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(2i5,1x,2f7.2,3f9.4,f11.3,f10.3,f11.3,f11.4)
	bsum = 0.0
	bsumsq = 0.0
	do i = 0,3599		! Fill array with null readings
	   do k = 3,10
	      ddata(i,k) = 99999.
	   end do ! for k
	   ddata(i,1) = 0.	! Temperature and Benmore etc null is 0
	   ddata(i,2) = 0.
	   ddata(i,9) = 0.
           if ( stn .eq. 'eyr' ) ddata(i,9) = 999.9
	   ddata(i,11) = 0.
	   ddata(i,12) = 0.
	end do    ! for i

!  If Eyrewell, read Benmore Correction File (BASALT .raw version)
        if ( stn .eq. 'eyr' ) then
 1200	format(27x,3(i2,1x),4x,f9.4)
	   do i = 0,3599		! For 1 hour of 1 sec readings
	      read(12,1200,end=160)bh,bm,bs,ben
	      write(40,*) bh,bm,bs, ben
	      if(abs(ben) .gt. 99.9) ben = 0.0	!  
	      j = bm*60+bs	
  	      if((j .eq. 0).and.(i .gt. 0)) goto 160		! in case blank line at end
 	      ddata(bm*60+bs,9) = ben/0.073
  160	      continue
	   end do
	   do i = 1,3599		! 
	      if(ddata(i,9) .gt. 999.0) ddata(i,9)=ddata(i-1,9)	! Interpolates missed data
	      if(ddata(0,9) .gt. 999.0) ddata(i,9)= 0.0		! In case no data read at all
	   end do
        end if

	do i = 0,3599		! For 1 hour of 1 sec readings
	   read(10,1000,end=100,err=111) ih,im,is,st,dt,xr,yr,zr,xc,
     &                               yc,zc,fc,ic
  111	   j = im*60+is	
	   if ((i .ne. j).or.(ih .ne. ihr)) write(32,*)" FGE Time ",
     &        "Problem ",ihr,ih,im,is, i, j
 	   write(30,3000) i,j,st,dt,xr,yr,zr,xc,yc,zc,ddata(j,9)
	   if(abs(xc) .gt. 1) then
	      if(abs(st) .gt. 99.9) st = 0.0	! Prevent running together 
	      if(abs(dt) .gt. 99.9) dt = 0.0	! of numbers in .sbc file
	      ddata(j,1) = st
	      ddata(j,2) = dt
              ddata(j,3) = xc	! these 3 lines not actually needed
	      ddata(j,4) = yc
	      ddata(j,5) = zc
c   Now processing raw data. 
c   Part I, basic sensitivity and offset
	      xcalc = xcoil*xr/xres + step * xcoil * xbias 
	      ycalc = ycoil*yr/yres + step * ycoil * ybias 
	      zcalc = -(zcoil*zr/zres + step * zcoil * zbias
     &            + zoffset)
              write(25,2400)ihr,im,is,xcalc,ycalc,zcalc,xc,yc,zc

c   The test file should show that xc == xcalc etc. 
c   xc is more accurate than xcalc, therefore use xc etc.

c   Following values are now altered using constants file
	      xcorr = xc + xb + xts*st + xte*dt
	      dminute = atan2(yc,xcorr)*mrad + ddeg*60 + dmin
	      hc = sqrt(xcorr*xcorr + yc*yc)
!	      ddata(j,6) = xc + xb + xts*st + xte*dt
	      ddata(j,6) = hc * cos(dminute/mrad)
	      ddata(j,7) = hc * sin(dminute/mrad)
!	      ddata(j,7) = atan2(yc,ddata(j,6))*mrad + ddeg*60 + dmin
	      ddata(j,8) = zc + zb + zts*st + zte*dt
	      ddata(j,8) = ddata(j,8) + bfact * ddata(j,9)	! Benmore Z correction
	      bsum = bsum + ddata(j,9)				! Make sure bfact=0 for SBA
	      bsumsq = bsumsq + ddata(j,9)*ddata(j,9)
 	   end if
 	end do 	! for i
	if(bfact .ge. 0.0001) then
	   bvar = (bsumsq - bsum*bsum/3600)/3599
	   write(34,3400) bvar,2000+iyr,mth,day,ihr,stn,bsum,bsumsq ! Benmore line status
 3400	   format(f10.6,i5,3i3,2x,a3,2f9.3)
 	end if
  100	continue
	write(21,*) "End of FGE"
c   Now read gsm file in same way
!	linef(1:2) = '  '
!	do while (linef(1:2) .ne. 'HH')
! 	   read(11, '(a10)',end=200) linef	! OK to process with no gsm file
c	   write(*,*) linef
!	end do
! 1100	format(3i3,f9.2,2i3,f6.1)
12100	format(a26,i3,2(1x,i2),6x,f9.2,4x,2i1)
 1100	format(a26,i3,2(1x,i2),6x,f7.0,4x,2i1)
	vav = 0.0
! Raw File format 28/9 HR, 31/2 MN, 34/5 Sec, 42 on reading * 100, 53 G, 54 Q
	do i = 0,3599		! assumes no extra readings, could change
!	   read(11,12100,end=200) ad,ih,im,is,f,g,q,v
	   read(11,1100,end=200) ad,ih,im,is,f
	   f = f/100.
	   write (41,12100) ad,ih,im,is,f,g,q
	   g = 9
	   q = 9
C	   if((g .lt. 8) .or. (q .lt. 8)) write(21,*) ih, im, is, 
C     &                                                    f, g, q, v
! 	   write(*,*) ih, im, is, f, g, q, v
	   j = im*60+is	
	   if (i .ne. j) write(32,*)" GSM Time Problem ",ihr,im,is,i,j
!   Check for data on line
	   if(f .gt. 1) then			! If f = 0, then will not correct it so never -ve
!   Constant of .931 based on effect of Z on F for 2006 Average values
	      ddata(j,10) = f - 0.931 * bfact * ddata(j,9) + fcor
	      ddata(j,11) = g
	      ddata(j,12) = q
	      vav = vav + v
!  Next lines compare Fs with Fcalc
!
	      if(ddata(j,10) .gt. 30000.) then
	         fcalc = sqrt(ddata(j,6)*ddata(j,6)+ddata(j,8)*
     &                         ddata(j,8)) 
!	         if(abs(ddata(j,10)-fcalc) .gt. ftol) write(21,*) 
!    &                   ih,im,is,ddata(j,10)-fcalc,g,q," Wrong Total"

	         if ((ddata(j,11).lt.1.1).or.(ddata(j,12) .lt. 5.1)) 
     &           write(21,*) ih,im,is,ddata(j,11),ddata(j,12),
     &           " Poor Proton"
	         if((abs(ddata(j,10)-fcalc) .gt. 2.0) .and.
     &             ((ddata(j,11).lt.3.1).or.(ddata(j,12) .lt. 5.1)))
     &           ddata(j,10) = 0.0
	      else
	            write(21,*) ih,im,is, "No GSM data"
	      end if
	   end if
	end do
  200	   continue
 2000   format(3i3,3f11.3,f10.2,3f7.2,f7.3)
 2001   format(3i3,3f11.3,f10.2,3f7.2)
 2400   format(3i3,2(f12.3,f9.3,f14.3))
!
! Next bit should be to remove spikes. Same threshold for fge & gsm
!
C  Look for spikes
C  First try, replace by median
   	do j = 6,8
 	   do i = 0,3599
c	      write(21,*) "XXX ",ihr,i,j,ddata(i,j)
 	      call fge_med(i,j,med)
c             A spike is defined by a data point being >5 above the median calculated for 12-sec chunks of data (in hour1w.f the threshold is 500 instead of 5)
 	      if (abs(ddata(i,j) - med) .gt. 5) then
               im = i/60
		 is = i - 60*im
		 write(21,2100) "FGE ",i,ihr,im,is,j,ddata(i,j),med
 	         ddata(i,j) = med
 	      end if
 	   end do
 	end do
 2100	format(a,5i4,2f12.2)
!   For GSM
 	   do i = 0,3599
c	      write(21,*) "XXX ",ihr,i,10,ddata(i,10)
 	      call gsm_med(i,med)
 	      if (abs(ddata(i,10) - med) .gt. 10) then
 	         im = i/60
		 is = i - 60*im
 	         write(21,2100)"GSM ",i,ihr,im,is,j,ddata(i,10),med
 	         ddata(i,10) = med
 	      end if
 	   end do
!
!
!
!  Includes Voltage Detector based on GSM data
!  Votage Dectector will trigger on short files
c  Now write out 1 second readings, whether or not there is data there
	do j = 0,3599
	   im = j/60 
	   is = j - 60*im 
!          if((j .eq. 0).and.(ihr .eq. 0)) then
           if (j .eq. 0) then
	      write(20,2000)ihr,im,is,ddata(j,6),ddata(j,7),ddata(j,8), 
     &           ddata(j,10),ddata(j,1),ddata(j,2),ddata(j,9),bfact	! stores bfact on line
	   else
	      write(20,2001)ihr,im,is,ddata(j,6),ddata(j,7),ddata(j,8), 
     &           ddata(j,10),ddata(j,1),ddata(j,2),ddata(j,9)
	   end if
	end do
	vav = vav/720.0
	nv = vav*100
	write(33,3300) nv,mth,day,ihr,stn
 3300	format(i5,3i3,2x,a3,2f9.3)
c	if(ihr .ge. 23) then
c	   write(*,*) 'Writing ', filen
c	   open(24,file= stc // '/' // filen)
c!	   write(24,*) 'HH    Eyrewell  ',yearday
c           write(24,*) 'HH',etext,yearday
c	   write(24,*) 'HH MM SS     H        D        Z    ',
c     &           '    F    Sensor Elec. Benmore'
c	   do j = 708,719
c	      im = j/12 
c	      is = 5*j - 60*im
c             write(24,2001)ihr,im,is,ddata(j,6),ddata(j,7),ddata(j,8),
c     &           ddata(j,10),ddata(j,1),ddata(j,2),ddata(j,9)
c	   end do
c	end if 
	end

!  Next subroutine checks for switch or unit changes

	subroutine fluxgatecheck(stn,linef,xbias,ybias,zbias)
	implicit none
	integer*2 isens,idrvr,isensor,idriver
	integer*2 xbias,ybias,zbias,xbiasv,ybiasv,zbiasv
	character*2 hexstr,xbhex,ybhex,zbhex
	character*3 stn
	character*6 change
	character*130 linef
	ybhex = '00'
	ybiasv = 00
	if(stn .eq.'eyr') then
	   xbhex = '8f'
	   xbiasv = 143
	   zbhex = '6f'
	   zbiasv = 111
 	   isens = 263
 	   idrvr = 308
	else
           xbhex = '4f'
	   xbiasv = 79
	   zbhex = 'c1'
	   zbiasv = 193
 	   isens = 257
 	   idrvr = 299
	end if

	linef(1:2) = '  '
	do while (linef(1:2) .ne. 'HH')
 	   read(10, '(a130)') linef
	   if(linef(1:5) .eq. 'xbias') then
		read(linef(9:10),'(a2)') hexstr
		if(hexstr .eq. xbhex) then
		   xbias = xbiasv
		else
		   change = ' xbias' 
		end if
	   end if
	   if(linef(1:5) .eq. 'ybias') then
		read(linef(9:10),'(a2)') hexstr
		if(hexstr .eq. ybhex) then
		   ybias = ybiasv
		else
		   change = ' ybias' 
		end if
	   end if
	   if(linef(1:5) .eq. 'zbias') then
		read(linef(9:10),'(a2)') hexstr
		if(hexstr .eq. zbhex) then
		   zbias = zbiasv
		else
		   change = ' zbias' 
		end if
	   end if
	   if(linef(1:6) .eq. 'sensor') then
		read(linef(8:10),'(i3)') isensor
                if(isensor .ne. isens) change = 'sensor' 
	   end if
	   if(linef(1:6) .eq. 'driver') then
		read(linef(8:10),'(i3)') idriver
                if(isensor .ne. idrvr) change = 'driver'
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

	subroutine fge_med(i,n,med)
!  This does median for fge components
!  Once this is running properly, look to remove ionosonde
	implicit none
	integer*2 i,j,k,n
	real*4 data(0:3599,1:12)
	real x(11), med	
C	common /a/ ddata	
	common /a/ data
c	write(21,*) 'Starting fge_med'	
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

	subroutine gsm_med(i,med)
!  This does median for gsm components
!  Main purpose is to remove zero values
!  Only GSM for 0,5,10 etc seconds, i.e. 0,5,10 elements
	implicit none
	integer*2 i,j,k,n
	real*4 data(0:3599,1:12)
	real x(11),med	
	common /a/ data

	n = 10			! F is in ddata(x,10)	
	if(i .lt. 5) then 
	   do j = 1,11 
	      x(j) = data(j-1,n)
	   end do
	else if (i .gt. 3594) then
	   do j = 1,11 
	      x(j) = data(3600-j,n)
	   end do
	else
	   do j = 1,11 
	      x(j) = data((i+j-6),n)
	   end do
	end if
	k = 11
	call sort(x,k)
!	write(31,*) (x(k), k=1,11)
	med = x(6)
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

