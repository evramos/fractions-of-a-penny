*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Title      : Matrix Multiplication
* Written by : Matthew Everett Christopher Ramos
* Date       : Saturday November 15, 2014
* Description: Matrix Multiplication
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* A0: Copy of MATRIX_A (shifts)       A4: MATRIX_A (End of column)
* A1: MATRIX_B                        A5: MATRIX_A (Start of column)
* A2: MATRIX_C (results)              A6:
* A3: 
* 
* D0: Trap Code                       D4: Multiplier value
* D1: Product value (result)          D5: Offset MATRIX_B row position
* D2: WORD #4                         D6: Keeps track of Offset
* D3: Multiplicand value              D7: Number of positions in column
*-------------------------------------------------------------------------------

            OPT        CRE
EXIT        EQU        $2700        * Simulator stop code
START       EQU        $1000        * Program begins here
WORD        EQU        4            * Advance by a word
LONG_M      EQU        16           * Advance by a long

            ORG    START

*-------------------------------------------------------------------------------
* Code section

            LEA MATRIX_C,A2         * Loading MATRIX_C (matrix with results) to A2
            LEA MATRIX_A,A4         * Loading MATRIX_A (Multiplicand matrix) to A4

            MOVEA.L A4,A5           * Save an end address column range
            ADDA.L #LONG_M,A4       * Sets an end range M column for Matrix_A. e.g. [Sxxx,xxxx,xxxx,xxxE]

            MOVE.L #WORD,D7

            BSR FIRST

END         STOP #EXIT

*-------------------------------------------------------------------------------
FIRST       MOVE.L #WORD,D2

            BSR MIDDLE
            CLR.L D5
            ADDA.L #LONG_M,A4       * Set end range of Matrix_A
            MOVEA.L A0,A5           * Sets a new range for MATRIX_A

            CMP.L #1,D7
            BEQ RETURN

            SUBI.L #1,D7
            BRA FIRST
*-------------------------------------------------------------------------------
* RESET MATRIX_A & B 
* Does a whole row and column and then shifts   
MIDDLE      MOVEA.L A5,A0           * Copys starting position of Matrix_A  [Resets MATRIX_A]
            LEA MATRIX_B,A1         * Loading MATRIX_B (Multiplier matrix) to A1 [Resets MATRIX_B]

            BSR OFFSET              * Creates an offset position for MATRIX_B
            BSR M_X_N

            CMP.L #1,D2
            BEQ RETURN

            SUBI.L #1,D2
            BRA MIDDLE

*-------------------------------------------------------------------------------
* Offsets the position of MATRIX_B as each row passed. Shifts to the needed row

OFFSET      CMP.L D5,D6             * Checks to see which row MATRIX_B needs to be set
            BNE OFFS_HELP
            CLR.L D6                * Resets the counter in D6
            RTS                     * Returns (Done with OFFSET)

OFFS_HELP   ADDA.L #WORD,A1         * Shifts the position of MATRIX_B's row
            ADDQ #1,D6              * Adds to D6 counter
            BRA OFFSET              * Branches back OFFSET (Loop)

*-------------------------------------------------------------------------------
* M X N
* Does one input

M_X_N       MOVE.L (A0)+,D3         * 
            MOVE.L (A1),D4

            BSR MULTIPLY            * Multiplication

            ADDA.L     #LONG_M,A1   * Increment pointer by a bit
            CMPA.L     A4,A0        * Are we done yet?
            BNE        M_X_N        * Past range? Exit

            MOVE.B #3,D0            * Display the results in output
            TRAP #15                * REMOVE WHEN DONE

            ADDQ.B #1,D5            * keeps track

            MOVE.L D1,(A2)+         * Places the results into MATRIX_C, then shifts positions
            CLR.L D1                * Clears to be ready for the next result
RETURN      RTS

*-------------------------------------------------------------------------------
* Multiplication Algorithm

MULTIPLY    CMP.L #0,D4             * Checking if done with multiplication
            BLT ADD_M               * Compares multiplier if negative
            BGT SUB_M               * Compares multiplier if positive
            RTS                     * Return when D4 equals zero

ADD_M       ADDI.L #1,D4            * Counts up to the negative multiplier
            SUB.L D3,D1             * Subtracts the multiplicand to the result
            BRA MULTIPLY            * Branch Always (loop) back to MULTIPLY

SUB_M       SUBI.L #1,D4            * Counts down to the positive multiplier
            ADD.L D3,D1             * Adds the multiplicand to the results
            BRA MULTIPLY            * Branch Always (loop) back to MULTIPLY
*-------------------------------------------------------------------------------
* Data section

MATRIX_A    DC.L 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
MATRIX_B    DC.L 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
MATRIX_C    DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    END    START       ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
