000100 IDENTIFICATION DIVISION.                                                 
000200***  CC#=0000112069   19/01/08-16.07   -DEL 00000200          *** C0112069
000300 PROGRAM-ID. T58010.                                                      
000400 AUTHOR.                                                                  
000500*CRT*************************************************************         
000600*CRV*      UMB  VERSION 5  RELEASE 0  CST 4  MLU 0              * C0114518
000700*CRT*************************************************************         
000800*CRY*     COPYRIGHT (C) 2023 COMPUTER SCIENCES CORPORATION      * C0114518
002000*CRT*     ALL RIGHTS RESERVED.                                  * C0114518
002100*CRT************************************************************* C0111723
002101*CRK* UMB5.0.4.0                                                  C0114518
002102***  CC#=0000112070   19/02/06-16.18   -DEL 002102            *** C0114518
      * pos test add
002200 DATE-COMPILED.                                                           
002300*****************************************************************         
003000 ENVIRONMENT DIVISION.                                                    
003100 CONFIGURATION SECTION.                                                   
003200 SOURCE-COMPUTER. IBM-370.                                                
003300 OBJECT-COMPUTER. IBM-370.                                                
003400 DATA DIVISION.                                                           
003500     EJECT                                                                
003600 WORKING-STORAGE SECTION.                                                 
003700 01  CC-CHANGE-ID.                                                        
003800     05  CC-CHANGE-ID-BASE            PIC X(9)  VALUE 'UMB504'.   C0114518
003801     05  FILLER                       PIC X(9)  VALUE 'C0107421'. C0107421
003802     05  FILLER                       PIC X(9)  VALUE 'C0112069'. C0112069
003803     05  FILLER                       PIC X(9)  VALUE 'C0114551'. C0114551
003900*                                                                         
004000 01  C-CONSTANTS.                                                         
004100     05  CH-DISP-TO-START-OF-TBL PIC S9(4)   COMP    VALUE +83.           
004200*                                                                         
004201 COPY T58007D. *> *DTS ACTION CODES                                       
004202 COPY T58008D. *> *DTS RESULT CODES                                       
004300     EJECT                                                                
004400 LOCAL-STORAGE SECTION.                                                   
004500 01  LOCAL-WORK-AREA.                                                     
004600     05  LWA-TBL-ENTRIES         PIC  9(4)   BINARY.                      
004700     EJECT                                                                
004800 LINKAGE SECTION.                                                         
004900*                                                                         
005000*                 TRANSACTION-CONTROL-BLOCK                               
005100 COPY P49000D. *> 000000000000000000000000000000000000000000000000        
005200*                                                                         
005300*                 DCB-HOLIDAY-TABLE                                       
005400 COPY T58015D. *> 000000000000000000000000000000000000000000000000        
005500*                                                                         
005600*                 SHELL SORT INTERFACE                                    
005700 COPY U48536D. *> 000000000000000000000000000000000000000000000000        
005701*                                                                 C0114551
005702*                 DATE CONTROL BLOCK                              C0114551
005703 COPY T58001D. *> 000000000000000000000000000000000000000000000000        
005800*                                                                         
005900*                                                                         
006000     EJECT                                                                
006100 PROCEDURE DIVISION  USING   TRANSACTION-CONTROL-BLOCK                    
006200                             DCB-HOLIDAY-TABLE                            
006300                             W536-SHELL-SORT-DG                   C0114551
006301                             DATE-CONTROL-BLOCK.                  C0114551
                        
011100 END PROGRAM T58009.                                                      
