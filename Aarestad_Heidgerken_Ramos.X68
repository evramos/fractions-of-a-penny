*-------------------------------------------------------------------------------
* Title      : Dissassembler
* Written by : Ryan Aarestad, David Heidgerken, Matthew Ramos
* Date       : Thursday November 6, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*-------------------------------------------------------------------------------

			OPT   CRE

CR			EQU   $0D
LF			EQU   $0A
START		EQU   $1000			* Program starting address
EXIT		EQU   $2700			* Simulator stoping code
WORD		EQU   2				* Advance by a word

BITMASK8	EQU	  $00FF
BITMASK4    EQU	  $0F
BITMASK3	EQU   $07

*----------------------- Address Register / Data Register ----------------------
* A0: Designated for Source Code
* A1: Designated for Displaying text
* A2: Designated for BITMASK list
* A3: Designated for English Translation list
* A4: 
* A5: 
* A6: 
*
* D0: Designated for task code values
* D1: Main 16bits copy of the instructions (PRINT)
* D2: Designated for n Base (while using task 15)
* D3: Temporary 16-bits for bitmask comparison
* D4: 
* D5: 
* D6: 
* D7: 
*

*------------------------ Main Program / Starting Point ------------------------

			ORG    START		* Program begins here

			LEA SOURCE_C,A0		* Load the source code into address register 0

RESET_MASK	* Resets the list of bitmasks & english to the begining

			LEA BITMASK,A2		* Load the bitmask list into address register 2
			LEA ENGLISH,A3		* Load the english list into address register 3

*-------------------------------------------------------------------------------
* Comments here

LOOP 		MOVE.W (A0),D3		* Move the current 16-bits into data register 3

			AND.W (A2),D3		* AND the current bitmask with temp instruction

			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3

			BNE NEXT_MASK		* No Match found branch to the NEXT_MASK

			*************************************
			* Pass the remaining code/part to EA
			*************************************

			MOVEA.W (A3),A1		* Loading current address from ENGLISH into (A1)
			MOVE.L #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF


			MOVE.W (A0),D1		* Moves the current 16-bits into D1

			BSR DISPLAY_BINARY_HEXADECIMAL	* Display the 16-bits in base 2 & 16

			BRA SHIFT			* Shifts to the next 16-bits of the source code

*---------------------- Advancing Bitmask & English list -----------------------
* Comments here

NEXT_MASK	ADDA.W #WORD,A2		* Shifts to the next bitmask
			ADDA.W #WORD,A3		* Shifts to the next OP Name

			TST.W (A3)			* Did I reach the end of the English list?
			BNE LOOP			* Go back to LOOP and test the new bitmask

SHIFT		ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction

			TST.W (A0)			* Checks to see if you reached the end of instructions
			BEQ END				* Branches to end the program 
			BRA RESET_MASK		* Resets the bitmask & english lists

END			STOP #EXIT

			SIMHALT				* halt simulator

*----------------------------- Display Subroutine ------------------------------
* Displays an output of a single 16-bit instruction 
* Written by: Matthew Ramos
* Example output:	'<OPERATION>  :  <BINARY>  :  <HEXADECIMAL>'
*

DISPLAY_BINARY_HEXADECIMAL:

; 			BSR Tab				* Displays a space between the OP & BINARY

; BINARY		MOVE.B #15,D0		* Moving task 15 into Data Register 0
; 			MOVE.B #2,D2		* Moving value 2 into Data Register 2 [base 2]
; 			TRAP #15			* Display an unsigned number in D1.L converted to number base 2 contained in D2.B

			BSR Tab				* Displays a space between the BINARY & HEXADECIMAL

HEXADECIMAL MOVE.B #15,D0		* Moving task 15 into Data Register 0 
			MOVE.B #16,D2		* Moving value 16 into Data Register 2 [base 16]
			TRAP #15			* Display an unsigned number in D1.L converted to number base 2 contained in D2.B


			LEA NEWLINE,A1		* Creates a newline for the next instruction. Loading NEWLINE into (A1)
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the NULL terminated string at (A1) without CR, LF
			RTS					* Returns from subroutine

TAB			LEA SPACE,A1		* Loading address from SPACE message into (A1)
			MOVE.B #14,D0		* Moving task 14 into Data Register 0 
			TRAP #15			* Display string at (A1) without CR, LF.
			RTS					* Returns from subroutine


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
*D6 used for Register value, D5 is EA Mode
*-----------------------------------------------------------------------------
OneOpEA		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D3 
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D4
			LSL.W	3,D5			;shift mask left 3 times
			
			AND.W	D7,D6			;and D7 and D3 store in D3 Register
			AND.W	D7,D5			;and D7 and D4 store in D4 Mode
			
			BSR						;return to calling instruction
			


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the instruciton to determine the offset being usedstored in D3
*-------------------------------------------------------------------------------
OneOpDis	MOVE.B	#BITMASK8, D6	;move 8bitmask into D6
			AND.L	D7,D6			;and D7 with D6(Offset)
			

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
*-------------------------------------------------------------------------------
TwoOp		MOVE.B	#BITMASK3, D6	;move primative 3 bit mask into D6
			MOVE.B	#BITMASK3, D5	;move primative 3 bitmask into D5
			MOVE.B	#BITMASK3, D4	;move primative 3 bit mask into D4
			MOVE.B	#BITMASK3, D3	;move primative 3 bit mask into D3
			
			LSL.W	3,D5			;shift mask left 3 times
			LSL.W	6,D4			;shift mask left 3 times
			LSL.W	6,D3			;shift mask left 3 times
			LSL.W	6,D3			;shift mask left 3 times
			
			AND.L	D7,D6			;and D7 with D6 DestRegister
			AND.L	D7,D6			;and D7 with D5	DestMode
			AND.L	D7,D6			;and D7 with D4 SrcMode
			AND.L	D7,D6			;and D7 with D3 SrcRegister
			
			BSR



