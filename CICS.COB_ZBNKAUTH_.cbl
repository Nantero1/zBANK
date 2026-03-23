     *----------------------------------------------------------------*
     * ZBNKAUTH - ZBANK AUTHENTICATION SUBPROGRAM                    *
     *                                                               *
     * Called via: EXEC CICS LINK PROGRAM('ZBNKAUTH')               *
     *             COMMAREA(WS-AUTH-AREA) LENGTH(37)                 *
     *                                                               *
     * COMMAREA LAYOUT (37 BYTES):                                   *
     *   CA-ACCNO    PIC 9(10) - ACCOUNT NUMBER TO AUTHENTICATE      *
     *   CA-PIN      PIC 9(10) - PIN PROVIDED BY USER               *
     *   CA-BALANCE  PIC 9(10) - RETURNED: CURRENT BALANCE          *
     *   CA-TXCOUNT  PIC 9(5)  - RETURNED: TX SEQUENCE COUNTER      *
     *   CA-RESULT   PIC 9(2)  - RESULT CODE:                       *
     *                  00 = AUTHENTICATED OK                        *
     *                  01 = ACCOUNT NOT FOUND                       *
     *                  02 = WRONG PIN                               *
     *                  03 = ACCOUNT LOCKED (3 FAILED ATTEMPTS)      *
     *                                                               *
     * MAX ATTEMPTS BEFORE LOCK: 3                                   *
     *----------------------------------------------------------------*
      IDENTIFICATION DIVISION.
      PROGRAM-ID. ZBNKAUTH.
      DATA DIVISION.
      WORKING-STORAGE SECTION.
      77 WS-REC-LEN     PIC S9(4) COMP VALUE 37.
      77 WS-FILE-NAME   PIC X(8)  VALUE 'VSAMZBNK'.
      77 WS-RESP-CODE   PIC 9(8).
      77 WS-MAX-TRIES   PIC 9(1)  VALUE 3.
      01 WS-FILE-REC.
        05 WS-ACCNO     PIC 9(10).
        05 WS-PIN       PIC 9(10).
        05 WS-BALANCE   PIC 9(10).
        05 WS-ATTEMPTS  PIC 9(1).
        05 WS-LOCKED    PIC 9(1).
        05 WS-TXCOUNT   PIC 9(5).
     *----------------------------------------------------------------*
     * COMMAREA — LINKED FROM MAIN PROGRAM                            *
     *----------------------------------------------------------------*
      01 CA-DATA.
        05 CA-ACCNO     PIC 9(10).
        05 CA-PIN       PIC 9(10).
        05 CA-BALANCE   PIC 9(10).
        05 CA-TXCOUNT   PIC 9(5).
        05 CA-RESULT    PIC 9(2).

      LINKAGE SECTION.
      01 DFHCOMMAREA.
        05 LK-ACCNO     PIC 9(10).
        05 LK-PIN       PIC 9(10).
        05 LK-BALANCE   PIC 9(10).
        05 LK-TXCOUNT   PIC 9(5).
        05 LK-RESULT    PIC 9(2).

      PROCEDURE DIVISION.
     *----------------------------------------------------------------*
     * COPY INPUT FROM COMMAREA                                        *
     *----------------------------------------------------------------*
          MOVE LK-ACCNO  TO WS-ACCNO
          MOVE LK-ACCNO  TO CA-ACCNO
          MOVE LK-PIN    TO CA-PIN
          MOVE 00        TO CA-RESULT

     *----------------------------------------------------------------*
     * UNLOCK DATASET BEFORE READ                                      *
     *----------------------------------------------------------------*
          EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
          END-EXEC

     *----------------------------------------------------------------*
     * READ ACCOUNT FROM VSAM                                          *
     *----------------------------------------------------------------*
          EXEC CICS READ DATASET(WS-FILE-NAME)
                    INTO(WS-FILE-REC)
                    RIDFLD(WS-ACCNO)
                    LENGTH(WS-REC-LEN)
                    UPDATE
                    RESP(WS-RESP-CODE)
          END-EXEC

          IF WS-RESP-CODE NOT = ZEROS
            MOVE 01 TO LK-RESULT
            EXEC CICS RETURN END-EXEC
          END-IF

     *----------------------------------------------------------------*
     * CHECK IF ACCOUNT IS LOCKED                                      *
     *----------------------------------------------------------------*
          IF WS-LOCKED = 1
            MOVE 03 TO LK-RESULT
            EXEC CICS UNLOCK DATASET(WS-FILE-NAME)
            END-EXEC
            EXEC CICS RETURN END-EXEC
          END-IF

     *----------------------------------------------------------------*
     * VALIDATE PIN                                                    *
     *----------------------------------------------------------------*
          IF CA-PIN NOT = WS-PIN
            ADD 1 TO WS-ATTEMPTS
            IF WS-ATTEMPTS >= WS-MAX-TRIES
              MOVE 1 TO WS-LOCKED
            END-IF
            EXEC CICS REWRITE DATASET(WS-FILE-NAME)
              FROM(WS-FILE-REC)
              LENGTH(WS-REC-LEN)
              RESP(WS-RESP-CODE)
            END-EXEC
            MOVE 02 TO LK-RESULT
            EXEC CICS RETURN END-EXEC
          END-IF

     *----------------------------------------------------------------*
     * AUTHENTICATION OK — RESET ATTEMPTS, RETURN DATA                 *
     *----------------------------------------------------------------*
          MOVE 0        TO WS-ATTEMPTS
          EXEC CICS REWRITE DATASET(WS-FILE-NAME)
            FROM(WS-FILE-REC)
            LENGTH(WS-REC-LEN)
            RESP(WS-RESP-CODE)
          END-EXEC

          MOVE WS-BALANCE  TO LK-BALANCE
          MOVE WS-TXCOUNT  TO LK-TXCOUNT
          MOVE 00          TO LK-RESULT

          EXEC CICS RETURN END-EXEC.
