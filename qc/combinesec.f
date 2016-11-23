	program combinesec
c
c  Program based on doadjust & adjustsec
c  Combines hourly IAGA2002 psec files with removal of headers
c  to produce psec files 
c  
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd year (2-digit), 3rd first doy, 4th last doy 
c  
c  Note: Call combinesec sba 14 002 009, where the 3rd and 4th parameters are first and last day of year.
c  It reads hourly psec files in sub-directory sba, and writes a daily psec file in sub-directory new.
c  If there are missing files, you need to use IAGAnull.csh to produce a nulled daily psec file. 
c  This is very slow. If there are missing files at the start of the day, you either need to produce 
c  the missing hourly psec files manually, or do the combining manually.
c
	implicit none

	integer i, j, k, ihr, iyr, idoy, imth, iday, fd, ld, comment 
	real*4 x,y,z,f,d,h,delD,delH,delZ,delF
	character*2 yr, mth, day, hr
	character*3 stn,fdoy,ldoy
	character*4 year
	character*11 splfile
	character*23 filein
	character*19 fileout
	character*29 datetime
	character*70 line
	
	if(iargc() .lt. 1) then
	   print *,'Call combinesec stn yyyy {doys doyf}'
	   call exit
	end if
	call getarg(1,stn)
	call getarg(2,yr)
	year = '20'//yr
	read(year,'(i4)') iyr
	if(iargc() .lt. 3) then
	   fdoy = '001'
	   ldoy = '366'
	else
	   call getarg(3,fdoy)
	   call getarg(4,ldoy)
	end if
	read(fdoy,'(i3)') fd
	read(ldoy,'(i3)') ld
	do k = 1, 366
	   if((k .ge. fd) .and. (k .le. ld)) then
	      call dayofyear(iyr,(k),imth,iday,-1)
              print *,k,' ', imth,' ',iday
              write(mth,'(i2.2)') imth
	      write(day,'(i2.2)') iday
	      fileout = stn//year//mth//day//'psec.sec'
	      open(unit=14,file =  'new/'//fileout)
!	Now process each hourly file
              do ihr = 0, 23
                 write(hr,'(i2.2)') ihr
!                print *, ' date is ',mth,' ',day,', hr is ',hr
	         filein = stn//year//mth//day//hr//'00psec.sec'
	         open(unit=4,file =  stn//'/'//filein)
              
	         comment = 1
!  First read comment lines but only write them out if ihr = 0
	      do while (comment .ne. 0)
	         read(4,'(a70)') line
		 if(line(2:10) .eq. 'Data Type') line(25:36) = 'Definitive  '
	         if(ihr .eq. 0) write(14,'(a70)') line
	         if (line(:1) .ne. ' ') comment = 0
	      end do
!  This should fail (comment = 0) on line starting with DATE,
!  which will be copied. The data should then immediately follow

!  Reading now simple free format read, one line per minute
 1400	format(a30,4f10.2)
!	      do i = 0, 23
	         do j = 0, 3599
!	            read(4,1400) datetime, x, y, z, f
	            read(4,'(a70)') line
!	            read(line(31:40),'(f10.2)') x
!	            read(line(41:50),'(f10.2)') y
!	            read(line(51:60),'(f10.2)') z
!	            read(line(61:70),'(f10.2)') f
!	            write(14,1400) line(:30), x,y,z,f
	            write(14,'(a70)') line
                 end do		!  for j
              end do  !  for ihr
!	      end do		!  for i
	   end if
	end do
  100   end

 
	subroutine dayofyear(yr,doy,mth,day,j)
	integer i, j, yr, mth, day, doy, dimth(12)
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
	   mth = 1
	   do while(doy .GT. 0)
	      doy = doy - dimth(mth)
	      mth = mth + 1
	   end do
	   mth = mth - 1
	   day = doy + dimth(mth)
	end if
	end 



