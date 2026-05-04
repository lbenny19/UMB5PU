000100 IDENTIFICATION DIVISION.                                                 
000200* HOGAN OS390                                                             
000300 PROGRAM-ID. T58005.                                                      
000400 AUTHOR. Liya susan                                                                 
000500*CRT*************************************************************         
000600*CRV*      UMB  VERSION 5  RELEASE 0  CST 0  MLU 0              *         
000700*CRT*************************************************************         
000800*CRT*  This software contains trade secrets and confidential    *         
000900*CRT*  information which are proprietary to Computer Sciences   *         
001000*CRT*  Corporation.  The use, reproduction, distribution, or    *         
001100*CRT*  disclosure of the software, in whole or in part, without *         
001200*CRT*  the express written permission of Computer Sciences      *         
001300*CRT*  Corporation is prohibited.  This software is also an     *         
001400*CRT*  unpublished work protected under the copyright laws of   *         
001500*CRT*  the United States of America and other countries.  If    *         
001600*CRT*  this software becomes published, the following notice    *         
001700*CRT*  shall apply:                                             *         
001800*CRY*      Copyright (C) 2013 Computer Sciences Corporation     *         
001900*CRT*      All Rights Reserved.                                 *         
002000*CRT*************************************************************         
002100*CRK* UMB5.0.0.0                                                          
002200 DATE-COMPILED.                                                                                    
002700 ENVIRONMENT DIVISION.                                                    
002800 CONFIGURATION SECTION.                                                   
002900 SOURCE-COMPUTER. IBM-370.                                                
003000 OBJECT-COMPUTER. IBM-370.                                                
003100 INPUT-OUTPUT SECTION.                                                    
003200 FILE-CONTROL.                                                            
003300 I-O-CONTROL.                                                             
003400 DATA DIVISION.                                                           
003500     EJECT                                                                
003600 WORKING-STORAGE SECTION.                                                 
003700*                                                                         
003800 01  CC-CHANGE-ID.                                                        
003900     05  CC-CHANGE-ID-BASE            PIC X(9)  VALUE 'UMB500'.           
004000*                                                                         
004100 01  C-DISPLAY-CONSTANTS.                                                 
004200     05  CD0                 PIC 9(2)        VALUE 00.                    
004300     05  CD1                 PIC 9(2)        VALUE 01.                    
004400     05  CD2                 PIC 9(2)        VALUE 02.                    
004500     05  CD4                 PIC 9(2)        VALUE 04.                    
004600     05  CD5                 PIC 9(2)        VALUE 05.                    
004700     05  CD6                 PIC 9(2)        VALUE 06.                    
004800     05  CD7                 PIC 9(2)        VALUE 07.                    
004900     05  CD8                 PIC 9(2)        VALUE 08.                    
005000     05  CD9                 PIC 9(2)        VALUE 09.                    
005100     05  CD12                PIC 9(2)        VALUE 12.                    
005200     05  CD13                PIC 9(2)        VALUE 13.                    
005300     05  CD15                PIC 9(2)        VALUE 15.                    
005400     05  CD19                PIC 9(2)        VALUE 19.                    
005500     05  CD20                PIC 9(2)        VALUE 20.                    
005600     05  CD29                PIC 9(2)        VALUE 29.                    
005700     05  CD81                PIC 9(2)        VALUE 81.                    
005800     05  CD96                PIC 9(2)        VALUE 96.                    
005900     EJECT                                                                
006000*                                                                         
006100******************************************************************        
006200*  PEM ACTIVITIES USED FOR PROCESSING.                           *        
006300******************************************************************        
006400*                                                                         
006500*                                                                         
006600 01  C-BINARY-CONSTANTS.                                                  
006700     05  CBA-VALUES          BINARY.                                      
006800         10  CF-ACTY-0035      PIC 9(9)      VALUE   35.                  
006900         10  CF-ACTY-0114      PIC 9(9)      VALUE  114.                  
007000         10  CF-ACTY-1928      PIC 9(9)      VALUE 1928.                  
007100         10  CF-ACTY-2901      PIC 9(9)      VALUE 2901.                  
007200         10  LINK-DATE-ROUTINE PIC 9(9)      VALUE 1900.                  
007300         10  CH-DG-ID-1601     PIC 9(4)      VALUE 1601.                  
007400*                                                                         
007500******************************************************************        
007600*   CARRIAGE CONTROLS.                                           *        
007700******************************************************************        
007800*                                                                         
007900*                                                                         
008000 01  C-CBC-PRINT.                                                         
008100     05  CX-SKIP             PIC X           VALUE X'8B'.                 
008200     05  CX-SPACE1           PIC X           VALUE X'09'.                 
008300     05  CX-SPACE2           PIC X           VALUE X'11'.                 
008400     EJECT                                                                
008500 01  C-CHARACTER.                                                         
008600     05  CC-B                PIC X           VALUE 'B'.                   
008700     05  CC-D                PIC X           VALUE 'D'.                   
008800     05  CC-E                PIC X           VALUE 'E'.                   
008900     05  CC-H                PIC X           VALUE 'H'.                   
009000     05  CC-N                PIC X           VALUE 'N'.                   
009100     05  CC-Q                PIC X           VALUE 'Q'.                   
009200     05  CC-T                PIC X           VALUE 'T'.                   
009300     05  CC-Y                PIC X           VALUE 'Y'.                   
009400     05  CC-P                PIC X           VALUE 'P'.                   
009500     05  CC-END              PIC XXX         VALUE 'END'.                 
009600*                                                                         
009700 01  C-MONTH-TABLE.                                                       
009800     05  C-MO-ENTRIES.                                                    
009900         10  FILLER          PIC 99          VALUE 31.                    
010000         10  FILLER          PIC 99          VALUE 28.                    
010100         10  FILLER          PIC 99          VALUE 31.                    
010200         10  FILLER          PIC 99          VALUE 30.                    
010300         10  FILLER          PIC 99          VALUE 31.                    
010400         10  FILLER          PIC 99          VALUE 30.                    
010500         10  FILLER          PIC 99          VALUE 31.                    
010600         10  FILLER          PIC 99          VALUE 31.                    
010700         10  FILLER          PIC 99          VALUE 30.                    
010800         10  FILLER          PIC 99          VALUE 31.                    
010900         10  FILLER          PIC 99          VALUE 30.                    
011000         10  FILLER          PIC 99          VALUE 31.                    
011100     05  C-MO-TBL            REDEFINES C-MO-ENTRIES.                      
011200         10  C-MO    OCCURS 12 TIMES.                                     
011300             15  C-MO-NO-DAYS  PIC 9(2).                                  
011400     EJECT                                                                
011500*                                                                         
011600******************************************************************        
011700*  HEADERS, MONTH HEADERS, AND SYMBOL INFORMATION PRINTED ON     *        
011800*  CALENDER.                                                     *        
011900******************************************************************        
012000*                                                                         
012100 01  C-PRINT-HEADERS.                                                     
012200     05  C-HDR-ONE.                                                       
012300         10  FILLER          PIC X(45)       VALUE                        
012400             'PR0001   BANK-ID 99999   X-BANK SHORT NAME-X '.             
012500         10  FILLER          PIC X(45)       VALUE                        
012600             '  XXXXXXXXXXXX  BANK NAME  XXXXXXXXXXXXXX    '.             
012700         10  FILLER          PIC X(42)       VALUE                        
012800             '  RUN DATE 99/99/99  99:99      PAGE  9999'.                
012900     05  C-HDR-TWO.                                                       
013000         10  FILLER          PIC X(59)       VALUE SPACES.                
013100         10  FILLER          PIC X(33)       VALUE                        
013200             '9999 CALENDAR'.                                             
013300         10  FILLER         PIC X(17)        VALUE                        
013400             'EFF DATE 99/99/99'.                                         
013500     05  C-TOP-LINE.                                                      
013600         10  FILLER          PIC X(3)        VALUE SPACES.                
013700         10  FILLER          PIC X(128)  VALUE ALL '*   '.                
013800     05  C-MID-LINE.                                                      
013900         10  FILLER          PIC X(3)        VALUE SPACES.                
014000         10  FILLER          PIC X(128)      VALUE ALL                    
014100             '*                           *   '.                          
014200     05  C-DAY-LINE.                                                      
014300         10  FILLER          PIC X(4)        VALUE SPACES.                
014400         10  FILLER          PIC X(128)      VALUE ALL                    
014500             'SUN MON TUE WED THU FRI SAT     '.                          
014600     05  C-SYMBOL-LINE1.                                                  
014700         10  FILLER          PIC X(34)       VALUE                        
014800             ' H = HOLIDAY                      '.                        
014900         10  FILLER          PIC X(51)       VALUE                        
015000             'Q = FIRST BUSINESS DAY OF THE QUARTER'.                     
015100         10  FILLER          PIC X(27)       VALUE                        
015200             'Y = FIRST AND LAST BUSINESS'.                               
015300     05  C-SYMBOL-LINE2.                                                  
015400         10  FILLER          PIC X(34)       VALUE                        
015500             ' N = NON-BUSINESS DAY             '.                        
015600         10  FILLER          PIC X(55)       VALUE                        
015700             'E = LAST BUSINESS DAY OF THE QUARTER'.                      
015800         10  FILLER          PIC X(15)       VALUE                        
015900             'DAY OF THE YEAR'.                                           
016000     05  C-MONTH-HDR1.                                                    
016100         10  FILLER          PIC X(13)       VALUE SPACES.                
016200         10  FILLER          PIC X(32)       VALUE 'JANUARY'.             
016300         10  FILLER          PIC X(34)       VALUE 'FEBRUARY'.            
016400         10  FILLER          PIC X(32)       VALUE 'MARCH'.               
016500         10  FILLER          PIC X(5)        VALUE 'APRIL'.               
016600     05  C-MONTH-HDR2.                                                    
016700         10  FILLER          PIC X(16)       VALUE SPACES.                
016800         10  FILLER          PIC X(31)       VALUE 'MAY'.                 
016900         10  FILLER          PIC X(32)       VALUE 'JUNE'.                
017000         10  FILLER          PIC X(31)       VALUE 'JULY'.                
017100         10  FILLER          PIC X(6)        VALUE 'AUGUST'.              
017200     05  C-MONTH-HDR3.                                                    
017300         10  FILLER          PIC X(13)       VALUE SPACES.                
017400         10  FILLER          PIC X(33)       VALUE 'SEPTEMBER'.           
017500         10  FILLER          PIC X(31)       VALUE 'OCTOBER'.             
017600         10  FILLER          PIC X(32)       VALUE 'NOVEMBER'.            
017700         10  FILLER          PIC X(8)        VALUE 'DECEMBER'.            
017800     05  C-RESULT-ERROR.                                                  
017900         10  FILLER          PIC X(48)       VALUE SPACES.                
018000         10  FILLER          PIC X(34)       VALUE                        
018100             'DTS ERROR: DCB RESULT VALUE: 99999'.                        
018200     EJECT                                                                
018300*                                                                         
018400 COPY T58007D. *> DATE ROUTINE ACTIONS                                    
018500 COPY T58008D. *> DATE ROUTINE RESULTS                                    
018600 COPY I57104D. *> PCD ACTION LIST                                         
018700 COPY I57105D. *> PCD RESULT LIST                                         
018800     EJECT                                                                
018900 LINKAGE SECTION.                                                         
019000*                                                                         
019100*---------------------------------------------------------------*         
019200*                                                               *         
019300*                  LINKAGE SECTION                              *         
019400*                                                               *         
019500*---------------------------------------------------------------*         
019600*                                                                         
019700 COPY P49000D. *> TCB                                                     
019800 COPY T58001D. *> DATE CONTROL BLOCK                                      
019900 COPY I57101D. *> PCD CONTROL BLOCK                                       
020000 COPY T50901D. *> BANK NAME AND ADDRESS                                   
020100     EJECT                                                                
020200*                                                                         
020300*****************************************************************         
020400*  DG WORKAREA #2013 USED FOR DEBLOCKING THE DATE AND FOR       *         
020500*  PROCESSING.                                                  *         
020600*****************************************************************         
020700*                                                                         
020800 COPY T58014D. *> CALENDER WORKAREA                                       
020900     EJECT                                                                
021000*                                                                         
021100******************************************************************        
021200*  PRINT LINE FOR THE BODY OF THE CALENDER.                      *        
021300******************************************************************        
021400*                                                                                                                
026400 PROCEDURE DIVISION  USING   TRANSACTION-CONTROL-BLOCK                    
026500                             DATE-CONTROL-BLOCK                           
026600                             PCD-CONTROL-BLOCK                            
026700                             P-BANK-NAME-ADDRESS                          
026800                             W000-WORKAREA                                
026900                             PRINT-LINE.                                  
027000     EJECT                                                                                        
070100 END PROGRAM T58007.                                                      
