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
BYTE 		EQU   $0001 		* Advance address by a byte
WORD		EQU   $0002			* Advance address by a word
LONG		EQU   $0004			* Advance address by a long
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

******************** Main Program / Initial Starting Point *********************

			ORG    START		* Program begins here

			LEA SOURCE_C,A2		* Loading the source into address register A2

NEXT_SOURCE	MOVEA.L (A2)+,A0		*******  TESTING BETA  ******

			MOVE.L A2,SOURCE_LIST

*---------------------------- Displaying to output -----------------------------

			LEA LINE,A1
			MOVE.B #14,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.
			MOVE.B #13,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.

			LEA HEADER,A1		* Load Dissassembler header message into A1 
			TRAP #15			* Display the string at (A1) with CR, LF.

			LEA LINE,A1
			MOVE.B #14,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.
			MOVE.B #13,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.


			ADDQ.W #3,POSITION  *** IMPORTANT: Shifts the row position by 3 ***

			BSR INIT_OP			* Hunts down each Operation code like a mad man

			LEA LINE,A1
			MOVE.B #14,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.
			MOVE.B #13,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.

			LEA PRESS_ANY,A1
			MOVE.B #14,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.

*------------------------ Press ANY key to continue to -------------------------

			MOVE.B #5,D0		*******  TESTING BETA  ******
			TRAP #15			*******  TESTING BETA  ******

			MOVE.L SOURCE_LIST,A2

			TST.L (A2)			*******  TESTING BETA  ******
			BEQ END_PROGRAM		*******  TESTING BETA  ******

			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W #$FF00,D1	* Clear Screen : Set D1.W to $FF00
			TRAP #15

			CLR.W POSITION			*** TEST - RESET POSITION ***

			BRA NEXT_SOURCE

END_PROGRAM	CLR.W POSITION			*** TEST - RESET POSITION ***
			STOP #EXIT			* Halt Simulator


********************* OP-CODE Looping Algorithm Subroutine *********************

INIT_OP		* Resets the list of bitmasks & english to the begining

*----------- Displaying the current address as a hexadecimal value -------------

			MOVE.L A0,D2		* Moving the current 16-bits address into D2
			BSR DISPLAY_LONG_HEX

			LEA BITMASK,A2		* Load the bitmask list into address register 2
			LEA TASK_OP,A3		* Load the OP task list into address register 3


LOOP_OP		MOVE.W (A0),D3		* Move the current 16-bits into data register 3
			AND.W (A2),D3		* AND the current bitmask with temp instruction
			CMP.W (A2),D3		* Compares the current bitmask in (A2) with D3
			BNE NEXT_MASK		* No Match found branch to the NEXT_MASK
			
*----------------- Moving the cursor to the desired location -------------------

			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI.W #$0A00,D1	* Setting up the desired column position
			TRAP #15			* Position the cursor at [0Axx] x - any number

			MOVE.L A0,SAVE_STATE	******  TESTING BETA  ******

			MOVE.W (A0),D7 		 ***** Saving current instruction in D7 *****

*-------- Retrieve matched then execute task by jumping to subroutine ----------

			MOVEA.W (A3),A3		* Moves the task address into the same (An)
			JSR (A3)			* Jumps to the current task subroutine from A3

			BSR DISPLAY_INTRUCTION	******  TESTING BETA  ******

			BRA SHIFT_OP		* Shifts to the next 16-bits of the source code

*---------------------- Advancing Bitmask & OP Task list -----------------------

NEXT_MASK	ADDA.W #WORD,A2		* Shifts to the next bitmask
			ADDA.W #WORD,A3		* Shifts to the next OP Name

			TST.W (A3)			* Did I reach the end of the English list?
			BNE LOOP_OP			* Go back to LOOP_OP and test the new bitmask

SHIFT_OP	ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction

			MOVE.W POSITION,D0		******  TESTING BETA  ******
			CMPI.B #$1F,D0			******  TESTING BETA  ******
			BEQ POSI_CHECK			******  TESTING BETA  ******

			ADDQ.W #1,POSITION  *** IMPORTANT: Shifts the row position by 1 ***

