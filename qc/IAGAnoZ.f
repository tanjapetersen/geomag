	program IAGAnoXYZ
!   VERSION FOR Daily pmin.min files
c   This program reads Intermagnet daily files pmin files (e.g. eyr/eyr20121231pmin.min)
c   Note:- needs to be run from 1 level above ....pmin.min files (e.g run from /amp/magobs/eyr/)
c   Then writes a modified version into subdirectory new/ (e.g. into /amp/magobs/eyr/new/)
C   This variant writes "Bad Data" 99999.99 for XYZ components for time interval
c   Hardwired for 1 min data, i.e. 1440 readings/day
!   Call as IAGAnoXYZ eyr 12 12 31 1130 1240
!
	implicit none
	integer*2 hron, hroff, minon, minoff
	integer*4 i, ihr, iyr, mth, iday,idoy, j,k,q,ii,kdoy,kk(8),sk
	integer*4 ih, im 
	real*4 x,y,z,f
	character*2 hrstr,daystr,yrstr,monstr
	character*3 obs
	character*4 ton, toff
	character*6 fstr
	character*7 hstr,dstr,zstr
	character*23 fileo		! e.g. EYR05Jan.bin
	character*23 filei		! e.g. eyr20121231pmin.min
	character*70 line
	
c   Next few lines are to set up output file name and header
	
	call getarg(1,obs)		! e.g. sba
	if(obs .eq. '   ') then
	   print *,' Call IAGAnoXYZ eyr 12 12 31 1130 1240'
	   print *,' Being stn yr mth day tstart tstop'
	   call exit
	end if
	call getarg(2,yrstr)		
	call getarg(3,monstr)		
	call getarg(4,daystr)		
	call getarg(5,ton)		
	call getarg(6,toff)		
	read(ton(1:2),'(i2)') hron
	read(ton(3:4),'(i2)') minon
	read(toff(1:2),'(i2)') hroff
	read(toff(3:4),'(i2)') minoff
	filei = obs//'/'//obs//'20'//yrstr//monstr//daystr//'pmin.min'
	fileo = 'new/'//obs//'20'//yrstr//monstr//daystr//'pmin.min'
 	open(10,file=filei)	! Open Input File
 	open(20,file=fileo)	! Open Output File
	
!  Now start reading pmin.min file
!  HEADER READ HERE, line by line 
 
	line(1:1) = ' '
	do while (line(1:1) .ne. 'D')
	   read(10,'(a70)') line
	   write(20,'(a70)') line
	end do				! Input file now at start of data

	do ih = 0,23
	   do im = 0,59
	      read(10,'(a70)') line
	      if(ih*100+im .ge. hron*100+minon) then
	         if(ih*100+im .le. hroff*100+minoff) then
                   ! If you want to remove X&Y components:
                    ! line(33:40) = '99999.00'                   
                    ! line(43:50) = '99999.00'
                     line(52:60) = ' 99999.00'
                   ! Instead extrapolate the Z value:
                   ! line(52:58) = '-53582.'
                    ! line(63:70) = '99999.99'
		 end if
	      end if
	      write(20,'(a70)') line
	   end do
	end do


	end
