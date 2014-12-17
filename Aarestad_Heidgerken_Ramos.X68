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
LONG		EQU   $0004			* Advance address by a long
BITMASK8	EQU   $00FF

*----------------------- Address Register / Data Register ----------------------
* A0: Designated for Source Code
* A1: Designated for Displaying string to the output
* A2: Designated for OP Bitmask list / Hexadecimal Bitmask list
* A3: Designated for Task Operation list / Hexadecimal value list
* A4: 
* A5: Starting Address
* A6: Ending Address


* D0: Designated for task code values while using TRAP #15
* D1: Main 16-bits copy of the instructions (PRINTING PURPOSES) / Task 11
* D2: Hexadecimal Temp convert
* D3: Temporary 16-bits for bitmask comparison
* D4: 
* D5: 
* D6: 
* D7: Temporary 16-bits for EA

******************** Main Program / Initial Starting Point *********************

			ORG    START		* Program begins here

INIT_START	* BSR USER_HEX_INPUT

			; MOVEA.L A5,A0 		* Move a temp starting point from A5 to A0
			; BSR RANGE_ERROR_CHECK

			MOVEA	#$3500,A0
			MOVEA	#$3600,A6

*---------------------------- Displaying to output -----------------------------

NEXT_SOURCE	LEA LINE,A1
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

SEARCH_HUNT	CMPA.L A6,A0		* Did I happen to go over the user range?
			BGE END_PROGRAM		* If I did, I'll end the progarm.
			ADDA.W #WORD,A0		* If not, I'll continue to hunt for DATA
			CMPI.W #$FFFF,(A0)  * Did I happen to find any useful DATA?
			BEQ SEARCH_HUNT     * Nope, continue the hunt

*------------------------ Press ANY key to continue to -------------------------

			LEA PRESS_ANY,A1
			MOVE.B #14,D0		* Move task 13 into Data Register 0
			TRAP #15			* Display the string at (A1) without CR, LF.

			MOVE.B #5,D0			******  TESTING BETA  ******
			TRAP #15				******  TESTING BETA  ******

			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
			MOVE.W #$FF00,D1	* Clear Screen : Set D1.W to $FF00
			TRAP #15

			CLR.W POSITION			*** TEST - RESET POSITION ***

			BRA NEXT_SOURCE

END_PROGRAM	CLR.W POSITION			*** TEST - RESET POSITION ***
			
			LEA END_M,A1
			MOVE.B #14,D0
			TRAP #15

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

			MOVE.L A0,SAVE_STATE	******  BETA (Save the current address to display later) ******
			MOVE.W (A0),D7 			******  BETA (Saving current instruction in D7 for EA David) ******

*-------- Retrieve matched then execute task by jumping to subroutine ----------

			MOVE.B 	#14,D0			; Sets up task 14 
			MOVEA.W (A3),A3		* Moves the task address into the same (An)
			JSR (A3)			* Jumps to the current task subroutine from A3

			BSR DISPLAY_INTRUCTION	******  BETA (display the whole set of instructions used)  ******

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

POSI_CHECK	CMPI.W #$FFFF,(A0)		* See if you reached the end of the instructions

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
			ADDI #$0200,D1		* Increase the cursor two spaces '__'

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


*************************** No DATA Found subroutine ***************************

NO_DATA_FOUND:
			LEA ERROR_M0,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.L A5,D2
			BSR DISPLAY_LONG_HEX

			MOVE.B #$2C,D1
			MOVE.B #6,D0
			TRAP #15

			MOVE.L A6,D2
			BSR DISPLAY_LONG_HEX

			MOVE.B #$5D,D1
			MOVE.B #6,D0
			TRAP #15

			BSR NEWLINE

			CLR.L D2

			BRA END_PROGRAM


; **********************  Checking Range Input Subroutine  ***********************

; RANGE_ERROR_CHECK:
; *---------------------- Checks the range of START and END ----------------------
; 			CMPA.L A6,A5 		* Tests to see if the starting mark isn't greater than the ending
; 			BLT SEARCH_INIT 	* Okay good, you didn't crash my program. We can move on and be happy

; 			LEA ERROR_HM0,A1 	* Loads error message to the output
; 			MOVE.B #13,D0
; 			TRAP #15

; 			MOVE.L (A7)+,D2			**** SOME HOW POP FROM A7 ****
; 			CLR.L D2

; 			BRA INIT_START

; SEARCH_INIT	CMPA.L A6,A0		* Did I happen to go over the user range?
; 			BGE NO_DATA_FOUND	* If I did, I'll end the progarm.
			
; 			CMPI.W #$FFFF,(A0)  * Did I happen to find any useful DATA?

; 			BNE SEARCH_END     * Nope, continue the hunt
; 			ADDA.W #WORD,A0		* If not, I'll continue to hunt for DATA
; 			BRA SEARCH_INIT

; SEARCH_END	RTS					* Returns from subroutine


; **************************  ASCII -> HEX  Subroutine  **************************

; USER_HEX_INPUT:

; *--------------------- Starting/Ending Hexadecimal Input -----------------------

;             LEA SR_HEX_INP,A1       * Load the start hexadecimal address message
;             MOVE.B #14,D0           * Task 14: Display the string at (A1) without CR, LF
;             TRAP #15                * Display start hexadecimal address message
            
;             LEA HEX_USER_IN,A1      * Load the address of the reserved hex user input
;             MOVE.B #2,D0            * Task 2: Read string from keyboard and store at (A1),(max 80) 
;             TRAP #15                * Get user input, store it in A1, store length in D1

;             BSR .HEX_LENGTH         * Checks the length of the input from the user
;             SUBQ #1,D1              * Subtract one from the loop counter to account for offset
;             BSR .HEX_ASCII          * Branch to HEX_ASCII (starting range address)
;             MOVE.L D3,A5            * Move the starting address in hexadecimal into A5

;             CLR.L D3                * Clearing D3 for the ending address

;             LEA ED_HEX_INP,A1       * Load ending hexadecimal address message
;             MOVE.B #14,D0           * Task 14: Display the string at (A1) without CR, LF
;             TRAP #15                * Display ending hexadecimal address message
            
;             LEA HEX_USER_IN,A1      * Load the address of the reserved hex user input
;             MOVE.B #2,D0            * Task 2: Read string from keyboard and store at (A1),(max 80) 
;             TRAP #15                * Get user input, store it in A1, store length in D1
            
;             BSR .HEX_LENGTH         * Checks the length of the input from the user
;             SUBI #1,D1              * Deals with the offset from the HEX_ASCII loop 
;             BSR .HEX_ASCII          * Branch to HEX_ASCII (ending range address)
;             MOVE.L D3,A6            * Move the ending address in hexadecimal into A6

;             LEA START_RANGE_M,A1
;             MOVE.B #14,D0
;             TRAP #15

;             MOVE.L A5,D2
;             BSR DISPLAY_LONG_HEX

;             LEA COMMA_M,A1
;             MOVE.B #14,D0
;             TRAP #15

;             MOVE.L A6,D2
;             BSR DISPLAY_LONG_HEX

;             LEA FINAL_RANGE_M,A1
;             MOVE.B #13,D0
;             TRAP #15

; 			LEA PRESS_ANY,A1
; 			MOVE.B #14,D0		* Move task 13 into Data Register 0
; 			TRAP #15			* Display the string at (A1) without CR, LF.

; 			MOVE.B #5,D0			******  TESTING BETA  ******
; 			TRAP #15				******  TESTING BETA  ******

; 			CLR.L D2
; 			CLR.L D3