POSI_CHECK	TST.W (A0)			* See if you reached the end of the instructions
			BNE INIT_OP			* (!=) Resets the bitmask & OP task lists
			RTS					* Returns from subroutine


************************ Display Instruction Subroutine ************************

DISPLAY_INTRUCTION:

*--------- Displaying the current instruction as a hexadecimal value -----------

			MOVEA.L SAVE_STATE,A4	******  TESTING BETA  ******

			MOVE.W (A4)+,D2		* Reloads the orignal 16-bits as a temp again



*----------------- Moving the cursor to the desired location -------------------

			MOVE.B #11,D0		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI #$3500,D1		* Setting up the desired column position
			TRAP #15			* Position the cursor at [2Cxx] x - any number

			ADDI #$0200,D1			******  TESTING BETA  ******

			LEA INIT_HEX,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			BSR DISPLAY_WORD_HEX

CHECK_VALUE	CMP.W (A0),D2			******  TESTING BETA  ******
			BEQ NEWLINE				******  TESTING BETA  ******

			MOVE.B #11,D0		* Moving task 11 into Data Register 0
			ADDI #$0500,D1			******  TESTING BETA  ******
			TRAP #15			* Position the cursor at [2Cxx] x - any number

			MOVE.W (A4)+,D2			******  TESTING BETA  ******
			BSR DISPLAY_WORD_HEX	******  TESTING BETA  ******
			BRA CHECK_VALUE			******  TESTING BETA  ******

NEWLINE		LEA NEWLINE_M,A1	* Loading NEWLINE into (A1) for next instruction
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF
			RTS					* Returns from subroutine


************************ Display Hexadecimal Subroutine ************************
* Displays an output of a single 16-bit instruction as a hexadecimal value
* Take that prof. Nash (mostly Kim), I didn't want to use task #15 anyway

*** IMPORTANT *** Load the value that you wish to display in hexadecimal in D2

DISPLAY_LONG_HEX:

			ROL.L #4,D2
			BSR INTI_LOOP
			ROL.L #4,D2	
			BSR INTI_LOOP
			ROL.L #4,D2	
			BSR INTI_LOOP
			ROL.L #4,D2	
			BSR INTI_LOOP
			ROL.L #4,D2	
			BSR INTI_LOOP
			ROL.L #4,D2
			BSR INTI_LOOP
			ROL.L #4,D2
			BSR INTI_LOOP
			ROL.L #4,D2
			BSR INTI_LOOP

			RTS

DISPLAY_WORD_HEX:
			
			MOVE.W D1,D3 		* Saves the current position into D3 for later

			ROL #4,D2			* Shifts to read the next hexadecimal digit
			BSR INTI_LOOP		* Branch towards the loop of hex thingy

			ROL #4,D2 			* I HATE THIS, SO MUCH REPEATING CODE
			BSR INTI_LOOP		* I TRIED EVERYTHING WITHOUT USING ANOTHER
			ROL #4,D2 			* DATA REGISTER. THAT IS SUCH A WASTE... GOSH
			BSR INTI_LOOP		* SO I'M GOING TO LEAVE THIS HERE, BECUASE I 
			ROL #4,D2 			* REALLY DON"T CARE. TOO MUCH TIME WAS WASTED
			BSR INTI_LOOP		* ANNND YES!! NO MORE BAD CODE (IT WORKS DEAL)

			MOVE.W D3,D1 		* Move the saved position from D1 before display
			RTS					* Returns from subroutine

DISPLAY_BYTE_HEX:

			ROL #4,D2			* Shifts to read the next hexadecimal digit
			BSR INTI_LOOP		* Branch towards the loop of hex thingy
			ROL #4,D2
			BSR INTI_LOOP
			RTS					* Returns from subroutine


*----------------- Heart of the hexadecimal display Algorithm ------------------

INTI_LOOP	MOVE.W D2,D1		* Move the current 16-bits into data register 3

			ANDI.W #$000F,D1
			CMPI.B #9,D1
			BGT	PRINT_HEX
			
			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15

			RTS

PRINT_HEX	LEA HEX_BITMASK,A2
			LEA HEX_VALUE,A3

