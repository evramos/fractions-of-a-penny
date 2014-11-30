*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

			OPT   CRE

CR			EQU   $000D
LF			EQU   $000A
START		EQU   $1000			* Program starting address
EXIT		EQU   $2700			* Simulator stoping code
WORD		EQU   $0002			* Advance address by a word

BITMASK8	EQU   $00FF
BITMASK4	EQU   $000F
BITMASK3	EQU   $0007

*----------------------- Address Register / Data Register ----------------------
* A0: Designated for Source Code
* A1: Designated for Displaying string to the output
* A2: Designated for OP Bitmask list / Hexadecimal Bitmask list
* A3: Designated for Task Operation list / Hexadecimal value list
* A4: 
* A5: 
* A6: 


* D0: Designated for task code values while using TRAP #15
* D1: Main 16-bits copy of the instructions (PRINTING PURPOSES) / Task 11
* D2: Hexadecimal Temp convert
* D3: Temporary 16-bits for bitmask comparison
* D4: 
* D5: 
* D6: 
* D7: 

*------------------- Main Program / Initial Starting Point ---------------------

			ORG    START		* Program begins here

			LEA HEADER,A1		* Load Dissassembler header message into A1 
			MOVE.B #13,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) with CR, LF.

			LEA SOURCE_C,A0		* Load the source code into address register 0

			BSR INIT_OP			* Hunts down each Operation code like a mad man

			MOVE.W #$0A01,POSITION	*** TEST - RESET POSITION ***
			STOP #EXIT			* Halt Simulator


********************* OP-CODE Looping Algorithm Subroutine *********************

INIT_OP		* Resets the list of bitmasks & english to the begining

			MOVE.W A0,D2		* Moving the current 16-bits address into D2
			BSR DISPLAY_HEX	

			LEA BITMASK,A2		* Load the bitmask list into address register 2
			LEA TASK_OP,A3		* Load the OP task list into address register 3


LOOP_OP		MOVE.W (A0),D3		* Move the current 16-bits into data register 3

			AND.W (A2),D3		* AND the current bitmask with temp instruction

			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3
			BNE NEXT_MASK		* No Match found branch to the NEXT_MASK
			
			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Sets up the desired position
			TRAP #15			* Position the cursor at [0Axx] x - any number

			MOVEA.W (A3),A3		* Moves the task address into the same (An)

			JSR (A3)			* Jumps to the current task subroutine from A3
			; JMP (A3)			* Jumps to the current task subroutine from A3

RETURN 		MOVE.W (A0),D2		* Reloads the orignal 16-bits as a temp again
			BSR DISPLAY_INT		* Display the current 16-bits in Hexadecimal

			LEA NEWLINE,A1		* Loading NEWLINE into (A1) for next instruction
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			BRA SHIFT			* Shifts to the next 16-bits of the source code

*---------------------- Advancing Bitmask & OP Task list -----------------------

NEXT_MASK	ADDA.W #WORD,A2		* Shifts to the next bitmask
			ADDA.W #WORD,A3		* Shifts to the next OP Name

			TST.W (A3)			* Did I reach the end of the English list?
			BNE LOOP_OP			* Go back to LOOP_OP and test the new bitmask

SHIFT		ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction

			ADDQ.W #1,POSITION  *** VERY IMPORTANT: Shifts the position by 1 ***

			TST.W (A0)			* See if you reached the end of the instructions
			BNE INIT_OP			* (!=) Resets the bitmask & OP task lists
			RTS					* Returns from subroutine


************************ Display Hexadecimal Subroutine ************************
* Displays an output of a single 16-bit instruction as a hexadecimal value
* Take that prof. Nash (mostly Kim), I didn't want to use task #15 anyway

*** IMPORTANT *** Load the value that you wish to display in hexadecimal in D2
	

DISPLAY_INT	MOVE.B #11,D0		* Moving task 11 into Data Register 0
			ADDI #$2200,D1
			TRAP #15			* Position the cursor at [2Cxx] x - any number

			LEA INIT_HEX,A1
			MOVE.B #14,D0
			TRAP #15

DISPLAY_HEX LEA HEX_BITMASK,A2
			LEA HEX_VALUE,A3

			ROL #4,D2			* Shifts to read the next hexadecimal digit
			BSR LOOP_HEX		* Branch towards the loop of hex thingy

			ROL #4,D2 			* I HATE THIS, SO MUCH REPEATING CODE
			BSR LOOP_HEX		* I TRIED EVERYTHING WITHOUT USING ANOTHER
			ROL #4,D2 			* DATA REGISTER. THAT IS SUCH A WASTE... GOSH
			BSR LOOP_HEX		* SO I'M GOING TO LEAVE THIS HERE, BECUASE I 
			ROL #4,D2 			* REALLY DON"T CARE. TOO MUCH TIME WAS WASTED
			BSR LOOP_HEX		* ANNND YES!! NO MORE BAD CODE (IT WORKS DEAL)

			RTS					* Returns from subroutine

