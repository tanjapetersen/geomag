	program rerunsb4
!   This program reads Scott Base .sbn daily data files, produced by
!   concatenation of hourly .sb4 files (a copy of the original .sb1 file; 
!   e.g. in sbc/ cat 140706*.sb4>140706.sbn) and tries to get constants 
!   for Ionosonde cleaning by stacking the minute of data around the exact 
!   15 minutes. The correction file (e.g. 140706.ion located in sbc/) is 
!   then applied to the corresponding .sbn file (e.g. 140706.sbn).
!
!   S(1:3,0:60) contains average deviations of x, y and z for 60 seconds around
!   the exact 15 minutes 
!
!   Call:  in /amp/magobs/sba/ do rerunsb4 sba 140706
!
!   Output: e.g. 140706.sbw in /amp/magobs/sba/sbc/
!   Auxiliary Outputs 140706.ion, iono.txt
! 
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,g,q,iend
	integer*4 ih, im, is 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc
	real*4 ST, DT, XR, YR, ZR, XC, YC, ZC, FC, IC, Ben, f, v, mrad
	real*4 data(0:3599,1:7)
	real*8 S(1:3,0:60), MC(1:4), zd(0:30)	
	real*4 mdata(0:1439,1:4),tdata(0:1439,1:3),tmpd,tmph 
        real*4 sumsq(1:3)
	real*4 ddeg,dmin,xbias,zbias,xts,xte,zts,zte,fcalc,fcorr 
	real*4 ddeg2, dmin2, xbias2, zbias2, xts2, xte2, zts2, zte2 
	character*2 hrstr,daystr,mthstr,yrstr
 	character*3 dir, stc, stn, std, stnn, stw, doys
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
	stnn  = stn(1:2) // 'n'
	stw  = stn(1:2) // 'w'
	call getarg(2,filen)		
	open(10,file= stc//'/'// filen // '.' // stnn)
	open(11,file= stc//'/'// filen // '.' // stw)
	open(12,file= stc//'/'// filen // '.ion')
	open(13,file= stc//'/iono.txt', access='append')
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

              ! Allow for ionosonde starting away from the exact minute):
 	      if(k .le. 30) then
                 do j = 1,3
	            S(j,k+30) = S(j,k+30) + data(i,j) 
                 end do    ! for j
	      end if
              if((k .ge. 870).and.(k .lt. 900)) then  
                 do j = 1,3
	            S(j,k-870) = S(j,k-870) + data(i,j) 
                 end do    ! for j
	      end if
 	   end do	! for i
	end do		! for ihr
  100   continue
	do i = 1,3
           sumsq(i) = 0.0
 	   do j = 0,60
!	      write(11,*) i,j,(S(i,j)-S(i,0))/96.
              sumsq(i) = sumsq(i) + (S(i,j)-S(i,0))*(S(i,j)-S(i,0))/96.0  
          end do ! for j
	end do   ! for i

!  Now look at RMS average deviation from initial value
        do j = 0,60
	   write(12,'(i5,3f8.2)') j,(S(1,j)-S(1,0))/96., (S(2,j)-S(2,0))/96.,
     &		       (S(3,j)-S(3,0))/96.
	end do   ! for j
	write(13,'(a6,3f9.2)') filen,sqrt(sumsq(1))/31.,sqrt(sumsq(2))/31.,sqrt(sumsq(3))/31.
!  Now apply corrections to get 1-second .sbw file
        rewind (unit = 10)
	do ihr = 0,23
	   do i = 0,3599		! assumes no extra readings
	      read(10,*,end=100) ih,im,is,data(i,1),data(i,2),
     &        data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
!   iFor 1 minute about every 15 minutes make correction
	      k = i - (i/900)*900

              ! Allow for ionosonde starting away from the exact minute):
        ! k .le. 30 is first 30 secs after exact 15 min, k .ge. 870 is
        ! last 30 secs before exact 15 min 
 	      if(k .le. 30) then
                 do j = 1,3
	            data(i,j) = data(i,j) - (S(j,k+30)-S(j,60))/96.  
                 end do    ! for j
	      end if
              if((k .ge. 870).and.(k .lt. 900)) then  
                 do j = 1,3
	            data(i,j) = data(i,j)-(S(j,k-870)-S(j,0))/96.  
                 end do    ! for j
	      end if
              im = i / 60
              is = i - 60 * im
	      write(11,'(3i3,3f11.3,f10.2,3f7.2)') ihr,im,is,data(i,1),
     &      data(i,2),data(i,3),data(i,4), data(i,5),data(i,6),data(i,7)
 	   end do	! for i
	end do		! for ihr
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
