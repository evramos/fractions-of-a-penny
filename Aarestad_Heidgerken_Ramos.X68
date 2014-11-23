*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

            OPT   CRE
            
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


*-------------------------------------------------------------------------------
* Display output of a single 16bit instruction (So far works with NOP only)
* Written by: Matthew Ramos
* Example output:
*     '<OPERATION>  :  <BINARY>  :  <HEXADECIMAL>'
*-------------------------------------------------------------------------------

DISPLAY_BINARY_HEXADECIMAL:

*            BSR Tab           * Displays a space between the OP & BINARY
*
*BINARY      MOVE.B #15,D0     * Moving task 15 into Data Register 0
*            MOVE.B #2,D2      * Moving value 2 into Data Register 2 [base 2]
*            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B

            BSR Tab           * Displays a space between the BINARY & HEXADECIMAL

HEXADECIMAL MOVE.B #15,D0     * Moving task 15 into Data Register 0 
            MOVE.B #16,D2     * Moving value 16 into Data Register 2 [base 16]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B


            LEA NEWLINE,A1    * Creates a newline for the next instruction. Loading NEWLINE into (A1)
            MOVE.B #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF
            RTS
           
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

SPACE       DC.B  ' :  ',0
NEWLINE     DC.B  CR,LF,0

Byte_M      DC.B  '.B ',0
Word_M      DC.B  '.W ',0
Long_M      DC.B  '.L ',0

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

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
