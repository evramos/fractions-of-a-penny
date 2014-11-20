*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

            OPT   	CRE
SOURCE_H    EQU     $4E71
SOURCE_B    EQU     %0100111001110001
START 		EQU		$1000		

*-------------------------------------------------------------------------------

		    ORG    START                * Program begins here

            MOVE.W #SOURCE_B,D1           * 0x4E71  0100111001110001
            
            
            MOVE.W D1,D3
            ASR.W #8,D3
            ASR.W #4,D3
            
LOOP        CMPI.B #%0100,D3
            BEQ DISPLAY_R
                        
        
            SIMHALT                     * halt simulator

*-------------------------------------------------------------------------------
DISPLAY_R   BSR OPERATION
            BSR TAB
            BSR BINARY
            BSR TAB
            BSR HEXADECIMAL
            
            CLR.B D3
            BRA LOOP

OPERATION   LEA NOP,A1                  * Loading "NOP" message into A1
            MOVE.L #14,D0                            
            TRAP #15
            RTS

BINARY      MOVE.B #15,D0
            MOVE.B #2,D2
            TRAP #15
            RTS

HEXADECIMAL MOVE.B #15,D0
            MOVE.B #16,D2
            TRAP #15
            RTS

TAB         LEA SPACE,A1                * Loading "  :  " message into A1
            MOVE.B #14,D0
            TRAP #15
            RTS   


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

NOP         DC.B    'NOP',0
SPACE       DC.B    ' :  ',0

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
