      *----------------------------------------------------------------*
      * ZBNKBANK - ZBANK MAIN PROGRAM (GnuCOBOL Terminal)             *
      * Screens: 0=LOGIN  1=HOME  2=REGISTER  3=STATEMENT             *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZBNKBANK.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO WS-ACCT-PATH
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ACCNO
               FILE STATUS IS WS-FILE-STATUS.
           SELECT TX-FILE
               ASSIGN TO WS-TX-PATH
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-TX-KEY
               FILE STATUS IS WS-TX-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD ACCOUNT-FILE.
       01 ACCOUNT-RECORD.
         05 WS-ACCNO     PIC 9(10).
         05 WS-PIN       PIC 9(10).
         05 WS-BALANCE   PIC 9(10).
         05 WS-ATTEMPTS  PIC 9(1).
         05 WS-LOCKED    PIC 9(1).
         05 WS-TXCOUNT   PIC 9(5).
       FD TX-FILE.
       01 TX-RECORD.
         05 WS-TX-KEY.
           10 TX-ACCNO   PIC 9(10).
           10 TX-SEQNO   PIC 9(5).
         05 TX-TYPE      PIC X(1).
         05 TX-AMOUNT    PIC 9(10).
         05 TX-BALANCE   PIC 9(10).
       WORKING-STORAGE SECTION.
       77 WS-FILE-STATUS PIC XX.
       77 WS-TX-STATUS   PIC XX.
       77 WS-ACCT-PATH   PIC X(100).
       77 WS-TX-PATH     PIC X(100).
       77 EXIT-FLAG      PIC 9 VALUE 0.
       77 SCREEN-STATE   PIC 9 VALUE 0.
       77 WS-ACCNO-IN    PIC 9(10).
       77 WS-PIN-IN      PIC 9(10).
       77 WS-AMOUNT-IN   PIC 9(10).
       77 WS-DEST-IN     PIC 9(10).
       77 WS-ACTION      PIC X.
       77 WS-SESSION-ACC PIC 9(10).
       77 WS-BAL-DSP     PIC 9(10).
       77 WS-INFO        PIC X(50).
       77 WS-SEP         PIC X(50) VALUE ALL '='.
       77 WS-LINE-IDX    PIC 9.
       77 WS-STMT-COUNT  PIC 9.
      *--- COMMAREA FOR ZBNKAUTH ---
       01 LK-AUTH.
         05 LKA-ACCNO    PIC 9(10).
         05 LKA-PIN      PIC 9(10).
         05 LKA-BALANCE  PIC 9(10).
         05 LKA-TXCOUNT  PIC 9(5).
         05 LKA-RESULT   PIC 9(2).
         05 LKA-PATH     PIC X(100).
      *--- COMMAREA FOR ZBNKTXN ---
       01 LK-TXN.
         05 LKT-ACCNO    PIC 9(10).
         05 LKT-DEST     PIC 9(10).
         05 LKT-ACTION   PIC X(1).
         05 LKT-AMOUNT   PIC 9(10).
         05 LKT-BALANCE  PIC 9(10).
         05 LKT-RESULT   PIC 9(2).
         05 LKT-APATH    PIC X(100).
         05 LKT-TPATH    PIC X(100).
      *--- STATEMENT SLOTS (5 TRANSACTIONS) ---
       01 WS-STMT.
         05 STMT-LINE OCCURS 5 TIMES.
           10 SL-TYPE    PIC X(8).
           10 SL-AMT     PIC 9(10).
           10 SL-BAL     PIC 9(10).
       COPY ZBCOLOR.
       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY CB-ESC CB-BG-BLK
           DISPLAY CB-ESC CB-BGREEN
           MOVE 'ZBNKBANK.dat'   TO WS-ACCT-PATH
           MOVE 'ZBNKBANKTX.dat' TO WS-TX-PATH
           MOVE 'PLEASE LOG IN!' TO WS-INFO
           PERFORM BOOT-SEQUENCE
           PERFORM MAIN-LOOP
           DISPLAY CB-ESC CB-RESET
           STOP RUN.
      *================================================================*
      * PLAY BEEP - SEVASTOPOL TERMINAL SOUND                          *
      *================================================================*
       PLAY-BEEP.
           DISPLAY CB-BEL
           MOVE SPACES TO CB-SND-CMD
           STRING
               'paplay /mnt/c/Users/levi.lucena/Documents/'
               DELIMITED SIZE
               'GitHub/zBANK/gnucobol/sounds/'
               DELIMITED SIZE
               'beep.wav >/dev/null 2>&1 &'
               DELIMITED SIZE
               INTO CB-SND-CMD
           CALL "system" USING BY CONTENT CB-SND-BUF.
      *================================================================*
      * BOOT SEQUENCE - SEVASTOPOL CRT STARTUP                         *
      *================================================================*
       BOOT-SEQUENCE.
           MOVE SPACES TO CB-SND-CMD
           STRING
               'mpg123 -q /mnt/c/Users/levi.lucena/Documents/'
               DELIMITED SIZE
               'GitHub/zBANK/gnucobol/sounds/'
               DELIMITED SIZE
               'startup.mp3 >/dev/null 2>&1 &'
               DELIMITED SIZE
               INTO CB-SND-CMD
           CALL "system" USING BY CONTENT CB-SND-BUF
           DISPLAY CB-ESC CB-CLR
           DISPLAY CB-ESC CB-HOME-C
           DISPLAY CB-ESC CB-BG-BLK
           DISPLAY CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  SEEGSON COMMUNICATIONS  //  WORKSTATION v2.3.1'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  SYSID: ZBKV-2031 // SECTOR: GX-9 // NODE: 04'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY ' '
           CALL "system" USING BY CONTENT Z"sleep 0.6"
           DISPLAY CB-ESC CB-GREEN
               '  INITIATING POST MEMORY SCAN...'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.25"
           DISPLAY CB-ESC CB-BGREEN
               '  4F3A 1B2C A891 3F7D 9E4B 2D81 C076 5F38'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  B29A 7E15 0C4D F863 8127 4A90 D3E6 1B5C'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-BGREEN
               '  C5F2 394E 7B80 2D61 9A47 F3C8 1E05 6B24'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  8D37 A0C4 5291 6FE8 3B74 D1F9 0A2E 4C87'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-BGREEN
               '  2F60 B8D5 71AE 9304 C7F1 5E2B 8946 0D3C'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  7C91 E348 0B5F 2A6D 4E83 F7C1 9506 1D42'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-BGREEN
               '  A158 3D9B 6E04 C72F 5819 3E8A 0F4B 7D26'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  D4F0 82CE 15B7 6940 3A9C F268 E5B1 0437'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-BGREEN
               '  F19B 6043 2E87 A5DC 380C 9461 BF2A 7E58'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  039D 5C8E 4721 BFA6 D085 631F 2948 AC70'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-BGREEN
               '  E67A 14F3 8B20 57CD 90BE 3541 6C0F A829'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.07"
           DISPLAY CB-ESC CB-GREEN
               '  51D4 C9F6 0A38 7E2B 9340 F85C 1607 AB4E'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.3"
           DISPLAY CB-ESC CB-BGREEN
               '  MEMORY: 65536K ....................... [OK]'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.3"
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.2"
           DISPLAY CB-ESC CB-BGREEN
               '  VSAM SUBSYSTEM ................... [OK]'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.2"
           DISPLAY CB-ESC CB-GREEN
               '  TERMINAL I/O .................... [OK]'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.2"
           DISPLAY CB-ESC CB-BGREEN
               '  NETWORK SERVICES ................ [OK]'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.2"
           DISPLAY CB-ESC CB-GREEN
               '  ZBANK v2.3.1 .................... [OK]'
               CB-ESC CB-BGREEN
           CALL "system" USING BY CONTENT Z"sleep 0.5"
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY CB-ESC CB-BYELLOW
               '  >>>> SYSTEM READY. LOADING TERMINAL... <<<<'
               CB-ESC CB-BGREEN
           DISPLAY ' '
           CALL "system" USING BY CONTENT Z"sleep 1.2".
       MAIN-LOOP.
           PERFORM UNTIL EXIT-FLAG = 1
             EVALUATE SCREEN-STATE
               WHEN 0  PERFORM DO-LOGIN
               WHEN 1  PERFORM DO-HOME
               WHEN 2  PERFORM DO-REGISTER
               WHEN 3  PERFORM DO-STATEMENT
             END-EVALUATE
           END-PERFORM.
      *================================================================*
      * LOGIN SCREEN                                                     *
      *================================================================*
       DO-LOGIN.
           DISPLAY CB-ESC CB-CLR
           DISPLAY CB-ESC CB-HOME-C
           PERFORM SHOW-BANNER
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  >>  AUTHENTICATION TERMINAL'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-YELLOW
               '  [ ' WS-INFO ' ]'
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY '  ACCOUNT.....: ' WITH NO ADVANCING
           ACCEPT WS-ACCNO-IN
           PERFORM PLAY-BEEP
           DISPLAY '  PIN.........: ' WITH NO ADVANCING
           ACCEPT WS-PIN-IN
           PERFORM PLAY-BEEP
           DISPLAY ' '
           DISPLAY '  [ENTER]=LOGIN  [Q]=EXIT  [R]=REGISTER > '
             WITH NO ADVANCING
           ACCEPT WS-ACTION
           PERFORM PLAY-BEEP
           EVALUATE FUNCTION UPPER-CASE(WS-ACTION)
             WHEN 'Q'
               MOVE 1 TO EXIT-FLAG
             WHEN 'R'
               MOVE 2 TO SCREEN-STATE
               MOVE 'ENTER YOUR NEW ACCOUNT AND PIN.'
                 TO WS-INFO
             WHEN OTHER
               MOVE WS-ACCNO-IN TO LKA-ACCNO
               MOVE WS-PIN-IN   TO LKA-PIN
               MOVE WS-ACCT-PATH TO LKA-PATH
               CALL 'ZBNKAUTH' USING LK-AUTH
               EVALUATE LKA-RESULT
                 WHEN 00
                   MOVE 1 TO SCREEN-STATE
                   MOVE WS-ACCNO-IN TO WS-SESSION-ACC
                   MOVE LKA-BALANCE TO WS-BAL-DSP
                   MOVE 'WELCOME! LOGIN SUCCESSFUL.'
                     TO WS-INFO
                 WHEN 01
                   MOVE 'ACCOUNT NOT FOUND.' TO WS-INFO
                 WHEN 02
                   MOVE 'WRONG PIN. LOCKS AFTER 3 TRIES.'
                     TO WS-INFO
                 WHEN 03
                   MOVE 'ACCOUNT LOCKED. CONTACT ADMIN.'
                     TO WS-INFO
                 WHEN OTHER
                   MOVE 'UNEXPECTED ERROR.' TO WS-INFO
               END-EVALUATE
           END-EVALUATE.
      *================================================================*
      * HOME SCREEN                                                      *
      *================================================================*
       DO-HOME.
           DISPLAY CB-ESC CB-CLR
           DISPLAY CB-ESC CB-HOME-C
           PERFORM SHOW-BANNER
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  >>  MAIN TERMINAL'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-YELLOW
               '  [ ' WS-INFO ' ]'
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY '  ACCOUNT.....: ' WS-SESSION-ACC
           DISPLAY '  BALANCE.....: $' WS-BAL-DSP
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  --------------------------------------------------'
               CB-ESC CB-BGREEN
           DISPLAY '  [D]=DEPOSIT   [W]=WITHDRAW   [T]=TRANSFER'
           DISPLAY '  [S]=STATEMENT [Q]=LOGOUT'
           DISPLAY CB-ESC CB-GREEN
               '  --------------------------------------------------'
               CB-ESC CB-BGREEN
           DISPLAY '  ACTION > ' WITH NO ADVANCING
           ACCEPT WS-ACTION
           PERFORM PLAY-BEEP
           EVALUATE FUNCTION UPPER-CASE(WS-ACTION)
             WHEN 'Q'
               MOVE 0 TO SCREEN-STATE
               MOVE ZEROS TO WS-SESSION-ACC WS-BAL-DSP
               MOVE 'PLEASE LOG IN!' TO WS-INFO
             WHEN 'S'
               MOVE 3 TO SCREEN-STATE
               MOVE 'LAST 5 TRANSACTIONS.' TO WS-INFO
             WHEN 'D'
               DISPLAY '  AMOUNT > ' WITH NO ADVANCING
               ACCEPT WS-AMOUNT-IN
               PERFORM PLAY-BEEP
               PERFORM DO-DEPOSIT
             WHEN 'W'
               DISPLAY '  AMOUNT > ' WITH NO ADVANCING
               ACCEPT WS-AMOUNT-IN
               PERFORM PLAY-BEEP
               PERFORM DO-WITHDRAW
             WHEN 'T'
               DISPLAY '  DEST ACCOUNT > ' WITH NO ADVANCING
               ACCEPT WS-DEST-IN
               PERFORM PLAY-BEEP
               DISPLAY '  AMOUNT       > ' WITH NO ADVANCING
               ACCEPT WS-AMOUNT-IN
               PERFORM PLAY-BEEP
               PERFORM DO-TRANSFER
             WHEN OTHER
               MOVE 'INVALID COMMAND.' TO WS-INFO
           END-EVALUATE.
       DO-DEPOSIT.
           MOVE WS-SESSION-ACC TO LKT-ACCNO
           MOVE ZEROS          TO LKT-DEST
           MOVE 'D'            TO LKT-ACTION
           MOVE WS-AMOUNT-IN   TO LKT-AMOUNT
           MOVE WS-ACCT-PATH   TO LKT-APATH
           MOVE WS-TX-PATH     TO LKT-TPATH
           CALL 'ZBNKTXN' USING LK-TXN
           EVALUATE LKT-RESULT
             WHEN 00
               MOVE LKT-BALANCE TO WS-BAL-DSP
               MOVE 'DEPOSIT SUCCESSFUL!' TO WS-INFO
             WHEN 02
               MOVE 'INVALID AMOUNT. VALUE MUST BE > 0.'
                 TO WS-INFO
             WHEN OTHER
               MOVE 'DEPOSIT ERROR.' TO WS-INFO
           END-EVALUATE.
       DO-WITHDRAW.
           MOVE WS-SESSION-ACC TO LKT-ACCNO
           MOVE ZEROS          TO LKT-DEST
           MOVE 'W'            TO LKT-ACTION
           MOVE WS-AMOUNT-IN   TO LKT-AMOUNT
           MOVE WS-ACCT-PATH   TO LKT-APATH
           MOVE WS-TX-PATH     TO LKT-TPATH
           CALL 'ZBNKTXN' USING LK-TXN
           EVALUATE LKT-RESULT
             WHEN 00
               MOVE LKT-BALANCE TO WS-BAL-DSP
               MOVE 'WITHDRAWAL SUCCESSFUL!' TO WS-INFO
             WHEN 01
               MOVE 'INSUFFICIENT FUNDS.' TO WS-INFO
             WHEN 02
               MOVE 'INVALID AMOUNT. VALUE MUST BE > 0.'
                 TO WS-INFO
             WHEN OTHER
               MOVE 'WITHDRAWAL ERROR.' TO WS-INFO
           END-EVALUATE.
       DO-TRANSFER.
           MOVE WS-SESSION-ACC TO LKT-ACCNO
           MOVE WS-DEST-IN     TO LKT-DEST
           MOVE 'T'            TO LKT-ACTION
           MOVE WS-AMOUNT-IN   TO LKT-AMOUNT
           MOVE WS-ACCT-PATH   TO LKT-APATH
           MOVE WS-TX-PATH     TO LKT-TPATH
           CALL 'ZBNKTXN' USING LK-TXN
           EVALUATE LKT-RESULT
             WHEN 00
               MOVE LKT-BALANCE TO WS-BAL-DSP
               MOVE 'TRANSFER SUCCESSFUL!' TO WS-INFO
             WHEN 01
               MOVE 'INSUFFICIENT FUNDS.' TO WS-INFO
             WHEN 02
               MOVE 'INVALID AMOUNT. VALUE MUST BE > 0.'
                 TO WS-INFO
             WHEN 04
               MOVE 'DESTINATION ACCOUNT NOT FOUND.'
                 TO WS-INFO
             WHEN OTHER
               MOVE 'TRANSFER ERROR.' TO WS-INFO
           END-EVALUATE.
      *================================================================*
      * REGISTER SCREEN                                                  *
      *================================================================*
       DO-REGISTER.
           DISPLAY CB-ESC CB-CLR
           DISPLAY CB-ESC CB-HOME-C
           PERFORM SHOW-BANNER
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  >>  NEW ACCOUNT REGISTRATION'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-YELLOW
               '  [ ' WS-INFO ' ]'
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY '  NEW ACCOUNT..: ' WITH NO ADVANCING
           ACCEPT WS-ACCNO-IN
           PERFORM PLAY-BEEP
           DISPLAY '  NEW PIN......: ' WITH NO ADVANCING
           ACCEPT WS-PIN-IN
           PERFORM PLAY-BEEP
           DISPLAY ' '
           DISPLAY '  [C]=CREATE  [Q]=BACK > ' WITH NO ADVANCING
           ACCEPT WS-ACTION
           PERFORM PLAY-BEEP
           EVALUATE FUNCTION UPPER-CASE(WS-ACTION)
             WHEN 'Q'
               MOVE 0 TO SCREEN-STATE
               MOVE 'PLEASE LOG IN!' TO WS-INFO
             WHEN 'C'
               MOVE WS-ACCNO-IN TO WS-ACCNO
               MOVE WS-PIN-IN   TO WS-PIN
               MOVE ZEROS       TO WS-BALANCE
               MOVE 0           TO WS-ATTEMPTS
               MOVE 0           TO WS-LOCKED
               MOVE ZEROS       TO WS-TXCOUNT
               OPEN I-O ACCOUNT-FILE
               IF WS-FILE-STATUS NOT = '00'
                 OPEN OUTPUT ACCOUNT-FILE
               END-IF
               WRITE ACCOUNT-RECORD
                 INVALID KEY
                   MOVE 'ACCOUNT ALREADY EXISTS.' TO WS-INFO
                 NOT INVALID KEY
                   MOVE 0 TO SCREEN-STATE
                   MOVE 'ACCOUNT CREATED! PLEASE LOG IN.'
                     TO WS-INFO
               END-WRITE
               CLOSE ACCOUNT-FILE
             WHEN OTHER
               MOVE 'PRESS C TO CREATE OR Q TO GO BACK.'
                 TO WS-INFO
           END-EVALUATE.
      *================================================================*
      * STATEMENT SCREEN                                                  *
      *================================================================*
       DO-STATEMENT.
           PERFORM LOAD-STMT
           DISPLAY CB-ESC CB-CLR
           DISPLAY CB-ESC CB-HOME-C
           PERFORM SHOW-BANNER
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  >>  TRANSACTION HISTORY'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY '  ACCOUNT.....: ' WS-SESSION-ACC
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  TYPE       AMOUNT          BALANCE'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  --------   ----------      ----------'
               CB-ESC CB-BGREEN
           PERFORM VARYING WS-LINE-IDX FROM 1 BY 1
             UNTIL WS-LINE-IDX > 5
             IF SL-TYPE(WS-LINE-IDX) NOT = SPACES
               DISPLAY '  ' SL-TYPE(WS-LINE-IDX)
                       '   $' SL-AMT(WS-LINE-IDX)
                       '      $' SL-BAL(WS-LINE-IDX)
             END-IF
           END-PERFORM
           IF WS-STMT-COUNT = 0
             DISPLAY '  [ NO TRANSACTIONS FOUND ]'
           END-IF
           DISPLAY ' '
           DISPLAY '  [Q]=BACK > ' WITH NO ADVANCING
           ACCEPT WS-ACTION
           PERFORM PLAY-BEEP
           IF FUNCTION UPPER-CASE(WS-ACTION) = 'Q'
             MOVE 1 TO SCREEN-STATE
             MOVE 'SESSION ACTIVE.' TO WS-INFO
           END-IF.
      *================================================================*
      * BANNER - ALIEN ISOLATION CRT STYLE                             *
      *================================================================*
       SHOW-BANNER.
           DISPLAY CB-ESC CB-BG-BLK
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  >>  ZBANK FINANCIAL TERMINAL  //  REV 2.3.1     '
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  SYSID: ZBKV-2031  //  STATUS: NOMINAL'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY CB-ESC CB-BGREEN
               '  ##### ####   ###  ##  # #  #'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '     #  #   # #   # # # # # # '
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '    #   ####  ##### # ## ##    '
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '   #    #   # #   # #  ## # #  '
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-BGREEN
               '  ##### ###  #   # #  ## #  ## '
               CB-ESC CB-BGREEN
           DISPLAY ' '
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  >>  WEYLAND-YUTANI CORP.  //  AUTHORIZED USE ONLY'
               CB-ESC CB-BGREEN
           DISPLAY CB-ESC CB-GREEN
               '  =================================================='
               CB-ESC CB-BGREEN.
       LOAD-STMT.
           MOVE SPACES TO SL-TYPE(1) SL-TYPE(2) SL-TYPE(3)
                          SL-TYPE(4) SL-TYPE(5)
           MOVE ZEROS  TO SL-AMT(1) SL-AMT(2) SL-AMT(3)
                          SL-AMT(4) SL-AMT(5)
           MOVE ZEROS  TO SL-BAL(1) SL-BAL(2) SL-BAL(3)
                          SL-BAL(4) SL-BAL(5)
           MOVE 0 TO WS-STMT-COUNT
           OPEN INPUT TX-FILE
           IF WS-TX-STATUS NOT = '00'
             CLOSE TX-FILE
             EXIT PARAGRAPH
           END-IF
           MOVE WS-SESSION-ACC TO TX-ACCNO
           MOVE 99999          TO TX-SEQNO
           START TX-FILE KEY <= WS-TX-KEY
             INVALID KEY
               CLOSE TX-FILE
               EXIT PARAGRAPH
           END-START
           MOVE 1 TO WS-LINE-IDX
           PERFORM UNTIL WS-LINE-IDX > 5
             READ TX-FILE PREVIOUS
               AT END
                 MOVE 6 TO WS-LINE-IDX
               NOT AT END
                 IF TX-ACCNO = WS-SESSION-ACC
                   EVALUATE TX-TYPE
                     WHEN 'D'
                       MOVE 'DEPOSIT '
                         TO SL-TYPE(WS-LINE-IDX)
                     WHEN 'W'
                       MOVE 'WITHDRAW'
                         TO SL-TYPE(WS-LINE-IDX)
                     WHEN 'T'
                       MOVE 'TRANSFER'
                         TO SL-TYPE(WS-LINE-IDX)
                     WHEN OTHER
                       MOVE 'UNKNOWN '
                         TO SL-TYPE(WS-LINE-IDX)
                   END-EVALUATE
                   MOVE TX-AMOUNT  TO SL-AMT(WS-LINE-IDX)
                   MOVE TX-BALANCE TO SL-BAL(WS-LINE-IDX)
                   ADD 1 TO WS-STMT-COUNT
                   ADD 1 TO WS-LINE-IDX
                 ELSE
                   MOVE 6 TO WS-LINE-IDX
                 END-IF
             END-READ
           END-PERFORM
           CLOSE TX-FILE.
