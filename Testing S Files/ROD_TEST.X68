*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

ROD_TEST_1: ORG    $2000

        ROL.B #1,D7
        ROL.W #2,D6
        ROL.L #3,D5
        ROL.B #4,D4
        ROL.W #5,D3
        ROL.L #6,D2
        ROL.B #7,D1
        ROL.W #8,D0


ROD_TEST_2: ORG    $2020

	    ROL.B D0,D7
	    ROL.W D1,D6
	    ROL.L D2,D5
	    ROL.B D3,D4
	    ROL.W D4,D3
	    ROL.L D5,D2
	    ROL.B D6,D1
	    ROL.W D7,D0

    SIMHALT             ; halt simulator

    END    ROD_TEST_1
    END    ROD_TEST_2


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
