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
* Type 1 mode xxxx xxxx ssoo oorrr
* SubRoutine for handling One Operand addressing looking for a mode and register 
* value
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
* D6 used for Register value, D5 is mode D4 is the Size
*-----------------------------------------------------------------------------
EA_TYPE1	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4

			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			
			BSR						;return to calling instruction

*-------------------------------------------------------------------------------
* Type 2 xxxx xxxx dddd dddd
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the instruciton to determine the offset being used stored in D6
*-------------------------------------------------------------------------------
EA_TYPE2	MOVE.B	#%11111111, D6	;move 8bitmask into D6
			AND.L	D7,D6			;and D7 with D6(Offset)
			BSR

*-------------------------------------------------------------------------------
* Type 3 xxxx rrrooo oorrr
* SubRoutine for handling two Operand Effective addressing to find 2 3 bit modes
* and two 3 bit registers
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
* source register stored in D3, source mode in D4 Dest mode in D5 dest register
* in D6
*-------------------------------------------------------------------------------			
EA_TYPE3	MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D6
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D5
			MOVE.B	#BITMASK3, D4	;move primative 3 bit mask into D4
			MOVE.B	#BITMASK3, D3	;move primative 3 bit mask into D3
			
			LSL.W	3,D5			;shift mask left 3 times
			LSL.W	6,D4			;shift mask left 6 times
			LSL.W	6,D3			;shift mask left 6 times
			LSL.W	6,D3			;shift mask left 3 times
			
			AND.L	D7,D6			;and D7 with D6 DestRegister
			AND.L	D7,D5			;and D7 with D5	DestMode
			AND.L	D7,D4			;and D7 with D4 SrcMode
			AND.L	D7,D3			;and D7 with D3 SrcRegister
			
			BSR
			
*-------------------------------------------------------------------------------
* Type 4   - xxxx DDD1 ssoo orrr
* Sub Routine to find Size and EA(mode and Register) and Data from instruction
* D3 stores Databits
* D4 Stores Size
* D5 stores Mode
* D6 stores Register
*-------------------------------------------------------------------------------			
EA_TYPE4	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4
			MOVE.W	#%00001110, D3	; move Datamask into D3
			LSL.W	8,D3			; shift datamask 8 places
			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			AND.W	D7,D3			;and D7 and D3 store in D3 Data
			
			BSR						;return to calling instruction

*-------------------------------------------------------------------------------
* Type 5 mode xxxx xDxx ssoo oorrr
* SubRoutine for handling One Operand addressing looking for a mode and register 
* value
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
* D6 used for Register value, D5 is mode D4 is the Size D3 is direction bit
*-----------------------------------------------------------------------------
EA_TYPE5	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4
			MOVE.W	#%00000100, D3	;move data mask into D3
			LSL.W	8,D3			;shift mask 8 bits in D3

			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			AND.W	D7,D3			;and D7 and D3 store in D3 Direction
			BSR						;return to calling instruction
*-------------------------------------------------------------------------------
* Type 6 mode xxxx DDDx ssix xrrr	
* Subroutine for Shift and rotate funcitons
* D3 - stores Data
* D4 -stores Size
* D5 stores i(imediate or Register)
* D6 stores register
*-------------------------------------------------------------------------------
EA_TYPE6 	MOVE.B 	#%00001110, D3	;move data maskinto D3
			LSL.W	8,D3			; Shift it left into the upper 8 bytes
			MOVE.B	#%11000000, D4	;move size masking into D4
			MOVE.B	#%00100000,	D5	;move i masking into D5
			MOVE.B	#%00000111,	D6	;move register mask into D6
			
			AND.W	D7,D3			;value of Data in D3
			AND.W	D7,D4			;value of size in D4
			AND.W	D7,D5			;value of i in D5
			AND.W	D7,D6			;value of register in D6
			
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
