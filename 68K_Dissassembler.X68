*---------------------------------------------------------------------------------------------------
* Title: 68000 OPCODE Dissassembler
* Written by: Matthew Everett Christopher Ramos
* Date Created: Thursday November 6, 2014
* Date Modifed: Monday December 22, 2014
* Description: Assembly language program that can read a string of binary and
*			   decode it into Assembly language instructions.  
*---------------------------------------------------------------------------------------------------

*-------------------------------  Address Register / Data Register  --------------------------------
* A0: Designated for Source Code
* A1: Designated for Displaying string to the output
* A2: Designated for OP Bitmask list / Hexadecimal Bitmask list
* A3: Designated for Task Operation list / Hexadecimal value list
* A4: 
* A5: Starting Address
* A6: Ending Address
* A7: 

* D0: Designated for task code values while using TRAP #15
* D1: Main 16-bits copy of the instructions (PRINTING PURPOSES) / Task 11
* D2: Hexadecimal Temp convert
* D3: Temporary 16-bits for bitmask comparison
* D4: 
* D5: 
* D6: 
* D7: Temporary 16-bits for EA
*---------------------------------------------------------------------------------------------------

			OPT   CRE

CR			EQU   $000D
LF			EQU   $000A
START		EQU   $1000				; Program starting address
EXIT		EQU   $2700				; Simulator stoping code
WORD		EQU   $0002				; Advance address by a word
LONG        EQU   $0004 			; Advance address by a longword

*---------------------------------------------------------------------------------------------------
*****************************  Main Program // Initial Starting Point  *****************************
*---------------------------------------------------------------------------------------------------

INIT_START  ORG    START			; The program begins at the requried asking address at $00001000

*///////////////////////////////////////////////////////////////////////////////////////////////////
		    LEA     FILENAME,A1     ; TASK #52
		    MOVE    #52,D0          ;   Open new file..
		    TRAP    #15             ;   As above except the file is created if not found.
*///////////////////////////////////////////////////////////////////////////////////////////////////

			; BSR USER_HEX_INPUT
			; MOVEA.L A5,A0 		* Move a temp starting point from A5 to A0
			; BSR RANGE_ERROR_CHECK

			MOVEA	#$3000,A0 		******  ALPHA_00 - Force set a starting address  ******
			MOVEA.L	#$3500,A6		******  ALPHA_01 - Force sets an ending address  ******

*-------------------------  Displaying instructions to the output screen  --------------------------

.NEXT 		MOVE.B 	#13,D0			; Moves task 13 into D0. Displays string at (A1) with a return [CR,LF]
			LEA 	LINE,A1 		; Loading the LINE message '--------' into  (A1) ready to be displayed
			TRAP 	#15				; Triggers the loaded message from (A1) to be displayed into the output

			LEA 	HEADER,A1		* Load Dissassembler header message into A1
			TRAP 	#15				; Triggers the loaded message from (A1) to be displayed into the output

			ADDQ.W 	#3,POSITION  	; IMPORTANT - Shifts the row of the POSITION by three steps *** 

			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE
			BSR	PRINT_TO_FILE


			BSR 	INIT_OP			* Hunts down each Operation code like a mad man

			MOVE.B 	#13,D0			; Moves task 13 into D0. Displays string at (A1) with a return [CR,LF]
			LEA 	LINE,A1 		; Loading the LINE message '--------' into  (A1) ready to be displayed
			TRAP 	#15				; Triggers the loaded message from (A1) to be displayed into the output

.SEARCH 	CMPA.L 	A6,A0			* Did I happen to go over the user range?
			BGE 	END_PROGRAM		* If I did, I'll end the progarm.
			ADDA.W 	#WORD,A0		* If not, I'll continue to hunt for DATA
			CMPI.W 	#$FFFF,(A0)  	* Did I happen to find any useful DATA?
			BEQ 	.SEARCH 	    * Nope, continue the hunt

*---------------------------  Press the ANY key button to continue....  ----------------------------

			LEA 	PRESS_ANY,A1
			MOVE.B 	#14,D0			* Move task 13 into Data Register 0
			TRAP 	#15				* Display the string at (A1) without CR, LF.

			MOVE.B 	#5,D0			******  TESTING BETA  ******
			TRAP 	#15				******  TESTING BETA  ******

			MOVE.B 	#11,D0 			* Moving task 11 into Data Register 0
			MOVE.W 	#$FF00,D1		* Clear Screen : Set D1.W to $FF00
			TRAP 	#15

			CLR.W 	POSITION		*** TEST - RESET POSITION ***

			BRA 	.NEXT


END_PROGRAM	CLR.W 	POSITION		*** TEST - RESET POSITION ***
			
			LEA 	END_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

            MOVE  	#50,D0 			* ADDED
            TRAP    #15             ; close all files

			STOP 	#EXIT			* Halt Simulator


*---------------------------------------------------------------------------------------------------
******************************  OP-CODE Looping Algorithm Subroutine  ******************************
*---------------------------------------------------------------------------------------------------
INIT_OP:	* Resets the list of bitmasks & english to the begining

*----------------------  Displaying the Progarm Counter in Hexadecimal Form  -----------------------
			MOVE.L 	A0,D2			; Moves the current PC (Program Counter) into D2 set to be displayed 
			BSR DISPLAY_LONG_HEX	; Shows the follow progarm counter address into the display output

			LEA 	BITMASK,A2		; Loads the bitmask array into A2 ready for the current instruction
			LEA 	TASK_OP,A3		; Loads the operation task list into A3 of each individual OPCODE

