	program absnew
!   
!   This program is the latest version which compares the corrected (i.e. Quasi-Definitive)
!   IAGA-2002 files with the absolute readings as read from a list.stn file 
!   Currently does not take proper account of Benmore Correction for Z and F
!   MUST RUN in directory above new/*pmin.min
!   Compares D line with D from X and Y, also compares I with I from X, Y, and Z, then F compared to Fscalar
c    
!   1st parameter in this version is 3-character station, 2nd is year (4-digit)
!   (Alternative version reads list.xyz file with day at start) 

 	implicit none
	integer*4 ista,ifin,ib,if,dn,fn,xn,zn
	integer*4 i,j,k,iyear,mth,day,doy,idoy,n,hr1,hr2,mn1,mn2,ih1,ih2
	integer*4 in,cdeg,ddeg,ideg
	real*4 xv(0:1439),yv(0:1439),zv(0:1439),fv(0:1439),x,y,z,fb,fe,inc,dec
	real*4 pi,cmin,ff(1:1000), fqr, fdiff, fabs, fbeg,fend
	character*1 acpt,comma
	character*2 yr,hr,amth,aday,yrp,mthp,dayp,hrp
	character*3 stn,adoy
	character*4 hrmn, year		
	character*6 yrmtdy,dummy6,ddp,dfp,dxp		
	character*19 newfile
	character*66 line
	character*70 lineiaga
!	common /a/ data	
c   Next few lines are to set up output file name and header
	
	pi = 3.1415926535
!	call date_and_time(nowdate)
	call getarg(1,stn)
	if(stn .eq. '   ') then
	   print *,' Call as   "absnew sta " '
	   call exit
	end if
	call getarg(2,year)
	open(8,file='list'//year(3:4)//'.'//stn)
	open(25,file='d'//stn//year(3:4)//'n.csv')
	open(26,file='i'//stn//year(3:4)//'n.csv')
	open(28,file='f'//stn//year(3:4)//'n.csv')
	yrp = '00'		! Make sure of mismatch in first line read
!
	comma = ','
 	do n = 1,1000		! Reading loop for lines of data in list.stn
	   read(8,'(a66)') line
	   yr = line(1:2)
	   amth = line(3:4)
	   aday = line(5:6)
!	   read(line,*) dummy6,hrmn
!	   hr = hrmn(1:2)
!   If day changes, open and read new IAGA-2002 file
	   if((yr.ne.yrp).or.(amth.ne.mthp).or.(aday.ne.dayp)) then
	      newfile = stn//'20'//yr//amth//aday//'pmin.min'
	      print *, newfile
	      open(10,file='new/'//newfile)
	      yrp = yr
	      mthp = amth
	      dayp = aday
	      lineiaga(1:1) = ' '
	      do while (lineiaga(1:1) .ne. 'D')
	         read(10,'(a70)') lineiaga
	      end do			! Input file now at start of data
!   Read x,y,z,f into elements 0-1439 of arrays
 1400	format(a30,4f10.2)
 2500	format(a11,f10.3,a1,i6,3f10.3)
	      do i = 0,23
		 do j = 0,59
		    k = 60 * i + j 
		    read(10,'(30x,4f10.2)') xv(k),yv(k),zv(k),fv(k)
!		    write(40,*) xv(k),yv(k),zv(k),fv(k)
	         end do
	      end do
	   end if

!   Now reread line, first reading acpt to see what component the line is for

	   read (line,*), dummy6, ista , ifin, acpt
	   hr1 = ista/100
	   hr2 = ifin/100
	   mn1 = ista-100*hr1
	   mn2 = ifin-100*hr2
	   ib = hr1*60 + mn1
	   if = hr2*60 + mn2
!	   write(14,1401) dummy6,ista, ifin, acpt
!   F for Total Field
	   if((acpt .eq. 'F').or.(acpt .eq. 'f')) then
	      read (line,*), dummy6, ista , ifin, acpt, fbeg, fend
	      print *, ista , ifin, '  ', acpt, fbeg, fend
!	      write(14,1401) dummy6,ista, ifin, acpt, fbeg, fend
	      write(28,2500)aday//'/'//amth//'/20'//yr//',',fbeg-fv(ib),comma,
     & ista,fbeg,fv(ib),sqrt(xv(ib)*xv(ib)+yv(ib)*yv(ib)+zv(ib)*zv(ib))
	      write(28,2500)aday//'/'//amth//'/20'//yr//',',fend-fv(if),comma,
     & ifin,fend,fv(ib),sqrt(xv(ib)*xv(ib)+yv(ib)*yv(ib)+zv(ib)*zv(ib))
	   else
	      fabs = 0.0
!   I for Inclination
	      if((acpt .eq. 'I').or.(acpt .eq. 'i')) then
	         read (line,*), dummy6, ista , ifin, acpt, cdeg, cmin, fabs	! fabs only used on I line
	         print *, ista , ifin, '  ', acpt, cdeg, cmin, fabs	! fabs only used on I line
! Inclination entered as positive, but actually negative
	         inc = 60 * 180/pi * atan2(zv(if),sqrt(xv(if)*xv(if)+yv(if)*yv(if)))
!		 print *, 'inc = ',inc
		 write(26,2500) aday//'/'//amth//'/20'//yr//',', -cdeg *60 - cmin - inc,
     &                          comma,ista,-cdeg*60.-cmin,inc
	      else
!   D for Declination
	         read (line,*), dummy6, ista , ifin, acpt, cdeg, cmin	! fabs only used on I line
	         print *, ista , ifin, '  ', acpt, cdeg, cmin	
	         dec = 60 * 180/pi * atan2(yv(if),xv(if))
		 write(25,2500) aday//'/'//amth//'/20'//yr//',', cdeg *60 + cmin - dec,
     &                          comma,ista,cdeg*60+cmin,dec
	      end if							! for I
	      write(14,1402) dummy6,ista, ifin, acpt, cdeg, cmin
	   end if							! for F
 1401	format(a6,2i6.4,2x,a1,2f8.1)
 1402	format(a6,2i6.4,2x,a1,i4,f8.2)
!   Convert ista,ifin from hhmm to minutes
!	   ista = hr1*60+mn1	
!	   ifin = hr2*60+mn2	
	end do			! for n loop for list, was j loop for interactive
	end