; 			MOVE.B #11,D0 		* Moving task 11 into Data Register 0
; 			MOVE.W #$FF00,D1	* Clear Screen : Set D1.W to $FF00
; 			TRAP #15

;             RTS                     * Done with this Subroutine, and now go back to main

; *-------------------------- Hexadecimal length Check ---------------------------

; .HEX_LENGTH CMPI #8,D1              * Checks if the current length is less than a value of 8
;             LEA HEX_ERROR_LONG,A1   * Loading the HEX_ERROR_LONG error message into A1
;             BGT .BAD_HEX            * Branch to BAD_HEX if length is greater than a value of 8 (value > 0)
;             TST D1                  * Check if the current length is less than or equal to 0
;             LEA HEX_ERROR_NONE,A1   * Loading the HEX_ERROR_SHORT error message into A1
;             BLE .BAD_HEX            * Branchs to BAD_HEX if the current length is (value <= 0)
;             LEA HEX_USER_IN,A1      * Reload the Hex User Input location into A1
;             RTS
            
; *----------------------- Display Error Handling Message ------------------------

; .BAD_ASCII  LEA HEX_ERROR,A1       * Load the generic bad hex message

; .BAD_HEX    MOVE.B #13,D0           * Prepare for printing an error message, using task 13
;             TRAP #15                * Display the selected error message
;             CLR.L HEX_USER_IN
;             BRA USER_HEX_INPUT      * Branch to get input again
            
; *---------------------- Uppercase Hexadecimal Conversion -----------------------

; .HEX_ASCII  ROL.L #4,D3             * Rotate left shift by four bits (BYTE)
;             MOVE.B (A1)+,D2         * Move a byte from A1 into D2 to work with

;             CMP #'f',D2             * If D2 is great than lowercase 'f',0x66
;             BGT .BAD_ASCII          * Branch to the bad hexadecimal message
;             CMP #'0',D2             * If D2 is less than '0',0x30)
;             BLT .BAD_ASCII          * Branch to the bad hexadecimal message
;             CMP #'9',D2             * If D2 is or less than '9', 0x39. [0-9], 0x39
;             BLE .NUMUBER            * It's a number value, so branch yourself to NUMUBER
;             CMP #'a',D2             * If D2 is a lowercase letter [a - f], value >= 0x61
;             BGE .LOWERCASE          * Branch to LOWERCASE part
;             CMP #'A',D2             * If D2 is not below uppercase 'A', 0x41
;             BLT .BAD_ASCII          * Branch to the bad hexadecimal message
;             CMP #'F',D2             * If D2 is not above uppercase 'F', 0x46
;             BGT .BAD_ASCII          * Branch to the bad hexadecimal message
            
; *--------------------- ASCII: Uppercase Hexadecimal Value ----------------------

;             SUBI.B #$37,D2          * Subtract $37 to make ASCII A-F -> HEX A-F
;             OR.L D2,D3              * OR D2 w/ D3 and store the result in D3
;             DBF D1,.HEX_ASCII       * D1--, if D1 = -1 STOP, otherwise branch to HEX_ASCII
;             RTS                     * Done with this HEX translation, go back up.

; *---------------------- ASCII: Number Hexadecimal Value ------------------------

; .NUMUBER    SUBI.B #$30,D2          * Subtract $30 to make ASCII 0-9 -> HEX 0-9
;             OR.L D2,D3              * OR D2 w/ D3 and store the result in D3
;             DBF D1,.HEX_ASCII       * D1--, if D1 = -1 STOP, otherwise branch to HEX_ASCII
;             RTS                     * Done with this HEX translation, go back up.

; *--------------------- ASCII: Lowercase Hexadecimal Value ----------------------

; .LOWERCASE  SUBI.B #$57,D2          * Subtract $57 to make ASCII a-f -> HEX A-F
;             OR.L D2,D3              * OR D2 w/ D3 and store the result in D3
;             DBF D1,.HEX_ASCII       * D1--, if D1 = -1 STOP, otherwise branch to HEX_ASCII_S   
;             RTS                     * Done with this HEX translation, go back up.


************************ Display Hexadecimal Subroutine ************************
* Displays an output of a single 16-bit instruction as a hexadecimal value
* Take that prof. Nash (mostly Kim), I didn't want to use task #15 anyway

*** IMPORTANT *** Load the value that you wish to display in hexadecimal in D2

DISPLAY_LONG_HEX:

			ROL.L #4,D2			* Shifts to read the next hexadecimal digit
			BSR INTI_LOOP		* Branch towards the loop of hex thingy
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
			
			MOVE.W D1,D3		* Saves the current position into D3 for later

			ROL.W #4,D2			* Shifts to read the next hexadecimal digit
			BSR INTI_LOOP		* Branch towards the loop of hex thingy

			ROL.W #4,D2			* I HATE THIS, SO MUCH REPEATING CODE
			BSR INTI_LOOP		* I TRIED EVERYTHING WITHOUT USING ANOTHER
			ROL.W #4,D2			* DATA REGISTER. THAT IS SUCH A WASTE... GOSH
			BSR INTI_LOOP		* SO I'M GOING TO LEAVE THIS HERE, BECUASE I
			ROL.W #4,D2			* REALLY DON"T CARE. TOO MUCH TIME WAS WASTED
			BSR INTI_LOOP		* ANNND YES!! NO MORE BAD CODE (IT WORKS DEAL)

			MOVE.W D3,D1		* Move the saved position from D1 before display
			RTS					* Returns from subroutine

DISPLAY_BYTE_HEX:

			ROL.B #4,D2			* Shifts to read the next hexadecimal digit
			BSR INTI_LOOP		* Branch towards the loop of hex thingy
			ROL.B #4,D2
			BSR INTI_LOOP
			RTS					* Returns from subroutine


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

**********************  Display Operation Size [Byte, Word, Long] Subroutine  **********************
DISPLAY_SIZE_B:

			TRAP 	#15

			BTST 	#6,D7			; Ascertains the operation size is a WORD by the 6th bit from Opmode 
			BEQ 	.LONG   		; If the Z condition code is 0 = Word operation / 1 = Long operation
			LEA 	WORD_M,A1		* Loading message '.W' into address register 1

			BRA 	.SET_TRAP

.LONG		BTST 	#7,D7			; Ascertains the operation size is a LONG by the 7th bit from Opmode 
			BEQ 	.BYTE 
			LEA 	LONG_M,A1		* Loading message '.L' into address register 1

			BRA 	.SET_TRAP

.BYTE 	 	 LEA 	BYTE_M,A1		* Loading message '.B' into address register 1

.SET_TRAP 	TRAP 	#15				* Display the string at (A1) without CR, LF

			RTS						; Done with subroutine and return to previous task


******************** Display the Size (.B .W .L) Subroutine ********************

DISPLAY_SIZE:

			MOVE.W (A0),D3 		* Make a temp copy of the current instruction in D3
			ANDI.B #$C0,D3 		* Bitmask the current instruction to obtain only the size bits
			LSR.B #6,D3 		* Shift the obtained size bits to be the least bits in the register

			CMPI.B #3,D3
			BNE CHECK_A
			BRA DISPLAY_ERROR 		******  TESTING BETA  ******

CHECK_A
			TRAP #15			* Display the string at (A1) without CR, LF
			
			CMPI.B #2,D3
			BNE CHECK_B

			LEA LONG_M,A1		* Loading message '.L' into address register 1
			BRA CHECK_D

CHECK_B		CMPI.B #1,D3
			BNE CHECK_C

			LEA WORD_M,A1		* Loading message '.W' into address register 1
			BRA CHECK_D