LOOP_OP		MOVE.W 	(A0),D3			* Move the current 16-bits into data register 3
			AND.W 	(A2),D3			* AND the current bitmask with temp instruction
			CMP.W 	(A2),D3			* Compares the current bitmask in (A2) with D3
			BNE 	NEXT_MASK		* No Match found branch to the NEXT_MASK
			
*------------------------------------- Moving the cursor to the desired location -------------------

			MOVE.B 	#11,D0 			* Moving task 11 into Data Register 0
			MOVE.W 	POSITION,D1  	* Setting up the desired row position
			ADDI.W 	#$0A00,D1		* Setting up the desired column position
			TRAP 	#15				* Position the cursor at [0Axx] x - any number

			MOVE.L 	A0,SAVE_STATE	******  BETA (Save the current address to display later) ******
			MOVE.W 	(A0),D7 		******  BETA (Saving current instruction in D7 for EA David) ******

*---------------------------- Retrieve matched then execute task by jumping to subroutine ----------

			MOVE.B 	#14,D0			; Sets up task 14 
			MOVEA.W (A3),A3			* Moves the task address into the same (An)
			JSR 	(A3)			* Jumps to the current task subroutine from A3

			BSR 	DISPLAY_INTRUCTION	******  BETA (display the whole set of instructions used)  ******

			BSR	PRINT_TO_FILE

			BRA 	SHIFT_OP		* Shifts to the next 16-bits of the source code

*------------------------------------------ Advancing Bitmask & OP Task list -----------------------

NEXT_MASK	ADDA.W 	#WORD,A2		* Shifts to the next bitmask
			ADDA.W 	#WORD,A3		* Shifts to the next OP Name

			TST.W 	(A3)			* Did I reach the end of the English list?
			BNE 	LOOP_OP			* Go back to LOOP_OP and test the new bitmask

SHIFT_OP	ADDA.W 	#WORD,A0		* Shifts to the next set of 16-bits instruction

			MOVE.W 	POSITION,D0		******  TESTING BETA  ******
			CMPI.B 	#$1F,D0			******  TESTING BETA  ******
			BEQ 	POSI_CHECK		******  TESTING BETA  ******

			ADDQ.W 	#1,POSITION  	*** IMPORTANT: Shifts the row position by 1 ***

POSI_CHECK	CMPI.W 	#$FFFF,(A0)		* See if you reached the end of the instructions

			BNE 	INIT_OP			* (!=) Resets the bitmask & OP task lists
			RTS						* Returns from subroutine


*---------------------------------------------------------------------------------------------------
*********************************  Display Instruction Subroutine  *********************************
*---------------------------------------------------------------------------------------------------
DISPLAY_INTRUCTION:

*----------------------------- Displaying the current instruction as a hexadecimal value -----------

			MOVEA.L SAVE_STATE,A4	******  TESTING BETA  ******

			MOVE.W 	(A4)+,D2		* Reloads the orignal 16-bits as a temp again

*------------------------------------- Moving the cursor to the desired location -------------------

			MOVE.B 	#11,D0			* Moving task 11 into Data Register 0
			MOVE.W 	POSITION,D1  	* Setting up the desired row position
			ADDI 	#$3500,D1		* Setting up the desired column position
			TRAP 	#15				* Position the cursor at [2Cxx] x - any number
			ADDI 	#$0200,D1		* Increase the cursor two spaces '__'

			LEA 	INIT_HEX,A1
			MOVE.B 	#14,D0			* Moving task 14 into Data Register 0
			TRAP 	#15				* Display the string at (A1) without CR, LF

			BSR 	DISPLAY_WORD_HEX

CHECK_VALUE	CMP.W 	(A0),D2			******  TESTING BETA  ******
			BEQ 	NEWLINE			******  TESTING BETA  ******

			MOVE.B 	#11,D0			* Moving task 11 into Data Register 0
			ADDI 	#$0500,D1		******  TESTING BETA  ******
			TRAP 	#15				* Position the cursor at [2Cxx] x - any number

			MOVE.W 	(A4)+,D2		******  TESTING BETA  ******
			BSR DISPLAY_WORD_HEX    ******  TESTING BETA  ******
			BRA 	CHECK_VALUE		******  TESTING BETA  ******

NEWLINE		LEA 	NEWLINE_M,A1	* Loading NEWLINE into (A1) for next instruction
			MOVE.B 	#14,D0			* Moving task 14 into Data Register 0
			TRAP 	#15				* Display the string at (A1) without CR, LF
			RTS						* Returns from subroutine
			


*---------------------------------------------------------------------------------------------------
*///////////////////////////////////////////////////////////////////////////////////////////////////
*---------------------------------------------------------------------------------------------------
PRINT_TO_FILE:			

            CLR  	D3

			MOVE 	#22,D0			; Read CHAR		
			MOVE.L	ROW,D1			; Sets the row position to feed the string into memory [row,column 0000,0000] CLEARS D1 of any previous memory
			MOVE  	D1,D5			; Copy the datasize from LINE into D5

			MOVE  	#79,D2			; Counter and holds number of bytes to write (unaltered upon return)
			
.OFFSET 	MOVE  	D2,D1			; Sets the ending point feeding the string backwards
			TRAP	#15				; Triggers task 22 and reads a CHAR
			CMPI 	#' ',D1			; Compare the result from task 22 to see if it's the ascii HEX 20
			DBNE	D2,.OFFSET 		; D2--, if D2 = -1 STOP, otherwise branch to OFFSET

			MOVE 	D2,D3			; Copy the counter to another counter
			ADDQ	#3,D2			; Adjust the datasize by adding one to compensate the offset balance 
			ADD     D2,D5 			;  *** KNOWN ISSUES ***
			CLR     D1 
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

            CLR  	D3
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
*///////////////////////////////////////////////////////////////////////////////////////////////////


