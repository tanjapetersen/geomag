	program raw2txt
!
c   Arguments are stn yyyy.doy hr, e.g. eyr 2009.356 11 
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
	real*4 med,bdummy(10)
	real*4 ddata(0:3599,1:12)	
	real*4 mdata(0:719,1:4)
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
	character*36 mcodes
	character*62 l
	character*130 linef,lineo(744)

	common /a/ ddata	
	
c   Next few lines are to set up output file name and header
	

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
	open(8,file=yearday//'.'//hrstr//'00.00.gsm-scottbase.raw')
	open(9,file=yearday//'.'//hrstr//'00.00.gsm-scottbase.txt')
	write(9,'(8a)') 'HH MM SS'
	do i = 1,4000
	   read(8,'(a62)',end=100) l 
   	   write(9,*) l(28:29),' ',l(31:32),' ',l(34:35),' ',l(42:46),'.',l(47:48),' ',l(53:53),' ',l(54:54)
	   write(*,*) l 
	end do
  100	continue

	end
