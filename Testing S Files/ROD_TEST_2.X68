*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $2020
START:                  ; first instruction of program

	ROL.B D0,D7
	ROL.W D1,D6
	ROL.L D2,D5
	ROL.B D3,D4
	ROL.W D4,D3
	ROL.L D5,D2
	ROL.B D6,D1
	ROL.W D7,D0

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