*---------------------------------------------------------------------------------------------------
*********************************  Display Hexadecimal Subroutine  *********************************
*---------------------------------------------------------------------------------------------------
* Displays an output of a single 16-bit instruction as a hexadecimal value

*** IMPORTANT *** Load the value that you wish to display in hexadecimal in D2

DISPLAY_LONG_HEX:

			ROL.L 	#4,D2			* Shifts to read the next hexadecimal digit
			BSR 	INTI_LOOP		* Branch towards the loop of hex thingy
			ROL.L 	#4,D2	
			BSR 	INTI_LOOP
			ROL.L 	#4,D2	
			BSR 	INTI_LOOP
			ROL.L 	#4,D2	
			BSR 	INTI_LOOP
			ROL.L 	#4,D2	
			BSR 	INTI_LOOP
			ROL.L 	#4,D2
			BSR 	INTI_LOOP
			ROL.L 	#4,D2
			BSR 	INTI_LOOP
			ROL.L 	#4,D2
			BRA 	INTI_LOOP

DISPLAY_WORD_HEX:
			
			MOVE.W 	D1,D3

			ROL.W 	#4,D2
			BSR 	INTI_LOOP
			ROL.W 	#4,D2
			BSR 	INTI_LOOP
			ROL.W 	#4,D2
			BSR 	INTI_LOOP
			ROL.W 	#4,D2
			BSR 	INTI_LOOP

			MOVE.W 	D3,D1			* Move the saved position from D1 before display
			RTS						* Returns from subroutine

DISPLAY_BYTE_HEX:

			ROL.B 	#4,D2			* Shifts to read the next hexadecimal digit
			BSR 	INTI_LOOP		* Branch towards the loop of hex thingy
			ROL.B 	#4,D2
			BRA 	INTI_LOOP


*--------------------------  Heart of the hexadecimal display Algorithm  ---------------------------

INTI_LOOP	MOVE.W 	D2,D1			; Move the current 16-bits into data register 3

			ANDI.W 	#$000F,D1
			CMPI.B 	#9,D1
			BGT		PRINT_HEX
			
			MOVE.B 	#3,D0			; Display signed number in D1.L in decimal
			TRAP 	#15
			RTS

PRINT_HEX	LEA 	HEX_BITMASK,A2
			LEA 	HEX_VALUE,A3

LOOP_HEX	MOVE.B 	D1,D0
			AND.W 	(A2),D0			; AND the current bitmask with temp instruction
			CMP.W 	(A2),D0			; Compares the current bitmask in (A2) with D0
			BNE 	NEXT_HEX

			LEA 	(A3),A1 		; Loads the correct hex value to be printed
			MOVE.W 	#14,D0			; Moving task 14 into Data Register 0
			TRAP 	#15				; Display the string at (A1) without CR, LF
			RTS						; Returns from subroutine

NEXT_HEX	ADDA.W 	#WORD,A2		; Shifts to the next binary
			ADDA.W 	#WORD,A3		; Shifts to the next hexadecimal char
			BRA 	LOOP_HEX		; Go back to LOOP and test the new bitmask

HEX_BITMASK	DC.W $F,$E,$D,$C,$B,$A
HEX_VALUE   DC.W 'F','E','D','C','B','A'


*---------------------------------------------------------------------------------------------------
**********************  Display Operation Size [Byte, Word, Long] Subroutine  **********************
*---------------------------------------------------------------------------------------------------
DISPLAY_SIZE:

			TRAP 	#15				; Displaying the chosen operation into the output display screen

			BTST 	#6,D7			; Ascertains the operation size is a WORD by the 6th bit from Opmode 
			BEQ 	.LONG 		   	; If the Z condition code is 0 = Long or Byte / 1 = Word operation
			LEA 	WORD_M,A1		; Preparing the message size '.W' to be displayed after the Operation
			BRA 	OPERAND_POSITION

.LONG 		BTST 	#7,D7			; Ascertains the operation size is a LONG by the 7th bit from Opmode 
			BEQ 	.BYTE 			; If the Z condition code is 0 = Byte operation / 1 = Long operation
			LEA 	LONG_M,A1		; Preparing the message size '.L' to be displayed after the Operation
			BRA 	OPERAND_POSITION

.BYTE 	 	LEA 	BYTE_M,A1		; Preparing the message size '.B' to be displayed after the Operation


*---------------------------------------------------------------------------------------------------
**************************  EA Operand Cursor Position Shift Subroutine  ***************************
*---------------------------------------------------------------------------------------------------
OPERAND_POSITION:					; Positions the cursor at the desired location for the EA operand

			TRAP 	#15				; Displaying the selected operation/size into the output display screen

			MOVE.B 	#11,D0			; Prepare the following task in data register D0; Task 11
			MOVE.W 	#$1600,D1		; Setting up the desired column position
			ADD.W 	POSITION,D1  	; Setting up the desired row position
			TRAP 	#15				; Position the cursor at the location [2Cxx];[44,ROW]	

			MOVE.B 	#14,D0
			RTS						; Done with subroutine and return to previous task


*---------------------------------------------------------------------------------------------------
*****************************  Display Unknown Data Errors Subroutine  *****************************
*---------------------------------------------------------------------------------------------------
*1000	DATA	$WXYZ
DISPLAY_ERROR:

			LEA DATA_M,A1
			TRAP #15			* Display the string at (A1) without CR, LF

			LEA DOLLAR_M,A1
			TRAP #15			* Display the string at (A1) without CR, LF

			MOVE.W (A0),D2
			BRA DISPLAY_WORD_HEX	