LOOP_HEX	MOVE.B D1,D0
			AND.W (A2),D0		* AND the current bitmask with temp instruction
			CMP.W (A2),D0		* Compares the current bitmask in (A2) with D0
			BNE NEXT_HEX

			LEA (A3),A1 		* Loads the correct hex value to be printed
			MOVE.W #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF
			RTS					* Returns from subroutine

NEXT_HEX	ADDA.W #WORD,A2		* Shifts to the next binary
			ADDA.W #WORD,A3		* Shifts to the next hexadecimal char
			BRA LOOP_HEX		* Go back to LOOP and test the new bitmask

HEX_BITMASK	DC.W $F,$E,$D,$C,$B,$A
HEX_VALUE   DC.W 'F','E','D','C','B','A'


************************ 8-Bit Displacement Subroutine *************************
* Subroutine that displays a branching displacement as a hexadecimal value
*

DISPLACEMENT:

*--------- ERROR FILTER: Checks before printing a non existing branch ----------
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			ANDI.W #$FF00,D2
			CMP.W (A2),D2
			BNE  DISPLAY_ERROR

*---------- PRINT OP: Prints the pre-loaded OP message to the output -----------
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF


*----------------------- Display 8-bits 16-bits 32-bits ------------------------

			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			TST.B D2
			BEQ D_16_BIT

			CMPI.B #$FF,D2			******  TESTING BETA  ******
			BEQ D_32_BIT			******  TESTING BETA  ******

			BRA D_8_BIT

D_32_BIT	ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			SWAP D2
			
			ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2

			SUBQ.L #4,D2
			ADD.L A0,D2

			BSR DISPLAY_LONG_HEX
			RTS

D_16_BIT	ADDA.W #WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			ADD.W A0,D2
			BSR DISPLAY_WORD_HEX
			RTS	

D_8_BIT		MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			AND.W #BITMASK8,D2
			ADDQ #2,D2
			ORI.L #$FFFFFF00,D2
			ADD.L A0,D2
			BSR DISPLAY_WORD_HEX	
			RTS					* Returns from subroutine


******************** Display the Size (.B .W .L) Subroutine ********************

DISPLAY_SIZE:

			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			CMPI.B #$C0,D1
			BNE CHECK_A
			RTS

CHECK_A 	CMPI.B #$80,D1
			BNE CHECK_B

			LEA LONG_M,A1		* Loading message '.L' into address register 1
			BRA CHECK_D

CHECK_B		CMPI.B #$40,D1
			BNE CHECK_C

			LEA WORD_M,A1		* Loading message '.W' into address register 1
			BRA CHECK_D

CHECK_C		LEA BYTE_M,A1		* Loading message '.B' into address register 1

CHECK_D		TRAP #15			* Display the string at (A1) without CR, LF


			MOVE.W D1,D2 				******  TESTING BETA  ******


*----------------- Moving the cursor to the desired location -------------------

			MOVE.B #11,D0		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI #$1600,D1		* Setting up the desired column position
			TRAP #15			* Position the cursor at [2Cxx] x - any number	


			MOVE.W D2,D1 				******  TESTING BETA  ******

			RTS					* Returns from subroutine


************************ DISPLAY ERROR DATA Subroutine *************************
*1000	DATA	$WXYZ
*
DISPLAY_ERROR:
			LEA DATA_M,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			LEA INIT_MEM,A1
			MOVE.B #14,D0		* Moving task 14 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF

			MOVE.W (A0),D2
			BSR DISPLAY_WORD_HEX	
			RTS


****************** DISPLAY Dx,Ax,(Ax),(Ax)+,-(Ax) Subroutine *******************

DATA_REG_M DC.B 'D', 0
DISPLAY_DATAREG:

			LEA DATA_REG_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS

ADDER_REG_M DC.B 'A',0
DISPLAY_ADDEREG:

			LEA ADDER_REG_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS
			
INDIRO_M   DC.B '(A',0
INDIRC_M   DC.B ')',0			
DISPLAY_INDIR:

			LEA INDIRO_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS
			
			LEA INDIRC_M,A1
			MOVE.B #14,D0
			TRAP #15
			

