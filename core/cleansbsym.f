	program cleansbsym
!   This program reads Scott Base .sb1 hourly data files, and makes
!   adjustments to compensate for the Ionosonde, which now runs at 
!   exactly every 15 minutes  
!
!   The corrections are read of the file iono.sym (in /amp/magsob/sba/),
!   (for -30 to 30 seconds) so no need for a delay term  
!   REMEMBER: - The corrections are subtracted
! 
!   S(1:3,-30:30) contains adjustments to x, y and z for 30 seconds
!   each side of the exact 15 minutes 
!
!
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is, idum 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(0:3599,1:7)
	real*8 S(1:3,-30:30), MC(1:4)	
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

	open(14,file= "iono.sym")       ! Corrections input file located in /amp/magobs/sba/
 
!   Next few lines are to set up output file name and header
	
	call getarg(1,stn) 	! abc Station Code
	stc  = stn(1:2) // 'c'
	stnt = stn(1:2) // 't'
	stnx = stn(1:2) // 'x'
	call getarg(2,filen)		
	open(10,file= stc//'/'// filen)
        filel = filen(1:11)//'2'		! Output file is .sb2
	open(11,file= stc//'/'// filel)
!
	do i = -30,30
	   read(14,*) idum, S(1,i), S(2,i), S(3,i)	! idum to be -30..30
	end do				 
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(3i3,1x,f10.3,2f11.3,f9.2,3f7.2)

!             lines 0:3599 are current hour


	do i = 0,3599		! assumes no extra readings
	   read(10,*,end=100) ih,im,is,data(i,1),data(i,2),
     &     data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
	   k = i - (i/900)*900	
 	   if(k .le. 30) then  ! 0 to 30 secs after exact 15 min
	      do j = 1,3
	         data(i,j) = data(i,j) - S(j,k)
	      end do
	   end if
 	   if(k .ge. 870) then  ! -30 to -1 secs, i.e. before exact 15 min
	      do j = 1,3
	         data(i,j) = data(i,j) - S(j,k-900)
	      end do
	   end if
	   write(11,3000) ih,im,is,data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
 	end do
  100   continue
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