*---------------------------------------------------------------------------------------------------
**************************  Display Effective Addressing Mode Subroutine  **************************
*---------------------------------------------------------------------------------------------------
* Dn 		Data Register Direct Mode 															000
*---------------------------------------------------------------------------------------------------
DATA_REGISTER_DIRECT:
			LEA DATA_REG_M,A1
			TRAP #15

			MOVE.B #3,D0			; Display signed number in D1.L in decimal
			TRAP #15
			RTS

*---------------------------------------------------------------------------------------------------
* An 		Address Register Direct Mode 														001
*---------------------------------------------------------------------------------------------------
ADDRESS_REGISTER_DIRECT:
			LEA ADDRESS_Ax,A1
			TRAP #15

			MOVE.B #3,D0			; Display signed number in D1.L in decimal
			TRAP #15
			RTS

*---------------------------------------------------------------------------------------------------
* -(An) 	Address Register Indirect with Predecrement Mode 									100
*---------------------------------------------------------------------------------------------------
PREDECREMENT:
			LEA NEGATIVE_M,A1
			TRAP #15

*---------------------------------------------------------------------------------------------------
* (An) 		Address Register Indirect Mode 														010
*---------------------------------------------------------------------------------------------------
ADDRESS_REGISTER_INDIRECT:
			LEA PRE_BRACKET,A1
			TRAP #15

			MOVE.B #3,D0			; Display signed number in D1.L in decimal
			TRAP #15

			LEA POST_BRACKE,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
					
*---------------------------------------------------------------------------------------------------
* (An)+		Address Register Indirect with Postincrement Mode 									011
*---------------------------------------------------------------------------------------------------
POSTINCREMENT:
			BSR ADDRESS_REGISTER_INDIRECT
			LEA POSITIVE_M,A1
			TRAP #15
			RTS

*---------------------------------------------------------------------------------------------------
* (xxx).W 	Absolute Short Addressing Mode														111
*---------------------------------------------------------------------------------------------------
ABSOLUTE_SHORT_ADDRESSING:
	 		LEA 	DOLLAR_M,A1
			TRAP 	#15

			ADDA.W 	#WORD,A0
			MOVE.W 	(A0),D2
			BRA	DISPLAY_WORD_HEX		; display word in hex

*---------------------------------------------------------------------------------------------------
* (xxx).L 	Absolute Long Addressing Mode														111
*---------------------------------------------------------------------------------------------------
ABSOLUTE_LONG_ADDRESSING:
	 		LEA 	DOLLAR_M,A1
			TRAP 	#15

			ADDA.W 	#WORD,A0
			MOVE.L 	(A0),D2
			ADDA.W 	#WORD,A0
			BRA	DISPLAY_LONG_HEX	; display long in hex

*---------------------------------------------------------------------------------------------------
* #<data> 	Immediate Data																		111
*---------------------------------------------------------------------------------------------------
IMMEDIATE_DATA:

			LEA HASH_M,A1
			TRAP #15

			LEA DOLLAR_M,A1
			TRAP #15

			* 1100 0000
			MOVE.W (A0),D3 		* Make a temp copy of the current instruction in D3
			ANDI.B #$C0,D3 		* Bitmask the current instruction to obtain only the size bits
			LSR.B #6,D3 		* Shift the obtained size bits to be the least bits in the register

			TST.B D3
			BNE WORD_DATA

			ADDA.W #WORD,A0
			MOVE.W (A0),D2
			BRA DISPLAY_BYTE_HEX

WORD_DATA	CMP.B #1,D3
			BNE LONG_DATA

			ADDA.W #WORD,A0
			MOVE.W (A0),D2
			BRA DISPLAY_WORD_HEX

LONG_DATA	ADDA.W #WORD,A0
			MOVE.L (A0),D2
			ADDA.W #WORD,A0
			BRA DISPLAY_LONG_HEX


*---------------------------------------------------------------------------------------------------
***************************  Effective Address Algorithms & Subroutines  ***************************
*---------------------------------------------------------------------------------------------------
EA_TYPE_01:
*---------------------------------------------------------------------------------------------------
			MOVE.B	#$38,D5			* move primative 3 bitmask into D4 	0x38 (EA MODE)
			AND.W	D7,D5			* and D7 and D5 store in D5 (MODE)
			LSR.B	#3,D5			* Shifts the temp OPMODE right 3 places

			MOVE.B	#$07,D6			* move primative 3 bitmask into D3 	0x07 (EA REGISTER)
			AND.W	D7,D6			* and D7 and D6 store in D6 (REGISTER)
			MOVE.W	D6,D1			* Move register value to D1

			BRA EA_ENGINE


*---------------------------------------------------------------------------------------------------
* Main EA_ENGINE
*---------------------------------------------------------------------------------------------------

*------------------------ Compares between Addressing MODE 0-6 --------------------------

EA_ENGINE:	TST.B	D5				* Compare OpMode with 000	Dx  
			BNE		.A_MODE			* Branch to OpMode Data Register
			BRA		DATA_REGISTER_DIRECT	* Send to data register display subr

.A_MODE		CMP.B	#1, D5			* compare opmode with 001	Ax  
			BNE		.IND_MODE		* branch to Address reg mode
			BRA		ADDRESS_REGISTER_DIRECT 	* Invalid mode for this type
			
.IND_MODE	CMP.B	#2, D5			* compare opmode with 010  (Ax) 
			BNE		.PI_MODE		* branch to indirect Mode
			BRA		ADDRESS_REGISTER_INDIRECT	* Send to data register indirect subr