LOOP_HEX	MOVE.W D2,D3		* Move the current 16-bits into data register 3
			AND.W (A2),D3		* AND the current bitmask with temp instruction
			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3
			BNE NEXT_HEX

			LEA (A3),A1
			MOVE.B #14,D0
			TRAP #15
			
			LEA HEX_BITMASK,A2
			LEA HEX_VALUE,A3
			RTS					* Returns from subroutine

NEXT_HEX	ADDA.W #WORD,A2		* Shifts to the next binary
			ADDA.W #WORD,A3		* Shifts to the next hexadecimal char
			BRA LOOP_HEX		* Go back to LOOP and test the new bitmask

HEX_BITMASK	DC.W $F,$E,$D,$C,$B,$A,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0
HEX_VALUE	DC.W 'F','E','D','C','B','A','9','8','7','6','5','4','3','2','1','0'


************************* Effective Address Algorithm **************************
*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
*D6 used for Register value, D5 is EA Mode
*-----------------------------------------------------------------------------
; OneOpEA		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D3 
; 			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D4
; 			LSL.W	3,D5			;shift mask left 3 times
			
; 			AND.W	D7,D6			;and D7 and D3 store in D3 Register
; 			AND.W	D7,D5			;and D7 and D4 store in D4 Mode
			
			; BSR						;return to calling instruction
			

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the instruciton to determine the offset being usedstored in D3
*-------------------------------------------------------------------------------
; OneOpDis	MOVE.B	#BITMASK8, D6	;move 8bitmask into D6
; 			AND.L	D7,D6			;and D7 with D6(Offset)
			

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
*-------------------------------------------------------------------------------
; TwoOp		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D6
; 			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D5
; 			MOVE.B	#BITMASK3, D4	;move primative 3 bit mask into D4
; 			MOVE.B	#BITMASK3, D3	;move primative 3 bit mask into D3
			
; 			LSL.W	3,D5			;shift mask left 3 times
; 			LSL.W	6,D4			;shift mask left 3 times
; 			LSL.W	6,D3			;shift mask left 3 times
; 			LSL.W	6,D3			;shift mask left 3 times
			
; 			AND.L	D7,D6			;and D7 with D6 DestRegister
; 			AND.L	D7,D6			;and D7 with D5	DestMode
; 			AND.L	D7,D6			;and D7 with D4 SrcMode
; 			AND.L	D7,D6			;and D7 with D3 SrcRegister
			
			; BSR




******************** OP-CODE: Individual Task Subroutine Set *******************

*-------------------------------------------------
ROL_M		DC.B	'ROL',0		* Tested	0xE118
ROL_T		LEA ROL_M,A1
			MOVE.L #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF
			RTS
			; BRA RETURN
*-------------------------------------------------
LSL_M		DC.B	'LSL',0		* Tested	0xE108
LSL_T		LEA LSL_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
ASL_M		DC.B	'ASL',0		* Tested	0xE100
ASL_T		LEA ASL_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN			
*-------------------------------------------------
ROR_M		DC.B	'ROR',0		* Tested	0xE018
ROR_T		LEA ROR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
LSR_M		DC.B	'LSR',0		* Tested	0xE008
LSR_T		LEA LSR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
ASR_M		DC.B	'ASR',0		* Tested	0xE000
ASR_T		LEA ASR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
ANDA_M		DC.B	'ADDA',0	* Tested	0xD0C0
ANDA_T		LEA ANDA_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
ADD_M		DC.B	'ADD',0		* Tested	0xD000
ADD_T		LEA ADD_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MULS_M		DC.B	'MULS',0	* Issue		0xC1C0
MULS_T		LEA MULS_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
CMP_M		DC.B	'CMP',0					0xB000
CMP_T		LEA CMP_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
SUB_M		DC.B	'SUB',0					0x9000
SUB_T		LEA SUB_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
DIVS_M		DC.B	'DIVS',0	* Issue		0x81C0
DIVS_T		LEA DIVS_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
OR_M		DC.B	'OR',0					0x8000
OR_T		LEA OR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BLT_M		DC.B	'BLT',0					0x6D00
BLT_T		LEA BLT_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BGE_M		DC.B	'BGE',0					0x6C00
BGE_T		LEA BGE_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BVC_M		DC.B	'BVC',0					0x6800
BVC_T		LEA BVC_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BCS_M		DC.B	'BCS',0					0x6500
BCS_T		LEA BCS_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BRA_M		DC.B	'BRA ',0				0x6000
BRA_T		LEA BRA_M,A1
			MOVE.L #14,D0
			TRAP #15

			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			AND.W #BITMASK8,D2

			ASL.W #8, D2
			ASR.W #8, D2

			; ADD.W A0,D2

			BSR DISPLAY_HEX	
			
			RTS
			; BRA RETURN
