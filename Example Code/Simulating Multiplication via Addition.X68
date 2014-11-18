*-------------------------------------------------------------------------------
* Title      : Simulating Multiplication via Addition
* Written by : Matthew Everett Christopher Ramos
* Date       : Saturday November 15, 2014
* Description: Multiplication
*-------------------------------------------------------------------------------
            OPT        CRE
EXIT        EQU        $2700        * Simulator stop code
START       EQU        $1000        * Program begins here

            ORG    START

*-------------------------------------------------------------------------------
* Diplay message and user input

            LEA VAL_MESSAGE,A1      * Loads message (Multiplicand: ) into A1
            BSR LOAD
            MOVE.L D1,D3            * Moves user input into D2

            LEA TIM_MESSAGE,A1      * Loads message (Multiplier: ) into A1
            BSR LOAD
            MOVE.L D1,D4            * Moves user input into D3

            CLR.L D1                * Clears D1 for Resultant Sum

            JSR MULTIPLY

            MOVE.B #3,D0
            TRAP #15
            STOP #EXIT

*-------------------------------------------------------------------------------
* Multiplication algorithm

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
LOAD        MOVE.B #18,D0           * Loads Task 18 (Task 14 & 4)
            TRAP #15                * Triggers Task
            RTS                     * Return

VAL_MESSAGE DC.B 'Multiplicand: ',0
TIM_MESSAGE DC.B 'Multiplier: ',0

    END    START       ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
