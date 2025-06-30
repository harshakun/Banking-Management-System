# 🏦 Bank Management System using SQL Server (SSMS)

A mini relational database project simulating real-world banking operations. Built using **SQL Server Management Studio (SSMS)**, this system handles account creation, KYC approval, real-time transactions, balance updates, and passbook generation with the help of **stored procedures** and **triggers**.

---

## 📌 Features

-  Account creation with KYC workflow
-  Automatic account activation post-KYC via triggers
-  Credit/Debit transactions with real-time balance updates
-  Passbook generation (last N months)
-  Data integrity through relational constraints
-  Modular stored procedures for key operations

---

## 🧰 Technologies Used

- **SQL Server Management Studio (SSMS)**
- **T-SQL (DDL, DML, Triggers, Procedures)**
- **Relational Database Design**

---

## 🗃️ Database Schema Overview

### `Account_Opening_Form`
Stores account applications with personal details and KYC status.

### `Bank`
Holds core bank account data including type, date, and balance.

### `Account_Holder_Details`
Links account number to user identity and personal information.

### `Transaction_Details`
Maintains a log of all credit/debit operations.

---

## 🔁 Automation with Triggers

- `TR_Insert_Into_Bank`: Creates an account automatically after KYC approval.
- `TR_Update_Current_Balance`: Updates account balance based on transactions.

---

## 🧪 Stored Procedures

| Procedure Name       | Description                                      |
|----------------------|--------------------------------------------------|
| `Open_Account`        | Inserts a new account request                    |
| `Make_Transaction`    | Performs a credit or debit transaction           |
| `Payment_Statement`   | Retrieves N-month transaction history (passbook) |
| `Get_Account_Details` | Returns account holder's personal information    |

---

## 🚀 Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/bank-management-system.git
