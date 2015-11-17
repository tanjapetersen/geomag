	program absx
!   
!   This program is a LIST version which compares the absolute field measurements
!   to the values found in the .eyx files, e.g. 130101.eyx 
!   This is used to calculate the instrumental constants 
!   MUST RUN in directory above stn/*.eyx., where stn is 3-letter station code
!   Now produces x, y and z files (d -> y, i -> x,z), also f comparison
!   Was absonel when reading .txt files
!   without TEMPERATURE COMPENSATION as that has already been done
!   Eyrewell version, DOES HANDLE Benmore correction for Z & F 
!   Benmore correction HARD-WIRED at 0.24 - Good for WEST MELTON ONLY. 
!   Currently does not handle 9999999 for no reading. Effect will generally be obvious, i.e. nan   
!   1st and only parameter in this version is 3-character station

 	implicit none
	integer*4 ista,ifin,dn,fn,hn,zn,eof
	integer*4 i,j,k,ixyz,year,mth,day,n,hr1,hr2,mn1,mn2,ih1,ih2
	integer*4 ih(0:1439), im(0:1439), in,ideg
	integer*4 cdeg
	real*4 data(0:1439,1:7),pi,dqr,iqr, cmin, ddiff, idiff,bfact
	real*4 rdum1,rdum2,rdum3,rdum4,rdum5,fabs,xd,zd,dav,fav,hav,zav
	real*4 av,fa,dd(1:1000),inav,ii(1:1000),dmin,imin	
	real*4 xx(1:1000),yy(1:1000),zz(1:1000),xqr,yqr,zqr,hdiff,zdiff,h
	real*4 ff(1:1000), fqr, fdiff, iabs, habs, zabs,fbeg,fend,hcomp,zcomp
	real*4 dlow,dmax,flow,fmax,hlow,hmax,zlow,zmax
	real*4 st(1:100),et(1:100),be(1:100),avd(1000),avf(1000),avx(1000),avz(1000)
	character*1 acpt
	character*2 yr,hr,amth,aday,yrp,mthp,dayp,hrp,st2
	character*3 stn
	character*4 hrmn		
	character*6 yrmtdy,dummy6,ddp,dfp,dxp		
	character*8 nowdate		
	character*10 fileday
	character*72 line
	common /a/ data	
c   Next few lines are to set up output file name and header. Reads list.stn file.
	
	bfact = 0.24		!	bfact HARD-WIRED HERE FOR NOW FOR WEST MELTON
	pi = 3.1415926535
	call date_and_time(nowdate)
	call getarg(1,stn)
	if(stn .eq. '   ') then
	   print *,' Call as   "absxw sta " '
	   call exit
	end if
	st2 = stn(1:2)
	open(8,file='list.'//stn)
	yr = '00'			! Make sure of mismatch in first line read

!   Initial set up for daily averages
	ddp = '000000'
	dfp = '000000'
	dxp = '000000'
!   Limits that define which values to keep and which to throw out
	dlow = -20.0
!	dmax = +20.0 ! was used before EYR re-location to West Melton
	dmax = +40.0
        flow = -50.0
	fmax = +80.0
	hlow = -100.0
	hmax = +100.0
	zlow = -100.0
	zmax = +100.0
 	do n = 1,1000			! Reading loop for lines of data in list.stn
	   read(8,'(a72)',iostat=eof) line
     	   print *,line(1:50),' EOF ',eof
	   if(eof .lt. 0) then
	      yr = '20'
	      amth = '00'
	      aday = '00'
	      hr = '00'
	   else
	      yr = line(1:2)
	      amth = line(3:4)
	      aday = line(5:6)
	   end if
	   read(line,*) dummy6,hrmn
	   write(14,*) '    ',yr,amth,aday,' ',hrmn,eof
	   hr = hrmn(1:2)
	   if((yr.eq.yrp).and.(amth.eq.mthp).and.(aday.eq.dayp).and.(hr.eq.hrp)) goto 5000
c   If same date & hour, jump to comparing with existing data, else continue here
!   Now do printout of all components as soon as change in date or hour
	   if(eof .lt. 0) write(28,2500) dfp(5:6)
     &                    //'/'//dfp(3:4)//'/20'//dfp(1:2)//',', fav/fn
	   if(eof .lt. 0) write(25,2500) ddp(5:6)
     &                    //'/'//ddp(3:4)//'/20'//ddp(1:2)//',', dav/dn
	   if(eof .lt. 0) then
	     write(37,3700) dxp(5:6)//'/'//dxp(3:4)//'/20'//dxp(1:2)//',', hav/hn
	     write(38,3700) dxp(5:6)//'/'//dxp(3:4)//'/20'//dxp(1:2)//',', zav/zn
	   end if

	   write(14,*) ' New ',yr,amth,aday,' ',hrmn,eof
  	   yrp = yr
	   mthp = amth
	   dayp = aday
	   hrp  = hr

	   read(amth,'(i2)') mth
	   read(aday,'(i2)') day
	   read(yr,'(i2)') year
	   year = year + 2000		! 2-digit to 4-digit year
	   yrmtdy(1:2) = yr
!	   open(14,file='list'//yr//'.'//stn,access='append') 
	   write(yrmtdy(3:4),'(i2.2)') mth
	   write(yrmtdy(5:6),'(i2.2)') day
	   fileday = yr//amth//aday//'.'//st2//'x'
	   print *,fileday
	
!  Set up files and parameters for stations here
	   close(10)
	   open(10,file = stn//'/'//fileday)
	   open(15,file='doutp'//yr//'.'//stn,access='append')! D Output file
	   open(25,file='d'//stn//yr//'.csv',access='append')! D .csv Output file
	   open(16,file='ioutp'//yr//'.'//stn,access='append')! I Output file
	   open(17,file='houtp'//yr//'.'//stn,access='append')! H  Output 
	   open(18,file='foutp'//yr//'.'//stn,access='append')! F Output file
	   open(28,file='f'//stn//yr//'.csv',access='append')! F .csv 
	   open(37,file='h'//stn//yr//'.csv',access='append')! H .csv 
	   open(38,file='z'//stn//yr//'.csv',access='append')! Z .csv 
 1033	   format(2i3,4f9.1,6f6.1)
 3000	   format(3i4,1x,2f7.2,3f9.4,f11.3,f10.3,2f11.3,f8.2,f9.4)
	   
 1000	format(11x,i2,x,i2,14x,4f10.2)	   
  140	   do i = 0,1439	! now 1 minute readings, ixyz is dummy for day
	      read(10,*,end=200)ixyz,ih(i),im(i),data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
	      data(i,3) = data(i,3) - bfact * data(i,7)
	      data(i,4) = data(i,4) + 0.931 * bfact * data(i,7)
 	      write(33,1033) ih(i),im(i),data(i,1),data(i,2),
     &            data(i,3),data(i,4),data(i,5),data(i,6),data(i,7)
 	   end do
  200	   ixyz = i
	   print *, i,' readings'
!
!  Components are X Y Z F in that order
! 
c  Look for spikes on F channel, ignore others
c  First try, replace by median
	   j = 4
	   do i = 0,1439
	      fa = av(i,j,ixyz)
	      if (abs(data(i,j) - fa) .gt. 50) then
	         write(21,1200) fileday,ih(i),im(i),i,j, data(i,j), fa
	         data(i,j) = fa
	      end if
	   end do
 1200      format(a10,3x,2i3,2i6,2f9.2)

 2000      format(3i3,4f9.1,4f6.1)
 2300      format(a4,2i4,4f9.1,4f6.1)

 5000	continue

c Ask for input times
	   read (line,*), dummy6, ista , ifin, acpt
!	   write(14,1401) dummy6,ista, ifin, acpt
	   if((acpt .eq. 'F').or.(acpt .eq. 'f')) then
	      read (line,*), dummy6, ista , ifin, acpt, fbeg, fend
!	      write(14,1401) dummy6,ista, ifin, acpt, fbeg, fend,'F'
	   else
	      fabs = 0.0
	      if((acpt .eq. 'I').or.(acpt .eq. 'i')) then
	         read (line,*), dummy6, ista , ifin, acpt, cdeg, cmin, fabs	! fabs only used on I line
!	         write(14,*) line, 'I' 
	      else
	         read (line,*), dummy6, ista , ifin, acpt, cdeg, cmin	! fabs only used on I line
	      end if
!	      write(14,1402) dummy6,ista, ifin, acpt, cdeg, cmin, fabs,'D'
	   end if
 1401	format(a6,2i6.4,2x,a1,2f8.1,1x,a1)
 1402	format(a6,2i6.4,2x,a1,i4,2f8.2,1x,a1)
	   hr1 = ista/100
	   hr2 = ifin/100
	   mn1 = ista-100*hr1
	   mn2 = ifin-100*hr2
	   print *, 'Start & Finish (hr min): ',hr1,' ',mn1,' : ',hr2,' ',mn2
	   ista = hr1*60+mn1			! was *720 & *12	
	   ifin = hr2*60+mn2			! was *720 & *12
	   if((ixyz .lt. ifin).or.(ista .lt. 0)) then
	      print *, 'Data not yet available'
!!	      exit
	   else
	      if(ifin-ista .gt. 99) then
		 print *,'Too long a period'
!!		 exit
	      else
c  Read relevent section of fluxgate data
		 do i = ista,ifin
		    xx(i+1-ista) = data(i,1)
		    yy(i+1-ista) = data(i,2)
		    zz(i+1-ista) = data(i,3)
		    ff(i+1-ista) = data(i,4)
		    st(i+1-ista) = data(i,5)
		    et(i+1-ista) = data(i,6)
		    be(i+1-ista) = data(i,7)
		    dd(i+1-ista) = atan2(data(i,2),data(i,1))
		    ii(i+1-ista) = atan2(data(i,3),sqrt(data(i,1)*data(i,1)+
     &                             data(i,2)*data(i,2)))
		 end do
c  
		    in = ifin+1-ista
		    call sort(xx,in)
		    call sort(yy,in)
		    call sort(zz,in)
! Don't sort ff	    call sort(ff,in)
		    call sort(dd,in)
		    call sort(ii,in)
		    call sort(st,in)
		    call sort(et,in)
		    call sort(be,in)
		    xqr = xx(aint(in*0.75)) - xx(aint(in*0.25))
		    yqr = yy(aint(in*0.75)) - yy(aint(in*0.25))
		    zqr = zz(aint(in*0.75)) - zz(aint(in*0.25))
!		    fqr = ff(aint(in*0.75)) - ff(aint(in*0.25))
		    dqr =(dd(aint(in*0.75))-dd(aint(in*0.25)))*180*60/pi
		    iqr =(ii(aint(in*0.75))-ii(aint(in*0.25)))*180*60/pi

c  For F, use first and last minutes

	            if((acpt .eq. 'F').or.(acpt .eq. 'f')) then
		       write(18,1800) yrmtdy,year,mth,day,fbeg-ff(1),
     &                            fbeg, ff(1),yrmtdy,nowdate 
C		       write(28,2500)aday//'/'//amth//'/20'//yr//',',fbeg-ff(1)
		       write(18,1800) yrmtdy,year,mth,day,fend -
     &                            ff(in),fend,ff(in),yrmtdy,nowdate 
		       if(yrmtdy .gt. dfp) then
			  if(dfp .gt. '000000') write(28,2500) dfp(5:6)
     &                    //'/'//dfp(3:4)//'/20'//dfp(1:2)//',', fav/fn
			  dfp = yrmtdy
			     fdiff = fbeg - ff(1)
			  if((fdiff.le.fmax).and.(fdiff.ge.flow)) then
			     fav = fdiff
			     fn = 1
			  else
			     fav = 0.0 
			     fn = 0
			  end if
			  fdiff = fend - ff(in)
			  if((fdiff.le.fmax).and.(fdiff.ge.flow)) then
			     fav = fav + fdiff
			     fn = fn + 1
			  end if
		       else
			  fdiff = fbeg - ff(1)
			  if((fdiff.le.fmax).and.(fdiff.ge.flow)) then
			     fav = fav + fdiff
			     fn = fn + 1
			  end if
			  fdiff = fend - ff(in)
			  if((fdiff.le.fmax).and.(fdiff.ge.flow)) then
			     fav = fav + fdiff
			     fn = fn + 1
			  end if
		       end if
C		       write(28,2500) aday//'/'//amth//'/20'//yr//',', fend - f2(31)
		    end if    
c  Use midpoint sorted values for all components except for F 
		    in = in/2			! midpoint of sorted values

c  Angle is y/x radians, convert to minutes
	            dmin = 180*60/pi*atan2(yy(in),xx(in)) 
	            if(dmin .lt. 0.) dmin = dmin + 180*60 
	            print *, 'X Y Z F ', xx(in),'  ',yy(in),
     &               '  ',zz(in),'  ',ff(in),'  nT.'
		    imin = -ii(in)*60*180/pi
!		    print *, 'Median values between',hr1,'hr',mn1,'m &'
!     &                 ,hr2,'hr',mn2,'m.' 
	            if((acpt .eq. 'D').or.(acpt .eq. 'd')) then
		       ddiff = cdeg*60. + cmin - dmin
		       write(15,1500) yrmtdy,year,mth,day, ddiff, 
     &                 cdeg*60+cmin,dmin,yrmtdy,nowdate
		       if(yrmtdy .gt. ddp) then
			  if(ddp .gt. '000000') write(25,2500) ddp(5:6)
     &                    //'/'//ddp(3:4)//'/20'//ddp(1:2)//',', dav/dn
			  ddp = yrmtdy
			  if((ddiff.le.dmax).and.(ddiff.ge.dlow)) then
			     dav = ddiff
			     dn = 1
			  else
			     dav = 0.0 
			     dn = 0
			  end if
		       else
			  if((ddiff.le.dmax).and.(ddiff.ge.dlow)) then
			     dav = dav + ddiff
			     dn = dn + 1
			  end if
		       end if
		    end if    
1500  format(a6,i6,2i4,f7.2,2f9.2,2x,2x,a6,2x,a8)
1700  format(a6,i6,2i4,f8.2,f8.2,4f10.2,2f6.1,2x,a6,2x,a8)
1800  format(a6,i6,2i4,f9.2,2f10.2,2x,a6,2x,a8)
2500  format(a11,f8.3)
3700  format(a11,5(f8.3,a1))
	            if((acpt .eq. 'I').or.(acpt .eq. 'i')) then
		       idiff = cdeg*60. + cmin - imin
		       iabs = (cdeg + cmin/60.0) * pi/180.
!     For SBA, read Fabs on I line
 		       habs = fabs  * cos(iabs) 
 		       zabs = -fabs * sin(iabs) 
		       h = sqrt(xx(in)*xx(in)+yy(in)*yy(in)) 		! H rather than X now
		       hdiff = habs - h 
		       zdiff = zabs - zz(in) 
		       write(16,1500) yrmtdy,year,mth,day, idiff, 
     &                 cdeg*60+cmin,  imin,yrmtdy,nowdate
		       write(17,1700) yrmtdy,year,mth,day,hdiff,
     &                 zdiff,habs,h,zabs, zz(in), st(in), et(in),
     &                 yrmtdy,nowdate
c  Now write X, Z NOT with Temperature Compensation
!		       hcomp = h + 0.2 * st(in)	! 0.2 is X Temp Coeff
!		       zcomp = zz(in) + 0.4 * st(in)	! 0.4 is Z Temp Coeff
		       hcomp = h + 0.0 * st(in)	! NO X Temp Coeff
		       zcomp = zz(in) + 0.0 * st(in)	! NO Z Temp Coeff
		       hdiff = habs - hcomp 
		       zdiff = zabs - zcomp 
!		       write(27,1700) yrmtdy,year,mth,day,hdiff,
!     &                 zdiff,habs,hcomp,zabs,zcomp, st(in), et(in),
!     &                 yrmtdy,nowdate
		       if(yrmtdy .gt. dxp) then
			  if(dxp .gt. '000000') then
			     write(37,3700) dxp(5:6)//'/'//dxp(3:4)//'/20'//
     &				dxp(1:2)//',', hav/hn
			     write(38,3700) dxp(5:6)//'/'//dxp(3:4)//'/20'//
     &				dxp(1:2)//',', zav/zn
			  end if
!			  write(47,*) dxp, xav, xn, zav, zn, xd, zd
			  dxp = yrmtdy
			  if((hdiff.le.hmax).and.(hdiff.ge.hlow)) then
			     hav = hdiff
			     hn = 1
			  else
			     hav = 0.0 
			     hn = 0
			  end if
			  if((zdiff.le.zmax).and.(zdiff.ge.zlow)) then
			     zav = zdiff
			     zn = 1
			  else
			     zav = 0.0 
			     zn = 0
			  end if
		       else
			  if((hdiff.le.hmax).and.(hdiff.ge.hlow)) then
			     hav = hav + hdiff
			     hn = hn + 1
			  end if
			  if((zdiff.le.zmax).and.(zdiff.ge.zlow)) then
			     zav = zav + zdiff
			     zn = zn + 1
			  end if
		       end if
		    end if 
		    print 9000, dmin, imin,dqr,iqr
	         end if
	      end if	
!	   end do
9000	   format( 'Declination is ',f8.2,
     &           ' min, Inclination is',f8.2,' min.',2f6.2) 
	   close(unit=10)
	if(eof .lt. 0) call exit
	end do			! for n loop for list, was j loop for interactive
	end


	real*4 function av(i,n,last)
	implicit none
	integer*4 i,j,k,n,last
	real*4 data(0:1439,1:7)
	real x(11)	
	common /a/ data
	
	if(i .lt. 5) then 
	   do j = 1,11 
	      x(j) = data(j,n)
	   end do
	else if (i .gt. last-5) then
	   do j = last-10,last 
	      x(j-last+11) = data(j,n)
	   end do
	else
	   do j = i-5,i+5 
	      x(j-i+6) = data(j,n)
	   end do
	end if
	k = 11
	call sort(x,k)
!	write(31,*) (x(k), k=1,11)
	av = x(6)
	end

      SUBROUTINE SORT (X, N)
C
C        ALGORITHM AS 304.8 APPL.STATIST. (1996), VOL.45, NO.3
C
C        Sorts the N values stored in array X in ascending order
C
      INTEGER*4 N
      REAL X(N)
C
      INTEGER I, J, INCR
      REAL TEMP
C
      INCR = 1
C
C        Loop : calculate the increment
C
   10 INCR = 3 * INCR + 1
      IF (INCR .LE. N) GOTO 10

C
C        Loop : Shell-Metzner sort
C
   20 INCR = INCR / 3
      I = INCR + 1
   30 IF (I .GT. N) GOTO 60
      TEMP = X(I)
      J = I
   40 IF (X(J - INCR) .LT. TEMP) GOTO 50
      X(J) = X(J - INCR)
      J = J - INCR
      IF (J .GT. INCR) GOTO 40
   50 X(J) = TEMP
      I = I + 1
      GOTO 30
   60 IF (INCR .GT. 1) GOTO 20
C
      RETURN
      END
C

