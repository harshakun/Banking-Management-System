-- Creating the Database
CREATE DATABASE BANK_MANAGEMENT_SYSTEM;
DROP DATABASE BANK_MANAGEMENT_SYSTEM;

-- Creating Account Opening Form Table
CREATE TABLE Account_Opening_Form (
    ID INT IDENTITY PRIMARY KEY,
    Account_Type VARCHAR(20) DEFAULT 'SAVINGS',
    Account_Holder_Name VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL,
    Aadhar_Number VARCHAR(12) UNIQUE NOT NULL,
    Mobile_Number VARCHAR(15) NOT NULL,
    Account_Opening_Balance DECIMAL(10,2) CHECK (Account_Opening_Balance >= 1000),
    Address VARCHAR(100) NOT NULL,
    KYC_Status VARCHAR(10) DEFAULT 'PENDING',
    Date_Opened DATETIME DEFAULT GETDATE()
);

-- Creating Bank Table
CREATE TABLE Bank (
    Account_Number BIGINT IDENTITY PRIMARY KEY,
    Account_Type VARCHAR(20),
    Account_Opening_Date DATETIME DEFAULT GETDATE(),
    Current_Balance DECIMAL(10,2)
);

-- Creating Account Holder Details Table
CREATE TABLE Account_Holder_Details (
    Account_Number BIGINT PRIMARY KEY,
    Account_Holder_Name VARCHAR(50),
    DOB DATE,
    Aadhar_Number VARCHAR(12) UNIQUE,
    Mobile_Number VARCHAR(15),
    FOREIGN KEY (Account_Number) REFERENCES Bank(Account_Number)
);

-- Creating Transaction Details Table
CREATE TABLE Transaction_Details (
    Transaction_ID INT IDENTITY PRIMARY KEY,
    Account_Number BIGINT,
    Payment_Type VARCHAR(10) CHECK (Payment_Type IN ('CREDIT', 'DEBIT')),
    Transaction_Amount DECIMAL(10,2),
    Date_of_Transaction DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (Account_Number) REFERENCES Bank(Account_Number)
);

-- Trigger for Account Creation after KYC Approval
CREATE TRIGGER TR_Insert_Into_Bank
ON Account_Opening_Form
AFTER UPDATE
AS
BEGIN
    DECLARE @Status VARCHAR(20), @AccountType VARCHAR(20), @AccountHolderName VARCHAR(50), 
            @DOB DATE, @AadharNumber VARCHAR(12), @MobileNumber VARCHAR(15), 
            @AccountOpeningBalance DECIMAL(10,2);
    
    SELECT @Status = KYC_Status, @AccountType = Account_Type, @AccountHolderName = Account_Holder_Name,
           @DOB = DOB, @AadharNumber = Aadhar_Number, @MobileNumber = Mobile_Number, 
           @AccountOpeningBalance = Account_Opening_Balance
    FROM inserted;
    
    IF @Status = 'Approved'
    BEGIN
        INSERT INTO Bank (Account_Type, Current_Balance) 
        VALUES (@AccountType, @AccountOpeningBalance);
        
        DECLARE @NewAccountNumber BIGINT = SCOPE_IDENTITY();
        
        INSERT INTO Account_Holder_Details (Account_Number, Account_Holder_Name, DOB, Aadhar_Number, Mobile_Number)
        VALUES (@NewAccountNumber, @AccountHolderName, @DOB, @AadharNumber, @MobileNumber);
    END
END;

-- Trigger for Updating Account Balance after Transactions
CREATE TRIGGER TR_Update_Current_Balance
ON Transaction_Details
AFTER INSERT
AS
BEGIN
    DECLARE @PaymentType VARCHAR(20), @Amount DECIMAL(10,2), @AccountNumber BIGINT;
    
    SELECT @PaymentType = Payment_Type, @Amount = Transaction_Amount, @AccountNumber = Account_Number
    FROM inserted;
    
    IF @PaymentType = 'CREDIT'
    BEGIN
        UPDATE Bank
        SET Current_Balance = Current_Balance + @Amount
        WHERE Account_Number = @AccountNumber;
    END
    ELSE IF @PaymentType = 'DEBIT'
    BEGIN
        UPDATE Bank
        SET Current_Balance = Current_Balance - @Amount
        WHERE Account_Number = @AccountNumber;
    END
END;

-- Stored Procedure to Open an Account
CREATE PROCEDURE Open_Account
    @Account_Type VARCHAR(20),
    @Account_Holder_Name VARCHAR(50),
    @DOB DATE,
    @Aadhar_Number VARCHAR(12),
    @Mobile_Number VARCHAR(15),
    @Account_Opening_Balance DECIMAL(10,2),
    @Address VARCHAR(100)
AS
BEGIN
    INSERT INTO Account_Opening_Form (Account_Type, Account_Holder_Name, DOB, Aadhar_Number, Mobile_Number, Account_Opening_Balance, Address)
    VALUES (@Account_Type, @Account_Holder_Name, @DOB, @Aadhar_Number, @Mobile_Number, @Account_Opening_Balance, @Address);
END;

-- Stored Procedure for Making a Transaction
CREATE PROCEDURE Make_Transaction
    @Account_Number BIGINT,
    @Payment_Type VARCHAR(10),
    @Transaction_Amount DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Transaction_Details (Account_Number, Payment_Type, Transaction_Amount)
    VALUES (@Account_Number, @Payment_Type, @Transaction_Amount);
END;

-- Stored Procedure for Viewing Payment Statements (Passbook)
CREATE PROCEDURE Payment_Statement
    @Months INT, 
    @AccountNumber BIGINT
AS
BEGIN
    SELECT * FROM Transaction_Details 
    WHERE Date_of_Transaction >= DATEADD(MONTH, -@Months, GETDATE())
    AND Account_Number = @AccountNumber;
END;

-- Stored Procedure to Get Account Details
CREATE PROCEDURE Get_Account_Details
    @Account_Number BIGINT
AS
BEGIN
    SELECT * FROM Account_Holder_Details WHERE Account_Number = @Account_Number;
END;

-- Executing Sample Procedures

-- Insert an Account Opening Request
EXEC Open_Account 'SAVINGS', 'John Doe', '1990-05-10', '123456789012', '9876543210', 5000, '123 Street Name';

-- Approve the Account (Manually Updating the KYC Status)
UPDATE Account_Opening_Form
SET KYC_Status = 'Approved'
WHERE Aadhar_Number = '123456789012';

-- Make a Credit Transaction
EXEC Make_Transaction 1, 'CREDIT', 2000;

-- Make a Debit Transaction
EXEC Make_Transaction 1, 'DEBIT', 1000;

-- View Account Details
EXEC Get_Account_Details 1;

-- Check Transaction History for the last 3 months
EXEC Payment_Statement @Months = 3, @AccountNumber = 1;
