*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

            OPT   	CRE
SOURCE_H    EQU     $0000A003
SOURCE_B    EQU     %0100111001110001     * 0x4E71
START 		EQU		$1000		

*-------------------------------------------------------------------------------

		    ORG    START        * Program begins here

            ; MOVE.W #SOURCE_B,D1     * 0x4E71  0100111001110001
            LEA SOURCE,A1
            
LOOP        MOVE.L (A1)+,D1
            
            MOVE.W D1,D3
            ASR.W #8,D3
            ASR.W #4,D3
            
            CMPI.B #%0100,D3
            BEQ NOP
            BNE HEXADECIMAL   * else noting (just data)

        
            SIMHALT           * halt simulator


NOP         LEA NOP_M,A1      * Loading address from NOP message into (A1)
            BRA DISPLAY_OPERATION


*-------------------------------------------------------------------------------
* Display output of a single 16bit instruction (So far works with NOP only)
* 
* Example output:
*     '<OPERATION>  :  <BINARY>  :  <HEXADECIMAL>'
*-------------------------------------------------------------------------------

DISPLAY_OPERATION:

OPERATION   MOVE.L #14,D0     * Moving task 14 into Data Register 0
            TRAP #15          * Display the NULL terminated string at (A1) without CR, LF

            BSR Tab           * Displays a space between the OP & BINARY

BINARY      MOVE.B #15,D0     * Moving task 15 into Data Register 0
            MOVE.B #2,D2      * Moving value 2 into Data Register 2 [base 2]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B

            BSR Tab           * Displays a space between the BINARY & HEXADECIMAL

HEXADECIMAL MOVE.B #15,D0     * Moving task 15 into Data Register 0 
            MOVE.B #16,D2     * Moving value 16 into Data Register 2 [base 16]
            TRAP #15          * Display an unsigned number in D1.L converted to number base 2 contained in D2.B

            CLR.B D3          * Clears D3 and frees for future use
            BRA LOOP          * Branching Always to (LOOP)

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

NOP_M       DC.B    'NOP',0
SPACE       DC.B    ' :  ',0
SOURCE      DC.L    $4E71,$AAAA,0

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
