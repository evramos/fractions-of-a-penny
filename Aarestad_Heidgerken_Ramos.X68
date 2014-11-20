*-----------------------------------------------------------
* Title      :Dissassembler
* Written by :Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       :  Thursday November 6, 2014
* Description:Assembly language program that can read a string of binary
    and decode it into Assembly language instructions.  
*-----------------------------------------------------------
    

    ORG    $1000

START:                  ; first instruction of program


* Put program code here



    SIMHALT             ; halt simulator








----------------------------------------------------------------------------
*SubRoutine for handling One Operand Effective addressing.
*Written by: David Heidgerken
*Description.  16 bit Instruction will be passed to subroutine via the stack
    and will parse it to find which address mode and location is being used.
OneOpEA

*------------------------------------------------------------------------------
*SubRoutine for handling One Operand Displacement.
*Written by: David Heidgerken
*Description.  16 bit Instruction will be passed to subroutine via the stack
*   and will parse the instruciton to determine the offset being used.

OneOpDis

*------------------------------------------------------------------------------
*SubRoutine for handling One Operand Effective addressing.
*Written by: David Heidgerken
*Description.  16 bit Instruction will be passed to subroutine via the stack
    and will parse the last 12 bits to determine the addressing mode and 
    locations of the data.
*------------------------------------------------------------------------------
TwoOp

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
