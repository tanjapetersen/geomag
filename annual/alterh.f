	program alterk
c   This program reads a .bin file, and makes changes
c   to the 7th, 8th, 10th & 11th words of the header

	implicit none
	integer*1 pack(1:4)
	integer*2 hhno,dhno,xhno,yhno,zhno,fhno,hdno,ddno,xdno,ydno,
     &                 zdno,fdno
	integer*4 i, ihr, iyr, mth, iday,idoy, j,k,q,ii,kdoy,kk(8),sk
	integer*4 ih, im, is, idummyi, iyrk, imthk, idayk, idoyk 
	integer*4 iyc, imc, idc		! constant file year, month & day
	integer*4 iymd, iymdc,dec0,colat,long,id1,id2,id3
	integer*4 h1,d1,x1,y1,z1,f1,g1,fv,lmth,today(3)
	integer*4 words(1:5888),tohead
	integer*4 hhmn,dhmn,xhmn,yhmn,zhmn,fhmn,hdmn,ddmn,xdmn,ydmn,
     &                 zdmn,fdmn,ghmn,gdmn 
	character*1 type
	character*2 hrstr,daystr,yrstr,monstr
	character*3 mthstr,mthi,obs,obsi,obst,gin
	character*4 cpt,year
	character*5 yrmth
	character*6 fstr
	character*7 hstr,dstr,zstr
	character*8 file		! e.g. EYR05Jan
	character*12 fileo		! e.g. EYR05Jan.bin
	character*12 filei		! e.g. Dec3105.eyr
	character*12 stnname
	character*16 dummy,adummy
	character*34 filef, fileg
	character*36 mcodes
	character*62 line
	character*110 linef,lineo(744)
	
	equivalence(pack,tohead)

	call getarg(1,file)		! e.g. sba12jan
	obs = file(1:3)
	open(unit=10,file = obs//'/'//file//'.bin',access = 'DIRECT',recl=4)	
	open(unit=20,file = 'new/'//file//'.bin',access = 'DIRECT',recl=4)
	do iday = 1,31
	   do i = 1, 5888
	      read(10,rec=(iday-1)*5888+i) q	
!  This is where we can do alterations:
! =====================================
!	      if((iday .eq. 15).and.(i .eq.5877)) then 
	      if((i .eq. 7)) then 
		 pack(1)= ichar(' ')
		 pack(2)= ichar('G')
		 pack(3)= ichar('N')
		 pack(4)= ichar('S')    ! Data Source: GNS
		 q = tohead
	      end if
	      if((i .eq. 8)) then 
		 q = 10000	        ! D-conv. factor: SBA: 10000; API: 10000 according to Jan Reda (we first thought it would be 0)
	      end if
	      if((i .eq. 10)) then 
		 pack(1)= ichar(' ')
		 pack(2)= ichar(' ')
		 pack(3)= ichar('L')
		 pack(4)= ichar('C')	! Instrumentation: LC fluxgate
		 q = tohead
	      end if
	      if((i .eq. 11)) then 
		 q = 500		! K9-limit: 500 nT for EYR, 2000 nT for SBA, 300 nT for API
	      end if
              if ((i .eq. 3)) then     ! Colatitude: 103815 for API; 133474 for EYR; comment for SBA
	     	 q = 133474
              end if
              if ((i .eq. 4)) then     ! Longitude: 171781 for API; 172393 for EYR; comment for SBA
	     	 q = 172393
              end if

               if ((i .eq. 5)) then     ! Elevation is 102 m for EYR; comment for all other sites
	     	 q = 102
              end if

              if((i .eq. 13)) then 
		 pack(1)= ichar('H')
		 pack(2)= ichar('D')
		 pack(3)= ichar('Z')
		 pack(4)= ichar('F')	! Sensor orientation: HDZF
		 q = tohead
	         end if
	      write(20,rec=(iday-1)*5888+i) q
	   end do    ! for i
	end do       ! for iday

  100	end	
