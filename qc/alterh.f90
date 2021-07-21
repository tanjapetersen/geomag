PROGRAM alterk !rch it's not Fortran 77 because that didn't allow for lowercase code (even if the mil-spec 1978 did)
    ! This program reads a .bin file, and makes changes
    ! to the 7th, 8th, 10th & 11th words of the header !rch and 13th
    ! Rands version of alterh.f
    USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : output_unit, real64, int32 ! not using output_unit or real64 - just to show them
    IMPLICIT NONE

    INTEGER*1 pack(1:4)
    INTEGER( kind=int32 ) :: q
    INTEGER( kind=int32 ) :: i
    INTEGER( kind=int32 ) :: iday
    INTEGER( kind=int32 ) :: tohead
    INTEGER( kind=int32 ) :: inUnit
    INTEGER( kind=int32 ) :: outUnit
    CHARACTER( len=128 ) :: inFile
    CHARACTER( len=128 ) :: outFile
    CHARACTER( len=3 ) :: obs
    CHARACTER( len=8 ) :: file        ! e.g. EYR05Jan !rch rather restrictive on the filenames, as Fortran now allows much more

!    INTEGER, PARAMETER :: r6 = selected_real_kind(6)

    equivalence(pack,tohead)

    CALL getarg(1,file)     ! e.g. sba12jan
    ! for testing:file = 'sba12jan'
    obs = file(1:3)

    inFile = obs//'/'//file//'.bin'
    outFile = 'new/'//file//'.bin'

    ! block for testing: infile = 'alterh.f90'
  

    OPEN( newunit=inUnit,file=inFile, access='DIRECT', recl=4 )
    ! for testing:outFile = 'changed.f90'
    OPEN( newunit=outUnit, file=outFile, access='DIRECT', recl=4 )
    iday_: DO iday = 1,31 ! days in month
        i_: DO i = 1, 5888 ! records in month
            READ( unit=inUnit, rec=(iday-1)*5888+i ) q
            !  This is where we can do alterations:
            ! =====================================
            ! if((iday .eq. 15).and.(i .eq.5877)) then
            SELECT CASE( i )
                CASE( 7 )
                    pack(1)= ichar(' ')
                    pack(2)= ichar('G')
                    pack(3)= ichar('N')
                    pack(4)= ichar('S')    ! Data Source: GNS
                    q = tohead
                CASE( 8 )
                    q = 10000          ! D-conv. factor: SBA: 10000; API: 10000 according to Jan Reda (we first thought it would be 0)
                CASE( 10 )
                    pack(1)= ichar(' ')
                    pack(2)= ichar(' ')
                    pack(3)= ichar('L')
                    pack(4)= ichar('C')    ! Instrumentation: LC fluxgate
                    q = tohead
                CASE( 11 )
                    q = 2000       ! K9-limit: 300 nT for API, 500 nT for EYR, 2000 nT for SBA,
                CASE( 13 )
                    pack(1)= ichar('H')
                    pack(2)= ichar('D')
                    pack(3)= ichar('Z')
                    pack(4)= ichar('F')    ! Sensor orientation: HDZF
                    q = tohead
            END SELECT
            WRITE( outUnit, rec=(iday-1)*5888+i ) q
        END DO i_
    END DO iday_
    CLOSE( unit=inUnit )
END
