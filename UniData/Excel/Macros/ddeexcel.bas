DDE Example: MS Excel

 The following example opens a new file in Microsoft Excel and inserts some data. 
Please note that Microsoft Excel must be started before running this example.
This example can also be found in the EXAMPLES directory (file name: ddeexcel.bas). 
The DDE functions are printed in red bold characters.

10    !   RE-STORE "examples\ddeexcel.bas"
20    !
30    ! ***********************************************************************
40    ! *                                                                     *
50    ! *  BASIC DDE Client example for Excel 5.0 / 95 / 97 / 2000 / XP       *
60    ! *                                                                     *
70    ! *  Version :  1.10                                                    *
80    ! *  Author  :  Sven Henze, Tech Soft GmbH                              *
90    ! *  Created :  28-Jan-1999                                             *
100   ! *  Updated :  18-Dec-2001                                             *
110   ! *                                                                     *
120   ! *  Comments:  You must start Microsoft Excel before you can use this  *
130   ! *             application.                                            *
140   ! *                                                                     *
150   ! *  Copyright (c) 1999-2001  Tech Soft GmbH. All Rights Reserved.      *
160   ! *                           Email: HTB@TechSoft.de                    *
170   ! *                           www.HTBasic.de                            *
180   ! *                                                                     *
190   ! ***********************************************************************
200   !
210   ! Description:
220   !
230   !   This example application opens a new Excel sheet, pokes some data into
240   !   the sheet and retrieves the value of two cells (random cells).
250   !
260   !   Excel languages: German, English, French, Dutch
270   !
280   !
290       INTEGER Result,Ch1,Ch2,Res2,Res3,Res4
300       DIM Buf$(1:10)[256],Ret$(1:10)[128],Top$[1024],Value$[256],Ddeinfo$[8192]
310       L$=""
320       Ddeinfo$=""
330              !
340       CLEAR SCREEN
350       PRINT
360       PRINT " DDE example program (Excel)"
370       PRINT " ---------------------------"
380              !
390              ! Load the DDE library
400       IF NOT INMEM("Ddeinit") THEN
410           LOADSUB ALL FROM "htbdde.csb"
420           PRINT
430           PRINT " BASIC DDE Client CSUB was loaded.."
440       END IF
450          !
460          ! Try to detect Excel language automatically
470          !
480       INTEGER Language
490       Language=0
500       DdeInit(Result)
510       IF Result=0 THEN
520           DdeConnect(Ch1,"Excel","System")
530           IF Ch1>0 THEN
540               DdeExecute(Ch1,"[NEW(1)]",Result)       ! open new file
550               DdeRequest(Ch1,"Topics",Top$,Result)    ! Get all available topic names
560               DdeExecute(Ch1,"[CLOSE()]",Result)      ! close file
570               DdeTerminate(Ch1,Result)
580               Top$=UPC$(Top$)
590               IF POS(Top$,"SHEET") THEN Language=2    ! probably English Version of Excel
600               IF POS(Top$,"TABELLE") THEN Language=1  ! probably German Version of Excel
610               IF POS(Top$,"CLASSEUR") THEN Language=3 ! probably French Version of Excel
620               IF POS(Top$,"BLAD") THEN Language=4     ! probably Dutch Version of Excel
630           ELSE
640               BEEP
650               PRINT
660               PRINT " Connection to Microsoft Excel failed."
670               Ddeclean(Result)
680               STOP
690           END IF
700       END IF
710       Ddeclean(Result)
720       !
730       ! 1 = German
740       ! 2 = English
750       ! 3 = French
760       ! 4 = Dutch
770                   !
780       IF Language=0 THEN
790           OUTPUT KBD;"2";
800           INPUT "Select language of Excel (1=German, 2=English, 3=French, 4=Dutch):",Lang
810              !
820           SELECT Lang
830           CASE 1,2,3,4
840               Language=Lang
850           CASE ELSE
860               BEEP
870               DISP "Wrong language selected, program stopped."
880               STOP
890           END SELECT
900       END IF
910              !
920              !
930       SELECT Language
940       CASE 1                      ! German
950           Row$="Z"                !"Zeile"
960           Col$="S"                !"Spalte"
970           Sheet$="Tabelle"
980       CASE 2                      ! English
990           Row$="R"                !"Row"
1000           Col$="C"               !"Column"
1010           Sheet$="Sheet"
1020       CASE 3                     ! French
1030           Row$="L"               !"Ligne"
1040           Col$="C"               !"Colone"
1050           Sheet$="Feuil"
1060       CASE 4                     ! Dutch
1070           Row$="R"
1080           Col$="K"
1090           Sheet$="Blad"
1100       CASE ELSE
1110           BEEP
1120           PRINT "Language has not been set !"
1130           STOP
1140       END SELECT
1150               !
1160       FOR I=1 TO 10
1170           Buf$(I)=""
1180       NEXT I
1190               !
1200               ! Initialize the DDE DLL
1210       RANDOMIZE
1220       CALL DdeInit(Result)
1230       IF Result=0 THEN
1240           DISP "Doing some DDE conversation.."
1250                  !WAIT 2
1260                  !
1270                  ! connect to the application, returns a Channel number in Ch
1280           CALL DdeConnect(Ch1,"Excel","System")
1290           IF Ch1<>0 THEN
1300                     !
1310                     ! opens a new Excel sheet
1320               CALL DdeExecute(Ch1,"[NEW(1)]",Result)
1330                     !
1340                     ! connect to "Sheet1" (Note: Language sensitive !)
1350               CALL DdeConnect(Ch2,"Excel",Sheet$&"1")   ! select language before !!
1360               CALL DdeInfo(Ddeinfo$,Result)
1370                     ! Excel data
1380  Exceldata:         !
1390               DATA "HTBasic DDE Test","","","","","",""
1400               DATA "","","","","","",""
1410               DATA "","Jan","Feb","Mar","Apr","May","Jun"
1420               DATA "John","20","23","14","37","41","35"
1430               DATA "Rik","24","41","36","76","62","29"
1440               DATA "Sven","18","44","25","51","88","10"
1450               DATA "Mike","58","144","45","5","73","19"
1460               DATA "Anne","31","107","65","95","101","119"
1470                               !
1480               RESTORE Exceldata
1490                               !
1500               FOR I=1 TO 8
1510                   FOR J=1 TO 7
1520                           !
1530                       I$=Row$&VAL$(I)&Col$&VAL$(J) ! make sure that Row$ and Col$ match your Excel language !!
1540                       READ Value$
1550                       IF I=1 AND J=1 THEN Value$=Value$&" (current date and time: "&DATE$(TIMEDATE)&", "&TIME$(TIMEDATE)&")"
1560                           !
1570                           ! Poke the data into the sheet
1580                       CALL DdePoke(Ch2,I$,Value$,Result)
1590                   NEXT J
1600               NEXT I
1610                     !
1620               Res1=Result
1630       !
1640                     ! now define the cells to be retrieved
1650               Rv1$=VAL$(4+INT(5*RND))            ! random value R1 between 4 and 8
1660               Cv1$=VAL$(2+INT(6*RND))            ! random value C1 between 2 and 7
1670               Rv2$=VAL$(4+INT(5*RND))            ! random value R2 between 4 and 8
1680               Cv2$=VAL$(2+INT(6*RND))            ! random value C2 between 2 and 7
1690                        !
1700                     ! now read some values from Excel
1710               CALL DdeRequest(Ch2,Row$&Rv1$&Col$&Cv1$,Ret$(1),Res2)   ! get 1st value
1720               CALL DdeRequest(Ch2,Row$&Rv2$&Col$&Cv2$,Ret$(2),Res3)   ! get 2nd value
1730               CALL DdeTerminate(Ch2,Result)     ! Terminate connection to Sheet1/Tabelle1
1740               CALL DdeTerminate(Ch1,Result)     ! Terminate connection to "Excel -> System"
1750           ELSE
1760               BEEP
1770               Buf$(1)="Excel DDE connection failed"
1780           END IF
1790                     !
1800           CALL Ddeclean(Result)                 ! clean up DDE ressources
1810       ELSE
1820           BEEP
1830           Buf$(1)="DDE initialization failed"
1840       END IF
1850       CLEAR SCREEN
1860       PRINT Ddeinfo$
1870       IF NOT (Res1 OR Res2 OR Res3) THEN
1880           PRINT "Value of (Row "&Rv1$&", Col "&Cv1$&"): ";Ret$(1);
1890           PRINT "Value of (Row "&Rv2$&", Col "&Cv2$&"): ";Ret$(2);
1900       ELSE
1910           BEEP
1920           PRINT "** ERROR ** :   DdePoke / DdeRequest failed !"
1930           PRINT "Possible reason: Wrong language set for Excel"
1940       END IF
1950       IF Lang=0 THEN L$=" (Auto detect)"
1960       SELECT Language
1970       CASE 1
1980           PRINT "Excel language: German"&L$
1990       CASE 2
2000           PRINT "Excel language: English"&L$
2010       CASE 3
2020           PRINT "Excel language: French"&L$
2030       CASE 4
2040           PRINT "Excel language: Dutch"&L$
2050       CASE ELSE
2060           BEEP
2070           PRINT "Unknown Excel language !"
2080       END SELECT
2090       PRINT
2100       PRINT Buf$(*)
2110       PRINT "DDE Test finished"
2120       DELSUB DdeInit
2130       END