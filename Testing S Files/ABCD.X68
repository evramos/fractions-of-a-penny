*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
SCALE EQU $0002
    
    ORG    $1000
    
START:                  ; first instruction of program
    
    MOVE #'A',D0
    MOVE #'a',D1
    MOVE #$3FE,D2

    ABCD D0,D4
    ABCD D1,D5
    ABCD D2,D6
   
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