.PI_MODE	CMP.B	#3, D5			* compare opmode with 011  (Ax)+ 
			BNE		.PD_MODE		* branch tp post incrementmodebr
			BRA		POSTINCREMENT	* Send to POSTINCR display sub

.PD_MODE	CMP.B	#4, D5			* compare opmode with 100 -(Ax) 
			BNE		.DATA_MODE		* branchto Post decrement mode
			BRA		PREDECREMENT


*---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

.DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L 
			BNE		DISPLAY_ERROR	* branc to data modes


			MOVE.B #14,D0

			TST.B	D6				* compare register to 000 (xxx).W
			BEQ		ABSOLUTE_SHORT_ADDRESSING			;branch to word data
			
			CMP.B	#1,D6			* compare register to 001 (xxx).L
			BEQ		ABSOLUTE_LONG_ADDRESSING  			;branch to long data
			
			CMP.B 	#4,D6
			BEQ 	IMMEDIATE_DATA

			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1
						


*---------------------------------------------------------------------------------------------------
* Effective Addressing Type 6
*---------------------------------------------------------------------------------------------------
EA_TYPE_06: BTST 	#3,D7 			; Ascertains the operation type by the 3rd bit from the instruction
			BNE 	.TASK_A			; If the Z condition code is 0 = Arithmetic Shift / 1 = Logical or Rotate

			LEA 	ASd_M,A1 		; Preparing the message type 'AS' to be displayed as Arithmetic Shift
			BRA 	.DIRECTION      ; Branch to the next test to determine the direction of the shift

.TASK_A 	BTST 	#4,D7 			; Ascertains the operation type (AOd,LSd,ROd) by the 4th bit 
			BNE 	.TASK_B 		; If the Z condition code is 0 = Logical Shift / 1 = Rotate Shift

			LEA 	LSd_M,A1 		; Preparing the message type 'LS' to be displayed as Logical Shift
			BRA 	.DIRECTION      ; Branch to the next test to determine the direction of the shift

.TASK_B		LEA 	ROd_M,A1 		; Preparing the message type 'RO' to be displayed as Rotate Shift

.DIRECTION 	TRAP 	#15 			; Displaying the selected shift type into the output display screen

			BTST 	#8,D7 			; Ascertains the direction of the operation (Left/Right) by the 8rd bit 
			BEQ 	.RIGHT			; If the Z condition code is 0 = Rotate Right / 1 = Rotate Left

			LEA 	LEFT_M,A1 		; Preparing the message 'L' to be displayed as the left direction
			BRA 	.SIZE
.RIGHT		LEA 	RIGHT_M,A1 		; Preparing the message 'R' to be displayed as the right direction

.SIZE		BSR 	DISPLAY_SIZE

*--------------------  Determines the (Count/Register) & (Data Register) bits  ---------------------

			MOVE.W	#$0E00,D1		; Establish a bitmask to gain the (Count/Register) bits [0000 1110 0000 0000]
			AND.W 	D7,D1			; Performs an AND operation with the current instruction AND the bitmask
			ROL.W 	#7,D1 			; Position the obtained (Count/Register) bits to the least significant bit

			MOVE.B	#$7,D2			; Establish a bitmask to gain the data register bits [0000 0000 0000 0111]	
			AND.B	D7, D2			; Performs an AND operation with the current instruction AND the bitmask

*--------------------------  Determine the i/r bit (Immediate/Register)  ---------------------------

			BTST 	#5,D7 			; Ascertains the i/r bit (Immediate/Register) by the 5th bit 
			BNE		.REGISTER		; If the Z condition code is 0 = Immediate / 1 = Data Register
	
			LEA 	HASH_M,A1 		; If i/r = 0, this field contains the rotate count.
			TRAP 	#15				; The values 1 – 7 represent counts of 1 – 7, and zero specifies a count of eight.
			
			TST.B 	D1
			BEQ 	.TASK_C

			MOVE.B 	#3,D0
			TRAP 	#15
			BRA		.DONE			;evaluate eamode	

.TASK_C		MOVE.B 	#8,D1			
			MOVE.B 	#3,D0
			TRAP 	#15
			BRA		.DONE			;evaluate eamode	

			; If i/r = 1, this field specifies a data register that contains the rotate count.
.REGISTER	BSR	DATA_REGISTER_DIRECT

.DONE		LEA 	COMMA_M,A1
			MOVE.B 	#14,D0			; Move task 13 into Data Register 0
			TRAP 	#15				; Display the string at (A1) without CR, LF.

			MOVE.B 	D2,D1			; move DATA into D1
			BRA DATA_REGISTER_DIRECT


*---------------------------------------------------------------------------------------------------
*************************  Branch Conditionally & Displacement Subroutine  *************************
*---------------------------------------------------------------------------------------------------
* Subroutine that displays a branching displacement as a hexadecimal value

Bcc_T:		LEA 	BRANCH_M,A1		; Displays the starting char 'B' for the branch condition
			TRAP 	#15

			MOVE.B 	(A0),D2

			LEA 	BRANCH_OP,A1
			LEA 	BRANCH_CC,A2

.CHECK		CMP.B 	(A2)+,D2
			BEQ 	.MATCH
			ADDA.W 	#LONG,A1
			BRA 	.CHECK

.MATCH 		BSR 	OPERAND_POSITION

