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

			MOVE.W #$0001,POSITION	*** TEST - RESET POSITION ***

			STOP #EXIT			* Halt Simulator


********************* OP-CODE Looping Algorithm Subroutine *********************

INIT_OP		* Resets the list of bitmasks & english to the begining


*--- Displaying the current address as a hexadecimal value ---*
			MOVE.W A0,D2		* Moving the current 16-bits address into D2
			BSR DISPLAY_HEX	


			LEA BITMASK,A2		* Load the bitmask list into address register 2
			LEA TASK_OP,A3		* Load the OP task list into address register 3


LOOP_OP		MOVE.W (A0),D3		* Move the current 16-bits into data register 3
			AND.W (A2),D3		* AND the current bitmask with temp instruction
			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3
			BNE NEXT_MASK		* No Match found branch to the NEXT_MASK
			

*--- Moving the cursor to the desired location ---*
			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI.W #$0A00,D1	* Setting up the desired column position
			TRAP #15			* Position the cursor at [0Axx] x - any number

	 		; MOVE.W (A0),D7 		******  TESTING 1  ******
	 		MOVEA.W A0,A4			******  TESTING 2  ******

*--- Retrieve matched task then execute by jumping to subroutine  ---*
			MOVEA.W (A3),A3		* Moves the task address into the same (An)
			JSR (A3)			* Jumps to the current task subroutine from A3


*--- Displaying the current instruction as a hexadecimal value ---*
	 		; MOVE.W (A0),D2		* Reloads the orignal 16-bits as a temp again
	 		; MOVE.W D7,D2		* Reloads the orignal 16-bits as a temp again

			MOVE.W (A4)+,D2		* Reloads the orignal 16-bits as a temp again
			BSR DISPLAY_INT		* Display the current 16-bits in Hexadecimal
	
			CMP.W (A0),D2			******  TESTING 2  ******
			BNE HELP_HEX

NW_A		LEA NEWLINE,A1		* Loading NEWLINE into (A1) for next instruction
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			BRA SHIFT_OP			* Shifts to the next 16-bits of the source code


HELP_HEX	MOVE.B #11,D0		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI #$3300,D1		* Setting up the desired column position
			TRAP #15			* Position the cursor at [2Cxx] x - any number
			MOVE.W (A4)+,D2
			BSR DISPLAY_HEX

			BRA NW_A

*---------------------- Advancing Bitmask & OP Task list -----------------------

NEXT_MASK	ADDA.W #WORD,A2		* Shifts to the next bitmask
			ADDA.W #WORD,A3		* Shifts to the next OP Name

			TST.W (A3)			* Did I reach the end of the English list?
			BNE LOOP_OP			* Go back to LOOP_OP and test the new bitmask

SHIFT_OP	ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction

			ADDQ.W #1,POSITION  *** IMPORTANT: Shifts the row position by 1 ***

			TST.W (A0)			* See if you reached the end of the instructions
			BNE INIT_OP			* (!=) Resets the bitmask & OP task lists
			RTS					* Returns from subroutine


************************ Display Hexadecimal Subroutine ************************
* Displays an output of a single 16-bit instruction as a hexadecimal value
* Take that prof. Nash (mostly Kim), I didn't want to use task #15 anyway

*** IMPORTANT *** Load the value that you wish to display in hexadecimal in D2
	
DISPLAY_INT:
*--- Moving the cursor to the desired location ---*
			MOVE.B #11,D0		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI #$2C00,D1		* Setting up the desired column position
			TRAP #15			* Position the cursor at [2Cxx] x - any number


			LEA INIT_HEX,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

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
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF
			
			LEA HEX_BITMASK,A2
			LEA HEX_VALUE,A3
			RTS					* Returns from subroutine

NEXT_HEX	ADDA.W #WORD,A2		* Shifts to the next binary
			ADDA.W #WORD,A3		* Shifts to the next hexadecimal char
			BRA LOOP_HEX		* Go back to LOOP and test the new bitmask

