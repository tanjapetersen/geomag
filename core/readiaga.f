
	comment = 1
!  First read comment lines and write them out
!  Change Data Interval and "Reported" (in 2 places)
	do while (comment .ne. 0)
	   read(4,'(a70)') line
           if(line(2:14) .eq. 'Data Interval') line(25:42) = 
     &            '1-second          '
           if(line(25:28) .eq. 'XYZF') line(25:28) = 'XYZG'
           if(line(42:45) .eq. 'XYZF') line(42:45) = 'XYZG'
           if(line(1:4) .eq. 'DATE') line(66:66) = 'G'  ! APIF to APIG etc
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
	         read(4,'(a70)') line
	         read(line(31:40),'(f10.2)') x
	         read(line(41:50),'(f10.2)') y
	         read(line(51:60),'(f10.2)') z
	         read(line(61:70),'(f10.2)') f
