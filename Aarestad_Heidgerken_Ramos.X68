*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

            OPT   CRE
SOURCE_H    EQU   $0000A003
SOURCE_B    EQU   %0100111001110001       * 0x4E71
START       EQU   $1000
CR          EQU   $0D
LF          EQU   $0A
BITMASK8	EQU	  $00FF
BITMASK4    EQU	  $0F
BITMASK3	EQU   $07
*-------------------------------------------------------------------------------
     	      
            ORG    START      * Program begins here

            LEA SOURCE,A0     * Loading the Source Code into (A0)
            
LOOP        MOVE.L (A0)+,D1

            MOVE.L D1,D3

            *-------------------------------------------------------------------
            * NOP (No Operation)                      0100 1110 0111 0001 0x4E71

            CMPI.L #$4E71,D3  * Compares D1 if it is a NOP 
            BNE RTS

            LEA NOP_M,A1      * Loading address from NOP message into (A1)
            MOVE.L #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

            BRA DISPLAY_BINARY_HEXADECIMAL
        
            *-------------------------------------------------------------------
RTS         * RTS (Return)                            0100 1110 0111 0101 0x4E75

            CMPI.L #$4E75,D3  * Compares D1 if it is a RTS
            BNE JSR
            
            LEA RTS_M,A1      * Loading address from NOP message into (A1)
            MOVE.L #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

            BRA DISPLAY_BINARY_HEXADECIMAL

            *-------------------------------------------------------------------
JSR         * JSR <ea>                                 0100 1110 10 [EA - 6bits]

            AND.W #$4E80,D3   * Bitmask of JSR [0100 1110 10xx xxxx] 0x4E80
            CMPI.L #$4E80,D3  * Compares D1 if it is a RTS
            ; BNE NEG
            BNE DATA


            LEA JSR_M,A1      * Loading address from NOP message into (A1)
            MOVE.L #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

            ; Pass code to EA 

            BRA DISPLAY_BINARY_HEXADECIMAL

            *-------------------------------------------------------------------
; NEG         * NEG <ea>                      0100 0100 [Size - 2bits][EA - 6bits]

;             MOVE.L D1,D3      * Reset Data Register 3 from preivous bitmask

;             AND.W #$4480,D3   * Bitmask of NEG [0100 0100 xxxx xxxx] 0x4480
;             CMPI.L #$4480,D3  * Compares D1 if it is a RTS
;             BNE ADD

;             LEA NEG_M,A1      * Loading address from NEG message into (A1)
;             MOVE.L #14,D0     * Moving task 14 into Data Register 0
;             TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

;             MOVE.L D1,D3      * Reset Data Register 3 from preivous bitmask

;             * Checking what the 2 bit size is, wheather it is (B,W,L) 
;             AND.W #40,D3      * Bitmask [xxxx xxxx 01xx xxxx]
;             BEQ   * 01 1

;             * 00 0 BLT
;             * 10 2 BGT

;             ; Pass code to EA 

;             BRA DISPLAY_BINARY_HEXADECIMAL

;             *-------------------------------------------------------------------
; ADD         * ADD <ea>,Dn    1101 [Register - 3bits][OPmode - 3bits][EA - 6bits]
;             * ADD Dn,<ea>
;             * ADDA <ea>,An

;             MOVE.L D1,D3      * Reset Data Register 3 from preivous bitmask
            
;             AND.W #$D000,D3   * Bitmask of ADD [1101 xxx xxx xxx xxx] 0xD000
;             CMPI.L #$D000,D3  * Compares D1 if it is a RTS
;             BNE CMP

; ;             * Checks if the OP is ADD/ADDA
; ;             MOVE.L D1,D3      * Reset Data Register 3 from preivous bitmask
; ;             AND.W #$D080,D3   * Bitmask of ADD [1101 xxx 010 xxx xxx] 0xD080

; ;             BGT ADDA

; ; ADDA

;             LEA ADD_M,A1      * Loading address from ADD message into (A1)
;             MOVE.L #14,D0     * Moving task 14 into Data Register 0
;             TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

;             ; Pass code to EA 