*------------------------  Addresses 8-Bit, 16-Bit, or 32-Bit Displacement  ------------------------

			TST.B 	D7				; Checks if the least significant byte is zero [xx xx xx 00]
			BEQ 	.DPT_16_BIT 	; 16-Bit Displacement is used when the 8-bit displacement field contains $00
			
			CMPI.B 	#$FF,D7			; Checks if the least significant byte is #$FF [xx xx xx FF]
			BEQ 	.DPT_32_BIT		; 32-Bit Displacement is used when the 8-bit displacement field contains $FF

			MOVE.B 	D7,D2			* Moving the current 16-bits address into D2
			ADDQ 	#WORD,D2
			ORI.L 	#$FFFFFF00,D2
			ADD.L 	A0,D2
			BRA 	DISPLAY_WORD_HEX	

.DPT_16_BIT	ADDA.W 	#WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.W 	(A0),D2			* Moving the current 16-bits address into D2
			ADD.W 	A0,D2
			BRA 	DISPLAY_WORD_HEX

.DPT_32_BIT	ADDA.W 	#WORD,A0		* Shifts to the next set of 16-bits instruction
			MOVE.L 	(A0),D2			* Moving the current 16-bits address into D2			
			ADDA.W 	#WORD,A0		* Shifts to the next set of 16-bits instruction

			SUBQ.L 	#LONG,D2
			ADD.L 	A0,D2
			BRA 	DISPLAY_LONG_HEX

BRANCH_M	DC.B 'B',0
BRANCH_CC 	DC.B $6F,$6E,$6D,$6C,$6B,$6A,$69,$68,$67,$66,$65,$64,$63,$62,$60
BRANCH_OP 	DC.L 'LE','GT','LT','GE','MI','PL','VS','VC','EQ','NE','CS','CC','LS','HI','RA'


*---------------------------------------------------------------------------------------------------
*****************************  OPCODE: Individual Task Subroutine Set  *****************************
*---------------------------------------------------------------------------------------------------
* 000 xOd    Arithmetic Shift <ea>, Logical Shift <ea>, and Rotate Shift <ea>
*---------------------------------------------------------------------------------------------------
xOd_T:		BTST 	#9,D7 			; Ascertains the operation type by the 3rd bit from the instruction
			BNE 	.TASK_A			; If the Z condition code is 0 = Arithmetic Shift / 1 = Logical or Rotate

			LEA 	ASd_M,A1 		; Preparing the message type 'AS' to be displayed as Arithmetic Shift
			BRA 	.DIRECTION      ; Branch to the next test to determine the direction of the shift

.TASK_A 	BTST 	#10,D7 			; Ascertains the operation type (AOd,LSd,ROd) by the 4th bit 
			BNE 	.ROTATE 		; If the Z condition code is 0 = Logical Shift / 1 = Rotate Shift

			LEA 	LSd_M,A1 		; Preparing the message type 'LS' to be displayed as Logical Shift
			BRA 	.DIRECTION      ; Branch to the next test to determine the direction of the shift

.ROTATE		LEA 	ROd_M,A1 		; Preparing the message type 'RO' to be displayed as Rotate Shift

.DIRECTION 	TRAP 	#15 			; Displaying the selected shift type into the output display screen

			BTST 	#8,D7 			; Ascertains the direction of the operation (Left/Right) by the 8rd bit 
			BEQ 	.RIGHT			; If the Z condition code is 0 = Rotate Right / 1 = Rotate Left

			LEA 	LEFT_M,A1 		; Preparing the message 'L' to be displayed as the left direction
			BRA 	.SIZE
.RIGHT		LEA 	RIGHT_M,A1 		; Preparing the message 'R' to be displayed as the right direction

.SIZE		BSR 	OPERAND_POSITION
			BRA 	EA_TYPE_01 		* Change to Effective Addressing 3

*---------------------------------------------------------------------------------------------------
* 001 ADDA 	Add Address
*---------------------------------------------------------------------------------------------------
ADDA_T		LEA 	ADDA_M,A1
			TRAP 	#15

			BTST 	#8,(A0)			; Ascertains the operation size (WORD/LONG) by the 8th bit from Opmode 
			BNE 	.LONG   		; If the Z condition code is 0 = Word operation / 1 = Long operation
			LEA 	WORD_M,A1
			BRA 	.SET_TRAP
.LONG   	LEA 	LONG_M,A1

.SET_TRAP	BSR 	OPERAND_POSITION

			BSR 	EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1 		; 0000 111 000 000 000
			AND.W 	D7,D1
			ROL.W 	#7,D1

			BRA 	ADDRESS_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 002 ADD  	Addition
*---------------------------------------------------------------------------------------------------
ADD_T:		LEA 	ADD_M,A1
			BSR 	DISPLAY_SIZE

			BTST 	#8,D7			; Ascertains the Opmode type by the 8th bit from Opmode 
			BNE 	.NEXT 		   	* If the Z condition code is 0 = Long or Byte / 1 = Word operation

			BSR 	EA_TYPE_01		; EA_TYPE_02

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BRA DATA_REGISTER_DIRECT

.NEXT		LEA 	OPERATION_2,A1
			TRAP 	#15
			; BRA EA_TYPE_03
			RTS						; Complete operations with subroutine, returns to previous task

*---------------------------------------------------------------------------------------------------
* 003 MULS  Signed Multiply
*---------------------------------------------------------------------------------------------------
MULS_T		LEA MULS_M,A1
			BSR OPERAND_POSITION
			; BSR EA_TYPE7
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 004 EOR 	Exclusive OR Logical
*---------------------------------------------------------------------------------------------------
EOR_T 		LEA EOR_M,A1
			BSR OPERAND_POSITION
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 005 CMP 	Compare
*---------------------------------------------------------------------------------------------------
CMP_T		LEA CMP_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE_02

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BRA DATA_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 006 SUB  	Subtract
*---------------------------------------------------------------------------------------------------
SUB_T		LEA SUB_M,A1
			BSR DISPLAY_SIZE

			BTST 	#8,D7			; Ascertains the Opmode type by the 8th bit from Opmode 
			BNE 	.NEXT 		   	

			; BSR EA_TYPE_02
			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BRA DATA_REGISTER_DIRECT

