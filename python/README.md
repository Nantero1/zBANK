# zBANK — Python Edition

The original zBANK COBOL/CICS banking program, translated to a modern Python web application.

## What is this?

The original [zBANK](https://github.com/Nantero1/zBANK) runs on IBM z/OS with CICS transaction processing, BMS screen maps (3270 terminals), and VSAM keyed file storage. This is the same banking logic rewritten in Python with a web UI.

| Aspect | COBOL Original | Python Version |
|--------|---------------|----------------|
| UI | BMS terminal maps (3270) | Web UI (Flask) |
| Storage | VSAM keyed file | In-memory |
| Language | COBOL + CICS | Python |
| LOC | 140 | ~160 |

## Bugs Fixed

The original COBOL has real bugs that were caught during translation:

1. **Deposit accepts amount=0** — `ADD AMOUNT TO WS-BALANCE` runs with no validation
2. **Withdraw allows overdraft** — `SUBTRACT AMOUNT FROM WS-BALANCE` with no balance check; account can go negative
3. **Withdraw accepts amount=0** — no-op that still rewrites the VSAM file

## Quick Start

```bash
pip install -r requirements.txt
python app.py
```

Open http://localhost:5000

## Demo Accounts

| Account | PIN | Name | Balance |
|---------|-----|------|---------|
| 1000000001 | 1234 | Alice Johnson | $15,000 |
| 1000000002 | 5678 | Bob Smith | $3,200 |
| 1000000003 | 1111 | Carol Williams | $87,450 |

Click any name on the login screen to auto-fill credentials.

## Screenshots

**Login**
- Enter account number + PIN, or click a demo account
- Wrong PIN is rejected

**Home**
- Balance displayed on card
- Deposit and Withdraw buttons
- Quick amount buttons ($50, $100, $500, $1k)
- Transaction history

**Overdraft Protection**
- Try withdrawing more than your balance → "Insufficient funds"
- This bug exists in the original COBOL (no balance check before SUBTRACT)

## Structure

```
├── zbank.cbl       ← original COBOL source (for reference)
├── banking.py      ← business logic (translated from COBOL)
├── app.py          ← Flask web server
├── index.html      ← web UI
├── requirements.txt
└── README.md
```

## Mapping: COBOL → Python

| COBOL (original) | Python (this version) |
|-------------------|----------------------|
| `EXEC CICS READ DATASET ... INTO(WS-FILE-REC)` | `bank.get_account(accno)` |
| `IF PIN = WS-PIN` | `if pin != account.pin: raise AuthenticationError` |
| `ADD AMOUNT TO WS-BALANCE` | `account.balance += amount` |
| `SUBTRACT AMOUNT FROM WS-BALANCE` | `account.balance -= amount` (with overdraft check) |
| `EXEC CICS REWRITE DATASET` | automatic (in-memory state) |
| BMS SEND MAP / RECEIVE MAP | Flask routes + HTML/JS |
| VSAM keyed file | Python dict |