CHECK_C		LEA BYTE_M,A1		* Loading message '.B' into address register 1

CHECK_D		TRAP #15			* Display the string at (A1) without CR, LF

*----------------- Moving the cursor to the desired location -------------------

OPERAND_POSITION:
			MOVE.B #11,D0		* Moving task 11 into Data Register 0
			MOVE.W POSITION,D1  * Setting up the desired row position
			ADDI #$1600,D1		* Setting up the desired column position
			TRAP #15			* Position the cursor at [2Cxx] x - any number	
			RTS					* Returns from subroutine


********************* Display the Data Immediate Subroutine ********************

DISPLAY_IMMEDIATE:

			LEA INIT_DATA,A1
			MOVE.B #14,D0
			TRAP #15

			TST.B D3
			BNE WORD_DATA

			ADDA.W #WORD,A0
			MOVE.W (A0),D2
			BSR DISPLAY_BYTE_HEX
			BRA END_DATA

WORD_DATA	CMP.B #1,D3
			BNE LONG_DATA

			ADDA.W #WORD,A0
			MOVE.W (A0),D2
			BSR DISPLAY_WORD_HEX
			BRA END_DATA

LONG_DATA	ADDA.W #WORD,A0
			MOVE.L (A0),D2
			BSR DISPLAY_LONG_HEX
			ADDA.W #WORD,A0

END_DATA 	LEA COMMA_M,A1
			MOVE.B #14,D0
			TRAP #15
			RTS


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

			MOVE.L (A7)+,D2			**** SOME HOW POP FROM A7 ****
			BRA NEWLINE

****************** DISPLAY Dx,Ax,(Ax),(Ax)+,-(Ax) Subroutine *******************

DISPLAY_DATAREG: * DATA_REGISTER_DIRECT Dn
			LEA DATA_REG_M,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS

DISPLAY_ADDEREG: * ADDRESS_REGISTER_DIRECT An
			LEA ADDRESS_Ax,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15
			RTS

DISPLAY_PREDEC: * ADDRESS_REGISTER_INDIRECT_PREDECREMENT -(An)
			LEA NEGATIVE_M,A1
			MOVE.B #14,D0
			TRAP #15

DISPLAY_INDIR: * ADDRESS_REGISTER_INDIRECT (An)
			LEA PRE_BRACKET,A1
			MOVE.B #14,D0
			TRAP #15

			MOVE.B #3,D0		* Display signed number in D1.L in decimal
			TRAP #15

			LEA POST_BRACKE,A1
			MOVE.B #14,D0
			TRAP #15
			RTS
					
DISPLAY_POSTINC: * ADDRESS_REGISTER_INDIRECT_POSTINCREMENT (An)+
			BSR DISPLAY_INDIR

			MOVE.B #'+',D1
			MOVE.B #6,D0
			TRAP #15
			RTS

; *-------------------------------------------------------------------------------
; * Display_Reg1 - read 0 -> 15
; *
; * 16 bit regmask  A7->A0/D7->D0
; * assumed to be in D1
; * D2 will contain a count and points to current bit.
; * D3 will store a value of the previous bit
; * a value of 3 indicates that the previous char printed was a dash
; * Written by: David Heidgerken
; *-------------------------------------------------------------------------------
; DISPLAY_REGS:
; 					MOVE.L		#0, D2		; store counter count up
; 					CLR			D3
					
; .top				BTST		D2, D1
; 					BEQ			.currentzero	;if current is 0 branch to current_zero
; *-------------------------------------------------------------------------------
; .currentone			CMP.W 	#1, D3			;check previous(d3) value
; 					BEQ		.startofseq		;if 1 display startofseq
					
; 					CMP.W	#0, D3			;cmp prev(d3) to 0
; 					BEQ		.updateone		;branch to updateone
; 					BRA		.next			;otherwise(D3 = 3) next
					
; .updateone			MOVE.L	#1, D3			;update D3 w/ 1
; 					BRA		.next
					
; .startofseq			MOVE.L	D1,-(SP)			;move regmask onto stack

; 					MOVE.L	D2, D1				;move counter into d1
; 					SUBI	#1,D1				;subtract 1 to get previous i
; 					CMP.W	#8,	D1		        ;compare to 8
; 					BGE		.displayAxOne		;counter GE to 8are AddRegs		
				
; .displayDxOne		BSR		DISPLAY_DATAREG		
; 					BRA		.startnext
					
; .displayAxOne		SUBI	#8,D1	
; 					BSR		DISPLAY_ADDEREG
					
; .startnext			MOVE.L	(SP)+,D1			;move regmask back to D1
; 					MOVE.L	#3, D3				;update previous
; 					BRA		.next
; *-------------------------------------------------------------------------------
; .currentzero		CMP		#0, D3				;cmp prev(d3)to 0
; 					BEQ		.next				;if eq go .next

					
; 					MOVE.L	D1,-(SP)			;move regmask onto stack

; 					CMP		#1, D3
; 					BEQ		.endofseq
					
; 					MOVE.L	#$2D,D1				;move dashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; .endofseq			MOVE.L	D2, D1				;move counter into d1
; 					SUBI	#1,D1				;subtract 1 to get previous i
; 					CMP.W	#8,	D1		        ;compare to 8
; 					BGE		.displayAxZero		;counter GE to 8are AddRegs

; .displayDxZero		BSR		DISPLAY_DATAREG
; 					BRA		.endnext
					
; .displayAxZero		SUBI	#8,D1	
; 					BSR		DISPLAY_ADDEREG
					
; .endnext			MOVE.L	#$2F,D1				;move slashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; 					MOVE.L	(SP)+,D1			;move regmask back to D1
; 					MOVE.L	#0, D3				;update previous
; 					BRA		.next
					
; *-------------------------------------------------------------------------------
; .next				ADDI.W	#1,D2				;add 1 to counter
;                     CMP.W		#16,D2
; 					BEQ			.break			;head to break
; 					BRA     .top

; .break				CMP.W 	#0, D3				;check previous value
; 					BEQ		.exit				;if 0 exit, othewise display A7
	
; .displayA7			CMP.W	#1,D3
; 					BEQ		.nodash
					
; 					MOVE.L	#$2D,D1				;move dashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; .nodash				MOVE.L	#7, D1				;move 7 into d1
; 					BSR		DISPLAY_ADDEREG
					
; .exit				RTS
; *-------------------------------------------------------------------------------

; *-------------------------------------------------------------------------------
; * Display_Reg2 - read 15 -> 0  reverse order for -(Ax)
; *
; * 16 bit regmask  A7->A0/D7->D0
; * assumed to be in D1
; * D2 will contain a count and points to current bit.
; * D3 will store a value of the previous bit
; * a value of 3 indicates that the previous char printed was a dash
; * Written by: David Heidgerken
; *-------------------------------------------------------------------------------
; DISPLAY_REGS2:
; 					MOVE.L		#15, D2		; store counter count up
; 					CLR			D3
					
; .top				BTST		D2, D1
; 					BEQ			.currentzero	;if current is 0 branch to current_zero
; *-------------------------------------------------------------------------------
; .currentone			CMP.W 	#1, D3			;check previous(d3) value
; 					BEQ		.startofseq		;if 1 display startofseq
					
; 					CMP.W	#0, D3			;cmp prev(d3) to 0
; 					BEQ		.updateone		;branch to updateone
; 					BRA		.next			;otherwise(D3 = 3) next
					
; .updateone			MOVE.L	#1, D3			;update D3 w/ 1
; 					BRA		.next
					
; .startofseq			MOVE.L	D1,-(SP)			;move regmask onto stack