*-------------------------------------------------
SUBQ_M		DC.B	'SUBQ',0				0x5100
SUBQ_T		LEA SUBQ_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
JSR_M		DC.B	'JSR',0		* Tested	0x4E80
JSR_T		LEA JSR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
RTS_M		DC.B	'RTS',0		* Tested	0x4E75
RTS_T		LEA RTS_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
NOP_M		DC.B	'NOP',0		* Tested	0x4E71
NOP_T		LEA NOP_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOVEM_M		DC.B	'MOVEM',0				0x4880
MOVEM_T		LEA MOVEM_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
NEG_M		DC.B	'NEG',0		* Tested	0x4400
NEG_T		LEA NEG_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
LEA_M		DC.B	'LEA',0					0x41C0
LEA_T		LEA LEA_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOAW_M		DC.B	'MOVEA.W',0				0x3040
MOAW_T		LEA MOAW_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOW_M		DC.B	'MOVE.W',0				0x3000
MOW_T		LEA MOW_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOAL_M		DC.B	'MOVEA.L',0				0x2040
MOAL_T		LEA MOAL_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOL_M		DC.B	'MOVE.L',0				0x2000
MOL_T		LEA MOL_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
MOB_M		DC.B	'MOVE.B',0				0x1000
MOB_T		LEA MOB_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
CMPI_M		DC.B	'CMPI',0				0x0C00
CMPI_T		LEA CMPI_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
BCLR_M		DC.B	'BCLR',0				0x01C0
BCLR_T		LEA BCLR_M,A1
			MOVE.L #14,D0
			TRAP #15
			RTS
			; BRA RETURN
*-------------------------------------------------
ORI_M		DC.B	'ORI',0					0x0000
ORI_T		LEA ORI_M,A1
			MOVE.L #14,D0
			TRAP #15
            RTS
			; BRA RETURN

*-------------------------------- Data Section ---------------------------------

HEADER		DC.B 'ADDRESS   OP-CODE	OPERAND	    	 INSTRUCTION', 0 
INIT_HEX	DC.B '0x',0
NEWLINE		DC.B  CR,LF,0
POSITION 	DC.W  $0A01,0

; Byte_M		DC.B  '.B ',0
; Word_M		DC.B  '.W ',0
; Long_M		DC.B  '.L ',0

*---------------------------- Task Operation List ------------------------------
* The values for this constant are set to move in parallel with those of
* the constant BITMASK via steps at label NEXT_MASK.

TASK_OP		DC.W ROL_T,LSL_T,ASL_T,ROR_T,LSR_T,ASR_T,ANDA_T,ADD_T,MULS_T,CMP_T
			DC.W SUB_T,DIVS_T,OR_T,BLT_T,BGE_T,BVC_T,BCS_T,BRA_T,SUBQ_T,JSR_T
			DC.W RTS_T,NOP_T,MOVEM_T,NEG_T,LEA_T,MOAW_T,MOW_T,MOAL_T,MOL_T,MOB_T
			DC.W CMPI_T,BCLR_T,ORI_T,0

*--------------------------- Bitmask Translation List --------------------------
BITMASK		DC.W $E118,$E108,$E100,$E018,$E008,$E000,$D0C0,$D000,$C1C0,$B000
			DC.W $9000,$81C0,$8000,$6D00,$6C00,$6800,$6500,$6000,$5100,$4E80
			DC.W $4E75,$4E71,$4880,$4400,$41C0,$3040,$3000,$2040,$2000,$1000
			DC.W $0C00,$01C0,$0000,0

*--------------------------------- Source Code ---------------------------------
SOURCE_C    DC.W  $4E75,$D6C7,$4EB8,$4487,$D5C2,$4E71,$4EB9,$D280,$4E71,$4E75
;				   RTS   ADDA  JSR   NEG   ADDA  NOP   JSR   ADD   NOP   RTS
 			DC.W  $AAAA,$EE45,$E6AA,$E439,$2646,$EF45,$E7AA,$E539,$303C
;				   ERROR ASR   LSR   ROR   MOVEA ASL   LSL   ROL   MOVE.W
 			DC.W  $E539,$6078,$EF45,$68CD,$BBBB,$E6AA,$EE45,$85C3,$0001,0
;				   ROL   BRA   ASL   BVC   ERROR LSR   ASR   DIVS  TEST

; SOURCE_C	DC.W 	$1401,$1401,$60FC,$1401,0


	END		START				* last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
