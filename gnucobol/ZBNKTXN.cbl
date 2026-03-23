      *----------------------------------------------------------------*
      * ZBNKTXN - ZBANK TRANSACTION MODULE (GnuCOBOL)                 *
      * Replaces: EXEC CICS READ/REWRITE/WRITE + EXEC CICS LINK       *
      * Native:   READ/REWRITE/WRITE on indexed COBOL files            *
      * Bugs fixed:                                                    *
      *   - AMOUNT=0 rejected on deposit and withdraw                  *
      *   - Overdraft protected before SUBTRACT                        *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZBNKTXN.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO WS-ACCT-PATH
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ACCNO
               FILE STATUS IS WS-ACCT-STATUS.
 
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
       77 WS-ACCT-STATUS PIC XX.
       77 WS-TX-STATUS   PIC XX.
       77 WS-ACCT-PATH   PIC X(100).
       77 WS-TX-PATH     PIC X(100).
 
       01 WS-DEST-REC.
         05 WD-ACCNO     PIC 9(10).
         05 WD-PIN       PIC 9(10).
         05 WD-BALANCE   PIC 9(10).
         05 WD-ATTEMPTS  PIC 9(1).
         05 WD-LOCKED    PIC 9(1).
         05 WD-TXCOUNT   PIC 9(5).
 
       LINKAGE SECTION.
       01 LK-TXN.
         05 LK-ACCNO     PIC 9(10).
         05 LK-DEST      PIC 9(10).
         05 LK-ACTION    PIC X(1).
         05 LK-AMOUNT    PIC 9(10).
         05 LK-BALANCE   PIC 9(10).
         05 LK-RESULT    PIC 9(2).
         05 LK-ACCT-PATH PIC X(100).
         05 LK-TX-PATH   PIC X(100).
 
       PROCEDURE DIVISION USING LK-TXN.
           MOVE LK-ACCT-PATH TO WS-ACCT-PATH
           MOVE LK-TX-PATH   TO WS-TX-PATH
 
      *--- VALIDATE AMOUNT > 0 ---------------------------------------
           IF LK-AMOUNT = ZEROS
             MOVE 02 TO LK-RESULT
             GOBACK
           END-IF
 
      *--- READ SOURCE ACCOUNT ---------------------------------------
           MOVE LK-ACCNO TO WS-ACCNO
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-STATUS NOT = '00'
             MOVE 03 TO LK-RESULT
             CLOSE ACCOUNT-FILE
             GOBACK
           END-IF
 
           READ ACCOUNT-FILE
             KEY IS WS-ACCNO
             INVALID KEY
               MOVE 03 TO LK-RESULT
               CLOSE ACCOUNT-FILE
               GOBACK
           END-READ
 
           OPEN I-O TX-FILE
           IF WS-TX-STATUS = '35'
             OPEN OUTPUT TX-FILE
             CLOSE TX-FILE
             OPEN I-O TX-FILE
           END-IF
           IF WS-TX-STATUS NOT = '00'
             MOVE 03 TO LK-RESULT
             CLOSE ACCOUNT-FILE TX-FILE
             GOBACK
           END-IF
 
      *--- ROUTE BY ACTION -------------------------------------------
           EVALUATE LK-ACTION
 
      *     DEPOSIT
             WHEN 'D'
               ADD LK-AMOUNT TO WS-BALANCE
               ADD 1 TO WS-TXCOUNT
               MOVE WS-ACCNO    TO TX-ACCNO
               MOVE WS-TXCOUNT  TO TX-SEQNO
               MOVE 'D'         TO TX-TYPE
               MOVE LK-AMOUNT   TO TX-AMOUNT
               MOVE WS-BALANCE  TO TX-BALANCE
               WRITE TX-RECORD
               REWRITE ACCOUNT-RECORD
               MOVE WS-BALANCE  TO LK-BALANCE
               MOVE 00          TO LK-RESULT
 
      *     WITHDRAW
             WHEN 'W'
               IF LK-AMOUNT > WS-BALANCE
                 MOVE 01 TO LK-RESULT
                 CLOSE ACCOUNT-FILE TX-FILE
                 GOBACK
               END-IF
               SUBTRACT LK-AMOUNT FROM WS-BALANCE
               ADD 1 TO WS-TXCOUNT
               MOVE WS-ACCNO    TO TX-ACCNO
               MOVE WS-TXCOUNT  TO TX-SEQNO
               MOVE 'W'         TO TX-TYPE
               MOVE LK-AMOUNT   TO TX-AMOUNT
               MOVE WS-BALANCE  TO TX-BALANCE
               WRITE TX-RECORD
               REWRITE ACCOUNT-RECORD
               MOVE WS-BALANCE  TO LK-BALANCE
               MOVE 00          TO LK-RESULT
 
      *     TRANSFER
             WHEN 'T'
               IF LK-AMOUNT > WS-BALANCE
                 MOVE 01 TO LK-RESULT
                 CLOSE ACCOUNT-FILE TX-FILE
                 GOBACK
               END-IF
               MOVE LK-DEST TO WD-ACCNO
               MOVE WD-ACCNO TO WS-ACCNO
               READ ACCOUNT-FILE
                 KEY IS WS-ACCNO
                 INVALID KEY
                   MOVE 04 TO LK-RESULT
                   CLOSE ACCOUNT-FILE TX-FILE
                   GOBACK
               END-READ
               MOVE ACCOUNT-RECORD TO WS-DEST-REC
               MOVE LK-ACCNO TO WS-ACCNO
               READ ACCOUNT-FILE
                 KEY IS WS-ACCNO
               END-READ
               SUBTRACT LK-AMOUNT FROM WS-BALANCE
               ADD 1 TO WS-TXCOUNT
               MOVE WS-ACCNO    TO TX-ACCNO
               MOVE WS-TXCOUNT  TO TX-SEQNO
               MOVE 'T'         TO TX-TYPE
               MOVE LK-AMOUNT   TO TX-AMOUNT
               MOVE WS-BALANCE  TO TX-BALANCE
               WRITE TX-RECORD
               REWRITE ACCOUNT-RECORD
               ADD LK-AMOUNT TO WD-BALANCE
               ADD 1 TO WD-TXCOUNT
               MOVE WD-ACCNO    TO TX-ACCNO
               MOVE WD-TXCOUNT  TO TX-SEQNO
               MOVE 'T'         TO TX-TYPE
               MOVE LK-AMOUNT   TO TX-AMOUNT
               MOVE WD-BALANCE  TO TX-BALANCE
               WRITE TX-RECORD
               MOVE WS-DEST-REC TO ACCOUNT-RECORD
               MOVE WD-ACCNO    TO WS-ACCNO
               REWRITE ACCOUNT-RECORD
               MOVE LK-ACCNO    TO WS-ACCNO
               READ ACCOUNT-FILE KEY IS WS-ACCNO END-READ
               MOVE WS-BALANCE  TO LK-BALANCE
               MOVE 00          TO LK-RESULT
 
             WHEN OTHER
               MOVE 02 TO LK-RESULT
           END-EVALUATE
 
           CLOSE ACCOUNT-FILE TX-FILE
           GOBACK.
