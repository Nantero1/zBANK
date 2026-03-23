      *--- ESC CHARACTER (ASCII 27) ---
       77 CB-ESC     PIC X(1) VALUE X"1B".
      *--- RESET / BOLD ---
       77 CB-RESET   PIC X(3) VALUE '[0m'.
       77 CB-BOLD    PIC X(3) VALUE '[1m'.
      *--- STANDARD COLORS ---
       77 CB-RED     PIC X(4) VALUE '[31m'.
       77 CB-GREEN   PIC X(4) VALUE '[32m'.
       77 CB-YELLOW  PIC X(4) VALUE '[33m'.
       77 CB-BLUE    PIC X(4) VALUE '[34m'.
       77 CB-CYAN    PIC X(4) VALUE '[36m'.
       77 CB-WHITE   PIC X(4) VALUE '[37m'.
      *--- BRIGHT COLORS ---
       77 CB-BRED    PIC X(4) VALUE '[91m'.
       77 CB-BGREEN  PIC X(4) VALUE '[92m'.
       77 CB-BYELLOW PIC X(4) VALUE '[93m'.
       77 CB-BBLUE   PIC X(4) VALUE '[94m'.
       77 CB-BCYAN   PIC X(4) VALUE '[96m'.
       77 CB-BWHITE  PIC X(4) VALUE '[97m'.
      *--- BACKGROUND ---
       77 CB-BG-BLK  PIC X(4) VALUE '[40m'.
      *--- SCREEN CONTROL ---
       77 CB-CLR     PIC X(3) VALUE '[2J'.
       77 CB-HOME-C  PIC X(2) VALUE '[H'.
      *--- SOUND ---
       77 CB-BEL     PIC X(1) VALUE X"07".
       01 CB-SND-BUF.
         49 CB-SND-CMD PIC X(120).
         49 CB-SND-NUL PIC X(1) VALUE X"00".
