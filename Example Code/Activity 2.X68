*-------------------------------------------------------------------------------
* Title      : Activity 2
* Written by : Matthew Everett Christopher Ramos
* Date       : Monday October 27, 2014
* Description:
*-------------------------------------------------------------------------------

START:  ORG $1000            ; first instruction of program

*-------------------------------------------------------------------------------
* Code for OUTPUT
*-------------------------------------------------------------------------------

LOOP    LEA MESSAGE,A1
        MOVE.B  #14,D0
        TRAP    #15
                
*-------------------------------------------------------------------------------
* Code for INPUT
*-------------------------------------------------------------------------------

        MOVE.B  #4,D0       ; Trap task 4 does the following:
        TRAP    #15         ; Read a number from the keyboard into D1.L
        
        CMP.L   #0,D1       ; Compares D1 to the number 0
        BEQ     DONE        ; Branch to DONE if they are equal
      
        CMP.B   #20,D1       ; Compares D1 to 20
        BLT     INVALID     ; BLT branches if D1 is less than 20
        
        CMP.B   #25,D1       ; Compares D1 to 25
        BGT     INVALID     ; BFT branches if D1 is greater than 25
                
                
*-------------------------------------------------------------------------------
*  Figure out what the number actually is
*-------------------------------------------------------------------------------

        CMP.B   #20,D1           ; Compares D1 and 1
        BNE     TWO             ; BEQ branches if D1 and 1 are not equal
        LEA     DISPONE,A1      
        MOVE.B  #14,D0  
        TRAP    #15
        BRA     LOOP    
                
TWO     CMP.B   #21,D1          ; Compares D1 and 2
        BNE     THREE           ; BEQ branches if D1 and 2 are not equal
        LEA     DISPTWO,A1      
        MOVE.B  #14,D0  
        TRAP    #15
        BRA     LOOP

THREE   CMP.B   #22,D1           ; Compares D1 and 3
        BNE     FOUR            ; BEQ branches if D1 and 3 are not equal
        LEA     DISPTHR,A1      
        MOVE.B  #14,D0  
        TRAP    #15
        BRA     LOOP

FOUR    CMP.B   #23,D1           ; Compares D1 and 4
        BNE     FIVE
        LEA     DISPFOU,A1      
        MOVE.B  #14,D0  
        TRAP    #15
        BRA     LOOP

FIVE    CMP.B   #24,D1           ; Compares D1 and 2
        BNE     SIX             ; BEQ branches if D1 and 2 are not equal
        LEA     DISPFIV,A1      
        MOVE.B  #14,D0  
        TRAP    #15
        BRA     LOOP

SIX     LEA     DISPSEV,A1      
        MOVE.B  #14,D0  
        TRAP    #15

        BRA     LOOP            ; Branch to LOOP

INVALID LEA     INV,A1
        MOVE.B  #14,D0
        TRAP    #15
        BRA     LOOP            ; Branch to LOOP
        
DONE    MOVE.B  #9,D0
        TRAP    #15             ; Halt Simlator
   
MESSAGE DC.B    'Enter a number between 20 and 25, Enter 0 to exit: ',0
INV     DC.B    'That is not between 20 and 25.',CR,LF,0
DISPONE DC.B    'Fithos Lusec Wecos Vinosec',CR,LF,0
DISPTWO DC.B    'Excitate vos e somno, liberi mei',CR,LF,0
DISPTHR DC.B    'Veni hortum veritatis',CR,LF,0
DISPFOU DC.B    'Incendite tenebras mundi',CR,LF,0
DISPFIV DC.B    'Valete liberi',CR,LF,'Diebus fatalibus',CR,LF,0
DISPSIX DC.B    'Surgite',CR,LF,'Invenite',CR,LF,0
DISPSEV DC.B    'Liberi Fatali',CR,LF,0

CR      EQU     $0D
LF      EQU     $0A

    END    START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
