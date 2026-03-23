//VSAMZBNK JOB CLASS=A,MSGCLASS=X
//*
//* DEFINE MAIN ACCOUNT VSAM CLUSTER
//* RECORD LAYOUT (37 BYTES):
//*   WS-ACCNO    PIC 9(10)  - KEY
//*   WS-PIN      PIC 9(10)
//*   WS-BALANCE  PIC 9(10)
//*   WS-ATTEMPTS PIC 9(1)   - LOGIN ATTEMPT COUNTER (0-3)
//*   WS-LOCKED   PIC 9(1)   - 0=OPEN 1=LOCKED
//*   WS-TXCOUNT  PIC 9(5)   - TRANSACTION SEQUENCE COUNTER
//*
//STEP1 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=A
//SYSIN DD *
   DEFINE CLUSTER (NAME(U0210.VSAM.ZBANK)   -
   VOL(B2SYS1)                              -
   INDEXED                                  -
   RECSZ(37 37)                             -
   TRACKS(1,1)                              -
   KEYS(10 0))                              -
   DATA (NAME(U0210.VSAM.ZBANK.DATA))       -
   INDEX (NAME(U0210.VSAM.ZBANK.INDEX))
/*
