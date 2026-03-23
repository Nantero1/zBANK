      *----------------------------------------------------------------*
      * ZBNKAUTH - ZBANK AUTHENTICATION MODULE (GnuCOBOL)             *
      * Replaces: EXEC CICS READ / REWRITE + COMMAREA via EXEC LINK   *
      * Native:   READ/REWRITE on indexed COBOL file                  *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZBNKAUTH.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO WS-ACCT-PATH
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ACCNO
               FILE STATUS IS WS-FILE-STATUS.
 
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
 
       WORKING-STORAGE SECTION.
       77 WS-FILE-STATUS PIC XX.
       77 WS-ACCT-PATH   PIC X(100).
       77 WS-MAX-TRIES   PIC 9 VALUE 3.
 
       LINKAGE SECTION.
       01 LK-AUTH.
         05 LK-ACCNO     PIC 9(10).
         05 LK-PIN       PIC 9(10).
         05 LK-BALANCE   PIC 9(10).
         05 LK-TXCOUNT   PIC 9(5).
         05 LK-RESULT    PIC 9(2).
         05 LK-ACCT-PATH PIC X(100).
 
       PROCEDURE DIVISION USING LK-AUTH.
           MOVE LK-ACCT-PATH TO WS-ACCT-PATH
           MOVE LK-ACCNO     TO WS-ACCNO
           MOVE 00           TO LK-RESULT
 
           OPEN I-O ACCOUNT-FILE
           IF WS-FILE-STATUS NOT = '00'
             MOVE 01 TO LK-RESULT
             CLOSE ACCOUNT-FILE
             GOBACK
           END-IF
 
           READ ACCOUNT-FILE
             KEY IS WS-ACCNO
             INVALID KEY
               MOVE 01 TO LK-RESULT
               CLOSE ACCOUNT-FILE
               GOBACK
           END-READ
 
      *--- ACCOUNT LOCKED? -------------------------------------------
           IF WS-LOCKED = 1
             MOVE 03 TO LK-RESULT
             CLOSE ACCOUNT-FILE
             GOBACK
           END-IF
 
      *--- WRONG PIN? ------------------------------------------------
           IF LK-PIN NOT = WS-PIN
             ADD 1 TO WS-ATTEMPTS
             IF WS-ATTEMPTS >= WS-MAX-TRIES
               MOVE 1 TO WS-LOCKED
             END-IF
             REWRITE ACCOUNT-RECORD
             MOVE 02 TO LK-RESULT
             CLOSE ACCOUNT-FILE
             GOBACK
           END-IF
 
      *--- OK: RESET ATTEMPTS, RETURN DATA ---------------------------
           MOVE 0          TO WS-ATTEMPTS
           REWRITE ACCOUNT-RECORD
           MOVE WS-BALANCE TO LK-BALANCE
           MOVE WS-TXCOUNT TO LK-TXCOUNT
           MOVE 00         TO LK-RESULT
 
           CLOSE ACCOUNT-FILE
           GOBACK.
