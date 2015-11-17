	program apx2usgs
c   This program produces a file in the format for MagProc from an .apx file
c   Hardwire /amp/magobs/api/api directory for both files 
!   Call as apx2usgs yymmdd

	implicit none
	integer*2 i, iyr, imth, iday, idoy, idum, ihr, imin
	integer*4 ih, ie, iz, if
        real*4 x,y,z,f, d, ddeg, dmin, xb, zb, fb
        character*3 doy, mth
	character*6 ymd
	character*10 filei		! e.g. 151022.apx
	character*14 fileo		! e.g. API2015295.min
	character*36 amth
        amth = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'

        xb =  105.2
        ddeg = 11.0
        dmin = 53.3
        zb = -39.0
        fb = -40.0
	call getarg(1,ymd)		! e.g. 151022
	filei = ymd//'.apx'
	read(ymd(1:2),'(i2)') iyr
	read(ymd(3:4),'(i2)') imth
	read(ymd(5:6),'(i2)') iday
        mth = amth(imth*3-2:imth*3)
!        print *, mth
	call dayofyear(idoy,iyr,imth,iday)	! doy to month & day 
	write(doy,'(i3.3)') idoy
	fileo = 'API20'//ymd(1:2)//doy//'.min'
	open(unit=10,file='/amp/magobs/api/api/'//filei)
	open(unit=12,file='/amp/magobs/api/api/'//fileo)
1200    format(a7,2a2,a3,2a2,a1,a3,a1,a2,a33)
        write(12,1200) 'API  20',ymd(1:2),'  ',doy,'  ',ymd(5:6),'-',
     &     mth,'-',ymd(1:2),'  HEZF  0.01nT  File Version 2.00' 
        do i = 0, 1439
           read(10,*) idum, ihr, imin, x, y, z, f
           write(14,*) idum, ihr, imin, x, y, z, f
           ih = sqrt((x+xb)*(x+xb) + y*y) * 100
!  d is angle (in minutes) between field dirn and sensor x dirn
           d = (atan2(y,x) * 180*60/3.1415926535-ddeg*60-dmin)
!  ie is nT in horiz dirn perpendicular to sensor x dirn
           ie = ih * tan(d * 3.1415926535/(180*60)) ! * 100 included in ih
           iz = (z + zb) * 100
           if = (f + fb) * 100
           write(12,1210) i, ih, ie, iz, if
        end do
1210	format(i4.4,4i9)
	end

      subroutine dayofyear(doy,Y,M,D)

!  From Program:      GREG2DOY
!
!  Programmer:   David G. Simpson
!                NASA Goddard Space Flight Center
!                Greenbelt, Maryland  20771
!
      IMPLICIT NONE
      integer*2 y,m,d,doy,k
      logical leap

      LEAP = .FALSE.
      IF (MOD(Y,4) .EQ. 0) LEAP = .TRUE.

      IF (MOD(Y,100) .EQ. 0) LEAP = .FALSE.
      IF (MOD(Y,400) .EQ. 0) LEAP = .TRUE.

      IF (LEAP) THEN
         K = 1
      ELSE
         K = 2
      END IF

      doy = ((275*M)/9) - K*((M+9)/12) + D - 30

      end
