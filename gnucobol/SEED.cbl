      *----------------------------------------------------------------*
      * SEED - CREATE DEMO ACCOUNTS IN INDEXED FILES                   *
      * Run once before starting ZBNKBANK.                             *
      * Demo accounts:                                                  *
      *   1000000001 / PIN 1234 / Balance $15000                       *
      *   1000000002 / PIN 5678 / Balance $3200                        *
      *   1000000003 / PIN 1111 / Balance $87450                       *
      *----------------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SEED.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ZBNKBANK.dat'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS WS-ACCNO
               FILE STATUS IS WS-STATUS.
 
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
       77 WS-STATUS PIC XX.
 
       PROCEDURE DIVISION.
           OPEN OUTPUT ACCOUNT-FILE
 
           MOVE 1000000001 TO WS-ACCNO
           MOVE 1234       TO WS-PIN
           MOVE 15000      TO WS-BALANCE
           MOVE 0          TO WS-ATTEMPTS WS-LOCKED
           MOVE 0          TO WS-TXCOUNT
           WRITE ACCOUNT-RECORD
 
           MOVE 1000000002 TO WS-ACCNO
           MOVE 5678       TO WS-PIN
           MOVE 3200       TO WS-BALANCE
           MOVE 0          TO WS-ATTEMPTS WS-LOCKED
           MOVE 0          TO WS-TXCOUNT
           WRITE ACCOUNT-RECORD
 
           MOVE 1000000003 TO WS-ACCNO
           MOVE 1111       TO WS-PIN
           MOVE 87450      TO WS-BALANCE
           MOVE 0          TO WS-ATTEMPTS WS-LOCKED
           MOVE 0          TO WS-TXCOUNT
           WRITE ACCOUNT-RECORD
 
           CLOSE ACCOUNT-FILE
           DISPLAY 'SEED: 3 accounts created successfully.'
           STOP RUN.
