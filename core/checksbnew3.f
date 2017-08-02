	program checksbnew3
!   This program reads Scott Base daily data psec files, produced by
!   concatenation of hourly psec files and tries to get constants for 
!   Ionosonde cleaning by stacking the 30 secs before and after the exact 15 minutes.
!
!   Later it may be changed to calculate median
!   differences, so as to better exclude the effects of jumps
!   There are 96 15min in a day, so median of 96 values, assume less
!   than half are 99999.00
!
!   Call:  in /amp/magobs/sba/ do checksbnew3 sba 140706
!   It looks at files in sub-directory sba
!
!   Output: e.g. 140706.dps       plotting file (with PlotDay.csh) with each of the possible 96 Z ionosonde effects
!                140706.sym       correction file (based on iono.sym) based on the average deviation
!                                 over the day for each of the 30seconds before and after the exact 
!                                 15 minutes to use for that day
! 
	implicit none
	integer*4 i, ihr, iyr, mth, day, doy, j,k,n, idum, comment
	integer*4 ih, im, is 
        real*4 sumsq
	real*4 data(7),f30(3,0:30,96), l30(3,0:30,96)   ! cpt, sec, no of 15min
	real*4 SF(1:3,0:30), SL(1:3,0:30), SN(1:3,-30:30)
 	character*3 dir, stn, doys
	character*6 fstr,filen
	character*10 adate		! e.g. 2005-07-04
	character*12 fileo,filel	! 
	character*70 line

!   Next few lines are to set up output file name and header
	
	call getarg(1,stn) 	! abc Station Code
	call getarg(2,filen)		
	open(10,file= stn//'/'// stn // '20' // filen // 'psec.sec')
	open(16,file= 'iono/'// filen // '.sym')
	open(14,file= 'iono/iono.sym')
	open(15,file= 'iono/'// filen// '.dps')
 1000	format(3i3,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
 3000	format(3i3,1x,f10.3,2f11.3,f9.2,3f7.2)

!  Null sums
        do j = 1,3
           do k = 0,30
              SF(j,k) = 0.0
              SL(j,k) = 0.0
           end do ! for k
        end do ! for j
!

	comment = 1
!  First read comment lines and ignore them
	do while (comment .ne. 0)
	   read(10,'(a70)') line
	   if (line(:1) .ne. ' ') comment = 0
	end do
!  This should fail (comment = 0) on line starting with DATE,
!  The data should then immediately follow

!  Reading now simple free format read, one line per minute
!
	do i = 0,86399		! assumes no extra readings
	      read(10,'(a70)',end=100) line
	      read(line(31:40),'(f10.2)') data(1)
	      read(line(41:50),'(f10.2)') data(2)
	      read(line(51:60),'(f10.2)') data(3)
!   Are we approaching or leaving an exact 15 minutes?
	      k = i - (i/900)*900
              n = 1 + (i/900)
 	      if(k .le. 30) then                ! 0 to 30 secs after 15 min
                 do j = 1,3
	            f30(j,k,n) = data(j) 
                 end do    ! for j
	      end if
 	      if(k .ge. 869) then
                 do j = 1,3
!                   l30(j,0,n) is for k = 869, l30(j,30,n) for k =899           
	            l30(j,k-869,n) = data(j)    ! 31 to 1 sec before 15 min
                 end do    ! for j
	      end if
 	   end do	! for i
  100      continue
!
!  Now we have all relevent values, first cut is to get means (medians later)
!
	do j = 1,3      ! for 3 cpts
 	   do k = 0,30  ! for 31 secs
              do n = 1,96 ! all 96 15min sections
                 SF(j,k) = SF(j,k) + f30(j,k,n)
                 SL(j,k) = SL(j,k) + l30(j,k,n)
              end do ! for n
           end do ! for k
        end do ! for j
!  Next bit is to produce a file to plot Z sections about exact 15 mins
        do n = 1,96 ! all 96 15min sections
 	   do k = 0,30  ! for 31 secs
	      write(15,'(2i5,f8.2)')n,k,f30(3,k,n)-f30(3,30,n)   
           end do ! for k 
           write(15,'(2i5,f8.0)') n,30,-9900. 
           write(15,'(2i5,f8.0)') n+1,-30,-9900. 
 	   do k = 0,30  ! for 31 secs
	      write(15,'(2i5,f8.2)')n+1,k-30,l30(3,k,n)-l30(3,0,n)   
           end do ! for k
        end do ! for n

        do j = -30,30
           read(14,*) idum, SN(1,j) , SN(2,j), SN(3,j)
           if(j .ge. 0) then
              SN(1,j) = SN(1,j) + (SF(1,j) - SF(1,30))/96.
              SN(2,j) = SN(2,j) + (SF(2,j) - SF(2,30))/96.
              SN(3,j) = SN(3,j) + (SF(3,j) - SF(3,30))/96.
           else
              SN(1,j) = SN(1,j) + (SL(1,j+31) - SL(1,0))/96.
              SN(2,j) = SN(2,j) + (SL(2,j+31) - SL(2,0))/96.
              SN(3,j) = SN(3,j) + (SL(3,j+31) - SL(3,0))/96.
           end if
           write(16,'(i5,3f8.2)')idum,SN(1,j),SN(2,j),SN(3,j)
        end do  ! for j
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
