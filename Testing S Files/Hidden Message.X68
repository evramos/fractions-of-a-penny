*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

        LEA HIDDEN_MESSAGE_1,A1
        MOVE.B #13,D0
        TRAP #15
        
        LEA HIDDEN_MESSAGE_2,A1
        TRAP #15
        
    SIMHALT             ; halt simulator

HIDDEN_MESSAGE_1 DC.B 'Nice try Nash',0
HIDDEN_MESSAGE_2 DC.W $4E69,$6365,$2074,$7279,$204E,$6173,$6800,0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