; 					MOVE.L	D2, D1				;move counter into d1
; 					ADDI	#1,D1				;add 1 to get previous i
; 					CMP.W	#8,	D1		        ;compare to 8
; 					BLT		.displayAxOne		;counter GE to 8are AddRegs		
				
; .displayDxOne		SUBI	#15,D1
; 					NEG		D1
; 					BSR		DISPLAY_DATAREG		
; 					BRA		.startnext
					
; .displayAxOne		SUBI	#7,D1
; 					NEG		D1
; 					BSR		DISPLAY_ADDEREG
					
; .startnext			MOVE.L	(SP)+,D1			;move regmask back to D1
; 					MOVE.L	#3, D3				;update previous
; 					BRA		.next
; *-------------------------------------------------------------------------------
; .currentzero		CMP		#0, D3				;cmp prev(d3)to 0
; 					BEQ		.next				;if eq go .next

					
; 					MOVE.L	D1,-(SP)			;move regmask onto stack

; 					CMP		#1, D3
; 					BEQ		.endofseq
					
; 					MOVE.L	#$2D,D1				;move dashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; .endofseq			MOVE.L	D2, D1				;move counter into d1
; 					ADDI	#1,D1				;add 1 to get previous i
; 					CMP.W	#8,	D1		        ;compare to 8
; 					BLT		.displayAxZero		;counter GE to 8are AddRegs

; .displayDxZero		SUBI	#15,D1
; 					NEG		D1
; 					BSR		DISPLAY_DATAREG		
; 					BRA		.endnext
					
; .displayAxZero		SUBI	#7,D1
; 					NEG		D1
; 					BSR		DISPLAY_ADDEREG
					
; .endnext			MOVE.L	#$2F,D1				;move slashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; 					MOVE.L	(SP)+,D1			;move regmask back to D1
; 					MOVE.L	#0, D3				;update previous
; 					BRA		.next
					
; *-------------------------------------------------------------------------------
; .next				SUBI.W	#1,D2				;sub 1 to counter
;                     CMP.W		#0,D2
; 					BLT			.break			;head to break
; 					BRA     .top

; .break				CMP.W 	#0, D3				;check previous value
; 					BEQ		.exit				;if 0 exit, othewise display A7
	
; .displayA7			CMP.W	#1, D3
; 					BEQ		.nodash
					
; 					MOVE.L	#$2D,D1				;move dashvalu into D1
; 					MOVE.B #6,D0
; 					TRAP #15					;and display
					
; .nodash				MOVE.L	#7, D1				;move 7 into d1
; 					BSR		DISPLAY_ADDEREG
					
; .exit				RTS


***************************  Effective Address Algorithms & Subroutines  ***************************
*---------------------------------------------------------------------------------------------------
EA_MODE_01:
			MOVE.B	#%00111000, D5	* move primative 3 bitmask into D4 	0x38 (OPMODE)
			MOVE.B	#%00000111, D6	* move primative 3 bitmask into D3 	0x07 (REGISTER)

			AND.W	D7,D5			* and D7 and D5 store in D5 (OPMODE)
			AND.W	D7,D6			* and D7 and D6 store in D6 (REGISTER)
			LSR.B	#3,D5			* Shifts the temp OPMODE right 3 places
			
			MOVE.L	D6,D1			* Move register value to D1

*------------------------ Compares between OPMODE 0-6 --------------------------

			TST.B	D5				* Compare OpMode with 000	Dx  ************
			BNE		.A_MODE			* Branch to OpMode Data Register
			BRA		DISPLAY_DATAREG	* Send to data register display subr

.A_MODE		CMP.B	#1, D5			* compare opmode with 001	Ax  ************
			BNE		.IND_MODE		* branch to Address reg mode
			BRA		DISPLAY_ADDEREG	* Invalid mode for this type
			
.IND_MODE	CMP.B	#2, D5			* compare opmode with 010  (Ax) ************
			BNE		.PI_MODE		* branch to indirect Mode
			BRA		DISPLAY_INDIR	* Send to data register indirect subr

.PI_MODE	CMP.B	#3, D5			* compare opmode with 011  (Ax)+ ***********
			BNE		.PD_MODE		* branch tp post incrementmodebr
			BRA		DISPLAY_POSTINC	* Send to POSTINCR display sub

.PD_MODE	CMP.B	#4, D5			* compare opmode with 100 -(Ax) ************
			BNE		.DATA_MODE		* branchto Post decrement mode
			BRA		DISPLAY_PREDEC

*---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

.DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L ************
			BNE		DISPLAY_ERROR	* branc to data modes

			TST.B	D6				* compare register to 000 (xxx).W
			BEQ		.WORDDATA		;branch to word data
			
			CMP.B	#1, D6			* compare register to 001 (xxx).L
			BEQ		.LONGDATA		;branch to long data
			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1
						
.WORDDATA	LEA INIT_MEM,A1
			MOVE.B #14,D0
			TRAP #15

			ADDA.W #WORD,A0
			MOVE.W (A0),D2
			BRA	DISPLAY_WORD_HEX		; display word in hex

.LONGDATA	LEA INIT_MEM,A1
			MOVE.B #14,D0
			TRAP #15

			ADDA.W #WORD,A0
			MOVE.L (A0),D2
			ADDA.W #WORD,A0
			BRA	DISPLAY_LONG_HEX	; display long in hex


;  *-------------------------------------------------------------------------------
;  * Type 3 xxxx rrrooo oorrr
;  * Subroutine for handling two Operand Effective addressing to find 2 3 bit modes
;  * and two 3 bit registers
;  * Written by: David Heidgerken
;  * Description.  16 bit Instruction will be passed to subroutine via D7
;  * and will parse the last 12 bits to determine the addressing mode and 
;  * locations of the data.
;  * source register stored in D3, source mode in D4 Dest mode in D5 dest register
;  * in D6
;   * ADD ADDA CMP MOVE.* OR SUB 
;  *-------------------------------------------------------------------------------		
;  EA_TYPE3:
;  			MOVE.W	#%00001110, D3	* move primative 3 bitmask into D3 	0xD (REGISTER)
;  			LSL.W	#8, D3			* shift right eight time into upper bit 0x0D00
;  			MOVE.W	#%11100000, D4	* move primative 3 bitmask into D4 	0xD0 (OPMODE)
;  			LSL.W	#1, D4			* shiftleft 1 time 0x01C0
;  			MOVE.W	#%00111000, D5	* move primative 3 bitmask into D5 0x38(EA MODE)
;  			MOVE.W 	#%00000111, D6	* move primative 3 bit maskinto D6 0x7(EA REGISTER)

;  			MOVE.W	#%11100000, D4	* move primative 3 bitmask into D4 	0xD0 (OPMODE)
;  			LSL.W	#1, D4			* shiftleft 1 time 0x01C0
;  			MOVE.W	#%00111000, D5	* move primative 3 bitmask into D5 0x38(EA MODE)
;  			MOVE.W 	#%00000111, D6	* move primative 3 bit maskinto D6 0x7(EA REGISTER)


;  			AND.W	D7, D3			* and D7 and D5 store in D3 (REGISTER)
;  			LSR.W	#8, D3			* shift it right 8 times
; 			LSR.W	#1, D3			* shift right one more time.
;  			AND.W	D7, D4			* and D7 and D6 store in D4 (OPMODE)
;  			LSR.W	#6, D4			* Shifts the temp OPMODE right 6 places.
;  			AND.W	D7, D5			* and D7 and D5 (EA MODE)
;  			LSR.W	#3, D5			* shift right 3 times
;  			AND.W	D7, D6			* and D7 and D6 (EA REGISTER)
		