;             BRA DISPLAY_BINARY_HEXADECIMAL

;             *-------------------------------------------------------------------
; CMP         * CMP <ea>,Dn    1011 [Register - 3bits][OPmode - 3bits][EA - 6bits]

;             MOVE.L D1,D3      * Reset Data Register 3 from preivous bitmask

;             AND.W #$B000,D3   * Bitmask of ADD [1011 xxx xxx xxxxxx] 0xB000
;             CMPI.L #$B000,D3  * Compares D1 if it is a RTS
;             BNE DATA

            *-------------------------------------------------------------------
DATA        TST.L D1          * Are we done yet? 
            BNE HEXADECIMAL   * else noting (just DATA)

        
            SIMHALT           * halt simulator

*-------------------------------------------------------------------------------
* Display output of a single 16bit instruction (So far works with NOP only)
* Written by: Matthew Ramos
* Example output:
*     '<OPERATION>  :  <BINARY>  :  <HEXADECIMAL>'
*-------------------------------------------------------------------------------

DISPLAY_BINARY_HEXADECIMAL:

            BSR Tab           * Displays a space between the OP & BINARY

BINARY      MOVE.B #15,D0     * Moving task 15 into Data Register 0
            MOVE.B #2,D2      * Moving value 2 into Data Register 2 [base 2]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B

            BSR Tab           * Displays a space between the BINARY & HEXADECIMAL

HEXADECIMAL MOVE.B #15,D0     * Moving task 15 into Data Register 0 
            MOVE.B #16,D2     * Moving value 16 into Data Register 2 [base 16]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B


            LEA NEWLINE,A1    * Creates a newline for the next instruction. Loading NEWLINE into (A1)
            MOVE.B #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF


            CLR.L D3          * Clears D3 and frees for future use
            BRA LOOP          * Branching Always to (LOOP)

TAB         LEA SPACE,A1      * Loading address from SPACE message into (A1)
            MOVE.B #14,D0     * Moving task 14 into Data Register 0 
            TRAP #15          * Display string at (A1) without CR, LF.
            RTS               * Returns from subroutine


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
*D6 used for Register value, D5 is EA Mode
*-----------------------------------------------------------------------------
OneOpEA		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D3 
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D4
			LSL.W	3,D5			;shift mask left 3 times
			
			AND.W	D7,D6			;and D7 and D3 store in D3 Register
			AND.W	D7,D5			;and D7 and D4 store in D4 Mode
			
			BSR						;return to calling instruction
			


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the instruciton to determine the offset being usedstored in D3
*-------------------------------------------------------------------------------
OneOpDis	MOVE.B	#BITMASK8, D6	;move 8bitmask into D6
			AND.L	D7,D6			;and D7 with D6(Offset)
			

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
*-------------------------------------------------------------------------------
TwoOp		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D6
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D5
			MOVE.B	#BITMASK3, D4	;move primative 3 bit mask into D4
			MOVE.B	#BITMASK3, D3	;move primative 3 bit mask into D3
			
			LSL.W	3,D5			;shift mask left 3 times
			LSL.W	6,D4			;shift mask left 3 times
			LSL.W	6,D3			;shift mask left 3 times
			LSL.W	6,D3			;shift mask left 3 times
			
			AND.L	D7,D6			;and D7 with D6 DestRegister
			AND.L	D7,D6			;and D7 with D5	DestMode
			AND.L	D7,D6			;and D7 with D4 SrcMode
			AND.L	D7,D6			;and D7 with D3 SrcRegister
			
			BSR


*-------------------------------------------------------------------------------
* Data section - Put variables and constants here

NOP_M       DC.B  'NOP',0
RTS_M       DC.B  'RTS',0
JSR_M       DC.B  'JSR ',0
NEG_M       DC.B  'NEG',0
SPACE       DC.B  ' :  ',0

Byte_M      DC.B  '.B ',0
Word_M      DC.B  '.W ',0
Long_M      DC.B  '.L ',0

NEWLINE     DC.B  CR,LF,0
SOURCE      DC.L  $4E71,$89ABCDEF,$4E75,$ABCD,%1010101010101010,0

    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
