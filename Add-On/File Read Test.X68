
EXIT		EQU  	$2700			; Simulator stoping code
CR			EQU  	$000D
LF			EQU 	$000A

START       ORG     $1000
*---------------------------------------------------------------------------------------------------
		    LEA     FILENAME,A1     ; TASK #52
		    MOVE    #52,D0          ;   Open new file..
		    TRAP    #15             ;   As above except the file is created if not found.
*---------------------------------------------------------------------------------------------------

			LEA 	MESSAGE,A1
			MOVE 	#14,D0
			TRAP	#15

			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE

            MOVE  	#50,D0
            TRAP    #15             ; close all files
			STOP 	#EXIT			* Halt Simulator

*---------------------------------------------------------------------------------------------------
****************************************************************************************************
*---------------------------------------------------------------------------------------------------
PRINT_TO_FILE:			
			MOVE 	#22,D0			; Read CHAR		
			MOVE.L	ROW,D1			; Sets the row position to feed the string into memory [row,column 0000,0000] CLEARS D1 of any previous memory
			MOVE  	D1,D5			; Copy the datasize from LINE into D5

			MOVE  	#79,D2			; Counter and holds number of bytes to write (unaltered upon return)
			
.OFFSET 	MOVE  	D2,D1			; Sets the ending point feeding the string backwards
			TRAP	#15				; Triggers task 22 and reads a CHAR
			CMPI 	#' ',D1			; Compare the result from task 22 to see if it's the ascii HEX 20
			DBNE	D2,.OFFSET 		; D2--, if D2 = -1 STOP, otherwise branch to OFFSET

			MOVE  	D2,D3			; Copy the counter to another counter
			ADDQ	#3,D2			; Adjust the datasize by adding one to compensate the offset balance 
			ADD     D2,D5 			;  *** KNOWN ISSUES ***
			CLR     D1 
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
			LEA 	DATA,A1

			CLR 	D4				  *** Quick fix to clear D4 before using ***


.READ_CHAR	TRAP	#15				; Triggers task 22 and reads a CHAR
			MOVE.B 	D1,(A1)+
			ADDQ 	#1,D4
			MOVE  	D4,D1
            DBF     D3,.READ_CHAR   ; D3--, if D3 = -1 STOP, otherwise branch to LOOP_HERE

            MOVE.B 	#CR,(A1)+
            MOVE.B 	#LF,(A1)+

            CLR  	D4
*---------------------------------------------------------------------------------------------------
            CLR.L   D1        		; Sets the File-ID (FID)
            MOVE    #54,D0          ; write to file TASK #54
            						; D2 aready is set for the number of bytes
            LEA     DATA,A1         ; data to write         Write file
            TRAP    #15

            MOVE    #55,D0			
			MOVE    D5,D2		  	; *** KNOWN ISSUES ***
            TRAP    #15

            ADDQ 	#1,ROW			; Shift to the next row position
            MOVE 	D5,ROW+2

			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
****************************************************************************************************
*---------------------------------------------------------------------------------------------------

					*          10        20        30        40        50        60        70        80
					*--------------------------------------------------------------------------------
MESSAGE		DC.B	'The Dragon In The Dungeon                                                       ',CR,LF
			DC.B 	'#1 of The Dragon In The Dungeon                                                 ',CR,LF
			DC.B 	'A young woman ventures deep into a massive dungeon to begin caring for it''s only',CR,LF
			DC.B 	'captive, an old dragon held for mysterious reasons. Having long been neglected  ',CR,LF
			DC.B 	'she decides the old dragon could use a good hot bath, and in the end they both  ',CR,LF
			DC.B 	'enjoy the encounter far more then they could have anticipated.                  ',0

FILENAME    DC.B    'data.txt',0
ROW 	   	DC.L 	$00000000
TEMPA		DC.B 	'START >>'
DATA    	DS.B 	82
TEMPB		DC.B 	'<< END',0

    END     START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
