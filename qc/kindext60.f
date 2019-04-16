 	program kindext
!       f77 kindext.f -o kindext
!
!   Calculates K-indices for a days data. This version uses the  
!   yymmdd.eyt files, and to get good smoothing, we add 3 hours 
!   data at each end from the adjacent day in the filtering 
!   routine. This means that we have to wait until the third 
!   hour of the next day is processed before we can run any 
!   days kindex.  
!   Has .dka output included
!   Now incorporating sba as option
!
!   Call as kindext eyr 100510 100511 100512 to read 100510.eyt 100511.eyt & 100512.eyt
!
!   NOW interpolating through 99999.00 values
!
        implicit none
	integer*2 i,j,qstart,qend,doy,iyr,oyr,mth,day,odoy,k(8),ih,im,is
	integer*2 dgap, hgap, dstart,dend, hstart, hend, lmax
        real*8 mu
	real*4 qfactor, obsh, kv(9)
	real*4 h(1800),rawh(1800),smooth(1800)
	real*4 d(1800),rawd(1800),smootd(1800)
	real*4 z(1800),f(1800)
	character*2 daystr,oldday
	character*3 obs,OBU,amth,omth
	character*4 yearstr,oldyear,obssuf
	character*6 fileo, filec, filen
	character*8 yeardoy,fileday,fileold
	character*36 mcodes
	character*62 linein
	
	mcodes = 'JanFebMarAprMayJunJulAugSepOctNovDec'

        lmax = 60       ! Interpolate over 60 minutes maximum

	mu = 0.1
	qfactor = 0.5
	qstart = 20
	qend = 1780
	
	call getarg(1,obs)
	if(obs .eq. '') obs = 'eyr'
	do i = 1,3
	   OBU(i:i) = achar(iachar(obs(i:i))-32)
	end do
	obsh = 11250
	if(obs .eq. 'eyr') obsh = 21100
	open(8,file= 'kval.' // obs)
 	do i = 1,9
	   read(8,*) kv(i)
	   write(*,*) i,'  ',kv(i)
	end do	
	obssuf = '.' // obs(1:2) // 't'
	call getarg(2,fileo)		! Yesterday file in form 101231
	call getarg(3,filec)		! Today file 
	call getarg(4,filen)		! Tomorrow file 
	read(filec(1:2),'(i2)') iyr
	read(filec(3:4),'(i2)') mth
	read(filec(5:6),'(i2)') day
	iyr = iyr + 2000				! TESTING TESTING
	print *,'iyr = ',iyr,mth,day	
	open(9, file= obs // '/' // fileo // obssuf)
	open(10,file= obs // '/' // filec // obssuf)
	open(11,file= obs // '/' // filen // obssuf)
! 	open(20,file= fileday // 'dh' )
!	open(21,file= fileday // obs(1:2) )
!	open(22,file= fileday // 'smc' )
	j = 1
	
!   Read 'previous' day file, only last 3 hours
	do i = 1,1260
	   read(9,*) linein
	end do
	do i = 1,180
	      read(9,*,end=90) ih,im,is, d(i), h(i), z(i), f(i)
!	      write(31,*) ih,im,is,h(j),d(j)
	end do
!   Now read 'today' file	
	do i = 181,1620
	      read(10,*,end=90) ih,im,is, d(i), h(i), z(i), f(i)
!             write(31,*) i,j,h(j),d(j)
	end do
!   Finally read 'next' file	
	do i = 1621,1800
	      read(11,*,end=90) ih,im,is, d(i), h(i), z(i), f(i)
!	      write(31,*) i,j,h(j),d(j)
	end do
   90	dgap = 1        ! Assume gap until good number read
        dstart = 1
        hgap = 1        ! and for h
        hstart = 1
        do i = 1, 1800
!  Gap interpolation code here
           if(dgap .eq. 1) then
              if(d(i) .lt. 90000.) then
                 dend = i
                 dgap = 0
!                do interpolation
                 write(19,*) 'DINT', dstart, dend, d(dstart), d(dend)
                 if((dstart .gt. 1).and.((dend-dstart).le.lmax)) then
                    do j = dstart+1,dend-1
                       d(j) = d(dstart) + (j-dstart)*(d(dend)-d(dstart))
     &                                         /(dend-dstart)                
                    end do
                 end if
              end if
           else
              if(d(i) .gt. 90000.) then
                 dstart = i-1           ! i not 1 as initially dgap=1
                 dgap = 1
!                write(19,*) 'DGAP', i, dstart, dgap, d(dstart)
              end if
           end if
	end do
        do i = 1, 1800
!  Gap interpolation code here
           if(hgap .eq. 1) then
              if(h(i) .lt. 90000.) then
                 hend = i
                 hgap = 0
!                do interpolation
                 write(19,*) 'HINT', hstart, hend, h(hstart), h(hend)
                 if((hstart .gt. 1).and.((hend-hstart).le.lmax)) then
                    do j = hstart+1,hend-1
                       h(j) = h(hstart) + (j-hstart)*(h(hend)-h(hstart))
     &                                          /(hend-hstart)     
                    end do          
                 end if
              end if
           else
              if(h(i) .gt. 90000.) then
                 hstart = i-1           ! i not 1 as initially dgap=1
                 hgap = 1
!                write(19,*) 'HGAP', i, hstart, hgap, h(hstart)
              end if
           end if
	end do
        do i = 1, 1800
  	   d(i) = obsh / 3437.75 * d(i)
  	   write(19,*) i,h(i),d(i),dgap, dstart, dend,z(i),f(i)
	end do
	write(*,*) 'Calling kfltr1'
 	call kfltr1(h,rawh,smooth,mu,qfactor,qstart,qend)
 	call kfltr1(d,rawd,smootd,mu,qfactor,qstart,qend)
 2100   format(i5,6f11.4)
!	do i = 1,1800
!	   write (21,2100) i,rawh(i)-smooth(i)+ 50.,rawh(i)+ 150.,
!    &           smooth(i)+ 250.,rawd(i)-smootd(i)- 50.,rawd(i)- 150.,
!    &           smootd(i)- 250.
!	   write (22,2100) i,h(i),smooth(i),rawh(i),rawh(i)-smooth(i)
!	end do
	write(*,*) 'Calling kndx2'
	call kndx2(kv,k,obs,iyr,mth,day,rawh,smooth,rawd,smootd,mu,*100)
  100	stop
	end
!     kfltr1.f95                                             1999-03-19

!     KFILTER1 FILTERS H & D DATA THEN KNDX1 DETERMINES THE KWASI-K


      subroutine kfltr1  
     & (signal,raw,smooth,mu,qfactor,qstart,qend)

      implicit none

      integer*2 i,n,n1,n2,n3,iter,l,lz,iterations,qstart,qend
      integer*2 M,minnum,it1,it2

      character lf

      real*4    qs,qe,error1,error2,t1,t2
      real*4    sss,sg,qfactor,u,u2,u2fact,w
      real*4    raw(1800),signal(1800),smooth(1800),error
      real*4    aver,sum,x(1800),y(1800),yy(1800)
      real*4    pmaxx,pmax,pminx,pmin,difrange,ra,rnd,ig
      real*8    mu
      
!     real (kind=2) r
      real r

      integer seed

      save seed

      data seed /-1/



!     x   -- reference signal
!     w   -- filter weight
!     signal   -- primary signal (to be smoothed)
!     y   -- forward filter output
!     yy  -- reverse filter output
!     smooth -- zero phase filter output

      lf = char(10)

      n = 1800                            ! data length
      l = 1                               ! filter length
      iterations=2                        ! order of filter (at least=2)
      n1=1
      n2=1800
      pmax=10.0E-6
      pmin=10.0E6
      sg=0.0
      ig=2.0
      u2fact=0.08                         ! ratio of L2/L1 smoothing factor

!     INITIALISE ARRAYS
      do i=n1,n2
         y(i) =0.0
         yy(i)=0.0
         if (seed.eq.-1) then
            r=0.234
!           call dclock@(r)
            seed=r
            seed = mod(seed,151)
         end if
         n = mod(111*seed+11,151)
         seed = n
         rnd = real(n)/150.
         ra=rnd-1.0
         x(i)=1.0 +0.005*ra
      end do

!     REMOVE MEAN
      sum=0.0       
      do i=n1,n2
         sum=sum+signal(i)
      end do
      pmaxx=10.0E-10
      pminx=10.0E10
      aver=sum/(n2-n1+1)                          ! average
      do i=n1,n2
         signal(i)=signal(i)-aver                 ! subtract average
         pmaxx=amax1(pmaxx,signal(i))
         pminx=amin1(pminx,signal(i))
      end do
      do i=1,n2
         raw(i)=signal(i)                         ! raw = original-average
         smooth(i)=signal(i)
      end do
      u =mu
      u2=u*u2fact
      do i=n1,n2-2
         sss=signal(i+2)-signal(i)
         if(sss.gt.pmax)pmax=sss
         if(sss.lt.pmin)pmin=sss
      end do
      difrange=pmax-pmin 
   
      if(difrange.lt.qfactor) then 
         u2=u2*3.0
      else
         n3=4
         do i=n1,n3
            sg=sg+signal(i)
         end do
         sg=sg/n3

         qs=qstart
         qe=qend
         if (qe.lt.qs) qe=n2
!        START SMOOTHING OPERATION (L1-NORM)
         do iter=1,iterations
            w=signal(1)
            t1=signal(1)-signal(2)
            t2=signal(2)-signal(3)
            call chksig(t1,it1)
            call chksig(t2,it2)
            if(it1.eq.it2) then
               w=signal(2)
            else
               error1 = signal(1)-signal(2)
               error2 = signal(2)-signal(3)
               if(abs(error1).gt.abs(error2)) then
                  w=signal(3)
               end if
            end if
!           FORWARD FILTER OPERATION
            M=61
            do i=n1,n2
               minnum=i
               if(minnum.ge.n2) minnum=minnum-n2
               y(i)=y(i)+w*x(i)                        ! filter ref signal
               error=signal(i)-y(i)

               call chksig(error,lz) ! nou hier

               if(minnum.gt.qs.and.minnum.lt.qe) then
                  w=w+2.0*u*lz*x(i)
               else
                  if((qs.gt.qe).and.(minnum.lt.qe.or.minnum.gt.qs))then
                     w=w+2.0*u*lz*x(i)
                  else
                     w=w+2.0*u/3.0*lz*x(i)
                  end if
               end if
            end do
           
!           REVERSE FILTER OPERATION
            if(qs.gt.qe) w=signal(n2)
            M=1
            do i=n2,n1,-1
               minnum=i
               if(minnum.ge.n2) minnum=minnum-n2
               yy(i)=yy(i)+w*x(i)
               error=signal(i)-yy(i)

               call chksig(error,lz)  

               if(minnum.gt.qs.and.minnum.lt.qe) then
                  w=w+2.0*u*lz*x(i)
               else
                  if((qs.gt.qe).and.(minnum.lt.qe.or.minnum.gt.qs)) then
                     w=w+2.0*u*lz*x(i)
                  else
                     w=w+2.0*u/3.0*lz*x(i)
                  end if
               end if
            end do
           
!           AVERAGE OF FORWARD AND REVERSE PROCESS TO REMOVE PHASE SHIFT
            w=yy(n1)
            do i=n1,n2
               signal(i)=signal(i)-(y(i)+yy(i))/2.0
               y(i) =0.0
               yy(i)=0.0
            end do
         end do

         do i=n1,n2
            smooth(i)=raw(i)-signal(i)
            signal(i)=raw(i)-signal(i)
         end do
      end if


!     L2-NORM SECTION
      do iter=1,iterations
         w=signal(n1)
         do i=n1,n2
            minnum=i
            if(minnum.ge.n2) minnum=minnum-n2
            y(i)=y(i)+w*x(i)
            error=signal(i)-y(i)
            if(minnum.gt.qs.and.minnum.lt.qe) then
                w=w+2.0*u2*error*x(i)
            else
                if((qs.gt.qe).and.(minnum.lt.qe.or.minnum.gt.qs))then
                   w=w+2.0*u2*error*x(i)
                else
                   w=w+2.0*u2/2.0*error*x(i)
                end if
            end if
         end do
         if(qs.gt.qe) w=signal(n2)
         do i=n2,n1,-1
            minnum=i
            if(minnum.ge.n2) minnum=minnum-n2
            yy(i)=yy(i)+w*x(i)
            error=signal(i)-yy(i)
            if(minnum.gt.qs.and.minnum.lt.qe) then
                w=w+2.0*u2*error*x(i)
            else
                if((qs.gt.qe).and.(minnum.lt.qe.or.minnum.gt.qs))then
                   w=w+2.0*u2*error*x(i)
                else
                   w=w+2.0*u2/2.0*error*x(i)
                end if
            end if
         end do

         do i=n1,n2
            signal(i)=signal(i)-(y(i)+yy(i))/2.0
            y(i) =0.0
            yy(i)=0.0
         end do
      end do

      do i=n1,n2
         smooth(i)=smooth(i)-signal(i)           ! smooth signal
      end do

      return
      end
      subroutine chksig(r,i)

      integer*2 i
      real*4    r

      i = 0
      if (r.gt.0.0)  i = 1
      if (r.lt.0.0)  i = -1

      return
      end
!     kndx3.f95                                                1999-03-19
!      write(26,1005)year,mnd,dag,ndy,mmu,(k(i),i=1,8),BIGAk
      subroutine kndx2(knx,k,obs,year,mth,day,raw1,smooth1,raw,smooth,
     &                mu,*)

!     PROGRAM TO DETERMINE THE K-INDEX OF 3HR TIME INTERVALS
!     OVER A 24 HOUR PERIOD FOR A SPECIFIC OBS ,YEAR ,DAYNO
!   Now do middle 24 hours of a 30 hour period, i.e. 181-1620 of 1800 points 

      implicit none

      character*1  lf
      character*3  obs,obser,OBU,amth(12)
      integer*2    day,dno,i,j,jaar,year,ll
      integer*2    k(8),ak(9),BIGAk,ksum
      integer*2    m,mm,mth,doy

      real         raw1(1800),smooth1(1800),raw(1800),smooth(1800)
      real         amp,diffh,diffd,greatd,greath,ranged,rangeh
      real         knx(9),smalld,smallh,Aak,mmu
      real*8       mu
	character*2 yr

      data         ak/3,7,15,27,48,80,140,240,400/
      amth(1) = 'JAN'
      amth(2) = 'FEB'
      amth(3) = 'MAR'
      amth(4) = 'APR'
      amth(5) = 'MAY'
      amth(6) = 'JUN'
      amth(7) = 'JUL'
      amth(8) = 'AUG'
      amth(9) = 'SEP'
      amth(10) = 'OCT'
      amth(11) = 'NOV'
      amth(12) = 'DEC'
      lf = char(10)
      jaar=0
      dno=0

	do i = 1,3
	   OBU(i:i) = achar(iachar(obs(i:i))-32)
	end do

	write(yr,'(i2.2)') year-2000
      open(16,file='klatest.' // obs)
      open(17,file='kbimonth.' // obs, access='append')
      open(18,file='kyear'//yr//'.' // obs, access='append')
      open(29,file=obs//'20'//yr//'.dka', access='append')
      write(*,*) 'knx',year,yr
!     call monday(year,ndy,mnd,dag)  
!	print *, year,ndy,mth,day
        print *, 'H and D ranges for 3-hour intervals'
        do j = 1,8                                ! 8 TIME INTERVALS
          greath = -99999.0
          smallh =  99999.0
          greatd = -99999.0
          smalld =  99999.0
          mm = j*180				! was j-1 in previous version
!         mm = 60 +(j*180)     DUD VALUE HERE	! was j-1 in previous version
          do i = 1,180
            m = mm + i
            diffh = raw1(m)-smooth1(m)           ! element H Out of range
            diffd = raw(m)-smooth(m)             ! element D
            greath= amax1(diffh,greath)          ! max pos difference h
            smallh= amin1(diffh,smallh)          ! max neg difference h
            greatd= amax1(diffd,greatd)          ! max pos difference d
            smalld= amin1(diffd,smalld)          ! max neg difference d
          end do
          rangeh = greath - smallh               ! total difference h
          ranged = greatd - smalld               ! total difference d 
          amp    = amax1(rangeh,ranged)
	print *,rangeh,ranged
          if(amp.le.knx(1))then
             k(j)=0
          else
             if(amp.gt.knx(9))then
                k(j)=9
             else
                do ll=1,8
                   if(amp.gt.knx(ll).and.amp.le.knx(ll+1))then
                     k(j)=ll
!                    exit       ! should only save time
                   end if
                end do 
! Bereken H en D K-waardes afsonderlil                
!                do ll=1,8
!                if(rangeh.gt.knx(ll).and.rangeh.le.knx(ll+1)) then
!                    write(38,"('H : ',i2)")ll
!                    exit
!                endif
!                enddo
!                do ll=1,8
!                if(ranged.gt.knx(ll).and.ranged.le.knx(ll+1)) then
!                    write(38,"('D : ',i2)")ll
!                    exit
!                endif
!                enddo                
             end if
          end if
      end do
	write(*,*) 'Aak'

      call dayofyear(doy,year,mth,day)		! Calculates doy from Y,M,D
      print *, year,doy,mth,day

      Aak=0.0
      ksum = 0
      do i=1,8
         ksum = ksum + k(i)
         ll=k(i)
         if(ll.ne.0) Aak=ak(ll)+Aak
      end do
      BIGAk=nint(Aak/8.0)
	write(*,*) 'Bak'
	write(*,*) (k(i), i=1,8), Aak
	write(16,1601) OBU,year,mth,day,(k(i), i=1,8), Aak
	write(17,1601) OBU,year,mth,day,(k(i), i=1,8)	!   No Ak for Potsdam 
	write(18,1801) year,mth,day,doy,(k(i), i=1,8), Aak,ksum
	write(29,1901) day,amth(mth),yr,doy,(k(i), i=1,8), ksum
      mmu=mu
!      write(26,1005)year,mth,day,ndy,mmu,(k(i),i=1,8),BIGAk
!      close (38)
	write(*,*) 'Rak'
      return

1001  format(a3,9f6.1)
1003  format(1x,3i2,8i1,a1)
1005  format(i4,'-',i2.2,'-',i2.2,'(',i3.3,')',1x,f5.2,2x, 
     & 4i1,1x,4i1,3x,i3)
1601  format(a3,i5,2i3.2,8i3,f6.0)
1701  format(i5,2i3,i4,8i3,f5.0)
1801  format(i5,2i3,i4,8i3,f5.0,i4)
1901  format(3x,i2.2,'-',a3,'-',a2,i6,1x,4i5,2x,4i5,i9)
      end
c     MONDAY.F95                                         2000-01-19


      subroutine monday(jaar,jday,mnth,mday)


c     MONDAY Converts the DAY NUMBER into MONTH and DAY

!     Input Parameters are   jaar = YEAR   jday = DAY NUMBER

!     Output Parameter are mnth and DAY

      implicit none

      integer*2 jaar,jday,mnth,mday

      do mnth = 2,13

         mday = jday - (mnth-1)*30 - (mnth + (mnth/9))/2  
     &    - (1 - (jaar-jaar/4*4+3)/4)*(mnth+10)/13+(mnth+10)/13*2

         IF(mday.LE.0) GO TO 120

      end do



120   continue

      mnth = mnth - 1

      mday = jday - (mnth-1)*30 - (mnth + (mnth/9))/2 
     & - (1 - (jaar-jaar/4*4+3)/4)*(mnth+10)/13+(mnth+10)/13*2

      return

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
