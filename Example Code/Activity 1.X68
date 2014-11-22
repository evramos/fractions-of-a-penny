*-----------------------------------------------------------
* Title      : Activity 1
* Written by : Matthew Everett Christopher Ramos
* Date       : Saturday November 1, 2014
* Description: Favorite Final Fantasy VIII Song
*-----------------------------------------------------------
START    ORG $1000                 
        
         move.w #14,d0        Set up printing strings
         lea addrlist,a2      Start of our list
        
LOOP     movea.w (a2)+,a1        
         move.w a1,d2         D2 is a temp
        
         cmp #0,d2            Compare to NULL
         beq DONE             If NULL, jump to end of program
                 
         trap #15             Otherwise print and keep going
         bra LOOP
        
DONE     move.b  #9,d0
         trap    #15          Halt sumulator

*-----------------------------------------------------------
* dc (define constant) is used to place data in memory

artist    dc.b   'Nobuo Uematsu',CR,LF,0                  Artist Name
song      dc.b   '"Liberi Fatali"',CR,LF,0                Music Title

chorusA   dc.b   'Fithos Lusec Wecos Vinosec',CR,LF,0
chorusB   dc.b   'Excitate vos e somno, liberi ',0
chorusC   dc.b   'Ardente veritate',CR,LF,0

verseA    dc.b   'mei',CR,LF,'Cunae sunt non',CR,LF,0
verseB    dc.b   'fatali',CR,LF,'Somnus est non',CR,LF,0
verseC    dc.b   'Veni hortum veritatis',CR,LF 
          dc.b   'Horti verna veritatis',CR,LF,0
verseD    dc.b   'Valete liberi',CR,LF
          dc.b   'Diebus fatalibus',CR,LF,0
          
lineA     dc.b   'Surgite',CR,LF,'Invenite',CR,LF,0
lineB     dc.b   'Urite mala mundi',CR,LF,0
lineC     dc.b   'Incendite tenebras mundi',CR,LF,0

goodbye   dc.b   'Thank you for listening!',0
nwln      dc.b   '',CR,LF,0                              New Line         

addrlist  dc.w   artist,song,nwln,chorusA,chorusA,chorusA,nwln
          dc.w   chorusB,verseA,chorusB,verseB,nwln,lineA,nwln
          dc.w   verseC,nwln,chorusC,lineB,chorusC,lineC,nwln
          dc.w   verseD,nwln,verseD,nwln,chorusA,nwln,goodbye,0

CR    EQU $0d
LF    EQU $0a

    END    START             ; last line of source













*~Font name~Courier New~
*~Font size~8~
*~Tab type~1~
*~Tab size~4~
