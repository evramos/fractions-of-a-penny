


    ORG    $1000
START:                  ; first instruction of program
            MOVEA #$2000, A7

			MOVE.W	#%1011011110110111, D1		; Move 16 bits into D1
			BSR	    DISPLAY_REGS2
            BRA     EXIT
            
DISPLAY_DATAREG:
			LEA DATA_REG_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS

DISPLAY_ADDEREG:
			LEA ADDRESS_Ax,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
            RTS
*-------------------------------------------------------------------------------
* Display_Reg
* as source
* 16 bit regmask  A7->A0/D7->D0
* assumed to be in D1
* D2 will contain a count and points to current bit.
* D3 will store a value of the previous bit
* a value of 3 indicates that the previous char printed was a dash
* Written by: David Heidgerken
*-------------------------------------------------------------------------------
DISPLAY_REGS2:

					MOVE.L		#15, D2		; store counter count up

.top				CMP.W		#0,D2
					BEQ			.exit       ;undfined symbol?
					
					BTST		D2, D1
					BEQ			.current_zero	;if current is 0 branch to current_zero

.current_one		CMP.W 	#0, D3			;check previous value
					BEQ     .updateone
					
                    CMP     #1,D3
                    BEQ		.display_dash	;if eq branch to display_dash					
                    BRA     .next
.updateone          MOVE.L  #1, D3
					BRA		.next			;if last was dash no display needed.
		
.current_zero		CMP.L	#1, D3			;chk previous value
					BGE		.display_previous	;if 1 display previous
					

					BRA		.next				;if - go next
					
.display_dash		MOVE.L	D1,-(SP)			;move regmask onto stack
				
                    MOVE.L	D2, D1				;move counter
					SUBI    #1,  D1              ;get previous ndex
                    CMP.W	#7,	D1		        ;compare to 7
					BLE		.displaycurAx		;counter GE to 8are AddRegs		

					SUBI	#15,D1				;subtract ctr from 15 for data regs
                    NEG.W   D1
					BSR		DISPLAY_DATAREG	

					MOVE.L	#$2D,D1				;move dashvalu into D1
					MOVE.B #6,D0
					TRAP #15
	
					BRA		.current_next
					
.displaycurAx		SUBI	#7,D1				;subtract ctr from 7 for addr regs
                    NEG.W   D1
					BSR		DISPLAY_ADDEREG

					MOVE.L	#$2D,D1				;move dashvalu into D1
					MOVE.B #6,D0
					TRAP #15
					
.current_next		MOVE.L	(SP)+,D1			;move regmask back to D1
					MOVE.L	#1, D3				;update previous
					BRA		.next
					
.display_previous	MOVE.L	D1,-(SP)			;move regmask onto stack

					MOVE.L	D2, D1				;move counter into D1
					ADDI    #1, D1              ;addone to get previousvalue
					CMP.W	#7,D1				;compare to 8
					BLE		.displayprevAx			;counter GE to 8are AddRegs		
				
					SUBI	#15,D1
					NEG.W     D1
					
					BSR		DISPLAY_DATAREG		
					BRA		.display_slash

.displayprevAx		SUBI	#7,D1
                    NEG.W     D1
					BSR		DISPLAY_ADDEREG	

.display_slash  	MOVE.L	#$2F,D1				;move slashvalu into D1
					MOVE.B #6,D0
					TRAP #15
				
					BRA		.previous_next

.previous_next		MOVE.L	(SP)+,D1			;move regmask back to D1

					MOVE.L	#0, D3				;update previous
					BRA		.next
            
.next				SUBI.W	#1,D2				;sub 1 to counter
                    BRA     .top

.exit				RTS


EXIT                SIMHALT             ; halt simulator

STACK EQU $4000
ADDRESS_Ax	DC.B 	'A',0
DATA_REG_M	DC.B 	'D',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
