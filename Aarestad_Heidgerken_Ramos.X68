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


*----------------------- Address Register / Data Register ----------------------
* A0: Designated for Source Code
* A1: Designated for Displaying text
* A2: Designated for BITMASK list / TEMP POSITION
* A3: Designated for Task Operation list
* A4: 
* A5: 
* A6: 


* D0: Designated for task code values while using TRAP #15
* D1: Main 16-bits copy of the instructions (PRINTING PURPOSES)
* D2: Task 11 only
* D3: Temporary 16-bits for bitmask comparison
* D4: 
* D5: 
* D6: 
* D7: 
*


*------------------- Main Program / Initial Starting Point ---------------------

			ORG    START		* Program begins here

			LEA HEADER,A1 		* Load Dissassembler header message into A1 
			MOVE.B #13,D0 		* Move task 13 into Data Register 2
			TRAP #15			* Display the string at (A1) with CR, LF.


			LEA SOURCE_C,A0		* Load the source code into address register 0

RESET_MASK	* Resets the list of bitmasks & english to the begining

			LEA BITMASK,A2		* Load the bitmask list into address register 2
			LEA TASK_OP,A3		* Load the OP task list into address register 3


*--------------------- OP-CODE filter / Looping Algorithm ----------------------
* Comments here
*

LOOP 		MOVE.W (A0),D3		* Move the current 16-bits into data register 3

			AND.W (A2),D3		* AND the current bitmask with temp instruction

			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3

			BNE NEXT_MASK		* No Match found branch to the NEXT_MASK


			MOVE.L A0,D1		* Moving the current 16-bits address into data register 1
			MOVE.B #3,D0		* Moving task 3 into Data Register 0 
			TRAP #15			* Display signed number in D1.L in decimal in smallest field. 
			
			; LEA POSITION,A2		* Loading the OP print position into A2
			; MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			; MOVE.W (A2),D1
			; ADDQ.W #1,(A2)
			; TRAP #15

			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1
			ADDQ.W #1,POSITION
			TRAP #15

            MOVEA.W (A3),A3     * Moves the task address into the same (An)
            JSR (A3)            * Jumps to the current task subroutine from A3

			MOVE.L #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF


			BSR DISPLAY			* Display the current 16-bits address

			BRA SHIFT			* Shifts to the next 16-bits of the source code
            

*---------------------- Advancing Bitmask & OP Task list -----------------------
* Comments here
*

NEXT_MASK	ADDA.W #WORD,A2		* Shifts to the next bitmask
			ADDA.W #WORD,A3		* Shifts to the next OP Name

			TST.W (A3)			* Did I reach the end of the English list?
			BNE LOOP			* Go back to LOOP and test the new bitmask

SHIFT		ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction

			TST.W (A0)			* Checks to see if you reached the end of the instructions
			BEQ END				* (==) Branches to END stopping the program 
			BRA RESET_MASK		* Resets the bitmask & OP task lists

END
            MOVE.W #$0A01,POSITION   *** TEST ***
*			POSITION 	DC.W  $0A01,0

            STOP #EXIT			* Halt Simulator


*----------------------------- Display Subroutine ------------------------------
* Displays an output of a single 16-bit instruction 
* Written by: Matthew Ramos
*

**** Beta Display Subroutine ***************************************************
* <Address>  <OP><SIZE>	<Dn/An>,<Dn/An>		<DATA_1><DATA_2> 	<HEXADECIMAL>
* xxxxxxxx   xxxx.x 	xx,xx	$xxxxxxxx $xxxxxxxx				xxxx
*xxxxxxxx   xxx 
********************************************************************************

DISPLAY		

			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			ADDI #$2200,D1
			TRAP #15

			MOVE.L (A0),D1		* Moves the current 16-bits into D1
			MOVE.B #3,D0		* Moving task 15 into Data Register 0 
			TRAP #15			* Display an unsigned number in D1.L converted to number base 2 contained in D2.B

			LEA NEWLINE,A1		* Creates a newline for the next instruction. Loading NEWLINE into (A1)
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the NULL terminated string at (A1) without CR, LF
			RTS					* Returns from subroutine


*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse it to find which address mode and location is being used.
*-------------------------------------------------------------------------------
OneOpEA

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Displacement.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse the instruction to determine the offset being used.
*-------------------------------------------------------------------------------
OneOpDis

*-------------------------------------------------------------------------------
* SubRoutine for handling One Operand Effective addressing.
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via the stack
* and will parse the last 12 bits to determine the addressing mode and 
* locations of the data.
*-------------------------------------------------------------------------------
TwoOp



*------------------- OP-CODE: Individual Task Subroutine Set -------------------
* Comments here

*-------------------------------------------------
ROL_M		DC.B	'ROL',0		* Tested	0xE118
ROL_T		LEA ROL_M,A1
            RTS
*-------------------------------------------------
LSL_M		DC.B	'LSL',0		* Tested	0xE108
LSL_T		LEA LSL_M,A1
            RTS
*-------------------------------------------------
ASL_M		DC.B	'ASL',0		* Tested	0xE100
ASL_T		LEA ASL_M,A1
            RTS
*-------------------------------------------------
ROR_M		DC.B	'ROR',0		* Tested	0xE018
ROR_T		LEA ROR_M,A1
            RTS