HEX_BITMASK	DC.W $F,$E,$D,$C,$B,$A,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0
HEX_VALUE	DC.W 'F','E','D','C','B','A','9','8','7','6','5','4','3','2','1','0'


************************ 8-Bit Displacement Subroutine *************************
* SubRoutine that displays a branching displacement as a hexadecimal value
*

DISPLACEMENT:

*--- ERROR FILTER: Checks before printing a non existing branch ---*
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			ANDI.W #$FF00,D2
			CMP.W (A2),D2
			BNE  DISPLAY_DATA

*--- PRINT OP: Prints the pre-loaded OP message to the output ---*
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF


*--- 8-bits 16-bits 32-bits ---*
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			TST.B D2
			BEQ D_16_BIT
			BRA D_8_BIT


D_16_BIT	ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			ADD.W A0,D2
			BRA D_DONE			


D_8_BIT		MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			AND.W #BITMASK8,D2
            ADDQ #2,D2
			ORI.L #$FFFFFF00,D2
			ADD.L A0,D2

D_DONE		BSR DISPLAY_HEX	
			RTS


*******************************  DATA Subroutine *******************************
*1000    DATA    $WXYZ
*
DISPLAY_DATA:
			
			LEA DATA_M,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			LEA INIT_MEM,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			MOVE.W (A0),D2
			BSR DISPLAY_HEX	
			RTS


************************* Effective Address Algorithm **************************
*-------------------------------------------------------------------------------
* Type 1 mode xxxx xxxx ssoo oorrr
* SubRoutine for handling One Operand addressing looking for a mode and register 
* value
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
* D6 used for Register value, D5 is mode D4 is the Size
*-------------------------------------------------------------------------------
EA_TYPE1	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	#3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4

			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			
			; BSR						;return to calling instruction

*-------------------------------------------------------------------------------
* Type 2 xxxx xxxx dddd dddd
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the instruciton to determine the offset being used stored in D6
*-------------------------------------------------------------------------------
EA_TYPE2	MOVE.B	#%11111111, D6	;move 8bitmask into D6
			AND.L	D7,D6			;and D7 with D6(Offset)
			; BSR

*-------------------------------------------------------------------------------
* Type 3 xxxx rrrooo oorrr
* SubRoutine for handling two Operand Effective addressing to find 2 3 bit modes
* and two 3 bit registers
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
* source register stored in D3, source mode in D4 Dest mode in D5 dest register
* in D6
*-------------------------------------------------------------------------------			
EA_TYPE3	MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D6
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D5
			MOVE.B	#BITMASK3, D4	;move primative 3 bit mask into D4
			MOVE.B	#BITMASK3, D3	;move primative 3 bit mask into D3
			
			LSL.W	#3,D5			;shift mask left 3 times
			LSL.W	#6,D4			;shift mask left 6 times
			LSL.W	#6,D3			;shift mask left 6 times
			LSL.W	#6,D3			;shift mask left 3 times
			
			AND.L	D7,D6			;and D7 with D6 DestRegister
			AND.L	D7,D5			;and D7 with D5	DestMode
			AND.L	D7,D4			;and D7 with D4 SrcMode
			AND.L	D7,D3			;and D7 with D3 SrcRegister
			
			; BSR
			
*-------------------------------------------------------------------------------
* Type 4   - xxxx DDD1 ssoo orrr
* Sub Routine to find Size and EA(mode and Register) and Data from instruction
* D3 stores Databits
* D4 Stores Size
* D5 stores Mode
* D6 stores Register
*-------------------------------------------------------------------------------			
EA_TYPE4	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	#3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4
			MOVE.W	#%00001110, D3	; move Datamask into D3
			LSL.W	#8,D3			; shift datamask 8 places
			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			AND.W	D7,D3			;and D7 and D3 store in D3 Data
	
			; BSR						;return to calling instruction

