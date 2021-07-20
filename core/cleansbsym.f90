PROGRAM cleansbsym
    !   This PROGRAM reads Scott Base .sb1 hourly data files, and makes
    !   adjustments to compensate for the Ionosonde, which now runs at
    !   exactly every 15 minutes
    !
    !   The corrections are READ of the file iono.sym ( in /amp/magsob/sba/iono/ ),
    !   ( for -30 to 30 seconds ) so no need for a delay term
    !   REMEMBER: - The corrections are subtracted
    !
    !   S( 1:3, -30:30 ) contains adjustments to x, y and z for 30 seconds
    !   each side of the exact 15 minutes
    !
    !   Note: Last modified on 20 Feb 2017. Now: if it has a 3rd parameter, it uses
    !   it as yr, mth, day to access a daily customised .sym file ( e.g. 170220.sym )
    !   instead of iono.sym.

    ! gfortran -g -fbacktrace -ffpe-trap=zero,overflow,underflow -fmax-errors=5 -std=f2008 cleansbsym.f90
    USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : real32, real64, int32 ! not using output_unit or real64 - just to show them
    IMPLICIT NONE

    INTEGER( kind=int32 ) :: idum, i, j, k, iargs, ih, im, is
    REAL( kind=real32 ), DIMENSION( 0:3599, 1:7 ) :: dd
    REAL( kind=real64 ), DIMENSION( 1:3, -30:30 ) :: S
    CHARACTER( len=3 ) :: stn, stc, stnt, stnx
    CHARACTER( len=6 ) :: ionfile
    CHARACTER( len=12 ) :: filen, filel
    INTEGER :: inUnit1, inUnit2, outUnit

!    OPEN( newunit=inUnit2, file='iono/iono.sym' )       ! Corrections input file located in /amp/magobs/sba/iono !rch Why is this file opened?
    !   Next few lines are to set up output file name and header

    CALL get_command_argument( 1, stn )
    stc  = stn( 1:2 ) // 'c'
    stnt = stn( 1:2 ) // 't'
    stnx = stn( 1:2 ) // 'x'
    CALL get_command_argument( 2, filen )
    OPEN( newunit=inUnit1, file= stc//'/'// filen )
    filel = filen( 1:11 )//'2'        ! Output file is .sb2
    iargs = command_argument_count()
    !   Now OPEN a file of corrections for effect of ionosonde
    !   A non-zero 3rd parameter means use $yr$mth$day.sym instead of iono.sym
    IF( iargs >= 3 ) THEN
        CALL get_command_argument( 1, ionfile )
        OPEN( newunit=inUnit2, file= 'iono/'//ionfile//'.sym' )       ! Day-specific correction file
        PRINT *, filen( 1:6 ), '.sym'
    ELSE
        OPEN( newunit=inUnit2, file= 'iono/iono.sym' )       ! Current correction file located in /amp/magobs/sba/iono
        PRINT *, 'iono.sym'
    END IF
    OPEN( newunit=outUnit, file= stc//'/'// filel )

    DO i = -30, 30
        READ( inUnit2, * ) idum, S( 1, i ), S( 2, i ), S( 3, i )  ! idum to be -30..30
    END DO

    ! lines 0:3599 are current hour
    DO i = 0, 3599 ! assumes no extra readings
        READ( inUnit1, *, END=100 ) ih, im, is, dd( i, 1:7 ) ! dd( i, 1 ), dd( i, 2 ), dd( i, 3 ), dd( i, 4 ), dd( i, 5 ), dd( i, 6 ), dd( i, 7 )
        k = i - ( i/900 )*900
        IF( k <= 30 ) THEN  ! 0 to 30 secs after exact 15 min
            DO j = 1, 3
                dd( i, j ) = dd( i, j ) - S( j, k )
            END DO
        END IF
        IF( k >= 870 ) THEN  ! -30 to -1 secs, i.e. before exact 15 min !rch this comment doesn't match the code
            DO j = 1, 3
                dd( i, j ) = dd( i, j ) - S( j, k-900 )
            END DO
        END IF
        WRITE( outUnit, 3000 ) ih, im, is, dd( i, 1:7 ) ! dd( i, 1 ), dd( i, 2 ), dd( i, 3 ), dd( i, 4 ), dd( i, 5 ), dd( i, 6 ), dd( i, 7 )
    END DO
100 CONTINUE
!1000   FORMAT( 3i3, 1x, 2f7.2, 3f9.4, f11.3, f10.3, 2f11.3, f8.2, f9.4 )
3000   FORMAT( 3i3, 1x, f10.3, 2f11.3, f9.2, 3f7.2 )
END PROGRAM

SUBROUTINE dayofyear( yr, doy, mth, day )
    USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : int32
    IMPLICIT NONE

    INTEGER( kind=int32 ) :: i, yr, day, doy, mth
    INTEGER( kind=int32 ), DIMENSION( 12 ) :: dimth
    !  yr, mth, day to doy
    DO i = 1, 12
        dimth( i ) = 31
    END DO
    dimth( 2 ) = 28
    dimth( 4 ) = 30
    dimth( 6 ) = 30
    dimth( 9 ) = 30
    dimth( 11 ) = 30
    IF( mod( yr, 4 ) == 0 ) dimth( 2 ) = 29
    doy = day
    IF( mth > 1 ) THEN
        DO i=1, mth-1
            doy = doy + dimth( i )
        END DO
    END IF
END  SUBROUTINE
