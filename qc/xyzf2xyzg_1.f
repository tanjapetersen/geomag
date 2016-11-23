	program xyzf2xyzg
c
c  Program to make change Fs to Fv-Fs (G) 
c  in IAGA2002 second files for a whole day 
c  Reads from directory stn, writes to directory xyzg
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)

 
	implicit none

	integer i, j, k, iday, ih, im, comment,i999 
	real*4 x,y,z,f,fv,fs,df
	character*2 yr, mth, day
	character*3 stn
	character*4 ton,toff
	character*7 del
	character*19 fileout
	character*29 datetime
	character*70 line
	
	call getarg(1,stn)
	call getarg(2,yr)
	call getarg(3,mth)
	call getarg(4,day)
	fileout = stn//'20'//yr//mth//day//'dsec.sec'
	open(unit=4,file =  stn // '/'//fileout)
	open(unit=14,file =  'xyzg/'//fileout)

	comment = 1
!  First read comment lines and write them out
	do while (comment .ne. 0)
	   read(4,'(a70)') line
           if(line(2:14) .eq. 'Data Interval') line(25:42) = 
     &            '1-second          '
           if(line(25:28) .eq. 'XYZF') line(25:28) = 'XYZG'
           if(line(42:45) .eq. 'XYZF') line(42:45) = 'XYZG'
	   write(14,'(a70)') line
	   if (line(:1) .ne. ' ') comment = 0
	end do
!  This should fail (comment = 0) on line starting with DATE,
!  which will be copied. The data should then immediately follow

!  Reading now simple free format read, one line per minute
 1400	format(a30,6f10.2)
	do i = 0, 23
	   do j = 0, 59
	      do k = 0, 59
	         read(4,'(a70)') line
	         read(line(31:40),'(f10.2)') x
	         read(line(41:50),'(f10.2)') y
	         read(line(51:60),'(f10.2)') z
	         read(line(61:70),'(f10.2)') f
	         fv = 0
	         i999 = 0
	         if(x.lt. 99000.) then
		    fv = x * x 
	         else
		    i999 = 1
	         end if
	         if(y.lt. 99000.) then
		    fv =  fv + y * y 
	         else
		    i999 = 1
	         end if
	         if(z.lt. 99000.) then
		    fv = fv + z * z 
		    fv = sqrt(fv)
	         else
		    i999 = 1
	         end if
	         if(i999.le. 0) then
		    if( f .lt. 99000.) then
                       df = fv - f
                    else
                       df = 99999.99
                    end if  ! for f < 99000
	         else
                    x = 99999.99
                    y = 99999.99
                    z = 99999.99
                    df = 99999.99
                 end if  ! for i999 = 0
	         write(14,1400) line(:30),x, y, z, df
!	         write(14,1400) line(:30),x, y, z, f, df, fs-fv
              end do  ! for k
           end do  ! for j
	end do  ! for i
      end
