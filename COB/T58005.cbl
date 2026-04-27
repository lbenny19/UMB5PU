000100 IDENTIFICATION DIVISION.                                                 
000200* HOGAN OS390                                                             
000300 PROGRAM-ID. T58005.                                                      
000400 AUTHOR.                                                                  
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
      *cc111
002200 DATE-COMPILED.                                                           
002300*****************************************************************         
002400*                                                                         
002500* This is a batch only program                                            
002600* It chases the date services holiday calc PCD tables                     
002700* chains to determine integrity.                                          
002800*                                                                         
002900* It also print the holiday build chains using PCD 2002 and 2003.         
003000*                                                                         
003100 ENVIRONMENT DIVISION.                                                    
003200 CONFIGURATION SECTION.                                                   
003300 SOURCE-COMPUTER. IBM-370.                                                
003400 OBJECT-COMPUTER. IBM-370.                                                
003500 DATA DIVISION.                                                           
003600     EJECT                                                                
003700 WORKING-STORAGE SECTION.                                                 
003800*                                                                         
003900 01  CC-CHANGE-ID.                                                        
004000     05  CC-CHANGE-ID-BASE            PIC X(9)  VALUE 'UMB500'.           
004100*                                                                         
004200 01  C-BINARY-CONSTANTS    BINARY SYNC.                                   
004300     05  HOLIDAY-INDEX-FMT      PIC 9(9)        VALUE 2002.               
004400     05  HOLIDAY-CALC-FMT       PIC 9(9)        VALUE 2003.               
004500     05  HOLIDAY-TRANSLATE-1911 PIC 9(9)        VALUE 1911.               
004600     05  SDB-PRINT-1200         PIC 9(9)        VALUE 1200.               
004700 01  H-BINARY-CONSTANTS    BINARY.                                        
004800     05  FILLER                 PIC 9(9)        VALUE 58009.              
004900     05  FILLER                 PIC 9(9)        VALUE 58010.              
005000 01  H-BINARY-CONSTANTS-R REDEFINES H-BINARY-CONSTANTS.                   
005100     05  FILLER                 PIC XX.                                   
005200     05  CCP-58009              PIC XX.                                   
005300     05  FILLER                 PIC XX.                                   
005400     05  CCP-58010              PIC XX.                                   
005500*                                                                         
005600 01  C-CHARACTER-CONSTANTS.                                               
005700     05  CC-INDEX-KEY        PIC X(11)   VALUE 'DCB INDEX  '.             
005800     05  CC-CALC-KEY         PIC X(11)   VALUE 'DCB CALC   '.             
005900*                                                                         
006000 01  C-DISPLAY-CONSTANTS.                                                 
006100     05  CD01                PIC 99              VALUE 01.                
006200     05  CD12                PIC 99              VALUE 12.                
006300     05  CD31                PIC 99              VALUE 31.                
006400     EJECT                                                                
006500 LOCAL-STORAGE SECTION.                                                   
006600*                                                                         
006700 01  W000-WORKAREA.                                                       
006800     05  W005-I              PIC S9(3) COMP-3.                            
006900*                                                                                          
007500*                                                                         
007600     EJECT                                                                
007700 LINKAGE SECTION.                                                         
007800*                                                                         
007900*                    TRANSACTION-CONTROL-BLOCK                            
008000 COPY P49000D. *> 000000000000000000000000000000000000000000000000        
008100*                                                                         
008200*                    DCB-HOLIDAY-INDEX                                    
008300 COPY T58003D. *> 000000000000000000000000000000000000000000000000        
008400*                                                                         
008500*                    DCB-HOLIDAY-CALC                                     
008600 COPY T58004D. *> 000000000000000000000000000000000000000000000000        
008700*                                                                         
008800*                    SPS-PRINT LINE                                       
008900 COPY I54076D. *> 000000000000000000000000000000000000000000000000        
009000                                                                          
009100 COPY U48030D. *> 000000000000000000000000000000000000000000000000        
009200                                                                          
009300                                                                          
009400     EJECT                                                                
009500 PROCEDURE DIVISION  USING   TRANSACTION-CONTROL-BLOCK                    
009600                             DCB-HOLIDAY-INDEX                            
009700                             DCB-HOLIDAY-CALC                             
009800                             SPS-DSR-DETAIL-BLOCK                         
009900                             CDMF-ITEM-MAINT-SCREEN-DG.                   
010000     EJECT                                                                                                             
028700 END PROGRAM T58005.                                                      
