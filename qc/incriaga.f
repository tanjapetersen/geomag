	program incriaga
c
c  Program to make an arbitrary change to ALL 4 COMPONENTS 
c  in IAGA2002 files for a known time (or whole day) 
!  Change increases from zero at start to full at end
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)
c  5th is start time 0955, 6th is stop time
c  7th is delX, 8th is delY, 9th is delZ, 10th is delF 

 
	implicit none

	integer i, j, iday, ih, im, comment 
	integer*2 hron, hroff, minon, minoff
	real*4 x,y,z,f,delX,delY,delZ,delF, fraction
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
	fileout = stn//'20'//yr//mth//day//'pmin.min'
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

!  Reading now simple free format read, one line per minute
 1400	format(a30,4f10.2)
	do i = 0, 23
	   do j = 0, 59
	      fraction=(i*60+j-hron*60.-minon)/((hroff-hron)*60.+minoff-minon)
!	      read(4,1400) datetime, x, y, z, f
	      read(4,'(a70)') line
	      read(line(31:40),'(f10.2)') x
	      read(line(41:50),'(f10.2)') y
	      read(line(51:60),'(f10.2)') z
	      read(line(61:70),'(f10.2)') f
	         if((i*100+j).ge.hron*100+minon) then
	            if((i*100+j).lt.hroff*100+minoff) then
		       if(x.lt. 99990.) x = x + delX * fraction
		       if(y.lt. 99990.) y = y + delY * fraction
		       if(z.lt. 99990.) z = z + delZ * fraction
		       if(f.lt. 99990.) f = f + delF * fraction
		    end if
		 end if
	      write(14,1400) line(:30), x,y,z,f
           end do
	end do
      end
