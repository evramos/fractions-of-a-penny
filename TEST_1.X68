*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $2000
START:                  ; first instruction of program

    ROL.B #1,D7
    ROL.W #2,D6
    ROL.L #3,D5
    ROL.B #4,D4
    ROL.W #5,D3
    ROL.L #6,D2
    ROL.B #7,D1
    ROL.W #8,D0

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