POSTO_M   DC.B '(A',0
POSTC_M   DC.B ')+',0			
DISPLAY_POSTINC:

			LEA POSTO_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS
			
			LEA POSTC_M,A1
			MOVE.B #14,D0
			TRAP #15
			
PREO_M   DC.B '(A',0
PREC_M   DC.B ')+',0			
DISPLAY_PREDEC:

			LEA PREO_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS
			
			LEA PREC_M,A1
			MOVE.B #14,D0
			TRAP #15


************************* Effective Address Algorithm **************************
*-------------------------------------------------------------------------------
* Type 1 mode xxxx xxxx ssoo oorrr
* Subroutine for handling One Operand addressing looking for a mode and register 
* value
* Written by: David Heidgerken
* Description.  16 bit Instruction will be passed to subroutine via D7
* and will parse it to find which address mode and location is being used.
* D6 used for Register value, D5 is mode D4 is the Size
*-------------------------------------------------------------------------------
EA_TYPE1:
			MOVE.B	#%00000111, D6	;move primative 3 bit mask into D3 
			MOVE.B	#%00000111, D5	;move primative 3 bitmask into D4
			LSL.W	#3,D5			;shift mask in D5 left 3 times
			MOVE.W  #%11000000, D4	;move size mask into D4

			
			AND.W	D7,D6			;and D7 and D6 store in D6 Register
			AND.W	D7,D5			;and D7 and D5 store in D5 Mode
			AND.W	D7,D4			;and D7 and D4 store in D4 Size
			
			MOVE.L	D4,D1			;load sizeinto D1
			
			CMP.B	#3,D1			;siz of %11(3) is invalid
			BEQ		.INV_SIZE		;branch to invalid size block
			
			BSR		DISPLAY_SIZE	;send to display size subr
			
			CMP.B 	#0, D5			;compare mode with 0
			BEQ		.D_MODE			;branch to Data reg mode
			
			CMP.B	#1, D5			;compare mode with 1
			BEQ		.A_MODE			;branch to Address reg mode
			
			CMP.B	#2, D5			;compare mode with #2
			BEQ		.IND_MODE		;branch to indirect Mode (Ax)

			CMP.B	#3, D5			;compare mode with 3
			BEQ		.PI_MODE			; branch tp post incrementmodebr
			
			CMP.B	#4, D5			;compare mode with 4
			BEQ		.PD_MODE			;branchto Post decrement mode
			
			CMP.B	#5, D5			; compare mode with 5 (not implemented)
			BEQ		.INV_MODE		;brancht invalid mode
			
			CMP.B	#6, D5			; compare mode to 6 (not implemented)
			BEQ		.INV_MODE		;brancht invalid mode

			CMP.B	#7, D5			; compare mode with 7
			BEQ		.DATA_MODE		; branc to data modes
			
.INV_SIZE	BSR		DISPLAY_ERROR	;display error	
			BRA		.break			;break from type subroutine
			
.INV_MODE 	BSR		DISPLAY_ERROR	;display error
			BRA		.break			;break from type subroutine
			
.D_MODE		MOVE.W	D6,D1			;move reg value to D1
			BSR		DISPLAY_DATAREG	;send to data register display subr  ********
			BRA		.break			;break

.A_MODE		BRA		.INV_MODE		;invalid mode for this type

.IND_MODE	MOVE.W	D6,D1			;move reg value to D1
			BSR		DISPLAY_INDIR	;send to data register indirect subr  ********
			BRA		.break			;break
			
.PI_MODE		MOVE.W	D6,D1			;move reg value to D1
			BSR		DISPLAY_POSTINC	;send to POSTINCR display sub  ********
			BRA		.break			;break
			
.PD_MODE		MOVE.W	D6,D1			;move reg value to D1
			BSR		DISPLAY_PREDEC	;send to data PREDEC display sub  ********
			BRA		.break			;break
			
.DATA_MODE	CMP.B	#0,D6			; compare register to 000
			BEQ		.worddata		;branch to word data
			
			CMP.B	#1, D6			;compare register to 1
			BEQ		.longdata		;branch to long data
			BGT		.INV_MODE		;branch to invalid mode if reg greater than1
						