*-------------------------------- Data Section ---------------------------------

SPACE		DC.B  '  :  ',0
NEWLINE		DC.B  CR,LF,0

Byte_M		DC.B  '.B ',0
Word_M		DC.B  '.W ',0
Long_M		DC.B  '.L ',0

*----------------------------- English Translation -----------------------------

ROL_M		DC.B	'ROL',0		* Tested	0xE118
LSL_M		DC.B	'LSL',0		* Tested	0xE108
ASL_M		DC.B	'ASL',0		* Tested	0xE100
ROR_M		DC.B	'ROR',0		* Tested	0xE018
LSR_M		DC.B	'LSR',0		* Tested	0xE008
ASR_M		DC.B	'ASR',0		* Tested	0xE000
ANDA_M		DC.B	'ADDA',0	* Tested	0xD0C0
ADD_M		DC.B	'ADD',0		* Tested	0xD000
MULS_M		DC.B	'MULS',0	* Issue		0xC1C0		Not sure if corrent bitmask
CMP_M		DC.B	'CMP',0					0xB000
SUB_M		DC.B	'SUB',0					0x9000
DIVS_M		DC.B	'DIVS',0	* Issue		0x81C0		Not sure if corrent bitmask
OR_M		DC.B	'OR',0					0x8000

BLT_M		DC.B	'BLT',0					0x6D00		May need to make branching
BGE_M		DC.B	'BGE',0					0x6C00		its own subroutine loop
BVC_M		DC.B	'BVC',0					0x6800
BCS_M		DC.B	'BCS',0					0x6500
BRA_M		DC.B	'BRA',0					0x6000

SUBQ_M		DC.B	'SUBQ',0				0x5100
JSR_M		DC.B	'JSR',0		* Tested	0x4E80
RTS_M		DC.B	'RTS',0		* Tested	0x4E75
NOP_M		DC.B	'NOP',0		* Tested	0x4E71
; MOVEM_M		DC.B	'MOVEM',0
NEG_M		DC.B	'NEG',0		* Tested	0x4400
LEA_M		DC.B	'LEA',0					0x41C0
; MOVEA.L_M	DC.B	'MOVEA.L',0
; MOVE.W_M	DC.B	'MOVE.W',0
; MOVEA.L_M	DC.B	'MOVEA.L',0
; MOVE.L_M	DC.B	'MOVE.L',0
; MOVE.B_M	DC.B	'MOVE.B',0
CMPI_M		DC.B	'CMPI',0				0x0C00
BCLR_M		DC.B	'BCLR',0				0x01C0
ORI_M		DC.B	'ORI',0					0x0000

*-------------------------- English Translation List ---------------------------
* The values for this constant are set to move in parallel with those of
* the constant BITMASK via steps at label NEXT_MASK.

ENGLISH		DC.W ROL_M,LSL_M,ASL_M,ROR_M,LSR_M,ASR_M,ANDA_M,ADD_M,MULS_M,CMP_M
			DC.W SUB_M,DIVS_M,OR_M,BLT_M,BGE_M,BVC_M,BCS_M,BRA_M,SUBQ_M,JSR_M
			DC.W RTS_M,NOP_M,NEG_M,LEA_M,CMPI_M,BCLR_M,ORI_M,0


*--------------------------- Bitmask Translation List --------------------------
BITMASK		DC.W $E118,$E108,$E100,$E018,$E008,$E000,$D0C0,$D000,$C1C0,$B000
			DC.W $9000,$81C0,$8100,$6D00,$6C00,$6800,$6500,$6000,$5100,$4E80
			DC.W $4E75,$4E71,$4400,$41C0,$0C00,$01C0,$0000,0


*--------------------------------- Source Code ---------------------------------
SOURCE_C	DC.W  $4E75,$D6C7,$4EB8,$4487,$D5C2,$4E71,$4EB9,$D280,$4E71,$4E75
;				   RTS   ADDA  JSR   NEG   ADDA  NOP   JSR   ADD   NOP   RTS
			DC.W  $EE45,$E6AA,$AAAA,$E439,$EF45,$E7AA,$E539
;				   ASR   LSR   ERROR ROR   ASL   LSL   ROL
			DC.W  $E539,$E7AA,$EF45,$E439,$BBBB,$E6AA,$EE45,$85C3,0
;				   ROL   LSL   ASL   ROR   ERROR LSR   ASR   DIVS

	END		START				* last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