.NEXT		LEA 	OPERATION_2,A1
			TRAP 	#15
			; BRA EA_TYPE_03
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 007 DIVS 	Signed Divide
*---------------------------------------------------------------------------------------------------
DIVS_T		LEA DIVS_M,A1
			BSR OPERAND_POSITION
			; BSR EA_TYPE7
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 008 OR 	Inclusive OR Logical
*---------------------------------------------------------------------------------------------------
OR_T		LEA OR_M,A1
			BSR DISPLAY_SIZE

			BTST 	#8,D7			; Ascertains the Opmode type by the 8th bit from Opmode 
			BEQ 	.NEXT 		   	

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BSR DATA_REGISTER_DIRECT

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15
			; BRA EA_TYPE_03
			RTS						; Complete operations with subroutine, returns to previous task

.NEXT					
			; BSR EA_TYPE_04
			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BRA DATA_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 010 SUBQ 	Subtract Quick
*---------------------------------------------------------------------------------------------------
SUBQ_T		LEA SUBQ_M,A1
			BSR DISPLAY_SIZE

			BSR IMMEDIATE_DATA

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			; BRA EA_TYPE_02
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 011 JSR 	Jump to Subroutine
*---------------------------------------------------------------------------------------------------
JSR_T		LEA JSR_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BRA EA_TYPE_01
*---------------------------------------------------------------------------------------------------
* 012 RTS   Return from Subroutine 
*---------------------------------------------------------------------------------------------------
RTS_T		LEA 	RTS_M,A1
			TRAP 	#15
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 013 NOP 	No Operation
*---------------------------------------------------------------------------------------------------
NOP_T		LEA 	NOP_M,A1
			TRAP 	#15
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 014 MOVEM Move Multiple Registers
*---------------------------------------------------------------------------------------------------
MOVEM_T		LEA MOVEM_M,A1
			TRAP #15
			; BSR	OPERAND_POSITION
			; BSR EA_TYPE5
			RTS						; Complete operations with subroutine, returns to previous task
*---------------------------------------------------------------------------------------------------
* 015 NEG  	Negate
*---------------------------------------------------------------------------------------------------
NEG_T		LEA NEG_M,A1
			BSR DISPLAY_SIZE
			BRA EA_TYPE_01
*---------------------------------------------------------------------------------------------------
* 016 LEA 	Load Effective Address
*---------------------------------------------------------------------------------------------------
LEA_T		LEA LEA_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR 	EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1 		; 0000 111 000 000 000
			AND.W 	D7,D1
			ROL.W 	#7,D1

			BRA 	ADDRESS_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 017 MOVEA.W Move Address (WORD)
*---------------------------------------------------------------------------------------------------
MOAW_T		LEA MOAW_M,A1
			BSR OPERAND_POSITION
			BSR EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1 		; 0000 111 000 000 000
			AND.W 	D7,D1
			ROL.W 	#7,D1
			BRA 	ADDRESS_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 018 MOVE.W Move Data from Source to Destination (WORD)
*---------------------------------------------------------------------------------------------------
MOW_T		LEA MOW_M,A1
			BSR OPERAND_POSITION
			BSR EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			; BSR EA_TYPE3
			RTS
*---------------------------------------------------------------------------------------------------
* 019 MOVEA.L Move Address (LONG)
*---------------------------------------------------------------------------------------------------
MOAL_T		LEA MOAL_M,A1
			BSR OPERAND_POSITION
			BSR EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			MOVE.W 	#$0E00,D1 		; 0000 111 000 000 000
			AND.W 	D7,D1
			ROL.W 	#7,D1

			BRA 	ADDRESS_REGISTER_DIRECT
*---------------------------------------------------------------------------------------------------
* 020 MOVE.L  Move Data from Source to Destination (LONG)
*---------------------------------------------------------------------------------------------------
MOL_T		LEA MOL_M,A1
			BSR OPERAND_POSITION
			BSR EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			; BSR EA_TYPE3
			RTS
*---------------------------------------------------------------------------------------------------
* 021 MOVE.B  Move Data from Source to Destination (BYTE)
*---------------------------------------------------------------------------------------------------
MOB_T		LEA MOB_M,A1
			BSR OPERAND_POSITION
			BSR EA_TYPE_01

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			; BSR EA_TYPE3
			RTS
*---------------------------------------------------------------------------------------------------
* 022 CMPI  Compare Immediate
*---------------------------------------------------------------------------------------------------
CMPI_T		LEA CMPI_M,A1
			BSR DISPLAY_SIZE
			BSR IMMEDIATE_DATA

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			BRA EA_TYPE_01
*---------------------------------------------------------------------------------------------------
* 023 BCLR 	Test a Bit and Clear
*---------------------------------------------------------------------------------------------------
BCLR_T		LEA BCLR_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR	EA_TYPE7
			RTS
*---------------------------------------------------------------------------------------------------
* 024 ORI 	Inclusive OR Immediate
*---------------------------------------------------------------------------------------------------
ORI_T		LEA ORI_M,A1

			BSR DISPLAY_SIZE
			BSR IMMEDIATE_DATA

			LEA 	COMMA_M,A1
			MOVE.B 	#14,D0
			TRAP 	#15

			BRA EA_TYPE_01			* EA_TYPE_04