.worddata	MOVE.W	(A6), D2		;pull word from datastream
			ADDA	#WORD, A6		;increment data pointer
			
			BSR		DISPLAY_WORD_HEX		; display word in hex
			BRA		.break			; break from sub

.longdata	MOVE.L 	(A6), D2		;pull long from datastream into D2
			ADDA	#LONG, A0		;increment data pointer
			
			BSR		DISPLAY_LONG_HEX	; display long in hex
			BRA		.break			; break from sub

		
.break			RTS					;return to calling instruction


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
* D5 stores i(immediate or Register)
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

*- 000 ROL ---------------------- Rotate Left ----------------------------------

ROL_T		LEA ROL_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 001 LSL ------------------- Logical Shift Left ------------------------------

LSL_T		LEA LSL_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 002 ASL ----------------- Arithmetic Shift Left -----------------------------

ASL_T		LEA ASL_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 003 ROR ---------------------- Rotate Right ---------------------------------

ROR_T		LEA ROR_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 004 LSL ------------------ Logical Shift Right ------------------------------

LSR_T		LEA LSR_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 005 ASR ----------------- Arithmetic Shift Right ----------------------------

ASR_T		LEA ASR_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 006 ADDA --------------------- Add Address ----------------------------------

ADDA_T		LEA ADDA_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 007 ADD -------------------------- Add --------------------------------------

ADD_T		LEA ADD_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 008 MULS ------------------- Signed Multiply --------------------------------

MULS_T		LEA MULS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 009 CMP ------------------------ Compare ------------------------------------

CMP_T		LEA CMP_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 010 SUB ------------------------ Subtract -----------------------------------

SUB_T		LEA SUB_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 011 DIVS -------------------- Signed Divide ---------------------------------

DIVS_T		LEA DIVS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 012 OR ------------------- Inclusive OR Logical -----------------------------

OR_T		LEA OR_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 013 BLT -------------------- Branch Less Than -------------------------------

BLT_T		LEA BLT_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT 	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 014 BGE ---------------- Branch Greater OR Equal ----------------------------

BGE_T		LEA BGE_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT 	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 015 BVC ----------------- Branch Overflow Clear -----------------------------

BVC_T		LEA BVC_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT 	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 015 BVS -------------------- Branch Carry Set -------------------------------

BCS_T		LEA BCS_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT 	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 017 BRA --------------------- Branch Always ---------------------------------

BRA_T		LEA BRA_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT 	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 018 SUBQ -------------------- Subtract Quick --------------------------------

SUBQ_T		LEA SUBQ_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 019 JSR ------------------- Jump to Subroutine ------------------------------

JSR_T		LEA JSR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 020 RTS ------------------ Return to Subroutine -----------------------------

RTS_T		LEA RTS_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 021 NOP ---------------------- No Operation ---------------------------------

NOP_T		LEA NOP_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 022 MOVEM -------------- Move Multiple Registers ----------------------------

MOVEM_T		LEA MOVEM_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 023 NEG ------------------------- Negate ------------------------------------

NEG_T		LEA NEG_M,A1


			; MOVE.W (A0),D2		* Moving the current 16-bits address into D2
			; ANDI.W #$FF00,D2
			; CMP.W (A2),D2
			; BNE  DISPLAY_ERROR

			; BSR DISPLAY_SIZE

			BSR EA_TYPE1
			RTS

*- 024 LEA ----------------- Load Effective Address ----------------------------

LEA_T		LEA LEA_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 025 MOVEA.W -------------- Move Address (WORD) ------------------------------

MOAW_T		LEA MOAW_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 026 MOVE.W --- Move Data from Source to Destination (WORD) ------------------

MOW_T		LEA MOW_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 027 MOVEA.L -------------- Move Address (LONG) ------------------------------

MOAL_T		LEA MOAL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 028 MOVE.L --- Move Data from Source to Destination (LONG) ------------------

MOL_T		LEA MOL_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 029 MOVE.B --- Move Data from Source to Destination (BYTE) ------------------

MOB_T		LEA MOB_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 030 CMPI ------------------ Compare Immediate -------------------------------

