
*-------------------------------------------------------------------------------
* Testing Type 6
*-------------------------------------------------------------------------------

ROD_TEST_1: ORG    $3000

        ROL.B #1,D7
        ROR.W #2,D6
        LSL.L #3,D5
        LSR.B #4,D4
        ASL.W #5,D3
        ASR.L #6,D2
        ROL.B #7,D1
        ROR.W #8,D0

ROD_TEST_2: ORG    $3020

	    LSL.B D0,D7
	    LSR.W D1,D6
	    ASL.L D2,D5
	    ASR.B D3,D4
	    ROL.W D4,D3
	    ROR.L D5,D2
	    ASL.B D6,D1
	    ASR.W D7,D0

ROD_TEST_3: ORG    $3040

        ROL (A1)
        ROR (A2)+
        ASL -(A3)
        ASR $4000
        LSL $40006000
        LSR (A6)



*-------------------------------------------------------------------------------
* Testing Type 1
*-------------------------------------------------------------------------------

ORI_TEST_1: ORG    $3100

        
        ORI.B #$BD,D0
        ORI.W #$ABCD,D1
        ORI.L #$89ABCEF,D2
        NOP
        ORI.B #$AB,$3000
        ORI.W #$ABCD,$3000
        ORI.L #$89ABCDEF,$5000
        NOP
        ORI.B #$AB,$30004000
        ORI.W #$ABCD,$30005000
        ORI.L #$89ABCDEF,$50006000

CMPI_TEST_1: ORG    $3200
    
        CMPI.B #$EF,D0
        CMPI.W #$DCBA,D1
        CMPI.L #$FECBA98,D2
        NOP
        CMPI.B #$CD,$3000
        CMPI.W #$CDEF,$3000
        CMPI.L #$FECBA98,$5000
        NOP
        CMPI.B #$AB,$30004000
        CMPI.W #$CDEF,$30005000
        CMPI.L #$FECBA98,$50006000

*-------------------------------------------------------------------------------
* Testing Type 2
*-------------------------------------------------------------------------------

BRANCH_TEST_1: ORG  $3300

A   MOVE.L D3,D4       
B   BLE A
C   BGT B
D   BLT C
E   BGE D
F   BMI E
G   BPL F
H   BVS G
I   BVC H
J   BEQ I
K   BNE J
M   BCS K
N   BCC M
L   BLS N
O   BHI L
    BRA O

*-------------------------------------------------------------------------------
* Testing Type 3
*-------------------------------------------------------------------------------

ADDA_TEST_1: ORG  $3400

    ADDA.W D0,A0
    ADDA.L A0,A1
    ADDA.W (A0),A2
    ADDA.L (A0)+,A3
    ADDA.W -(A0),A4
    ADDA.L $9000,A5
    ADDA.W $90003000,A6
    ADDA.L #$90003000,A7

ADD_TEST_1: ORG  $3500

    ADD.B D0,D1
    ADD.W A2,D3
    ADD.L (A4),D5

    ADD.B (A6)+,D7
    ADD.W -(A0),D1
    ADD.L $2000,D2

    ADD.B $20006000,D3
    ADDI.B #$AB,D4
    ADDI.W #$ABCD,D5
    ADDI.L #$89ABCDEF,D6


    SIMHALT             ; halt simulator


    END     ROD_TEST_1
    END     ROD_TEST_2
    END     ROD_TEST_3
    END     ORI_TEST_1
    END     CMPI_TEST_1
    END     BRANCH_TEST_1
    END     ADDA_TEST_1
    END     ADD_TEST_1


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
