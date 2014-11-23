*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

            OPT   CRE
<<<<<<< HEAD
SOURCE_H    EQU   $0000A003
SOURCE_B    EQU   %0100111001110001       * 0x4E71
START       EQU   $1000
CR          EQU   $0D
LF          EQU   $0A

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

=======
            
CR          EQU   $0D
LF          EQU   $0A
START       EQU   $1000
EXIT        EQU   $2700        * Simulator stop code
WORD        EQU   2            * Advance by a word

*-------------------------------------------------------------------------------
* A0: Designated for SOURCE
* A1: Designated for Displaying text
* A2: Current Mask
* A3: English OP
* A4: 
* A5: 
* A6: 
*
* D0: Designated for task code values
* D1: Main 16bits copy of the instructions
* D2: Designated for n Base (while using task 15)
* D3: Temporary 16bits for bitmasking
* D4: 
* D5: 
* D6: 
*-------------------------------------------------------------------------------

            ORG    START      * Program begins here

            LEA SOURCE_C,A0   * Loading the source code into (A0)

RESET       LEA BITMASK,A2    * Loading the bitmask list into (A2)
            LEA ENGLISH,A3    * Loading the english list into (A3)

*-------------------------------------------------------------------------------
LOOP        MOVE.W (A0),D3

            AND.W (A2),D3     * Loads current bitmask with current instruction

            CMP.W (A2),D3     * Compares the current bitmask to Data Register 3

            BNE NEXT

            MOVEA.W (A3),A1     * Loading address from NOP message into (A1)
            MOVE.L #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

            MOVE.W (A0),D1
            BSR DISPLAY_BINARY_HEXADECIMAL
            
            BRA SHIFT

NEXT        ADDA.W #WORD,A2
            ADDA.W #WORD,A3
            ; MOVE.W (A3)+,D3


            TST.W (A2)        * End of bitmask
            BNE LOOP

SHIFT       ADDA.W #WORD,A0   * Shifts to the next set of instructions

            TST.W (A0)
            BEQ END

            BRA RESET


END         STOP #EXIT

            SIMHALT           * halt simulator


>>>>>>> master
*-------------------------------------------------------------------------------
* Display output of a single 16bit instruction (So far works with NOP only)
* Written by: Matthew Ramos
* Example output:
*     '<OPERATION>  :  <BINARY>  :  <HEXADECIMAL>'
*-------------------------------------------------------------------------------

DISPLAY_BINARY_HEXADECIMAL:

<<<<<<< HEAD
            BSR Tab           * Displays a space between the OP & BINARY

BINARY      MOVE.B #15,D0     * Moving task 15 into Data Register 0
            MOVE.B #2,D2      * Moving value 2 into Data Register 2 [base 2]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B
=======
*            BSR Tab           * Displays a space between the OP & BINARY
*
*BINARY      MOVE.B #15,D0     * Moving task 15 into Data Register 0
*            MOVE.B #2,D2      * Moving value 2 into Data Register 2 [base 2]
*            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B
>>>>>>> master

            BSR Tab           * Displays a space between the BINARY & HEXADECIMAL

HEXADECIMAL MOVE.B #15,D0     * Moving task 15 into Data Register 0 
            MOVE.B #16,D2     * Moving value 16 into Data Register 2 [base 16]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B


            LEA NEWLINE,A1    * Creates a newline for the next instruction. Loading NEWLINE into (A1)
            MOVE.B #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF
<<<<<<< HEAD


            CLR.L D3          * Clears D3 and frees for future use
            BRA LOOP          * Branching Always to (LOOP)

=======
            RTS
           
>>>>>>> master
TAB         LEA SPACE,A1      * Loading address from SPACE message into (A1)
            MOVE.B #14,D0     * Moving task 14 into Data Register 0 
            TRAP #15          * Display string at (A1) without CR, LF.
            RTS               * Returns from subroutine


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse it to find which address mode and location is being used.
*-------------------------------------------------------------------------------
OneOpEA

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse the instruciton to determine the offset being used.
*-------------------------------------------------------------------------------
OneOpDis

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
*-------------------------------------------------------------------------------
TwoOp


*-------------------------------------------------------------------------------
* Data section - Put variables and constants here

<<<<<<< HEAD
NOP_M       DC.B  'NOP',0
RTS_M       DC.B  'RTS',0
JSR_M       DC.B  'JSR ',0
NEG_M       DC.B  'NEG',0
SPACE       DC.B  ' :  ',0
=======
SPACE       DC.B  ' :  ',0
NEWLINE     DC.B  CR,LF,0
>>>>>>> master

Byte_M      DC.B  '.B ',0
Word_M      DC.B  '.W ',0
Long_M      DC.B  '.L ',0

<<<<<<< HEAD
NEWLINE     DC.B  CR,LF,0
SOURCE      DC.L  $4E71,$89ABCDEF,$4E75,$ABCD,%1010101010101010,0
=======
ANDA_M      DC.B  'ADDA',0
AND_M       DC.B  'ADD',0
JSR_M       DC.B  'JSR',0
RTS_M       DC.B  'RTS',0
NOP_M       DC.B  'NOP',0
NEG_M       DC.B  'NEG',0

SOURCE_C    DC.W  $4E75,$D6C7,$4EB8,$4487,$D5C2,$4E71,$4EB9,$D280,$4E71,$4E75
;                  RTS   ADDA  JSR   NEG   ADDA  NOP   JSR   ADD   NOP   RTS
            DC.W  $4487,0
;                  NEG

BITMASK     DC.W $D0C0,$D000,$4E80,$4E75,$4E71,$4400,0
ENGLISH     DC.W ANDA_M,AND_M,JSR_M,RTS_M,NOP_M,NEG_M,0
>>>>>>> master

    END    START        ; last line of source



<<<<<<< HEAD





=======
>>>>>>> master
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