*-------------------------------------------------
LSR_M		DC.B	'LSR',0		* Tested	0xE008
LSR_T		LEA LSR_M,A1
            RTS
*-------------------------------------------------
ASR_M		DC.B	'ASR',0		* Tested	0xE000
ASR_T		LEA ASR_M,A1
            RTS
*-------------------------------------------------
ANDA_M		DC.B	'ADDA',0	* Tested	0xD0C0
ANDA_T		LEA ANDA_M,A1
            RTS
*-------------------------------------------------
ADD_M		DC.B	'ADD',0		* Tested	0xD000
ADD_T		LEA ADD_M,A1
            RTS
*-------------------------------------------------
MULS_M		DC.B	'MULS',0	* Issue		0xC1C0		Not sure if corrent bitmask
MULS_T		LEA MULS_M,A1
            RTS
*-------------------------------------------------
CMP_M		DC.B	'CMP',0					0xB000
CMP_T		LEA CMP_M,A1
            RTS
*-------------------------------------------------
SUB_M		DC.B	'SUB',0					0x9000
SUB_T		LEA SUB_M,A1
            RTS
*-------------------------------------------------
DIVS_M		DC.B	'DIVS',0	* Issue		0x81C0		Not sure if corrent bitmask
DIVS_T		LEA DIVS_M,A1
            RTS
*-------------------------------------------------
OR_M		DC.B	'OR',0					0x8000
OR_T		LEA OR_M,A1
            RTS
*-------------------------------------------------
BLT_M		DC.B	'BLT',0					0x6D00		May need to make branching
BLT_T		LEA BLT_M,A1
            RTS
*-------------------------------------------------
BGE_M		DC.B	'BGE',0					0x6C00		its own subroutine loop
BGE_T		LEA BGE_M,A1
            RTS
*-------------------------------------------------
BVC_M		DC.B	'BVC',0					0x6800
BVC_T		LEA BVC_M,A1
            RTS
*-------------------------------------------------
BCS_M		DC.B	'BCS',0					0x6500
BCS_T		LEA BCS_M,A1
            RTS
*-------------------------------------------------
BRA_M		DC.B	'BRA',0					0x6000
BRA_T		LEA BRA_M,A1
            RTS
*-------------------------------------------------
SUBQ_M		DC.B	'SUBQ',0				0x5100
SUBQ_T		LEA SUBQ_M,A1
            RTS
*-------------------------------------------------
JSR_M		DC.B	'JSR',0		* Tested	0x4E80
JSR_T		LEA JSR_M,A1
            RTS
*-------------------------------------------------
RTS_M		DC.B	'RTS',0		* Tested	0x4E75
RTS_T		LEA RTS_M,A1
            RTS
*-------------------------------------------------
NOP_M		DC.B	'NOP',0		* Tested	0x4E71
NOP_T		LEA NOP_M,A1
            RTS
*-------------------------------------------------
MOVEM_M		DC.B	'MOVEM',0				0x4880
MOVEM_T		LEA MOVEM_M,A1
			RTS
*-------------------------------------------------
NEG_M		DC.B	'NEG',0		* Tested	0x4400
NEG_T		LEA NEG_M,A1
            RTS
*-------------------------------------------------
LEA_M		DC.B	'LEA',0					0x41C0
LEA_T		LEA LEA_M,A1
            RTS
*-------------------------------------------------
MOAW_M		DC.B	'MOVEA.W',0				0x3040
MOAW_T		LEA MOAW_M,A1
            RTS
*-------------------------------------------------
MOW_M		DC.B	'MOVE.W',0				0x3000
MOW_T		LEA MOW_M,A1
            RTS
*-------------------------------------------------
MOAL_M		DC.B	'MOVEA.L',0				0x2040
MOAL_T		LEA MOAL_M,A1
            RTS
*-------------------------------------------------
MOL_M		DC.B	'MOVE.L',0				0x2000
MOL_T 		LEA MOL_M,A1
            RTS
*-------------------------------------------------
MOB_M		DC.B	'MOVE.B',0				0x1000
MOB_T		LEA MOB_M,A1
            RTS
*-------------------------------------------------
CMPI_M		DC.B	'CMPI',0				0x0C00
CMPI_T		LEA CMPI_M,A1
            RTS
*-------------------------------------------------
BCLR_M		DC.B	'BCLR',0				0x01C0
BCLR_T		LEA BCLR_M,A1
            RTS
*-------------------------------------------------
ORI_M		DC.B	'ORI',0					0x0000
ORI_T		LEA ORI_M,A1
            RTS

*-------------------------------- Data Section ---------------------------------

HEADER		DC.B 'ADDRESS   OP-CODE                           HEX INSTRUCTION', 0 
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
 			DC.W  $AAAA,$EE45,$E6AA,$E439,$EF45,$E7AA,$E539,$303C
;				   ERROR ASR   LSR   ROR   ASL   LSL   ROL   MOVE.W
		    DC.W  $E539,$E7AA,$EF45,$E439,$BBBB,$E6AA,$EE45,$85C3,0
;				   ROL   LSL   ASL   ROR   ERROR LSR   ASR   DIVS


	END		START				* last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
