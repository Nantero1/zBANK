     *----------------------------------------------------------------*
     * ZBNKTXN - ZBANK TRANSACTION SUBPROGRAM                        *
     *                                                               *
     * Called via: EXEC CICS LINK PROGRAM('ZBNKTXN')                *
     *             COMMAREA(WS-TXN-AREA) LENGTH(44)                  *
     *                                                               *
     * COMMAREA LAYOUT (44 BYTES):                                   *
     *   TX-ACCNO   PIC 9(10) - SOURCE ACCOUNT NUMBER                *
     *   TX-DEST    PIC 9(10) - DEST ACCOUNT (TRANSFER ONLY)        *
     *   TX-ACTION  PIC X(1)  - D=DEPOSIT W=WITHDRAW T=TRANSFER     *
     *   TX-AMOUNT  PIC 9(10) - TRANSACTION AMOUNT                   *
     *   TX-BALANCE PIC 9(10) - RETURNED: BALANCE AFTER TX          *
     *   TX-RESULT  PIC 9(2)  - RESULT CODE:                        *
     *                  00 = OK                                       *
     *                  01 = INSUFFICIENT FUNDS                       *
     *                  02 = INVALID AMOUNT (ZERO OR NEGATIVE)       *
     *                  03 = ACCOUNT NOT FOUND                        *
     *                  04 = DESTINATION ACCOUNT NOT FOUND           *
     *                                                               *
     * BUGS FIXED:                                                    *
     *   - DEPOSIT/WITHDRAW ACCEPTS AMOUNT=0: NOW VALIDATED          *
     *   - WITHDRAW ALLOWED OVERDRAFT: NOW CHECKED BEFORE SUBTRACT   *
     *----------------------------------------------------------------*
      IDENTIFICATION DIVISION.
      PROGRAM-ID. ZBNKTXN.
      DATA DIVISION.
      WORKING-STORAGE SECTION.
      77 WS-FILE-NAME   PIC X(8)  VALUE 'VSAMZBNK'.
      77 WS-TX-FILE     PIC X(8)  VALUE 'VSAMZBTX'.
      77 WS-REC-LEN     PIC S9(4) COMP VALUE 37.
      77 WS-TX-LEN      PIC S9(4) COMP VALUE 36.
      77 WS-RESP-CODE   PIC 9(8).
      77 WS-RESP2       PIC 9(8).

     *----------------------------------------------------------------*
     * MAIN ACCOUNT RECORD (SOURCE)                                   *
     *----------------------------------------------------------------*
      01 WS-FILE-REC.
        05 WS-ACCNO     PIC 9(10).
        05 WS-PIN       PIC 9(10).
        05 WS-BALANCE   PIC 9(10).
        05 WS-ATTEMPTS  PIC 9(1).
        05 WS-LOCKED    PIC 9(1).
        05 WS-TXCOUNT   PIC 9(5).

     *----------------------------------------------------------------*
     * DESTINATION ACCOUNT RECORD (TRANSFER ONLY)                     *
     *----------------------------------------------------------------*
      01 WS-DEST-REC.
        05 WD-ACCNO     PIC 9(10).
        05 WD-PIN       PIC 9(10).
        05 WD-BALANCE   PIC 9(10).
        05 WD-ATTEMPTS  PIC 9(1).
        05 WD-LOCKED    PIC 9(1).
        05 WD-TXCOUNT   PIC 9(5).

     *----------------------------------------------------------------*
     * TRANSACTION HISTORY RECORD                                      *
     *----------------------------------------------------------------*
      01 WS-TX-REC.
        05 TX-ACCNO     PIC 9(10).
        05 TX-SEQNO     PIC 9(5).
        05 TX-TYPE      PIC X(1).
        05 TX-AMOUNT    PIC 9(10).
        05 TX-BALANCE   PIC 9(10).

      01 WS-TX-KEY.
        05 TXK-ACCNO    PIC 9(10).
        05 TXK-SEQNO    PIC 9(5).

     *----------------------------------------------------------------*
     * LINKAGE SECTION — COMMAREA                                      *
     *----------------------------------------------------------------*
      LINKAGE SECTION.
      01 DFHCOMMAREA.
        05 LK-ACCNO     PIC 9(10).
        05 LK-DEST      PIC 9(10).
        05 LK-ACTION    PIC X(1).
        05 LK-AMOUNT    PIC 9(10).
        05 LK-BALANCE   PIC 9(10).
        05 LK-RESULT    PIC 9(2).

      PROCEDURE DIVISION.
     *----------------------------------------------------------------*
     * VALIDATE AMOUNT > 0                                             *
     *----------------------------------------------------------------*
          IF LK-AMOUNT = ZEROS
            MOVE 02 TO LK-RESULT
            EXEC CICS RETURN END-EXEC
          END-IF

     *----------------------------------------------------------------*
     * READ SOURCE ACCOUNT FOR UPDATE                                  *
     *----------------------------------------------------------------*
          MOVE LK-ACCNO TO WS-ACCNO
          EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
          END-EXEC
          EXEC CICS READ DATASET(WS-FILE-NAME)
                    INTO(WS-FILE-REC)
                    RIDFLD(WS-ACCNO)
                    LENGTH(WS-REC-LEN)
                    UPDATE
                    RESP(WS-RESP-CODE)
          END-EXEC

          IF WS-RESP-CODE NOT = ZEROS
            MOVE 03 TO LK-RESULT
            EXEC CICS RETURN END-EXEC
          END-IF

     *----------------------------------------------------------------*
     * ROUTE BY ACTION                                                  *
     *----------------------------------------------------------------*
          EVALUATE LK-ACTION

     *--- DEPOSIT ---------------------------------------------------*
            WHEN 'D'
              ADD LK-AMOUNT TO WS-BALANCE
              ADD 1 TO WS-TXCOUNT
              PERFORM WRITE-TX-RECORD
              EXEC CICS REWRITE DATASET(WS-FILE-NAME)
                FROM(WS-FILE-REC)
                LENGTH(WS-REC-LEN)
                RESP(WS-RESP-CODE)
              END-EXEC
              MOVE WS-BALANCE TO LK-BALANCE
              MOVE 00 TO LK-RESULT

     *--- WITHDRAW --------------------------------------------------*
            WHEN 'W'
              IF LK-AMOUNT > WS-BALANCE
                EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
                END-EXEC
                MOVE 01 TO LK-RESULT
                EXEC CICS RETURN END-EXEC
              END-IF
              SUBTRACT LK-AMOUNT FROM WS-BALANCE
              ADD 1 TO WS-TXCOUNT
              PERFORM WRITE-TX-RECORD
              EXEC CICS REWRITE DATASET(WS-FILE-NAME)
                FROM(WS-FILE-REC)
                LENGTH(WS-REC-LEN)
                RESP(WS-RESP-CODE)
              END-EXEC
              MOVE WS-BALANCE TO LK-BALANCE
              MOVE 00 TO LK-RESULT

     *--- TRANSFER --------------------------------------------------*
            WHEN 'T'
              IF LK-AMOUNT > WS-BALANCE
                EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
                END-EXEC
                MOVE 01 TO LK-RESULT
                EXEC CICS RETURN END-EXEC
              END-IF

     *       READ DESTINATION ACCOUNT FOR UPDATE
              MOVE LK-DEST TO WD-ACCNO
              EXEC CICS READ DATASET(WS-FILE-NAME)
                        INTO(WS-DEST-REC)
                        RIDFLD(WD-ACCNO)
                        LENGTH(WS-REC-LEN)
                        UPDATE
                        RESP(WS-RESP2)
              END-EXEC

              IF WS-RESP2 NOT = ZEROS
                EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
                END-EXEC
                MOVE 04 TO LK-RESULT
                EXEC CICS RETURN END-EXEC
              END-IF

     *       APPLY TRANSFER
              SUBTRACT LK-AMOUNT FROM WS-BALANCE
              ADD LK-AMOUNT TO WD-BALANCE
              ADD 1 TO WS-TXCOUNT
              ADD 1 TO WD-TXCOUNT

     *       WRITE TX HISTORY FOR SOURCE (T)
              MOVE 'T' TO LK-ACTION
              PERFORM WRITE-TX-RECORD

     *       REWRITE SOURCE ACCOUNT
              EXEC CICS REWRITE DATASET(WS-FILE-NAME)
                FROM(WS-FILE-REC)
                LENGTH(WS-REC-LEN)
                RESP(WS-RESP-CODE)
              END-EXEC

     *       WRITE TX HISTORY FOR DEST (CREDIT)
              MOVE WD-ACCNO    TO TX-ACCNO
              MOVE WD-TXCOUNT  TO TX-SEQNO
              MOVE 'T'         TO TX-TYPE
              MOVE LK-AMOUNT   TO TX-AMOUNT
              MOVE WD-BALANCE  TO TX-BALANCE
              MOVE TXK-ACCNO   TO WD-ACCNO
              PERFORM WRITE-DEST-TX

     *       REWRITE DEST ACCOUNT
              EXEC CICS REWRITE DATASET(WS-FILE-NAME)
                FROM(WS-DEST-REC)
                LENGTH(WS-REC-LEN)
                RESP(WS-RESP2)
              END-EXEC

              MOVE WS-BALANCE TO LK-BALANCE
              MOVE 00 TO LK-RESULT

            WHEN OTHER
              MOVE 02 TO LK-RESULT
          END-EVALUATE

          EXEC CICS RETURN END-EXEC.

     *----------------------------------------------------------------*
     * WRITE-TX-RECORD: WRITE SOURCE ACCOUNT TX TO HISTORY VSAM       *
     *----------------------------------------------------------------*
      WRITE-TX-RECORD.
          MOVE WS-ACCNO    TO TX-ACCNO
          MOVE WS-TXCOUNT  TO TX-SEQNO
          MOVE LK-ACTION   TO TX-TYPE
          MOVE LK-AMOUNT   TO TX-AMOUNT
          MOVE WS-BALANCE  TO TX-BALANCE
          MOVE TX-ACCNO    TO TXK-ACCNO
          MOVE TX-SEQNO    TO TXK-SEQNO
          EXEC CICS WRITE DATASET(WS-TX-FILE)
            FROM(WS-TX-REC)
            RIDFLD(WS-TX-KEY)
            LENGTH(WS-TX-LEN)
            RESP(WS-RESP-CODE)
          END-EXEC.

     *----------------------------------------------------------------*
     * WRITE-DEST-TX: WRITE DESTINATION ACCOUNT TX TO HISTORY VSAM    *
     *----------------------------------------------------------------*
      WRITE-DEST-TX.
          MOVE WD-ACCNO    TO TXK-ACCNO
          MOVE WD-TXCOUNT  TO TXK-SEQNO
          EXEC CICS WRITE DATASET(WS-TX-FILE)
            FROM(WS-TX-REC)
            RIDFLD(WS-TX-KEY)
            LENGTH(WS-TX-LEN)
            RESP(WS-RESP2)
          END-EXEC.