;  			MOVE.L	D6,D1			* Move register value to D1

; *------------------------ Compares Destination or Source Modes -----------------
; .OPMODE	CMP.B       #3,D4			;compare opmode to 3
;  			BLE		.D_MODE			;do EA comparrisons first
;  			BGT		.DEST_MODE		;send to destination mode
 			
; .SRC_MODE	LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15

; 			MOVE.L	D3, D1			;load D3 into D1 for printing.
; 			CMP		#3,D4
; 			BEQ		.addasrc
; 			CMP		#8,D4
; 			BEQ		.addasrc
			
;  			BSR		DISPLAY_DATAREG	;display Data Reg first.
;  			BRA		.exit
; .addasrc
; 			BSR		DISPLAY_ADDEREG
; 			BRA		.exit
			
; .DEST_MODE	MOVE.L	D3, D1			;load D3 into D1 for printing.
; 			; CMP		#3,D4
; 			; BEQ		.addadest
; 			CMP		#7,D4
; 			BEQ		.addadest
;  			BSR		DISPLAY_DATAREG	;display Data Reg first.
; 			BRA		.comma
			
; .addadest	BSR		DISPLAY_ADDEREG

; .comma		LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15
			
;  			BRA		.D_MODE			;send to addressmode comparrisons
 			

;  *------------------------ Compares between EA MODE 0-6 --------------------------

; .D_MODE		TST.B	D5				* Compare OpMode with 000	Dx  ************
;  			BNE		.A_MODE			* Branch to A register mode
;  			MOVE.L	D6, D1			* load D6 into D1 for printing.
;  			BSR		DISPLAY_DATAREG	* Send to data register display subr
;  			BRA		.break

; .A_MODE		CMP.W	#1, D5			* compare opmode with 001	Ax  ************
;  			BNE		.IND_MODE		* branch to indir mode
;  			BRA		DISPLAY_ADDEREG	* Invalid mode for this type
; 			BRA     .break
			
; .IND_MODE	CMP.W	#2, D5			* compare opmode with 010  (Ax) ************
;  			BNE		.PI_MODE		* branch to post incr mode
;  			MOVE.L	D6, D1			* load D6 into D1 for printing.
;  			BSR		DISPLAY_INDIR	* Send to data register indirect subr
; 			BRA     .break
			
; .PI_MODE	CMP.W	#3, D5			* compare opmode with 011  (Ax)+ ***********
;  			BNE		.PD_MODE		* branch tp pre dec
;  			BSR		DISPLAY_POSTINC	* Send to POSTINCR display sub
; 			BRA     .break
			
; .PD_MODE	CMP.W	#4, D5			* compare opmode with 100 -(Ax) ************
;  			BNE		.DATA_MODE		* branchto Post data mode
;  			MOVE.L	D6, D1			* load D6 into D1 for printing.
;  			BSR		DISPLAY_PREDEC
; 			BRA     .BREAK


;  *---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

; .DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L ************
;  			BNE		.INV_MODE		* branch to invalid mode

;  			TST.B	D6				* compare register to 000 (xxx).W
;  			BEQ		.WORDDATA		;branch to word data
			
;  			CMP.B	#1, D6			* compare register to 001 (xxx).L
;  			BEQ		.LONGDATA		;branch to long data
			
;  			CMP.B	#4,D6			* compare register to 100 (xxx).B
;  			BEQ		.BYTEDATA
			
;  			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1

; .BYTEDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.W (A0),D2
;  			; ADDA.W #WORD, A0
;  			BSR	DISPLAY_BYTE_HEX
;  			BRA     .BREAK
						
; .WORDDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.W (A0),D2
;  			BSR	DISPLAY_WORD_HEX		; display word in hex
;  			BRA     .BREAK
 			

; .LONGDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.L (A0),D2
;  			ADDA.W #WORD,A0
;  			BSR	DISPLAY_LONG_HEX	; display long in hex
;  			BRA     .BREAK

; .INV_MODE	BRA		DISPLAY_ERROR	* Display error

; .BREAK		CMP.B	#3,D4			;compare opmode to 3
;  			BLE		.SRC_MODE		;send to src mode
	
; .EXIT		RTS

; *-------------------------------------------------------------------------------
; * Type 4   - xxxx DDD1 xxoo orrr
; * assumes that size has already been parsed and displayed in opcode.
; * Sub Routine to find EA(mode and Register) and Data from instruction
; * D4 stores Databits (1-8) 3bits add 1.
; * D5 stores Mode
; * D6 stores Register
; * SUBQ - 0101rrr1sseeeeee
; *-------------------------------------------------------------------------------		
; EA_TYPE4:
; 			MOVE.B	#%00001110, D4	* move primative 3 bitmask into D4 	0x0D (DATA)
; 			LSL.W	#8, D4			* shift data mask into upper byte.
; 			MOVE.B	#%00111000, D5	* move Primative 3 bit mask into D5 0x38 (EA MODE)
; 			MOVE.B	#%00000111, D6	* move primative 3 bitmask into D6 	0x07 (EA REGISTER)

;  			AND.W	D7, D4			* and D7 and D4 store in D4 (DATA)
; 			LSR.W	#8, D4			* shift into lower bit
;  			LSR.W	#1, D4			* shift right 1 time.
;  			AND.W	D7, D5			* and D7 and D5 store in D5 (OPMODE)
;  			LSR.W	#3, D5			* shift value right 3 times
;  			AND.W	D7, D6			* and D7 and D6 store in D6 (REGISTER)
		
; 			MOVE.L #$23,D1
; 			MOVE.L #6,D0
; 			TRAP #15
			
			
;  			MOVE.L	D4, D1			* move #DATA value into D1
; 			CMP 	#0, D1
; 			BNE	.display
; 			ADDI	#8,D1
			
; .display	MOVE.L	#3, D0
; 			TRAP	#15
			
; 			LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15
			
;  			MOVE.L	D6,D1			* Move register value to D1

; *------------------------ Compares between OPMODE 0-6 --------------------------

;  			TST.B	D5				* Compare OpMode with 000	Dx  ************
;  			BNE		.A_MODE			* Branch to OpMode Data Register
;  			BRA		DISPLAY_DATAREG	* Send to data register display subr

; .A_MODE		CMP.B	#1, D5			* compare opmode with 001	Ax  ************
;  			BNE		.IND_MODE		* branch to Address reg mode
;  			BRA		DISPLAY_ERROR	* Invalid mode for this type
			
; .IND_MODE	CMP.B	#2, D5			* compare opmode with 010  (Ax) ************
;  			BNE		.PI_MODE		* branch to indirect Mode
;  			BRA		DISPLAY_INDIR	* Send to data register indirect subr

; .PI_MODE	CMP.B	#3, D5			* compare opmode with 011  (Ax)+ ***********
;  			BNE		.PD_MODE		* branch tp post incrementmodebr
;  			BRA		DISPLAY_POSTINC	* Send to POSTINCR display sub

; .PD_MODE	CMP.B	#4, D5			* compare opmode with 100 -(Ax) ************
;  			BNE		.DATA_MODE		* branchto Post decrement mode
;  			BRA		DISPLAY_PREDEC

 
; *---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

; .DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L ************
;  			BNE		.INV_MODE		* branc to data modes

;  			TST.B	D6				* compare register to 000 (xxx).W
;  			BEQ		.WORDDATA		;branch to word data
			
;  			CMP.B	#1, D6			* compare register to 001 (xxx).L
;  			BEQ		.LONGDATA		;branch to long data
;  			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1
						
