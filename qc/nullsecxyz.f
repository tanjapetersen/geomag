	program nullsecxyz
c
c  Program to null part of an iaga SECOND file where null is 99999.99
c  trying just x,y, z, i.e. fluxgate problems 
c  Reads from directory stn, writes to directory new
c  1st arg stn, 2nd yr, 3rd mth, 4th day (all 2-digit)
c  5th hhmmss (time null on), 6th hhmmss (time null off)

 
	implicit none

	integer i, j, k, iday, ih, im, comment,i999 
        integer hron, hroff, minon, minoff, secon, secoff
        integer*4 t, ton, toff
	real*4 x,y,z,f,fv,fs,df
	character*2 yr, mth, day,ahon,ahoff,amon,amoff,ason,asoff
	character*3 stn
	character*6 nullon, nulloff
	character*19 fileout
	character*29 datetime
	character*70 line
	
	call getarg(1,stn)
	call getarg(2,yr)
	call getarg(3,mth)
	call getarg(4,day)
	call getarg(5,nullon)
	call getarg(6,nulloff)
	read(nullon(1:2),'(i2)') hron
	read(nullon(3:4),'(i2)'), minon
	read(nullon(5:6),'(i2)'), secon
	read(nulloff(1:2),'(i2)'), hroff
	read(nulloff(3:4),'(i2)'), minoff
	read(nulloff(5:6),'(i2)'), secoff
	fileout = stn//'20'//yr//mth//day//'dsec.sec'
	open(unit=4,file =  stn // '/'//fileout)
	open(unit=14,file =  'new/'//fileout)

        ton = 3600 * hron + 60*minon + secon ! seconds at which null starts
        toff = 3600 * hroff + 60*minoff + secoff ! seconds at which null ends
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
 1400	format(a30,6f10.2)
	do i = 0, 23
	   do j = 0, 59
	      do k = 0, 59
                 t = 3600 * i + 60 * j + k
!	      read(4,1400) datetime, x, y, z, f
	         read(4,'(a70)') line
	         read(line(31:40),'(f10.2)') x
	         read(line(41:50),'(f10.2)') y
	         read(line(51:60),'(f10.2)') z
	         read(line(61:70),'(f10.2)') f
		 if((t.ge.ton).and.(t.lt.toff)) then
                    x = 99999.99
		    y = 99999.99
		    z = 99999.99
                 end if
	         write(14,1400) line(:30),x, y, z, f
!	      write(14,1400) line(:30),x, y, z, f, df, fs-fv
              end do
           end do
	end do
      end
