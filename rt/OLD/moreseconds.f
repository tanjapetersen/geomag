	program moreseconds
c
c  Program to process some seconds of real-time data
c  Reads from directory /amp/magobs/eyr/rt/in/, writes files directly 
c  into /amp/ftp/pub/geomagnetism/
c  1st arg EYR, 2nd is 2-digit year, 3rd is dayi of year, 4th is hour, 
c  5th is previous number of lines, 6th is current number of lines 
c  No temperature correction in this, does not need Temperature files
c  Based on hour1aE.f
c  NOW USES case STATEMENT, COMPILE WITH f95 
	implicit none

	integer*4 i, j, ileno, ilen, iday, im, is , ih, ival
	integer*4 iymd, iymdc
        integer*2 hron, hroff, minon, minoff
	integer*2 xbias,ybias,zbias,iyr,iyc,imc,idc,mth,ihr,day,iend

	real*4 x,y,z,f,t1,t2,ben,delX,delY,delZ,delF
	real*4 data(11,0:3600), cx, cy, cz
	real*4 ddeg,dmin,mrad, xb,zb, xts,xte,zts,zte, fcalc,ftol 
	real*4 ddeg2, dmin2, xb2, zb2, xts2, xte2, zts2, zte2 
	real*4 xcoil,ycoil,zcoil,xres,yres,zres,hc,xcorr,dminute
	real*4 xcalc,ycalc,zcalc,step,scale,zoffset
	real*4 fcor,fcor2,bfact,bfact2,bmax

	character*2 yr, hrstr, daystr, mthstr, yrstr
	character*3 stn, doy
	character*4 year,leno,len
	character*7 hstr,dstr,zstr,deli
        character*8 yearday
	character*15 fileout
        character*14 etext
	character*30 file1,file2,file3,file4,file5,file6
	character*80 line
        print *,'Fortran Start'
        mrad = 3437.747                 ! minutes/radian
c  Approximate Q330 count to mV conversion
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
	print *, doy, iyr
	print *,'Yr',iyr,'; Mth',mth,'; Day ',day,'; ',daystr,' ',
     &      yrstr, '  ',iymd,'  hour ',ihr,'   ', yrstr//mthstr//daystr
	open(unit=24,file = '/home/tanjap/geomag/core/constants.'//stn)

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
 	write(*,*)'CONSTANTS ',xb,ddeg,dmin,zb,xts,xte,zts,zte,fcor
	print *, ' fcor = ',fcor,' ',bfact

        file1 = year//'.'//doy//'.'//hrstr//'.NZ_EYWM_50_LFX.csv'
        print *, file1
        open(unit=11,file=file1)
        do i = 0, ilen-1
           read(11,'(a80)') line
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              read (line(44:52),*) ival
              data(1,i) = ival * cx
!  data(1,i) is xr, try and do xcalc
              data(4,i) = xcoil*data(1,i)/xres + step * xcoil * xbias
              if(i .ne.(60*im+is)) data(4,i) = 99999.99
        !     print *,i,'  ',60*im+is,'  ',line(44:52),' ',ival
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
              read (line(44:52),*) ival
              data(2,i) = ival * cy
              data(5,i) = ycoil*data(2,i)/yres + step * ycoil * ybias
              if(i .ne.(60*im+is)) data(5,i) = 99999.99
        !     print *,i,'  ',60*im+is,'  ',line(44:52),' ',ival
           endif
        enddo ! for i 
        file3 = year//'.'//doy//'.'//hrstr//'.NZ_EYWM_50_LFZ.csv'
        print *, file3
        open(unit=13,file=file3)
        do i = 0, ilen-1
           read(13,'(a80)') line
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              read (line(44:52),*) ival
              data(3,i) = ival * cz
              data(6,i) = -(zcoil*data(3,i)/zres + step * zcoil * zbias
     &                    + zoffset)
              if(i .ne.(60*im+is)) data(6,i) = 99999.99
        !     print *,i,' ',60*im+is,'  ',line(44:52),' ',ival
!             print 1000,i,60*im+is,data(1,i),data(2,i),
!    &                  data(3,i),data(4,i),data(5,i),data(6,i)
           endif
        enddo ! for i
        file4 = year//'.'//doy//'.'//hrstr//'.NZ_EYWM_51_LFF.csv'
        print *, 'About to Open ', file4
        open(unit=14,file=file4)
!       print *, file4,' Lengths = ',ileno,' ', ilen-1
        do i = 0, ilen-1
           read(14,'(a80)',end=499,err=499) line
!          print *,'ZZ ',line
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              read (line(37:43),*) ival
              data(10,i) = ival * 0.01                   ! in 0.01nT
              if(i .ne.(60*im+is)) data(10,i) = 99999.99
!             print 1000,i,60*im+is,data(1,i),data(2,i),data(3,i),
!    &                  data(4,i),data(5,i),data(6,i),data(10,i)
           endif
        enddo ! for i
        goto 400
  499   print *,'LFF Failed'
  400   continue
 1000   format(2i6,3f9.5,4f10.2)
 1040   format(i6,3f9.5,7f10.2)
        file6 = year//'.'//doy//'.'//hrstr//'.NZ_SMHS_50_LFZ.csv'
        print *, file6
        open(unit=16,file=file6)
        do i = 0, ilen-1
           read(16,'(a80)') line
           if(i.ge.ileno) then
              read(line(15:16),'(i2)') im
              read(line(18:19),'(i2)') is
              read (line(37:43),*) ival
              data(9,i) = ival * 0.0000327
!  data(9,i) is benmore in some scale
              if(i .ne.(60*im+is)) data(9,i) = 99999.99
        !     print *,i,'  ',60*im+is,'  ',line(44:52),' ',ival
           endif
        enddo ! for i 
!  Now have x,y & z 
	fileout = stn//yrstr//mthstr//daystr//hrstr//'.out'
	open(unit=4,file = '/amp/ftp/pub/geomagnetism/'//fileout,
     &  position = 'APPEND' )
        do i = ileno, ilen-1
!  Now convert X, Y & Z in sensor co-ordinates to geographic X, Y & Z    
           if((data(4,i) .lt. 90000.).and.(data(5,i) .lt. 90000.)) then
              data(4,i) = data(4,i) + xb   ! NO TEMP CORR for now
              data(6,i) = data(6,i) + zb   ! NO TEMP CORR for now
              if(data(9,i) .lt. 99998.) then
                 data(6,i) = data(6,i) + bfact * data(9,i)
                 data(10,i) = data(10,i) - 0.931 * bfact * data(9,i)
              end if
              dminute = atan2(data(5,i),data(4,i))*mrad 
     &                  + ddeg*60. + dmin
              hc = sqrt(data(4,i)*data(4,i)+data(5,i)*data(5,i))
              data(7,i) = hc * cos(dminute/mrad)              
              data(8,i) = hc * sin(dminute/mrad)              
              data(11,i) = sqrt(data(6,i)*data(6,i)+data(7,i)*
     &        data(7,i) + data(8,i)*data(8,i))-data(10,i)
 3040   format(2i6,6f10.2)
              write(4,3040) i/60,i-60*(i/60),data(7,i),data(8,i),
     &                data(6,i),data(10,i),data(11,i),data(9,i)
!              write(34,3040) i/60,i-60*(i/60),data(7,i),data(8,i),
!     &                data(6,i),data(10,i),data(11,i),data(9,i)
           else
              data(7,i) = 99999.99
              data(8,i) = 99999.99
           endif
        enddo ! for i
        end