; .WORDDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.W (A0),D2
;  			BRA	DISPLAY_WORD_HEX		; display word in hex

; .LONGDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.L (A0),D2
;  			ADDA.W #WORD,A0
;  			BRA	DISPLAY_LONG_HEX	; display long in hex

; .INV_MODE	BRA		DISPLAY_ERROR	* Display error


; *-------------------------------------------------------------------------------
; * Type 5 mode xxxx xDxx xxoo oorrr   MOVEM needs Range work....
; * Subroutine for handling One Operand addressing looking for a mode and register 
; * value  assumes that size has already been parsed by opcode.
; * Written by: David Heidgerken
; * Description.  16 bit Instruction will be passed to subroutine via D7
; * and will parse it to find which address mode and location is being used.
; * D6 used for Register value, D5 is mode D4 is the direction bit
; * MOVEM
; *-----------------------------------------------------------------------------
; EA_TYPE5:   
;  			MOVE.B	#%00000100, D4	* move primative 1 bitmask into D4 	0x0D (DIRECTION)
;  			LSL.W	#8, D4			* shift data mask into upper byte.
;  			MOVE.B	#%00111000, D5	* move Primative 3 bit mask into D5 0x38 (EA MODE)
;  			MOVE.B	#%00000111, D6	* move primative 3 bitmask into D6 	0x07 (EA REGISTER)
;  			AND.W	D7, D4			* and D7 and D4 store in D4 (DIRECTION)
;  			LSR.W	#8, D4			* move DIRECTION value into lower byte.
;  			LSR.W	#2, D4			* shift right 2 times.
;  			AND.W	D7, D5			* and D7 and D5 store in D5 (OPMODE)
;  			LSR.W	#3, D5			* shift value right 3 times
;  			AND.W	D7, D6			* and D7 and D6 store in D6 (REGISTER)
			
;  			CMP.B	#0, D4			;verify direction of operation.
;  			BNE		.IND_MODE		;otherwise send to comparisons

;  			MOVE.W (A6), D1			; move a word from data stream into D1.
;  			ADDA	#WORD, A6		;increment data pointer
			
; 			CMP.W	#4,D5
; 			BNE		.forward
; 			BSR		DISPLAY_REGS2
			
; 			LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15
			
; 			BRA		.IND_MODE
			
; .forward 	BSR		DISPLAY_REGS	; display regs first.  then ea modes.

; *------------------------ Compares between OPMODE 2,4,7--------------------------
			
; .IND_MODE	CMP.B	#2, D5			* compare opmode with 010  (Ax) ************
; 			BNE		.PI_MODE		* branch to indirect Mode
; 			MOVE.L	D6,D1
;  			BSR		DISPLAY_INDIR	* Send to data register indirect subr
;             BRA     .break
            
; .PI_MODE	CMP.B	#3, D5			* compare opmode with 011  (Ax)+ ***********
;  			BNE		.PD_MODE		* branch tp post incrementmodebr
;             MOVE.L	D6,D1
;  			BSR		DISPLAY_POSTINC	* Send to POSTINCR display sub
;             BRA     .break
 			
; .PD_MODE	CMP.B	#4, D5			* compare opmode with 100 -(Ax) ************
;  			BNE		.DATA_MODE		* branchto Post decrement mode
;             MOVE.L	D6,D1
;  			BSR		DISPLAY_PREDEC
;             BRA     .break

; *---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

; .DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L ************
;  			BNE		.INV_MODE		* branc to data modes

;  			TST.B	D6				* compare register to 000 (xxx).W
;  			BEQ		.WORDDATA		;branch to word data
			
;  			CMP.B	#1, D6			* compare register to 001 (xxx).L
;  			BEQ		.LONGDATA		;branch to long data
;  			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1
						
; .WORDDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.W (A0),D2
;  			BSR	DISPLAY_WORD_HEX		; display word in hex

; 			BRA     .break


; .LONGDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W #WORD,A0
;  			MOVE.L (A0),D2
;  			ADDA.W #WORD,A0
;  			BSR	DISPLAY_LONG_HEX	; display long in hex

; 			BRA     .break


; .INV_MODE	BRA		DISPLAY_ERROR	* Display error

; *------------------- verify direction again ------------------------------------
; .break		CMP.B	#1, D4			;verify direction of operation.
;  			BEQ		.printregs
;  			BGT		.exit
			
; .printregs	MOVE.W (A0), D1			; move a word from data stream into D1.
;  			ADDA	#WORD, A0		;increment data pointer
			
; 			LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15
			
; 			CMP.W	#4,D5
; 			BNE		.forwardend
; 			BSR		DISPLAY_REGS2
; 			BRA		.exit
			
; .forwardend BSR	DISPLAY_REGS	; display regs last	
			
; .exit		RTS					;return to calling instruction


; *-------------------------------------------------------------------------------
; * Type 6 mode xxxx DDDx xxix xrrr	
; * Subroutine for Shift and rotate functions assumes size has been parsed.
; * D4 - stores Data (1-8) add 1 if immediate
; * D5 stores i(imediate or Register)
; * D6 stores register
; *-------------------------------------------------------------------------------
; EA_TYPE6:

; 			MOVE.W	#$0E00,D4		* move primative 3 bit mask into D4 0xE00 (COUNT/REGISTER)
; 			MOVE.B	#$20,D5			* move primative 1 bitmask into D5 	0x20 (I/R)
; 			MOVE.B	#$7,D6			* move primative 3 bitmask into D6 	0x07 (REGISTER)

; 			AND.W 	D7,D4			* AND D7 (Instruction) with D4 Bitmask (COUNT/REGISTER)
; 			ROL.W 	#7,D4 			* Shift the needed bits to the lower byte
; ; 			[0000 1110 0000 0000] into [0000 0000 0000 0111]

; 			AND.W	D7,D5			* and D7 and D5 store in D5 (I/R)
; 			LSR.B	#5, D5			* shift value right 5 places (0-1)
; ; 			[0000 0000 0010 0000] into [0000 0000 0000 0001]

; 			AND.W	D7, D6			* and D7 and D6 store in D6 (REGISTER)

; *------------------------------- Compares (I/R) --------------------------------

; 			TST.B 	D5				* Checks if i/r bit is an immediate value of 0
; 			BNE		.regmode		* D3 (I/R) is a Register Rotate Count
			
; ; If i/r = 0, this field contains the rotate count. The values 1 – 7 represent
; ; counts of 1 – 7, and zero specifies a count of eight.

; 			MOVE.B #$23,D1 			* Prints '#' into the output
; 			MOVE.B #6,D0
; 			TRAP #15
			
; 			MOVE.W D4,D1			; move DATA into D1

; 			TST.B D1
; 			BEQ .PRINT_8

; 			MOVE.B 	#3,D0
; 			TRAP #15
; 			BRA		.DONE			;evaluate eamode	

; .PRINT_8	MOVE.B 	#8,D1			
; 			MOVE.B 	#3,D0
; 			TRAP #15
; 			BRA		.DONE			;evaluate eamode	

; ; If i/r = 1, this field specifies a data register that contains the rotate
; ; count (modulo 64).

; .regmode	MOVE.W	D4,D1			* move the register number into D1
; 			BSR		DISPLAY_DATAREG	* display DataReg

; .DONE		LEA COMMA_M,A1
; 			MOVE.B #14,D0		* Move task 13 into Data Register 0
; 			TRAP #15			* Display the string at (A1) without CR, LF.

; 			MOVE.W D6,D1			; move DATA into D1
; 			BRA DISPLAY_DATAREG