CMPI_T		LEA CMPI_M,A1
			BSR DISPLAY_SIZE
			RTS

*- 031 BCLR ----------------- Test a Bit and Clear -----------------------------

BCLR_T		LEA BCLR_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS

*- 032 ORI ----------------- Inclusive OR Immediate ----------------------------

ORI_T		LEA ORI_M,A1
			BSR DISPLAY_SIZE
			RTS


********************************* Data Section *********************************

HEADER		DC.B	'Address   OP-Code	Operand				    Instruction', 0
LINE 		DC.B 	'----------------------------------------',0
PRESS_ANY   DC.B 	'  press ANY key to continue...',0
INIT_HEX	DC.B	'0x',0
INIT_MEM	DC.B	'$',0
DATA_M		DC.B	'DATA ',0
BYTE_M		DC.B  	'.B',0
WORD_M		DC.B  	'.W',0
LONG_M		DC.B  	'.L',0

; DISPLAY_DATAREG DC.B 'Dx' 0
; DISPLAY_ADDEREG DC.B 'Ax',0
; DISPLAY_INDIR   DC.B '(Ax)',0
; DISPLAY_POSTINC DC.B '(Ax)+',0
; DISPLAY_PREDEC  DC.B '-(Ax)',0

; DISPLAY_REGS - for use in MOVEM where we need to display a / delimited list of Registers and ranges of registers.

NEWLINE_M	DC.B  CR,LF,0

POSITION 	DC.W  $0000
SAVE_STATE	DS.L  1
SOURCE_LIST DS.L  1   

ROL_M		DC.B	'ROL',0		* Tested	0xE118
LSL_M		DC.B	'LSL',0		* Tested	0xE108
ASL_M		DC.B	'ASL',0		* Tested	0xE100
ROR_M		DC.B	'ROR',0		* Tested	0xE018
LSR_M		DC.B	'LSR',0		* Tested	0xE008
ASR_M		DC.B	'ASR',0		* Tested	0xE000
ADDA_M		DC.B	'ADDA',0	* Tested	0xD0C0
ADD_M		DC.B	'ADD',0		* Tested	0xD000
MULS_M		DC.B	'MULS',0	* Issue		0xC1C0
CMP_M		DC.B	'CMP',0					0xB000
SUB_M		DC.B	'SUB',0					0x9000
DIVS_M		DC.B	'DIVS',0	* Issue		0x81C0
OR_M		DC.B	'OR',0					0x8000
BLT_M		DC.B	'BLT ',0				0x6D00
BGE_M		DC.B	'BGE ',0				0x6C00
BVC_M		DC.B	'BVC ',0				0x6800
BCS_M		DC.B	'BCS ',0				0x6500
BRA_M		DC.B	'BRA ',0				0x6000
SUBQ_M		DC.B	'SUBQ',0				0x5100
JSR_M		DC.B	'JSR',0		* Tested	0x4E80
RTS_M		DC.B	'RTS',0		* Tested	0x4E75
NOP_M		DC.B	'NOP',0		* Tested	0x4E71
MOVEM_M		DC.B	'MOVEM',0				0x4880
NEG_M		DC.B	'NEG',0		* Tested	0x4400
LEA_M		DC.B	'LEA',0					0x41C0
MOAW_M		DC.B	'MOVEA.W',0				0x3040
MOW_M		DC.B	'MOVE.W',0				0x3000
MOAL_M		DC.B	'MOVEA.L',0				0x2040
MOL_M		DC.B	'MOVE.L',0				0x2000
MOB_M		DC.B	'MOVE.B',0				0x1000
CMPI_M		DC.B	'CMPI',0				0x0C00
BCLR_M		DC.B	'BCLR',0				0x01C0
ORI_M		DC.B	'ORI',0					0x0000

*---------------------------- Task Operation List ------------------------------
* The values for this constant are set to move in parallel with those of
* the constant BITMASK via steps at label NEXT_MASK.