*-------------------------------------------------------------------------------
* Type 5 mode xxxx xDxx ssoo oorrr
* SubRoutine for handling One Operand addressing looking for a mode and register 
* value
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
* D6 used for Register value, D5 is mode D4 is the Size D3 is direction bit
*-----------------------------------------------------------------------------
EA_TYPE5	MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	#3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4
			MOVE.W	#%00000100, D3	;move data mask into D3
			LSL.W	#8,D3			;shift mask 8 bits in D3

			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			AND.W	D7,D3			;and D7 and D3 store in D3 Direction
			; BSR						;return to calling instruction

*-------------------------------------------------------------------------------
* Type 6 mode xxxx DDDx ssix xrrr	
* Subroutine for Shift and rotate funcitons
* D3 - stores Data
* D4 -stores Size
* D5 stores i(imediate or Register)
* D6 stores register
*-------------------------------------------------------------------------------
EA_TYPE6 	MOVE.B 	#%00001110, D3	;move data maskinto D3
			LSL.W	#8,D3			; Shift it left into the upper 8 bytes
			MOVE.B	#%11000000, D4	;move size masking into D4
			MOVE.B	#%00100000,	D5	;move i masking into D5
			MOVE.B	#%00000111,	D6	;move register mask into D6
			
			AND.W	D7,D3			;value of Data in D3
			AND.W	D7,D4			;value of size in D4
			AND.W	D7,D5			;value of i in D5
			AND.W	D7,D6			;value of register in D6
			; BSR


******************** OP-CODE: Individual Task Subroutine Set *******************

*- 000 -------------------------------------------
ROL_M		DC.B	'ROL',0		* Tested	0xE118
ROL_T		LEA ROL_M,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF
			RTS
*- 001 -------------------------------------------
LSL_M		DC.B	'LSL',0		* Tested	0xE108
LSL_T		LEA LSL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 002 -------------------------------------------
ASL_M		DC.B	'ASL',0		* Tested	0xE100
ASL_T		LEA ASL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 003 -------------------------------------------
ROR_M		DC.B	'ROR',0		* Tested	0xE018
ROR_T		LEA ROR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 004 -------------------------------------------
LSR_M		DC.B	'LSR',0		* Tested	0xE008
LSR_T		LEA LSR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 005 -------------------------------------------
ASR_M		DC.B	'ASR',0		* Tested	0xE000
ASR_T		LEA ASR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 006 -------------------------------------------
ANDA_M		DC.B	'ADDA',0	* Tested	0xD0C0
ANDA_T		LEA ANDA_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 007 -------------------------------------------
ADD_M		DC.B	'ADD',0		* Tested	0xD000
ADD_T		LEA ADD_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 008 -------------------------------------------
MULS_M		DC.B	'MULS',0	* Issue		0xC1C0
MULS_T		LEA MULS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 009 -------------------------------------------
CMP_M		DC.B	'CMP',0					0xB000
CMP_T		LEA CMP_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 010 -------------------------------------------
SUB_M		DC.B	'SUB',0					0x9000
SUB_T		LEA SUB_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 011 -------------------------------------------
DIVS_M		DC.B	'DIVS',0	* Issue		0x81C0
DIVS_T		LEA DIVS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 012 -------------------------------------------
OR_M		DC.B	'OR',0					0x8000
OR_T		LEA OR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 013 -------------------------------------------
BLT_M		DC.B	'BLT ',0				0x6D00
BLT_T		LEA BLT_M,A1
			BSR DISPLACEMENT
			RTS
*- 014 -------------------------------------------
BGE_M		DC.B	'BGE ',0				0x6C00
BGE_T		LEA BGE_M,A1
			BSR DISPLACEMENT
			RTS
*- 015 -------------------------------------------
BVC_M		DC.B	'BVC ',0				0x6800
BVC_T		LEA BVC_M,A1
			BSR DISPLACEMENT
			RTS
*- 016 -------------------------------------------
BCS_M		DC.B	'BCS ',0				0x6500
BCS_T		LEA BCS_M,A1
			BSR DISPLACEMENT
			RTS