; *-------------------------------------------------------------------------------
; * Type 7 DDDx xxxooo oorrr 
; * Subrotine for handling two Operand Effective addressing to find 2 3 bit modes
; * and one 3 bit registers
; * Written by: David Heidgerken
; * Description.  16 bit Instruction will be passed to subroutine via D7
; * and will parse the last 12 bits to determine the addressing mode and 
; * locations of the data.
; * source register stored in D4, Dest mode in D5 dest register
; * in D6
; * BCLR MOVEA
; *-------------------------------------------------------------------------------	EA_MODE_01:
; EA_TYPE7:
;  			MOVE.B	#%11100000, D4	* move primative 3 bit mask into D4 0xE0 (REGISTER)
;  			LSL.W	#1, D4			* shift mask left 1 0x0100
;  			MOVE.B	#%00111000, D5	* move primative 3 bitmask into D5 	0x38 (EA MODE)
;  			MOVE.B	#%00000111, D6	* move primative 3 bitmask into D6 	0x07 (EA REGISTER)

;  			AND.W	D7, D4			* and D7 with D4 (REGISTER)
;  			LSR.W	#6, D4			* shift value right 6 times.
;  			AND.W	D7,D5			* and D7 and D5 store in D5 (EA MODE)
;  			LSR.B	#3,D5			* Shifts the temp OPMODE right 3 places
;  			AND.W	D7,D6			* and D7 and D6 store in D6 (EA REGISTER)

;  			MOVE.L	D4,D1			* Move register value to D1
; 			BSR	DISPLAY_DATAREG
			
; 			LEA COMMA_M,A1
; 			MOVE.B #14,D0
; 			TRAP #15
			
; 			MOVE.L	D6,D1
			

; *------------------------ Compares between OPMODE 0-6 --------------------------

;  			TST.B	D5				* Compare OpMode with 000	Dx  ************
;  			BNE		.IND_MODE			* Branch to OpMode Data Register
;  			BSR		DISPLAY_DATAREG	* Send to data register display subr
;  			BRA		.break			
; .IND_MODE	CMP.B	#2, D5			* compare opmode with 010  (Ax) ************
;  			BNE		.PI_MODE		* branch to indirect Mode
;  			BSR		DISPLAY_INDIR	* Send to data register indirect subr
;  			BRA		.break
			
; .PI_MODE	CMP.B	#3, D5			* compare opmode with 011  (Ax)+ ***********
;  			BNE		.PD_MODE		* branch tp post incrementmodebr
;  			BSR		DISPLAY_POSTINC	* Send to POSTINCR display sub
;  			BRA		.break
			
; .PD_MODE	CMP.B	#4, D5			* compare opmode with 100 -(Ax) ************
;  			BNE		.DATA_MODE		* branchto Post decrement mode
;  			BSR		DISPLAY_PREDEC
;  			BRA		.break

; *---------------- Compares between OPMODE 7 (xxx).W or (xxx).L -----------------

; .DATA_MODE	CMP.B	#7, D5			* compare opmode with 111 .W .L ************
;  			BNE		.INV_MODE		* branc to data modes

;  			TST.B	D6				* compare register to 000 (xxx).W
;  			BEQ		.WORDDATA		;branch to word data
			
;  			CMP.B	#1, D6			* compare register to 001 (xxx).L
;  			BEQ		.LONGDATA		;branch to long data
;  			BRA		DISPLAY_ERROR	;branch to invalid mode if reg greater than1
						
; .WORDDATA	LEA INIT_MEM,A1
;  			MOVE.B #14,D0
;  			TRAP #15

;  			ADDA.W 	#WORD,A0
;  			MOVE.W 	(A0),D2
;  			BSR		DISPLAY_WORD_HEX	; display word in hex		
; 			BRA		.break
			
; .LONGDATA	LEA INIT_MEM,A1
;  			MOVE.B 	#14,D0
;  			TRAP 	#15

;  			ADDA.W 	#WORD,A0
;  			MOVE.L 	(A0),D2
;  			ADDA.W 	#WORD,A0
;  			BSR		DISPLAY_LONG_HEX	; display long in hex
;  			BRA		.break

			
; .break		RTS			

; .INV_MODE	BRA		DISPLAY_ERROR	* Display error


*****************************  OPCODE: Individual Task Subroutine Set  *****************************
*---------------------------------------------------------------------------------------------------
* 000 ADDA 	Add Address
*---------------------------------------------------------------------------------------------------
ADDA_T:		LEA 	ADDA_M,A1
			TRAP 	#15

			BTST 	#8,(A0)			; Ascertains the operation size (WORD/LONG) by the 8th bit from Opmode 
			BNE 	.LONG   		; If the Z condition code is 0 = Word operation / 1 = Long operation
			LEA 	WORD_M,A1
			BRA 	.SET_TRAP
.LONG   	LEA 	LONG_M,A1
.SET_TRAP	TRAP	#15

			BSR OPERAND_POSITION

			BSR EA_MODE_01

			MOVE.B #',',D1
			MOVE.B #6,D0
			TRAP #15

			MOVE.W 	#$0E00,D1
			AND.W 	D7,D1
			ROL.W 	#7,D1

			BSR DISPLAY_ADDEREG

			RTS						; Done with subroutine and return to previous task

*---------------------------------------------------------------------------------------------------
* 020 RTS   Return from Subroutine 
*---------------------------------------------------------------------------------------------------
RTS_T		LEA RTS_M,A1
			TRAP #15
			RTS

*---------------------------------------------------------------------------------------------------
* 021 NOP 	No Operation
*---------------------------------------------------------------------------------------------------
NOP_T		LEA NOP_M,A1
			TRAP #15
			RTS

*---------------------------------------------------------------------------------------------------
* 007 ADD  	Addition
*---------------------------------------------------------------------------------------------------

ADD_T		LEA ADD_M,A1
			; BSR DISPLAY_SIZE
			BSR DISPLAY_SIZE_B
			; BSR EA_TYPE3
			RTS

*- 000 ROL ---------------------- Rotate Left ----------------------------------

ROL_T		LEA ROL_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS

*- 000.5 ROL E1------------------ Rotate Left ----------------------------------

ROL_E1_T	LEA ROL_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS			
			
*- 001 LSL ------------------- Logical Shift Left ------------------------------

LSL_T		LEA LSL_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS
			
*- 001.5 LSL E1--------------- Logical Shift Left ------------------------------

LSL_E1_T	LEA LSL_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS

*- 002 ASL ----------------- Arithmetic Shift Left -----------------------------

ASL_T		LEA ASL_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS
			
*- 002.5 ASL E1 ------------ Arithmetic Shift Left -----------------------------

ASL_E1_T	LEA ASL_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS

*- 003 ROR ---------------------- Rotate Right ---------------------------------

ROR_T		LEA ROR_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS
			
*- 003.5 ROR E1------------------ Rotate Right ---------------------------------

ROR_E1_T	LEA ROR_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS			

*- 004 LSL ------------------ Logical Shift Right ------------------------------

LSR_T		LEA LSR_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS

*- 004.5 LSL_E1 ------------- Logical Shift Right ------------------------------

LSR_E1_T	LEA LSR_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS			
			
*- 005 ASR ----------------- Arithmetic Shift Right ----------------------------

ASR_T		LEA ASR_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE6
			RTS
			
*- 005.5 ASR E1 ------------ Arithmetic Shift Right ----------------------------
            
ASR_E1_T	LEA ASR_M,A1
			TRAP #15
			BSR OPERAND_POSITION
			BSR EA_MODE_01
			RTS

*- 008 MULS ------------------- Signed Multiply --------------------------------

