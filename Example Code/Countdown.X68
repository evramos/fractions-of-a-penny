**-----------------------------------------------------------
** Title      : Counting Down between 1 and 100
** Written by : Matthew Everett Christopher Ramos
** Date       : Monday November 10, 2014
** Description: It just counts down, what else do you want from me
**-----------------------------------------------------------

LF  EQU  $0A   New line (line feed)
CR  EQU  $0D   Carriage Return

START ORG    $1000

**===========================================================
* WELCOME MESSAGE

    LEA MESSAGE,A1   Loads welcome message to A1
    MOVE.B #14,D0    Sets D0 to task 14.
    TRAP #15         Display A1 in output
    
*------------------------------------------------------------
* INPUT AND RANGE CHECKER (1-100)

    MOVE.B #4,D0        Sets D0 with task 4 (Read a number input)
    TRAP #15            Triggers input number into D1 as a long
    
    CMP.B #0,D1         Compares D1 to the number 0
    BEQ DONE            Branch to DONE if they are equal
    
    CMP.B #1,D1         Sets a comparison between D1 and 1
    BLT INVALID         Checks D1 if it is less than 1
    
    CMP.B   #100,D1     Sets a comparison between D1 and 100
    BGT INVALID         Checks D1 if it is greater than 100
    
*------------------------------------------------------------
* COUNTING DOWN METHOD

    MOVE.B #$F,D0       Sets D0 with task 15 to display a unsigned number
    MOVE.B #$A,D2       Using base 10 to display D0
    LEA NEWLINE,A1      Load newline in A1

LOOP:                   ;FOR LOOP
    SUB.L #1,D1         Adds 8 bytes to D1
    TRAP #15            Display D1 in output
    
    MOVE.B #14,D0       Switches D0 to task 14.
    TRAP #15            Display A1 in output
    
    MOVE.B #$F,D0       (CHANGE BACK)D0 to task 15 to display a unsigned number

    
    CMP.W #$0000,D1     Compares D1 to x value
    BNE LOOP            Branches to LOOP till not equal say x value
    
    LEA END,A1
    MOVE.B #14,D0       Sets D0 to task 14.
    TRAP #15            Display A1 in output
    
    BRA START           Always branchs back to the start of the program
    
DONE:
    LEA PRGEND,A1       Loan program terminate message
    MOVE.B #14,D0       Sets D0 to task 14.
    TRAP #15            Displays PRGEND message
        SIMHALT         Halt simulator

*------------------------------------------------------------
INVALID LEA INV,A1
        MOVE.B #14,D0   Sets D0 to task 14.
        TRAP #15        Display A1 in output
        BRA START       Branch back to START
        
INV     DC.B    'That is not between 1-100.',CR,LF,CR,LF,0
MESSAGE DC.B 'Input a number(1-100);0 to exit: ', 0
NEWLINE DC.B CR,LF,0
END     DC.B 'BOOM!!',CR,LF,CR,LF,0
PRGEND  DC.B 'Program has terminate',0

    END    START        Last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
