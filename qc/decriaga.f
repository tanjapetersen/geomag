	program decriaga
c
c  Program to make arbitrary changes to ALL 4 COMPONENTS 
c  in IAGA2002 files for a known time (or whole day) 
c  with the change decreasing with time (from a step change)
c  BOTH psec.sec & pmin.min files shifted
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)
c  5th is start time 0955, 6th is stop time
c  7th is delX, 8th is delY, 9th is delZ, 10th is delF 
c  
 
	implicit none

	integer i, j, k, iday, ih, im, comment 
	integer*2 hron, hroff, minon, minoff
	real*4 x,y,z,f, delX, delY, delZ, delF, frac 
	character*2 yr, mth, day
	character*3 stn
	character*4 ton,toff
	character*7 del
	character*19 fileout, sfileout
	character*29 datetime
	character*70 line
	
	if (iargc() .lt. 10) then
           print *, 'Call decriaga stn(a3) yr mth day(3*i2) start ', 
     &             'finish(2*hrmn)',' dx dy dz df(4*f)'
           stop
        end if
        call getarg(1,stn)
	call getarg(2,yr)
	call getarg(3,mth)
	call getarg(4,day)
	fileout = stn//'20'//yr//mth//day//'pmin.min'
	sfileout = stn//'20'//yr//mth//day//'psec.sec'
	open(unit=4,file =  stn // '/'//fileout)
	open(unit=14,file =  'new/'//fileout)
	call getarg(5,ton)
	call getarg(6,toff)
	read(ton(1:2),'(i2)') hron
	read(ton(3:4),'(i2)'), minon
	read(toff(1:2),'(i2)'), hroff
	read(toff(3:4),'(i2)'), minoff
	call getarg(7,del)
c	print *, del
	read(del,'(f8.0)') delX
	call getarg(8,del)
c	print *, del
	read(del,'(f8.0)'), delY
	call getarg(9,del)
c	print *, del
	read(del,'(f8.0)'), delZ
	call getarg(10,del)
c	print *, del
	read(del,'(f8.0)'), delF
	print *, hron, minon, hroff, minoff,delX,delY,delZ,delF

	comment = 1
!  First read comment lines and write them out
	do while (comment .ne. 0)
	   read(4,'(a70)') line
	   write(14,'(a70)') line
	   if (line(:1) .ne. ' ') comment = 0
	end do
!  This should fail (comment = 0) on line starting with DATE,
!  which will be copied. The data should then immediately follow
!  Reading minutes now simple free format read, one line per minute
 1400	format(a30,4f10.2)
	do i = 0, 23
	   do j = 0, 59
              frac = (hroff*60.+minoff-i*60.-j)/((hroff-hron)*60.+minoff
     &                -minon)
!	      read(4,1400) datetime, x, y, z, f
	      read(4,'(a70)') line
	      read(line(31:40),'(f10.2)') x
	      read(line(41:50),'(f10.2)') y
	      read(line(51:60),'(f10.2)') z
	      read(line(61:70),'(f10.2)') f
	         if((i*100+j).ge.hron*100+minon) then
	            if((i*100+j).lt.hroff*100+minoff) then
		       if(x.lt. 99000.) then
			  x = x + delX * frac
		       else
			  x = 99999.
		       end if
		       if(y.lt. 99000.) then
			  y = y + delY * frac
		       else
			  y = 99999.
		       end if
		       if(z.lt. 99000.) then
			  z = z + delZ * frac
		       else
			  z = 99999.
		       end if
		       if(f.lt. 99000.) then
			  f = f + delF * frac
		       else
			  f = 99999.
		       end if
		    end if
		 end if
	      write(14,1400) line(:30), x,y,z,f
           end do
	end do
        close(4)
        close(14)
!  Open seconds input and output files
	open(unit=5,file =  stn // '/'//sfileout)
	open(unit=15,file =  'new/'//sfileout)
!  Now read comment lines on second file and write them out
	comment = 1
	do while (comment .ne. 0)
	   read(5,'(a70)') line
	   write(15,'(a70)') line
	   if (line(:1) .ne. ' ') comment = 0
	end do

!  Reading seconds now simple free format read, one line per second
	do i = 0, 23
	   do j = 0, 59
              frac = (hroff*60.+minoff-i*60.-j)/((hroff-hron)*60.+minoff
     &                -minon)
	      do k = 0, 59
	         read(5,'(a70)') line
	         read(line(31:40),'(f10.2)') x
	         read(line(41:50),'(f10.2)') y
	         read(line(51:60),'(f10.2)') z
	         read(line(61:70),'(f10.2)') f
	         if((i*100+j).ge.hron*100+minon) then
	            if((i*100+j).lt.hroff*100+minoff) then
		       if(x.lt. 99000.) then
			  x = x + delX * frac
		       else
			  x = 99999.
		       end if
		       if(y.lt. 99000.) then
			  y = y + delY * frac
		       else
			  y = 99999.
		       end if
		       if(z.lt. 99000.) then
			  z = z + delZ * frac
		       else
			  z = 99999.
		       end if
		       if(f.lt. 99000.) then
			  f = f + delF * frac
		       else
			  f = 99999.
		       end if
		    end if
		 end if
	         write(15,1400) line(:30), x,y,z,f
              end do
           end do
	end do
      end