MULS_T		LEA MULS_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE7
			RTS

*- 009 CMP ------------------------ Compare ------------------------------------

CMP_T		LEA CMP_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE3
			RTS

*- 010 SUB ------------------------ Subtract -----------------------------------

SUB_T		LEA SUB_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE3
			RTS

*- 011 DIVS -------------------- Signed Divide ---------------------------------

DIVS_T		LEA DIVS_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE7
			RTS

*- 012 OR ------------------- Inclusive OR Logical -----------------------------

OR_T		LEA OR_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE3
			RTS

*- 013 BLT -------------------- Branch Less Than -------------------------------

BLT_T		LEA BLT_M,A1		* Loading the OP name into address register 1
			BSR DISPLACEMENT	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 014 BGE ---------------- Branch Greater OR Equal ----------------------------

BGE_T		LEA BGE_M,A1 		* Loading the OP name into address register 1
			BSR DISPLACEMENT	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 015 BVC ----------------- Branch Overflow Clear -----------------------------

BVC_T		LEA BVC_M,A1		* Loading the OP name into address register 1
			BSR DISPLACEMENT	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 015 BVS -------------------- Branch Carry Set -------------------------------

BCS_T		LEA BCS_M,A1		* Loading the OP name into address register 1
			BSR DISPLACEMENT	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 017 BRA --------------------- Branch Always ---------------------------------

BRA_T		LEA BRA_M,A1		* Loading the OP name into address register 1
			BSR DISPLACEMENT	* Branches to the displacement subroutine
			RTS					* Returns from subroutine

*- 018 SUBQ -------------------- Subtract Quick --------------------------------

SUBQ_T		LEA SUBQ_M,A1
			BSR DISPLAY_SIZE
			; BSR EA_TYPE4
			RTS

*- 019 JSR ------------------- Jump to Subroutine ------------------------------

JSR_T		LEA JSR_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_MODE_01
			RTS




*- 022 MOVEM -------------- Move Multiple Registers ----------------------------

MOVEM_T		LEA MOVEM_M,A1
			TRAP #15
			; BSR	OPERAND_POSITION
			; BSR EA_TYPE5
			RTS

*- 023 NEG ------------------------- Negate ------------------------------------

NEG_T		LEA NEG_M,A1
			BSR DISPLAY_SIZE
			BSR EA_MODE_01
			RTS

*- 024 LEA ----------------- Load Effective Address ----------------------------

LEA_T		LEA LEA_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE7
			RTS

*- 025 MOVEA.W -------------- Move Address (WORD) ------------------------------

MOAW_T		LEA MOAW_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR	EA_TYPE7
			RTS

*- 026 MOVE.W --- Move Data from Source to Destination (WORD) ------------------

MOW_T		LEA MOW_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE3
			RTS

*- 027 MOVEA.L -------------- Move Address (LONG) ------------------------------

MOAL_T		LEA MOAL_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR	EA_TYPE7
			RTS

*- 028 MOVE.L --- Move Data from Source to Destination (LONG) ------------------

MOL_T		LEA MOL_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE3
			RTS

*- 029 MOVE.B --- Move Data from Source to Destination (BYTE) ------------------

MOB_T		LEA MOB_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR EA_TYPE3
			RTS

*- 030 CMPI ------------------ Compare Immediate -------------------------------

CMPI_T		LEA CMPI_M,A1
			BSR DISPLAY_SIZE
			BSR DISPLAY_IMMEDIATE
			BSR EA_MODE_01
			RTS

*- 031 BCLR ----------------- Test a Bit and Clear -----------------------------

BCLR_T		LEA BCLR_M,A1
			TRAP #15
			; BSR OPERAND_POSITION
			; BSR	EA_TYPE7
			RTS

*- 032 ORI ----------------- Inclusive OR Immediate ----------------------------

ORI_T		LEA ORI_M,A1
			BSR DISPLAY_SIZE
			BSR DISPLAY_IMMEDIATE
			BSR EA_MODE_01
			RTS


********************************* Data Section *********************************

ERROR_M0	DC.B 'No DATA was found between range [',0
ERROR_HM0	DC.L $4f6b6179,$204e6173,$682c2074,$68697320,$73686f75,$6c642061
			DC.L $74206c65,$61737420,$636f756e,$7420666f,$72206120,$72656170
			DC.L $65722070,$6f696e74,$205b5261,$6e676520,$4572726f,$725d0000,0

HEADER		DC.B	'Address   OP-Code	Operand				    Instruction', 0
LINE		DC.B	'----------------------------------------',0
PRESS_ANY	DC.B	'  press ANY key to continue...',0

INIT_HEX	DC.B	'0x',0
INIT_MEM	DC.B	'$',0
INIT_DATA	DC.B	'#$',0
COMMA_M		DC.B 	',',0

DATA_M		DC.B	'DATA ',0

BYTE_M		DC.B	'.B',0
WORD_M		DC.B	'.W',0
LONG_M		DC.B	'.L',0

NEGATIVE_M	DC.B	'-',0
PRE_BRACKET	DC.B 	'(A',0
POST_BRACKE	DC.B 	')',0
ADDRESS_Ax	DC.B 	'A',0
DATA_REG_M	DC.B 	'D',0

NEWLINE_M	DC.B  CR,LF,0

POSITION 	DC.W  $0000
SAVE_STATE	DS.L  1
HEX_USER_IN DS.L 20

SR_HEX_INP      DC.L $53746172,$74696E67,$2052616E,$6765203A,$20307800,0
ED_HEX_INP      DC.L $456E6469,$6E672052,$616E6765,$2020203A,$20307800,0
HEX_ERROR       DC.B 'BAD INPUT',0
HEX_ERROR_NONE  DC.B 'NO INPUT FOUND',0
HEX_ERROR_LONG  DC.B 'INPUT TOO LONG',0
START_RANGE_M	DC.B CR,LF,'The Range [',0
FINAL_RANGE_M	DC.B '] is now set.',0
END_M       	DC.B '  [Program has terminated]',0

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
BCLR_M		DC.B	'BCLR',0				0x0180
ORI_M		DC.B	'ORI',0					0x0000

*---------------------------- Task Operation List ------------------------------
* The values for this constant are set to move in parallel with those of
* the constant BITMASK via steps at label NEXT_MASK.

TASK_OP		DC.W ROL_E1_T,ROR_E1_T,LSL_E1_T,LSR_E1_T,ASL_E1_T,ROL_T,LSL_T,ASL_T,ASR_E1_T,ROR_T
			DC.W LSR_T,ASR_T,ADDA_T,ADD_T,MULS_T,CMP_T,SUB_T,DIVS_T,OR_T,BLT_T
			DC.W BGE_T,BVC_T,BCS_T,BRA_T,SUBQ_T,JSR_T,RTS_T,NOP_T,MOVEM_T,NEG_T
			DC.W LEA_T,MOAW_T,MOW_T,MOAL_T,MOL_T,MOB_T,CMPI_T,BCLR_T,ORI_T,0

*--------------------------- Bitmask Translation List --------------------------
BITMASK		DC.W $E7C0,$E6C0,$E3C0,$E2C0,$E1C0,$E118,$E108,$E100,$E0C0,$E018
			DC.W $E008,$E000,$D0C0,$D000,$C1C0,$B000,$9000,$81C0,$8000,$6D00
			DC.W $6C00,$6800,$6500,$6000,$5100,$4E80,$4E75,$4E71,$4880,$4400
			DC.W $41C0,$3040,$3000,$2040,$2000,$1000,$0C00,$0180,$0000

	END		START				* last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