*---------------------------------------------------------------------------------------------------
******************************************  Data Section  ******************************************
*---------------------------------------------------------------------------------------------------

HEADER		DC.B	'Address   OP-Code	Operand				    Instruction',CR,LF
LINE		DC.B 	'--------------------------------------------------------------------------------',0
PRESS_ANY	DC.B	'  press ANY key to continue...',0
END_M      	DC.B 	'  [Program has terminated]',0

ERROR_M0	DC.B 'No DATA was found between range [',0
ERROR_HM0	DC.L $4f6b6179,$204e6173,$682c2074,$68697320,$73686f75,$6c642061
			DC.L $74206c65,$61737420,$636f756e,$7420666f,$72206120,$72656170
			DC.L $65722070,$6f696e74,$205b5261,$6e676520,$4572726f,$725d0000,0

INIT_HEX	DC.B	'0x',0
HASH_M		DC.B	'#',0
DOLLAR_M	DC.B	'$',0
COMMA_M		DC.B 	',',0

DATA_M		DC.B	'DATA ',0

BYTE_M		DC.B	'.B',0
WORD_M		DC.B	'.W',0
LONG_M		DC.B	'.L',0

DATA_REG_M	DC.B 	'D',0
PRE_BRACKET	DC.B 	'('
ADDRESS_Ax	DC.B 	'A',0
POST_BRACKE	DC.B 	')',0
NEGATIVE_M	DC.B	'-',0
POSITIVE_M 	DC.B 	'+',0

ASd_M		DC.B 	'AS',0
LSd_M		DC.B 	'LS',0
ROd_M		DC.B 	'RO',0
LEFT_M		DC.B 	'L',0
RIGHT_M		DC.B 	'R',0

NEWLINE_M	DC.B  	CR,LF,0

SR_HEX_INP  DC.L 	$53746172,$74696E67,$2052616E,$6765203A,$20307800,0
ED_HEX_INP  DC.L 	$456E6469,$6E672052,$616E6765,$2020203A,$20307800,0

HEX_ERROR   DC.B 	'BAD INPUT',0

HEX_ERROR_NONE  DC.B 'NO INPUT FOUND',0
HEX_ERROR_LONG  DC.B 'INPUT TOO LONG',0
START_RANGE_M	DC.B CR,LF,'The Range [',0
FINAL_RANGE_M	DC.B '] is now set.',0

ADDA_M		DC.B	'ADDA',0		* Tested	0xD0C0
ADD_M		DC.B	'ADD',0			* Tested	0xD000
MULS_M		DC.B	'MULS',0		* Issue		0xC1C0
EOR_M 		DC.B 	'EOR',0 		* ADDED		0xB100
CMP_M		DC.B	'CMP',0						0xB000
SUB_M		DC.B	'SUB',0						0x9000
DIVS_M		DC.B	'DIVS',0		* Issue		0x81C0
OR_M		DC.B	'OR',0						0x8000
SUBQ_M		DC.B	'SUBQ',0					0x5100
JSR_M		DC.B	'JSR',0			* Tested	0x4E80
RTS_M		DC.B	'RTS',0			* Tested	0x4E75
NOP_M		DC.B	'NOP',0			* Tested	0x4E71
MOVEM_M		DC.B	'MOVEM',0					0x4880
NEG_M		DC.B	'NEG',0			* Tested	0x4400
LEA_M		DC.B	'LEA',0						0x41C0
MOAW_M		DC.B	'MOVEA.W',0					0x3040
MOW_M		DC.B	'MOVE.W',0					0x3000
MOAL_M		DC.B	'MOVEA.L',0					0x2040
MOL_M		DC.B	'MOVE.L',0					0x2000
MOB_M		DC.B	'MOVE.B',0					0x1000
CMPI_M		DC.B	'CMPI',0					0x0C00
BCLR_M		DC.B	'BCLR',0					0x0180
ORI_M		DC.B	'ORI',0						0x0000


POSITION 	DC.W  	$0000
SAVE_STATE	DS.L  	1
; HEX_USER_IN DS.L 	20

*---------------------------------------------------------------------------------------------------
FILENAME    DC.B    'output.txt',0
ROW 	   	DC.L 	$00000000
TEMPA		DC.B 	'START >>'
DATA    	DS.B 	82
TEMPB		DC.B 	'<< END',0
*---------------------------------------------------------------------------------------------------

OPERATION_2	DC.B 	'Dn + <ea> -> <ea> EA_TYPE_03',0

*----------------------------  Individual OPCODE Operation Task Array  -----------------------------

* The values for this constant are set to move in parallel with those of
* the constant BITMASK via steps at label NEXT_MASK.

TASK_OP		DC.W xOd_T,EA_TYPE_06,ADDA_T,ADD_T,MULS_T,EOR_T,CMP_T,SUB_T,DIVS_T,OR_T,Bcc_T,SUBQ_T,JSR_T
			DC.W RTS_T,NOP_T,MOVEM_T,NEG_T,LEA_T,MOAW_T,MOW_T,MOAL_T,MOL_T,MOB_T,CMPI_T,BCLR_T,ORI_T,0

*-----------------------------  Individual Bitmask Translation Array  ------------------------------

BITMASK		DC.W $E0C0,$E000,$D0C0,$D000,$C1C0,$B100,$B000,$9000,$81C0,$8000,$6000,$5100,$4E80
			DC.W $4E75,$4E71,$4880,$4400,$41C0,$3040,$3000,$2040,$2000,$1000,$0C00,$0180,$0000

			END		START			* last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
