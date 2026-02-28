#!/usr/bin/env python3
"""zBANK — COBOL banking system translated to Python.

Original: Nantero1/zBANK (GitHub)
  - COBOL/CICS/BMS/VSAM, 140 LOC
  - Mainframe terminal UI with 3 screens (login, home, register)
  - VSAM keyed file for account storage

This Python version:
  - Flask web app with modern UI
  - In-memory storage (replaces VSAM)
  - Same business logic, bugs fixed
"""

from flask import Flask, jsonify, request, send_from_directory
from pathlib import Path
from banking import ZBank, BankError, AuthenticationError, InsufficientFundsError, InvalidAmountError, AccountNotFoundError

HERE = Path(__file__).resolve().parent

app = Flask(__name__, static_folder=None)

bank = ZBank()
bank.add_account(1000000001, 1234, 15000, "Alice Johnson")
bank.add_account(1000000002, 5678, 3200, "Bob Smith")
bank.add_account(1000000003, 1111, 87450, "Carol Williams")


@app.route("/")
def index():
    return send_from_directory(str(HERE), "index.html")


@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    accno = str(data.get("accno", ""))
    pin = data.get("pin", 0)
    try:
        account = bank.login(accno, pin)
        return jsonify({
            "success": True,
            "holder": account.holder,
            "balance": account.balance,
            "accno": accno,
            "transactions": [
                {"type": t.type, "amount": t.amount, "balance": t.balance_after}
                for t in bank.get_transactions(accno)
            ]
        })
    except AuthenticationError as e:
        return jsonify({"success": False, "error": "Wrong PIN"})
    except AccountNotFoundError:
        return jsonify({"success": False, "error": "Account not found"})


@app.route("/api/deposit", methods=["POST"])
def deposit():
    data = request.json
    accno = str(data.get("accno", ""))
    amount = data.get("amount", 0)
    try:
        new_balance = bank.deposit(accno, amount)
        return jsonify({"success": True, "balance": new_balance})
    except InvalidAmountError:
        return jsonify({"success": False, "error": "Amount must be greater than 0"})
    except AuthenticationError:
        return jsonify({"success": False, "error": "Not logged in"})
    except AccountNotFoundError:
        return jsonify({"success": False, "error": "Account not found"})


@app.route("/api/withdraw", methods=["POST"])
def withdraw():
    data = request.json
    accno = str(data.get("accno", ""))
    amount = data.get("amount", 0)
    try:
        new_balance = bank.withdraw(accno, amount)
        return jsonify({"success": True, "balance": new_balance})
    except InsufficientFundsError:
        return jsonify({"success": False, "error": "Insufficient funds"})
    except InvalidAmountError:
        return jsonify({"success": False, "error": "Amount must be greater than 0"})
    except AuthenticationError:
        return jsonify({"success": False, "error": "Not logged in"})
    except AccountNotFoundError:
        return jsonify({"success": False, "error": "Account not found"})


@app.route("/api/balance", methods=["POST"])
def balance():
    data = request.json
    accno = str(data.get("accno", ""))
    try:
        acct = bank.get_account(accno)
        if not acct.authenticated:
            return jsonify({"success": False, "error": "Not logged in"})
        return jsonify({
            "success": True,
            "balance": acct.balance,
            "holder": acct.holder,
            "transactions": [
                {"type": t.type, "amount": t.amount, "balance": t.balance_after}
                for t in bank.get_transactions(accno)
            ]
        })
    except AccountNotFoundError:
        return jsonify({"success": False, "error": "Account not found"})


@app.route("/api/logout", methods=["POST"])
def logout():
    data = request.json
    accno = str(data.get("accno", ""))
    bank.logout(accno)
    return jsonify({"success": True})


if __name__ == "__main__":
    print("zBANK (Python) — http://localhost:5000")
    print("  Accounts:")
    for k in ["1000000001", "1000000002", "1000000003"]:
        a = bank.get_account(k)
        print(f"    {k} / PIN {a.pin} — {a.holder} (${a.balance:,})")
    app.run(host="0.0.0.0", port=5000, debug=False)