TASK_OP		DC.W ROL_T,LSL_T,ASL_T,ROR_T,LSR_T,ASR_T,ADDA_T,ADD_T,MULS_T,CMP_T
			DC.W SUB_T,DIVS_T,OR_T,BLT_T,BGE_T,BVC_T,BCS_T,BRA_T,SUBQ_T,JSR_T
			DC.W RTS_T,NOP_T,MOVEM_T,NEG_T,LEA_T,MOAW_T,MOW_T,MOAL_T,MOL_T,MOB_T
			DC.W CMPI_T,BCLR_T,ORI_T,0

*--------------------------- Bitmask Translation List --------------------------
BITMASK		DC.W $E118,$E108,$E100,$E018,$E008,$E000,$D0C0,$D000,$C1C0,$B000
			DC.W $9000,$81C0,$8000,$6D00,$6C00,$6800,$6500,$6000,$5100,$4E80
			DC.W $4E75,$4E71,$4880,$4400,$41C0,$3040,$3000,$2040,$2000,$1000
			DC.W $0C00,$01C0,$0000

*--------------------------------- Source Code ---------------------------------

SOURCE_C	DC.L  TEST_1,0

TEST_1		DC.W $4400
			DC.W $4440
			DC.W $4480
			DC.W 0


; SOURCE_C	DC.L  SOURCE_1,SOURCE_2,SOURCE_3,SOURCE_4,SOURCE_5,0


SOURCE_1	DC.W $4E75				RTS
			DC.W $D6C7				ADDA
			DC.W $4EB8				JSR
			DC.W $4487				NEG.L
			DC.W $D5C2				ADDA
			DC.W $4E71				NOP
			DC.W $4EB9				JSR
			DC.W $D280				ADD.L
			DC.W $303C				MOVE.W
			DC.W $4E75				RTS
			DC.W 0

SOURCE_2	DC.W $66FC				DATA
			DC.W $EE45				ASR.W
			DC.W $6CFF,$0002,$6A12	BGE
			DC.W $E6AA				LSR.L
			DC.W $E439				ROR.B
			DC.W $2646				MOVEA.L
			DC.W $EF45				ASL.W
			DC.W $62FC				DATA
			DC.W $E539				ROL.B
			DC.W $60AA				BRA
			DC.W $EF45				ASL.W
			DC.W $68CD				BVC
			DC.W $BBBB				ERROR (CMP.L)
			DC.W $E6AA				LSR.L
			DC.W $EE45				ASR.W
			DC.W $85C3				DIVS
			DC.W $AAAA				ERROR (OR.L)
			DC.W 0

**** Displacement TESTING - REMOVE WHEN DONE ****

SOURCE_3	DC.W $6FFC				BLE	1111
			DC.W $6EFC				BGT	1110
			DC.W $6DFC				BLT	1101
			DC.W $6C00,$0004		BGE	1100
			DC.W $6BFC				BMI	1011
			DC.W $6AFC				BPL	1010
			DC.W $69FC				BVS	1001
			DC.W $68FF,$2803,$3201	BVC	1000
			DC.W $67FC				BEQ	0111
			DC.W $66FC				BNE	0110
			DC.W $65FC				BCS	0101
			DC.W $64FC				BCC	0100
			DC.W $63FC				BLS	0011
			DC.W $62FC				BHI	0010
			DC.W $60FC				BRA
			DC.W $60FF,$0000,$000A	BRA
			DC.W $60FF,$1234,$5678	BRA
			DC.W 0
			
**** Size BYTE,WORD,LONG TESTING - REMOVE WHEN DONE ****

SOURCE_4	DC.W $E118				ROL.B
			DC.W $E158				ROL.W
			DC.W $E198				ROL.L
			DC.W $E1D8				ROL

			DC.W $E018				LOL.B
			DC.W $E058				LOL.W
			DC.W $E098				LOL.L
			DC.W $E0D8				LOL	

			DC.W $E110				LSL.B
			DC.W $E150				LSL.W
			DC.W $E190				LSL.L
			DC.W $E1D0				LSL
			DC.W 0

SOURCE_5	DC.W $4E71
			DC.W $6DFC
			DC.W $6CFC
			DC.W $68FC
			DC.W $65FC
			DC.W $60FC
			DC.W 0

	END		START				* last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
