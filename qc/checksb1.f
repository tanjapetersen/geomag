	program checksb1
!   This program reads Scott Base .sbd daily data files, produced by
!   concatenation of hourly .sb1 files (e.g. in sbc/ cat 140706*.sb1 > 140706.sbd) 
!   and tries to get constants for Ionosonde cleaning by stacking the 
!   minute of data after the exact 15 minutes.
!
!   S(1:3,0:60) contains average deviations of x, y and z for 60 seconds from
!   the exact 15 minutes 
!
!   Call:  in /amp/magobs/sba/ do checksb1 sba 140706
!
!   Output: e.g. 140706.sbv
! 
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(0:3599,1:7)
	real*8 S(1:3,0:60), MC(1:4)	
	real*4 mdata(0:1439,1:4),tdata(0:1439,1:3),tmpd,tmph
	real*4 ddeg,dmin,xbias,zbias,xts,xte,zts,zte,fcalc,fcorr 
	real*4 ddeg2, dmin2, xbias2, zbias2, xts2, xte2, zts2, zte2 
	character*2 hrstr,daystr,mthstr,yrstr
 	character*3 dir, stc, stn, std, stv, doys
	character*6 fstr,filen
	character*7 hstr,dstr,zstr
	character*10 adate		! e.g. 2005-07-04
	character*12 fileo,filel	! 
	character*34 filef, fileg
	character*36 mcodes, UMCODES
	character*62 line
	character*110 linef,lineo(744)

!   Next few lines are to set up output file name and header
	
	call getarg(1,stn) 	! abc Station Code
	stc  = stn(1:2) // 'c'
	std  = stn(1:2) // 'd'
	stv  = stn(1:2) // 'v'
	call getarg(2,filen)		
	open(10,file= stc//'/'// filen // '.' // std)
	open(11,file= stc//'/'// filen // '.' // stv)
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(3i3,1x,f10.3,2f11.3,f9.2,3f7.2)

!   Null all S values
	do i = 1,3
	   do j = 0,60
	      S(i,j) = 0
	   end do
	end do
!          lines 0:3599 are current hour

	do ihr = 0,23
	   do i = 0,3599		! assumes no extra readings
	      read(10,*,end=100) ih,im,is,data(i,1),data(i,2),
     &        data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
!   On every 15 minutes (k passes 0 at 15 minutes) sum values up for the next 60 seconds
	      k = i - (i/900)*900

             ! This is for the normal version (ionosonde starts at axcactly on the minute):
 	     ! if(k .le. 60) then
             ! This is for when ionosonde starts 20 seconds too early:
              if((k .ge. 840).and.(k .le. 900)) then  

              do j = 1,3

	     ! This is for the normal version(ionosonde starts at axcactly on the minute):        
	     !       S(j,k) = S(j,k) + data(i,j) 
             !  This is for when ionosonde starts 20 seconds too early:
                     S(j,k-840) = S(j,k-840) + data(i,j) 

              end do
	      end if
 	   end do	! for i
	end do		! for ihr
  100   continue
	do i = 1,3

 ! This is for the normal version(ionosonde starts at axcactly on the minute):     
 !	   do j = 0,20
 !	      write(11,*) i,j,(S(i,j)-S(i,0))/96.
 !  This is for when ionosonde starts 20 seconds too early (take the 30 seconds before the excact minute):
	   do j = 30,60
	      write(11,*) i,j,(S(i,j)-S(i,30))/96.
	  

          end do
	end do
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
