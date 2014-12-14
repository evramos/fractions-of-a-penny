*-------------------------------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-------------------------------------------------------------------------------

ROD_TEST_1: ORG    $2000

        ROL.B #1,D7
        ROR.W #2,D6
        ROL.L #3,D5
        ROR.B #4,D4
        ROL.W #5,D3
        ROR.L #6,D2
        ROL.B #7,D1
        ROR.W #8,D0

ROD_TEST_2: ORG    $2020

	    ASL.B D0,D7
	    ASR.W D1,D6
	    ASL.L D2,D5
	    ASR.B D3,D4
	    ASL.W D4,D3
	    ASR.L D5,D2
	    ASL.B D6,D1
	    ASR.W D7,D0

ROD_TEST_3: ORG    $2040

        ROL (A1)
        ROR (A2)
        ASL (A3)
        ASR (A4)
        LSL (A5)
        LSR (A6)

*-------------------------------------------------------------------------------
ORI_TEST_1: ORG    $2060

        
        ORI.B #$BD,D0
        ORI.W #$ABCD,D1
        ORI.L #$89ABCEF,D2

        ORI.B #$AB,$3000
        ORI.W #$ABCD,$3000
        ORI.L #$89ABCDEF,$5000

        ORI.B #$AB,$30004000
        ORI.W #$ABCD,$30005000
        ORI.L #$89ABCDEF,$50006000


    SIMHALT             ; halt simulator


    END    ROD_TEST_1
    END    ROD_TEST_2
    END    ROD_TEST_3
    END    ORI_TEST_1



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
