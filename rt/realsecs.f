	program realsecs
c
c  Program to process some seconds of real-time data
c  Reads from directory ~hurst/rtdata/eyrin, writes ../eyrout
c  1st arg EYR, 2nd is 4-digit year, 3rd is mth, 4th is day, 
c  5th is day of year, 6th is hour, 7th is previous number of lines, 
c  8th is current number of lines 
c  Based on hour1aE.f
c  NOW USES case STATEMENT, COMPILE WITH F95
C  TEMPERATURE FILES NOT READ 
	implicit none

	integer*4 i, j, ileno, ilen, im, is , ival, start
	integer*4 iymd, iymdc
	integer*2 xbias,ybias,zbias,iyr,iyc,imc,idc,mth,ihr,day,iend

	real*4 x,y,z,f,t1,t2
	real*4 data(13,0:3600), ct, cx, cy, cz
	real*4 ddeg,dmin,mrad, xb,zb, xts,xte,zts,zte, fcalc,ftol 
	real*4 ddeg2, dmin2, xb2, zb2, xts2, xte2, zts2, zte2 
	real*4 xcoil,ycoil,zcoil,xres,yres,zres,hc,xcorr,dminute
	real*4 xcalc,ycalc,zcalc,step,scale,zoffset
	real*4 fcor,fcor2,bfact,bfact2

	character*2 yr, hrstr, daystr, mthstr, yrstr,amin,asec
	character*3 stn, doy
	character*4 year,leno,len
	character*23 iagadout
!	character*25 iagaout
        character*14 etext
        character*20 zfnull
	character*30 file1,file2
	character*80 line
        print *,'Fortran Start'
        mrad = 3437.747                 ! minutes/radian
        zfnull = '  99999.99  99999.99'
c  Approximate Q330 count to mV conversion
        ct = 0.000002384	
        cx = 0.000002384	
        cy = 0.000002384	
        cz = 0.000002384	
	call getarg(1,stn)
	call getarg(2,year)
	call getarg(3,mthstr)
	call getarg(4,daystr)
	call getarg(5,doy)
	call getarg(6,hrstr)
	call getarg(7,leno)
	call getarg(8,len)
        yrstr = year(3:4) 
        read(yrstr,'(i2)') iyr
        read(mthstr,'(i2)') mth
        read(daystr,'(i2)') day
        read(hrstr,'(i2)') ihr
        read(leno,'(i4)') ileno
        read(len,'(i4)') ilen
        print *, stn,' ',year,' ',doy,' ',mthstr,' ',daystr,' ',
     &  hrstr,' ',leno,' ',len
        print *,'Test 2a Out', ileno, ilen	
!  ileno & ilen are number of lines in file, 1st line is at 00:00
!  Next bit sets up sensor parameters for appropriate station, these
!  should not need to be changes at all
	select case (stn)
	   case('api') 
	      xcoil = 38386.
	      ycoil = 38543.
	      zcoil = 38329.
	      xres = 118.0
	      yres = 118.0
	      zres = 118.0
	      zoffset = 0.
	      step = 0.003922
	      ftol = 3.0
	      etext = '    Apia      '
           case('eyr') 
	      xbias = 143
	      ybias = 0
	      zbias = 109
              xcoil = 37683.
	      ycoil = 37968.
	      zcoil = 37618.
	      xres = 59.0
	      yres = 59.0
	      zres = 59.0
	      zoffset = 38000.
	      step = 0.003922
	      ftol = 3.0
	      etext = '    Eyrewell  '
	   case('sba')
	      xcoil = 38296.
	      ycoil = 38367.
	      zcoil = 38023.
	      xres = 29.5
	      yres = 29.5
	      zres = 29.5
	      zoffset = 38000.
	      step = 0.003922
	      ftol = 15.0
	      etext = '  Scott Base   '
	end select
        print *, etext	

!  Now look at constants.stn file in /tanjap/geomag/core directory
	iymd = 10000*iyr+100*mth+day
