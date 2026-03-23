     *----------------------------------------------------------------*
     * ZBNKBANK - ZBANK MAIN SCREEN CONTROLLER                       *
     *                                                               *
     * SCREEN STATES:                                                *
     *   0 = LOGIN    (CBLOGIN)                                      *
     *   1 = HOME     (CBHOME)                                       *
     *   2 = REGISTER (CBREG)                                        *
     *   3 = STATEMENT(CBSTMT)                                       *
     *                                                               *
     * SUBPROGRAMS:                                                   *
     *   ZBNKAUTH — authentication + lockout                         *
     *   ZBNKTXN  — deposit / withdraw / transfer + history          *
     *                                                               *
     * VSAM FILES:                                                    *
     *   VSAMZBNK  — account records (37 bytes, key 10)              *
     *   VSAMZBTX  — transaction history (36 bytes, key 15)          *
     *----------------------------------------------------------------*
      IDENTIFICATION DIVISION.
      PROGRAM-ID. ZBNKBANK.
      DATA DIVISION.
      WORKING-STORAGE SECTION.
      COPY ZBANKSET.

      77 WS-FILE-NAME   PIC X(8)  VALUE 'VSAMZBNK'.
      77 WS-TX-FILE     PIC X(8)  VALUE 'VSAMZBTX'.
      77 WS-REC-LEN     PIC S9(4) COMP VALUE 37.
      77 WS-TX-LEN      PIC S9(4) COMP VALUE 36.
      77 WS-RESP-CODE   PIC 9(8).
      77 WS-CA-LEN-AUTH PIC S9(4) COMP VALUE 37.
      77 WS-CA-LEN-TXN  PIC S9(4) COMP VALUE 44.

      01 ACCNO          PIC 9(10).
      01 PIN            PIC 9(10).
      01 EXIT-CONDITION PIC 9 VALUE 0.
      01 SCREEN-STATE   PIC 9 VALUE 0.
      01 ACTION         PIC X.
      01 AMOUNT         PIC 9(10).
      01 BALANCE        PIC 9(10).
      01 INFO           PIC X(50) VALUE 'PLEASE LOG IN!'.

     *----------------------------------------------------------------*
     * COMMAREA FOR ZBNKAUTH SUBPROGRAM (37 BYTES)                    *
     *----------------------------------------------------------------*
      01 WS-AUTH-AREA.
        05 CA-ACCNO     PIC 9(10).
        05 CA-PIN       PIC 9(10).
        05 CA-BALANCE   PIC 9(10).
        05 CA-TXCOUNT   PIC 9(5).
        05 CA-RESULT    PIC 9(2).

     *----------------------------------------------------------------*
     * COMMAREA FOR ZBNKTXN SUBPROGRAM (44 BYTES)                     *
     *----------------------------------------------------------------*
      01 WS-TXN-AREA.
        05 TX-ACCNO     PIC 9(10).
        05 TX-DEST      PIC 9(10).
        05 TX-ACTION    PIC X(1).
        05 TX-AMOUNT    PIC 9(10).
        05 TX-BALANCE   PIC 9(10).
        05 TX-RESULT    PIC 9(2).

     *----------------------------------------------------------------*
     * ACCOUNT RECORD (FOR REGISTER WRITE)                             *
     *----------------------------------------------------------------*
      01 WS-FILE-REC.
        05 WS-ACCNO     PIC 9(10).
        05 WS-PIN       PIC 9(10).
        05 WS-BALANCE   PIC 9(10).
        05 WS-ATTEMPTS  PIC 9(1)  VALUE 0.
        05 WS-LOCKED    PIC 9(1)  VALUE 0.
        05 WS-TXCOUNT   PIC 9(5)  VALUE 0.

     *----------------------------------------------------------------*
     * TRANSACTION HISTORY READ (FOR STATEMENT SCREEN)                *
     *----------------------------------------------------------------*
      01 WS-TX-REC.
        05 TX-R-ACCNO   PIC 9(10).
        05 TX-R-SEQNO   PIC 9(5).
        05 TX-R-TYPE    PIC X(1).
        05 TX-R-AMOUNT  PIC 9(10).
        05 TX-R-BALANCE PIC 9(10).

      01 WS-TX-KEY.
        05 TXK-ACCNO    PIC 9(10).
        05 TXK-SEQNO    PIC 9(5).

      01 WS-LINE-IDX    PIC 9 VALUE 1.

     *----------------------------------------------------------------*
     * STATEMENT DISPLAY LINES (5 SLOTS)                               *
     *----------------------------------------------------------------*
      01 WS-STMT-LINES.
        05 STMT-LINE OCCURS 5 TIMES.
          10 SL-TYPE    PIC X(8).
          10 SL-AMOUNT  PIC 9(10).
          10 SL-BALANCE PIC 9(10).

      PROCEDURE DIVISION.
     *================================================================*
     * MAIN LOOP — PROCESS SCREENS UNTIL EXIT                          *
     *================================================================*
          PERFORM WITH TEST BEFORE UNTIL EXIT-CONDITION = 1

     *----------------------------------------------------------------*
     * STATE 0: LOGIN SCREEN                                           *
     *----------------------------------------------------------------*
            IF SCREEN-STATE = 0
              MOVE LOW-VALUES TO CBLOGINO
              MOVE INFO TO LOGINFOO
              EXEC CICS SEND MAP('CBLOGIN') MAPSET('ZBANKSET')
                ERASE
              END-EXEC
              EXEC CICS RECEIVE MAP('CBLOGIN') MAPSET('ZBANKSET')
                INTO(CBLOGINI)
              END-EXEC

              MOVE LOGACCI TO ACCNO
              MOVE LOGPINI TO PIN
              MOVE LOGACTI TO ACTION

              IF ACTION = 'Q'
                MOVE 1 TO EXIT-CONDITION
              END-IF

              IF ACTION = 'R'
                MOVE 2 TO SCREEN-STATE
                MOVE 'ENTER NEW ACCOUNT NUMBER AND PIN.' TO INFO
              END-IF

              IF ACTION NOT = 'Q' AND ACTION NOT = 'R'
                MOVE ACCNO TO CA-ACCNO
                MOVE PIN   TO CA-PIN
                EXEC CICS LINK PROGRAM('ZBNKAUTH')
                  COMMAREA(WS-AUTH-AREA)
                  LENGTH(WS-CA-LEN-AUTH)
                END-EXEC
                EVALUATE CA-RESULT
                  WHEN 00
                    MOVE 1 TO SCREEN-STATE
                    MOVE 'WELCOME!' TO INFO
                    MOVE CA-BALANCE TO BALANCE
                  WHEN 01
                    MOVE 'ACCOUNT NOT FOUND.' TO INFO
                  WHEN 02
                    MOVE 'WRONG PIN. ACCOUNT LOCKS AT 3 ATTEMPTS.'
                      TO INFO
                  WHEN 03
                    MOVE 'ACCOUNT LOCKED. CONTACT ADMINISTRATOR.'
                      TO INFO
                  WHEN OTHER
                    MOVE 'UNEXPECTED ERROR. CONTACT ADMINISTRATOR.'
                      TO INFO
                END-EVALUATE
              END-IF

              IF EXIT-CONDITION NOT = 1
                EXEC CICS SEND MAP('CBLOGIN') MAPSET('ZBANKSET')
                  DATAONLY FROM(CBLOGINO)
                END-EXEC
              END-IF
            END-IF

     *----------------------------------------------------------------*
     * STATE 1: HOME SCREEN                                            *
     *----------------------------------------------------------------*
            IF SCREEN-STATE = 1
              MOVE LOW-VALUES TO CBHOMEO
              MOVE BALANCE TO BALANCEO
              MOVE INFO TO HOMINFOO
              EXEC CICS SEND MAP('CBHOME') MAPSET('ZBANKSET')
                ERASE
              END-EXEC
              EXEC CICS RECEIVE MAP('CBHOME') MAPSET('ZBANKSET')
                INTO(CBHOMEI)
              END-EXEC

              MOVE HOMACTI TO ACTION
              MOVE AMOUNTI TO AMOUNT

              EVALUATE ACTION

                WHEN 'Q'
                  MOVE 0 TO SCREEN-STATE
                  MOVE 'PLEASE LOG IN!' TO INFO
                  MOVE ZEROS TO ACCNO PIN BALANCE

                WHEN 'S'
                  MOVE 3 TO SCREEN-STATE
                  MOVE 'LAST 5 TRANSACTIONS.' TO INFO

                WHEN 'D'
                  MOVE ACCNO  TO TX-ACCNO
                  MOVE ZEROS  TO TX-DEST
                  MOVE 'D'    TO TX-ACTION
                  MOVE AMOUNT TO TX-AMOUNT
                  EXEC CICS LINK PROGRAM('ZBNKTXN')
                    COMMAREA(WS-TXN-AREA)
                    LENGTH(WS-CA-LEN-TXN)
                  END-EXEC
                  EVALUATE TX-RESULT
                    WHEN 00
                      MOVE TX-BALANCE TO BALANCE
                      MOVE 'MONEY SAFELY DEPOSITED!' TO INFO
                    WHEN 02
                      MOVE 'INVALID AMOUNT. ENTER A VALUE > 0.'
                        TO INFO
                    WHEN 03
                      MOVE 'ACCOUNT NOT FOUND.' TO INFO
                    WHEN OTHER
                      MOVE 'DEPOSIT ERROR. TRY AGAIN.' TO INFO
                  END-EVALUATE

                WHEN 'W'
                  MOVE ACCNO  TO TX-ACCNO
                  MOVE ZEROS  TO TX-DEST
                  MOVE 'W'    TO TX-ACTION
                  MOVE AMOUNT TO TX-AMOUNT
                  EXEC CICS LINK PROGRAM('ZBNKTXN')
                    COMMAREA(WS-TXN-AREA)
                    LENGTH(WS-CA-LEN-TXN)
                  END-EXEC
                  EVALUATE TX-RESULT
                    WHEN 00
                      MOVE TX-BALANCE TO BALANCE
                      MOVE 'MONEY SAFELY WITHDRAWN!' TO INFO
                    WHEN 01
                      MOVE 'INSUFFICIENT FUNDS.' TO INFO
                    WHEN 02
                      MOVE 'INVALID AMOUNT. ENTER A VALUE > 0.'
                        TO INFO
                    WHEN 03
                      MOVE 'ACCOUNT NOT FOUND.' TO INFO
                    WHEN OTHER
                      MOVE 'WITHDRAW ERROR. TRY AGAIN.' TO INFO
                  END-EVALUATE

                WHEN 'T'
                  MOVE ACCNO   TO TX-ACCNO
                  MOVE AMOUNTI TO TX-DEST
                  MOVE 'T'     TO TX-ACTION
                  MOVE AMOUNT  TO TX-AMOUNT
                  EXEC CICS LINK PROGRAM('ZBNKTXN')
                    COMMAREA(WS-TXN-AREA)
                    LENGTH(WS-CA-LEN-TXN)
                  END-EXEC
                  EVALUATE TX-RESULT
                    WHEN 00
                      MOVE TX-BALANCE TO BALANCE
                      MOVE 'TRANSFER COMPLETED!' TO INFO
                    WHEN 01
                      MOVE 'INSUFFICIENT FUNDS.' TO INFO
                    WHEN 02
                      MOVE 'INVALID AMOUNT. ENTER A VALUE > 0.'
                        TO INFO
                    WHEN 04
                      MOVE 'DESTINATION ACCOUNT NOT FOUND.' TO INFO
                    WHEN OTHER
                      MOVE 'TRANSFER ERROR. TRY AGAIN.' TO INFO
                  END-EVALUATE

                WHEN OTHER
                  MOVE 'INVALID ACTION. USE Q D W T S.' TO INFO
              END-EVALUATE

              IF SCREEN-STATE = 1
                EXEC CICS SEND MAP('CBHOME') MAPSET('ZBANKSET')
                  DATAONLY FROM(CBHOMEO)
                END-EXEC
              END-IF
            END-IF

     *----------------------------------------------------------------*
     * STATE 2: REGISTER SCREEN                                        *
     *----------------------------------------------------------------*
            IF SCREEN-STATE = 2
              MOVE LOW-VALUES TO CBREGO
              MOVE INFO TO REGINFOO
              EXEC CICS SEND MAP('CBREG') MAPSET('ZBANKSET')
                ERASE
              END-EXEC
              EXEC CICS RECEIVE MAP('CBREG') MAPSET('ZBANKSET')
                INTO(CBREGI)
              END-EXEC

              MOVE REGACTI TO ACTION

              IF ACTION = 'Q'
                MOVE 0 TO SCREEN-STATE
                MOVE 'PLEASE LOG IN!' TO INFO
              END-IF

              IF ACTION = 'C'
                MOVE REGACCI TO WS-ACCNO
                MOVE REGPINI TO WS-PIN
                MOVE ZEROS   TO WS-BALANCE
                MOVE 0       TO WS-ATTEMPTS
                MOVE 0       TO WS-LOCKED
                MOVE ZEROS   TO WS-TXCOUNT

                EXEC CICS WRITE DATASET(WS-FILE-NAME)
                  FROM(WS-FILE-REC)
                  RIDFLD(WS-ACCNO)
                  LENGTH(WS-REC-LEN)
                  RESP(WS-RESP-CODE)
                END-EXEC

                EVALUATE WS-RESP-CODE
                  WHEN 0
                    MOVE 'ACCOUNT CREATED! PLEASE LOG IN.' TO INFO
                    MOVE 0 TO SCREEN-STATE
                  WHEN 16
                    MOVE 'ACCOUNT NUMBER ALREADY EXISTS.' TO INFO
                  WHEN OTHER
                    MOVE 'CREATE ERROR. CONTACT ADMINISTRATOR.'
                      TO INFO
                END-EVALUATE
              END-IF

              IF SCREEN-STATE = 2
                EXEC CICS SEND MAP('CBREG') MAPSET('ZBANKSET')
                  DATAONLY FROM(CBREGO)
                END-EXEC
              END-IF
            END-IF

     *----------------------------------------------------------------*
     * STATE 3: STATEMENT SCREEN                                       *
     *----------------------------------------------------------------*
            IF SCREEN-STATE = 3
              MOVE LOW-VALUES TO CBSTMTO
              MOVE INFO TO STMINFOO
              MOVE ACCNO TO STMACCO

              PERFORM LOAD-STATEMENT

              EXEC CICS SEND MAP('CBSTMT') MAPSET('ZBANKSET')
                ERASE
              END-EXEC
              EXEC CICS RECEIVE MAP('CBSTMT') MAPSET('ZBANKSET')
                INTO(CBSTMTI)
              END-EXEC

              MOVE STMACTI TO ACTION
              IF ACTION = 'Q'
                MOVE 1 TO SCREEN-STATE
                MOVE 'WELCOME BACK!' TO INFO
              END-IF

              IF SCREEN-STATE = 3
                EXEC CICS SEND MAP('CBSTMT') MAPSET('ZBANKSET')
                  DATAONLY FROM(CBSTMTO)
                END-EXEC
              END-IF
            END-IF

          END-PERFORM.

     *----------------------------------------------------------------*
     * EXIT: CLEAR SCREEN AND RETURN                                   *
     *----------------------------------------------------------------*
          EXEC CICS SEND MAP('CBLOGIN') MAPSET('ZBANKSET')
            DATAONLY ERASE
          END-EXEC
          EXEC CICS RETURN END-EXEC.

     *================================================================*
     * LOAD-STATEMENT: BROWSE LAST 5 TX FROM HISTORY VSAM             *
     *================================================================*
      LOAD-STATEMENT.
          MOVE SPACES TO SL-TYPE(1) SL-TYPE(2) SL-TYPE(3)
                         SL-TYPE(4) SL-TYPE(5)
          MOVE ZEROS  TO SL-AMOUNT(1) SL-AMOUNT(2) SL-AMOUNT(3)
                         SL-AMOUNT(4) SL-AMOUNT(5)
          MOVE ZEROS  TO SL-BALANCE(1) SL-BALANCE(2) SL-BALANCE(3)
                         SL-BALANCE(4) SL-BALANCE(5)
          MOVE 1 TO WS-LINE-IDX

          MOVE ACCNO  TO TXK-ACCNO
          MOVE 99999  TO TXK-SEQNO

          EXEC CICS STARTBR DATASET(WS-TX-FILE)
            RIDFLD(WS-TX-KEY)
            GTEQ
            RESP(WS-RESP-CODE)
          END-EXEC

          IF WS-RESP-CODE NOT = ZEROS
            EXEC CICS ENDBR DATASET(WS-TX-FILE)
            END-EXEC
            EXIT PARAGRAPH
          END-IF

          PERFORM VARYING WS-LINE-IDX FROM 1 BY 1
            UNTIL WS-LINE-IDX > 5

            EXEC CICS READPREV DATASET(WS-TX-FILE)
              INTO(WS-TX-REC)
              RIDFLD(WS-TX-KEY)
              LENGTH(WS-TX-LEN)
              RESP(WS-RESP-CODE)
            END-EXEC

            IF WS-RESP-CODE NOT = ZEROS
              MOVE 6 TO WS-LINE-IDX
            ELSE
              IF TX-R-ACCNO = ACCNO
                EVALUATE TX-R-TYPE
                  WHEN 'D' MOVE 'DEPOSIT ' TO SL-TYPE(WS-LINE-IDX)
                  WHEN 'W' MOVE 'WITHDRAW' TO SL-TYPE(WS-LINE-IDX)
                  WHEN 'T' MOVE 'TRANSFER' TO SL-TYPE(WS-LINE-IDX)
                  WHEN OTHER
                           MOVE 'UNKNOWN ' TO SL-TYPE(WS-LINE-IDX)
                END-EVALUATE
                MOVE TX-R-AMOUNT  TO SL-AMOUNT(WS-LINE-IDX)
                MOVE TX-R-BALANCE TO SL-BALANCE(WS-LINE-IDX)
              ELSE
                MOVE 6 TO WS-LINE-IDX
              END-IF
            END-IF
          END-PERFORM

          EXEC CICS ENDBR DATASET(WS-TX-FILE)
          END-EXEC

          MOVE SL-TYPE(1)    TO STM1TYPO
          MOVE SL-AMOUNT(1)  TO STM1AMTO
          MOVE SL-BALANCE(1) TO STM1BALO
          MOVE SL-TYPE(2)    TO STM2TYPO
          MOVE SL-AMOUNT(2)  TO STM2AMTO
          MOVE SL-BALANCE(2) TO STM2BALO
          MOVE SL-TYPE(3)    TO STM3TYPO
          MOVE SL-AMOUNT(3)  TO STM3AMTO
          MOVE SL-BALANCE(3) TO STM3BALO
          MOVE SL-TYPE(4)    TO STM4TYPO
          MOVE SL-AMOUNT(4)  TO STM4AMTO
          MOVE SL-BALANCE(4) TO STM4BALO
          MOVE SL-TYPE(5)    TO STM5TYPO
          MOVE SL-AMOUNT(5)  TO STM5AMTO
          MOVE SL-BALANCE(5) TO STM5BALO.
