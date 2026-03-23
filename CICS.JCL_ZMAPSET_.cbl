//ZBANKSET JOB CLASS=A,MSGCLASS=X
//IBMLIB JCLLIB ORDER=(DFH530.CICS.SDFHPROC)
//ASSEM EXEC DFHMAPS,MAPNAME='ZBANKSET',INDEX='DFH530.CICS',
//     MAPLIB='DFH530.CICS.SDFHLOAD',
//     DSCTLIB='DFH530.CICS.SDFHMAC'
//SYSUT1 DD *
ZBANKSET DFHMSD TYPE=MAP,MODE=INOUT,LANG=COBOL2,STORAGE=AUTO,          X
               TIOAPFX=YES
*----------------------------------------------------------------*
* MAP: CBLOGIN - LOGIN SCREEN                                    *
*----------------------------------------------------------------*
CBLOGIN  DFHMDI SIZE=(24,80),LINE=1,COLUMN=1,CTRL=FREEKB
         DFHMDF POS=(1,33),LENGTH=17,ATTRB=(ASKIP,NORM),               X
               INITIAL='ZBANK LOGIN      '
         DFHMDF POS=(3,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    ______             _    '
         DFHMDF POS=(4,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    | ___ \           | |   '
         DFHMDF POS=(5,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' ___| |_/ / __ _ _ __ | | __'
         DFHMDF POS=(6,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='|_  / ___ \/ _` | `_ \| |/ /'
         DFHMDF POS=(7,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' / /| |_/ / (_| | | | |   < '
         DFHMDF POS=(8,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='/___\____/ \__,_|_| |_|_|\_\'
LOGINFO  DFHMDF POS=(10,15),LENGTH=50,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(13,30),LENGTH=20,ATTRB=(ASKIP,NORM),              X
               INITIAL='ACCOUNT NUMBER:'
LOGACC   DFHMDF POS=(13,47),LENGTH=10,ATTRB=(UNPROT,NUM,NORM,IC)
         DFHMDF POS=(14,30),LENGTH=20,ATTRB=(ASKIP,NORM),              X
               INITIAL='PIN (HIDDEN):    '
LOGPIN   DFHMDF POS=(14,47),LENGTH=4,ATTRB=(UNPROT,NUM,NORM,DRK)
         DFHMDF POS=(18,30),LENGTH=10,ATTRB=(ASKIP,NORM),              X
               INITIAL='ACTIONS:'
         DFHMDF POS=(19,30),LENGTH=30,ATTRB=(ASKIP,NORM),              X
               INITIAL='Q - EXIT, R - REGISTER'
LOGACT   DFHMDF POS=(18,42),LENGTH=1,ATTRB=(UNPROT,NORM)
*----------------------------------------------------------------*
* MAP: CBHOME - HOME / TRANSACTIONS SCREEN                       *
*----------------------------------------------------------------*
CBHOME   DFHMDI SIZE=(24,80),LINE=1,COLUMN=1,CTRL=FREEKB
         DFHMDF POS=(1,33),LENGTH=17,ATTRB=(ASKIP,NORM),               X
               INITIAL='ZBANK HOME       '
         DFHMDF POS=(3,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    ______             _    '
         DFHMDF POS=(4,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    | ___ \           | |   '
         DFHMDF POS=(5,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' ___| |_/ / __ _ _ __ | | __'
         DFHMDF POS=(6,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='|_  / ___ \/ _` | `_ \| |/ /'
         DFHMDF POS=(7,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' / /| |_/ / (_| | | | |   < '
         DFHMDF POS=(8,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='/___\____/ \__,_|_| |_|_|\_\'
HOMINFO  DFHMDF POS=(10,15),LENGTH=50,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(12,25),LENGTH=16,ATTRB=(ASKIP,NORM),              X
               INITIAL='CURRENT BALANCE:'
BALANCE  DFHMDF POS=(12,42),LENGTH=10,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(14,25),LENGTH=7,ATTRB=(ASKIP,NORM),               X
               INITIAL='AMOUNT:'
AMOUNT   DFHMDF POS=(14,42),LENGTH=10,ATTRB=(UNPROT,NUM,NORM,IC)
         DFHMDF POS=(15,25),LENGTH=17,ATTRB=(ASKIP,NORM),              X
               INITIAL='CHOOSE AN ACTION:'
         DFHMDF POS=(16,25),LENGTH=30,ATTRB=(ASKIP,NORM),              X
               INITIAL='Q - EXIT, D - DEPOSIT'
         DFHMDF POS=(17,25),LENGTH=30,ATTRB=(ASKIP,NORM),              X
               INITIAL='W - WITHDRAW, T - TRANSFER'
         DFHMDF POS=(18,25),LENGTH=30,ATTRB=(ASKIP,NORM),              X
               INITIAL='S - STATEMENT'
HOMACT   DFHMDF POS=(15,42),LENGTH=1,ATTRB=(UNPROT,NORM)
*----------------------------------------------------------------*
* MAP: CBREG - ACCOUNT REGISTRATION SCREEN                       *
*----------------------------------------------------------------*
CBREG    DFHMDI SIZE=(24,80),LINE=1,COLUMN=1,CTRL=FREEKB
         DFHMDF POS=(1,33),LENGTH=17,ATTRB=(ASKIP,NORM),               X
               INITIAL='ZBANK REGISTER   '
         DFHMDF POS=(3,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    ______             _    '
         DFHMDF POS=(4,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    | ___ \           | |   '
         DFHMDF POS=(5,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' ___| |_/ / __ _ _ __ | | __'
         DFHMDF POS=(6,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='|_  / ___ \/ _` | `_ \| |/ /'
         DFHMDF POS=(7,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' / /| |_/ / (_| | | | |   < '
         DFHMDF POS=(8,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='/___\____/ \__,_|_| |_|_|\_\'
REGINFO  DFHMDF POS=(10,15),LENGTH=50,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(13,30),LENGTH=20,ATTRB=(ASKIP,NORM),              X
               INITIAL='NEW ACCOUNT NUMBER:'
REGACC   DFHMDF POS=(13,51),LENGTH=10,ATTRB=(UNPROT,NUM,NORM,IC)
         DFHMDF POS=(14,30),LENGTH=20,ATTRB=(ASKIP,NORM),              X
               INITIAL='NEW PIN (HIDDEN):  '
REGPIN   DFHMDF POS=(14,51),LENGTH=4,ATTRB=(UNPROT,NUM,NORM,DRK)
         DFHMDF POS=(18,30),LENGTH=10,ATTRB=(ASKIP,NORM),              X
               INITIAL='ACTIONS:'
         DFHMDF POS=(19,30),LENGTH=25,ATTRB=(ASKIP,NORM),              X
               INITIAL='Q - BACK, C - CREATE'
REGACT   DFHMDF POS=(18,42),LENGTH=1,ATTRB=(UNPROT,NORM)
*----------------------------------------------------------------*
* MAP: CBSTMT - ACCOUNT STATEMENT SCREEN (LAST 5 TRANSACTIONS)  *
*----------------------------------------------------------------*
CBSTMT   DFHMDI SIZE=(24,80),LINE=1,COLUMN=1,CTRL=FREEKB
         DFHMDF POS=(1,31),LENGTH=20,ATTRB=(ASKIP,NORM),               X
               INITIAL='ZBANK STATEMENT     '
         DFHMDF POS=(3,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    ______             _    '
         DFHMDF POS=(4,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='    | ___ \           | |   '
         DFHMDF POS=(5,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' ___| |_/ / __ _ _ __ | | __'
         DFHMDF POS=(6,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='|_  / ___ \/ _` | `_ \| |/ /'
         DFHMDF POS=(7,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL=' / /| |_/ / (_| | | | |   < '
         DFHMDF POS=(8,27),LENGTH=30,ATTRB=(ASKIP,NORM),               X
               INITIAL='/___\____/ \__,_|_| |_|_|\_\'
STMINFO  DFHMDF POS=(10,15),LENGTH=50,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(11,20),LENGTH=9,ATTRB=(ASKIP,NORM),               X
               INITIAL='ACCOUNT:'
STMACC   DFHMDF POS=(11,30),LENGTH=10,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(12,20),LENGTH=4,ATTRB=(ASKIP,NORM),               X
               INITIAL='TYPE'
         DFHMDF POS=(12,28),LENGTH=12,ATTRB=(ASKIP,NORM),              X
               INITIAL='AMOUNT      '
         DFHMDF POS=(12,42),LENGTH=12,ATTRB=(ASKIP,NORM),              X
               INITIAL='BALANCE     '
STM1TYP  DFHMDF POS=(13,20),LENGTH=8,ATTRB=(ASKIP,NORM)
STM1AMT  DFHMDF POS=(13,28),LENGTH=12,ATTRB=(ASKIP,NORM)
STM1BAL  DFHMDF POS=(13,42),LENGTH=12,ATTRB=(ASKIP,NORM)
STM2TYP  DFHMDF POS=(14,20),LENGTH=8,ATTRB=(ASKIP,NORM)
STM2AMT  DFHMDF POS=(14,28),LENGTH=12,ATTRB=(ASKIP,NORM)
STM2BAL  DFHMDF POS=(14,42),LENGTH=12,ATTRB=(ASKIP,NORM)
STM3TYP  DFHMDF POS=(15,20),LENGTH=8,ATTRB=(ASKIP,NORM)
STM3AMT  DFHMDF POS=(15,28),LENGTH=12,ATTRB=(ASKIP,NORM)
STM3BAL  DFHMDF POS=(15,42),LENGTH=12,ATTRB=(ASKIP,NORM)
STM4TYP  DFHMDF POS=(16,20),LENGTH=8,ATTRB=(ASKIP,NORM)
STM4AMT  DFHMDF POS=(16,28),LENGTH=12,ATTRB=(ASKIP,NORM)
STM4BAL  DFHMDF POS=(16,42),LENGTH=12,ATTRB=(ASKIP,NORM)
STM5TYP  DFHMDF POS=(17,20),LENGTH=8,ATTRB=(ASKIP,NORM)
STM5AMT  DFHMDF POS=(17,28),LENGTH=12,ATTRB=(ASKIP,NORM)
STM5BAL  DFHMDF POS=(17,42),LENGTH=12,ATTRB=(ASKIP,NORM)
         DFHMDF POS=(20,20),LENGTH=8,ATTRB=(ASKIP,NORM),               X
               INITIAL='ACTIONS:'
         DFHMDF POS=(21,20),LENGTH=10,ATTRB=(ASKIP,NORM),              X
               INITIAL='Q - BACK'
STMACT   DFHMDF POS=(20,30),LENGTH=1,ATTRB=(UNPROT,NORM)
         DFHMSD TYPE=FINAL
         END
/*
