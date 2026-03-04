"""zBANK business logic — translated from COBOL/CICS/VSAM to Python.

Original: Nantero1/zBANK (GitHub) — 140 LOC COBOL with CICS screens and VSAM file I/O.
This module extracts the pure business logic, stripping away CICS screen handling,
BMS map sends/receives, and VSAM file operations.

Bugs fixed during translation:
  1. Deposit accepted amount=0 (no validation in original)
  2. Withdraw allowed overdraft — no balance check (SUBTRACT without IF)
  3. Withdraw accepted amount=0
"""

from dataclasses import dataclass, field
from typing import Optional, List, Dict


@dataclass
class Account:
    accno: int
    pin: int
    balance: int
    holder: str
    authenticated: bool = False


class BankError(Exception):
    pass


class AuthenticationError(BankError):
    pass


class InsufficientFundsError(BankError):
    pass


class InvalidAmountError(BankError):
    pass


class AccountNotFoundError(BankError):
    pass


@dataclass
class Transaction:
    type: str  # "deposit" | "withdraw"
    amount: int
    balance_after: int


class ZBank:
    """In-memory bank matching the original COBOL VSAM structure.

    Original COBOL data layout:
        01 WS-FILE-REC.
          05 WS-ACCNO   PIC 9(10).
          05 WS-PIN     PIC 9(10).
          05 WS-BALANCE PIC 9(10).
    """

    def __init__(self):
        self._accounts: Dict[str, Account] = {}
        self._transactions: Dict[str, List[Transaction]] = {}

    def add_account(self, accno: int, pin: int, balance: int, holder: str):
        key = str(accno)
        self._accounts[key] = Account(accno=accno, pin=pin, balance=balance, holder=holder)
        self._transactions[key] = []

    def get_account(self, accno: str) -> Account:
        if accno not in self._accounts:
            raise AccountNotFoundError("Account not found")
        return self._accounts[accno]

    def login(self, accno: str, pin: int) -> Account:
        """Authenticate by account number + PIN.

        Original COBOL (lines 40-56):
            EXEC CICS READ DATASET(WS-FILE-NAME) INTO(WS-FILE-REC) RIDFLD(WS-ACCNO) ...
            IF PIN = WS-PIN
              MOVE 1 TO SCREEN-STATE
              MOVE WS-BALANCE TO BALANCE
        """
        account = self.get_account(accno)

        if pin != account.pin:
            raise AuthenticationError("Wrong PIN")

        account.authenticated = True
        return account

    def deposit(self, accno: str, amount: int) -> int:
        """Add funds to account. Returns new balance.

        Original COBOL (lines 88-99):
            ADD AMOUNT TO WS-BALANCE
            EXEC CICS REWRITE DATASET(WS-FILE-NAME) FROM(WS-FILE-REC) ...

        BUG FIXED: original accepts amount=0, no validation.
        """
        account = self.get_account(accno)
        if not account.authenticated:
            raise AuthenticationError("Not logged in")

        if amount <= 0:
            raise InvalidAmountError("Amount must be greater than 0")

        account.balance += amount

        self._transactions[accno].append(
            Transaction(type="deposit", amount=amount, balance_after=account.balance)
        )
        return account.balance

    def withdraw(self, accno: str, amount: int) -> int:
        """Remove funds from account. Returns new balance.

        Original COBOL (lines 101-111):
            SUBTRACT AMOUNT FROM WS-BALANCE
            EXEC CICS REWRITE DATASET(WS-FILE-NAME) FROM(WS-FILE-REC) ...

        BUGS FIXED:
          - Original has NO overdraft check (SUBTRACT without IF)
          - Original accepts amount=0
        """
        account = self.get_account(accno)
        if not account.authenticated:
            raise AuthenticationError("Not logged in")

        if amount <= 0:
            raise InvalidAmountError("Amount must be greater than 0")

        if account.balance < amount:
            raise InsufficientFundsError("Insufficient funds")

        account.balance -= amount

        self._transactions[accno].append(
            Transaction(type="withdraw", amount=amount, balance_after=account.balance)
        )
        return account.balance

    def get_balance(self, accno: str) -> int:
        account = self.get_account(accno)
        if not account.authenticated:
            raise AuthenticationError("Not logged in")
        return account.balance

    def get_transactions(self, accno: str, limit: int = 10) -> List[Transaction]:
        if accno not in self._transactions:
            return []
        return self._transactions[accno][-limit:]

    def logout(self, accno: str):
        if accno in self._accounts:
            self._accounts[accno].authenticated = False