!	print *, doy, iyr
!	print *,'Yr',iyr,'; Mth',mth,'; Day ',day,'; ',daystr,' ',
!     &      yrstr, '  ',iymd,'  hour ',ihr,'   ', yrstr//mthstr//daystr
	open(unit=24,file = '/home/tanjap/geomag/core/constants.'//stn)
!	open(unit=24,file = '/home/hurst/rtprog/constants.'//stn) ! For testing

!   Now we have date of data, look in constants file for last date before this
!   Read first line of constants file
	read(24,*) idc,imc,iyc,xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor,bfact
	iymdc = 10000*iyc+100*imc+idc
	if(iymdc .gt. iymd) call exit
	iend = 0
	do while (iend .lt. 1)     ! read another line of constants file
	   read(24,*,end=140) idc,imc,iyc,xb2,ddeg2,dmin2,zb2,
     &                        xts2,xte2,zts2,zte2,fcor2,bfact2
	   iymdc = 10000*iyc+100*imc+idc
	   if(iymdc .gt. iymd) then     ! Leave loop
              iend = 1
           else                 ! Update constants
	      xb = xb2
	      ddeg = ddeg2
	      dmin = dmin2
	      zb = zb2
	      xts = xts2
	      xte = xte2
	      zts = zts2
	      zte = zte2
 	      fcor = fcor2
	      bfact = bfact2
           end if
	end do
  140	continue
!	write(*,*)'CONSTANTS ',xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor
!       print *, ' fcor = ',fcor,' ',bfact

        file1 = year//'.'//doy//'.'//hrstr//'.NZ_EYWM_50_LFX.csv'
        print *, file1
        open(unit=11,file=file1)
        do i = 0, ilen-1
           read(11,'(a80)') line
           if(i.eq.ileno) then  ! Get starting min and sec for filename  
              amin = line(15:16)
              asec = line(18:19)
           endif
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              start = index(line(1:52),'LFX')
! Make sure reading ival in right part of line
              read (line(start+4:start+12),*) ival
              data(1,i) = ival * cx
!  data(1,i) is xr, try and do xcalc
              data(4,i) = xcoil*data(1,i)/xres + step * xcoil * xbias
              if(i .ne.(60*im+is)) data(4,i) = 99999.99
!             print *,i,'  ',60*im+is,'  ',line(44:52),' ',ival
           endif
        enddo ! for i 
        file2 = year//'.'//doy//'.'//hrstr//'.NZ_EYWM_50_LFY.csv'
        print *, file2
        open(unit=12,file=file2)
        do i = 0, ilen-1
           read(12,'(a80)') line
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              start = index(line(1:52),'LFY')
! Make sure reading ival in right part of line
              read (line(start+4:start+12),*) ival
              data(2,i) = ival * cy
              data(5,i) = ycoil*data(2,i)/yres + step * ycoil * ybias
              if(i .ne.(60*im+is)) data(5,i) = 99999.99
!             print *,i,'  ',60*im+is,'  ',line(start + 4: start + 12),
!    &              ' ',ival, ' ',start
           endif
        enddo ! for i 
 1000   format(2i6,3f9.5,4f10.2)
 1040   format(i6,3f9.5,7f10.2)
!  Now have x & y
!	iagaout = stn//year//mthstr//daystr//hrstr//'psec.dat'
	iagadout = stn//year//mthstr//daystr//'psec.dat'
	open(unit=39,file = '/amp/magobs/eyr/rt/sec/'//iagadout,
     &  position = 'APPEND' )
        do i = ileno, ilen-1
!  Now convert X, Y & Z in sensor co-ordinates to geographic X, Y & Z    
           if((data(4,i) .lt. 90000.).and.(data(5,i) .lt. 90000.)) then
              data(4,i) = data(4,i) + xb   ! NO X TEMP CORR 
!             data(6,i) = data(6,i) + zb   ! NO TEMP CORR for now
!             if(data(9,i) .lt. 99998.) then
!                data(6,i) = data(6,i) + bfact * data(9,i)
!                data(10,i) = data(10,i) - 0.931 * bfact * data(9,i)
!             end if
              dminute = atan2(data(5,i),data(4,i))*mrad 
     &                  + ddeg*60. + dmin
              hc = sqrt(data(4,i)*data(4,i)+data(5,i)*data(5,i))
              data(7,i) = hc * cos(dminute/mrad)              
              data(8,i) = hc * sin(dminute/mrad)              
 1900   format(a4,2(a1,a2),i3.2,2(a1,i2.2)a5,a3,f13.2,f10.2,a20)
 3040   format(2i6,6f10.2)
!              write(19,1900) year,'-',mthstr,'-',daystr,ihr,':',
!     &       i/60,':',i-60*(i/60),'.000 ',doy,data(7,i),data(8,i),zfnull
              write(29,1900) year,'-',mthstr,'-',daystr,ihr,':',
     &       i/60,':',i-60*(i/60),'.000 ',doy,data(7,i),data(8,i),zfnull
              write(39,1900) year,'-',mthstr,'-',daystr,ihr,':',
     &       i/60,':',i-60*(i/60),'.000 ',doy,data(7,i),data(8,i),zfnull
           else
              data(7,i) = 99999.99
              data(8,i) = 99999.99
           endif
        enddo ! for i
        close(unit=19)
        print *, 'Fortran finished'
        end