*- 017 -------------------------------------------
BRA_M		DC.B	'BRA ',0				0x6000
BRA_T		LEA BRA_M,A1
			BSR DISPLACEMENT
			RTS
*- 018 -------------------------------------------
SUBQ_M		DC.B	'SUBQ',0				0x5100
SUBQ_T		LEA SUBQ_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 019 -------------------------------------------
JSR_M		DC.B	'JSR',0		* Tested	0x4E80
JSR_T		LEA JSR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 020 -------------------------------------------
RTS_M		DC.B	'RTS',0		* Tested	0x4E75
RTS_T		LEA RTS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 021 -------------------------------------------
NOP_M		DC.B	'NOP',0		* Tested	0x4E71
NOP_T		LEA NOP_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 022 -------------------------------------------
MOVEM_M		DC.B	'MOVEM',0				0x4880
MOVEM_T		LEA MOVEM_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 023 -------------------------------------------
NEG_M		DC.B	'NEG',0		* Tested	0x4400
NEG_T		LEA NEG_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 024 -------------------------------------------
LEA_M		DC.B	'LEA',0					0x41C0
LEA_T		LEA LEA_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 025 -------------------------------------------
MOAW_M		DC.B	'MOVEA.W',0				0x3040
MOAW_T		LEA MOAW_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 026 -------------------------------------------
MOW_M		DC.B	'MOVE.W',0				0x3000
MOW_T		LEA MOW_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 027 -------------------------------------------
MOAL_M		DC.B	'MOVEA.L',0				0x2040
MOAL_T		LEA MOAL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 028 -------------------------------------------
MOL_M		DC.B	'MOVE.L',0				0x2000
MOL_T		LEA MOL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 029 -------------------------------------------
MOB_M		DC.B	'MOVE.B',0				0x1000
MOB_T		LEA MOB_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 030 -------------------------------------------
CMPI_M		DC.B	'CMPI',0				0x0C00
CMPI_T		LEA CMPI_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 031 -------------------------------------------
BCLR_M		DC.B	'BCLR',0				0x01C0
BCLR_T		LEA BCLR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
*- 032 -------------------------------------------
ORI_M		DC.B	'ORI',0					0x0000
ORI_T		LEA ORI_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*-------------------------------- Data Section ---------------------------------

HEADER		DC.B	'ADDRESS   OP-CODE	OPERAND	    	 INSTRUCTION', 0 
INIT_HEX	DC.B	'0x',0
INIT_MEM	DC.B	'$',0
DATA_M		DC.B	'DATA ',0
NEWLINE		DC.B  CR,LF,0

POSITION 	DC.W  $0001

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
; SOURCE_C    DC.W  $4E75,$D6C7,$4EB8,$4487,$D5C2,$4E71,$4EB9,$D280,$4E71,$4E75
; 				   RTS   ADDA  JSR   NEG   ADDA  NOP   JSR   ADD   NOP   RTS
 			; DC.W  $66FC,$EE45,$E6AA,$E439,$2646,$EF45,$62FC,$E539,$303C
; 				   DATA  ASR   LSR   ROR   MOVEA ASL   DATA  ROL   MOVE.W
 			; DC.W  $E539,$6078,$EF45,$68CD,$BBBB,$E6AA,$EE45,$85C3,$0001,0
; 				   ROL   BRA   ASL   BVC   ERROR LSR   ASR   DIVS  TEST

**** Displacement TESTING - REMOVE WHEN DONE ****
; SOURCE_C	DC.W 	$4E71,$3204,$B045,$66F8,$6DFA,$4E71,$3A0B,$61F4,$60EE,$65FA,0
; SOURCE_C	DC.W 	$2803,$6FFC,$6EFC,$6DFC,$6CFC,$6BFC,$6AFC,$69FC,$68FC,$67FC
; 			DC.W 	$66FC,$65FC,$64FC,$63FC,$62FC,$60FC,0
SOURCE_C	DC.W 	$3202,$6D00,$000C,$3C0B,$6000,$0004,$3201,$4E71,$5241,0


	END		START				* last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
