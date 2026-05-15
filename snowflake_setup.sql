-- =============================================================
-- SNOWFLAKE SETUP: Sample BFSI Data for Lakehouse Pipeline
-- Run this in your Snowflake trial worksheet
-- =============================================================

-- 1. Create database and schema
CREATE DATABASE IF NOT EXISTS BFSI_SOURCE;
USE DATABASE BFSI_SOURCE;
CREATE SCHEMA IF NOT EXISTS RAW;
USE SCHEMA RAW;

-- 2. Create warehouse (if not already exists)
CREATE WAREHOUSE IF NOT EXISTS BFSI_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE BFSI_WH;

-- 3. Customers table
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id       VARCHAR(20),
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    email             VARCHAR(100),
    phone             VARCHAR(20),
    date_of_birth     DATE,
    account_open_date DATE,
    kyc_status        VARCHAR(20),
    risk_category     VARCHAR(20),
    country           VARCHAR(50),
    city              VARCHAR(50),
    created_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 4. Accounts table
CREATE OR REPLACE TABLE ACCOUNTS (
    account_id        VARCHAR(20),
    customer_id       VARCHAR(20),
    account_type      VARCHAR(30),
    currency          VARCHAR(3),
    balance           DECIMAL(15,2),
    interest_rate     DECIMAL(5,4),
    status            VARCHAR(20),
    opened_date       DATE,
    last_activity_date DATE,
    branch_code       VARCHAR(10),
    created_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 5. Transactions table
CREATE OR REPLACE TABLE TRANSACTIONS (
    transaction_id    VARCHAR(30),
    account_id        VARCHAR(20),
    transaction_date  TIMESTAMP_NTZ,
    amount            DECIMAL(15,2),
    transaction_type  VARCHAR(20),
    category          VARCHAR(30),
    merchant_name     VARCHAR(100),
    channel           VARCHAR(20),
    status            VARCHAR(20),
    reference_number  VARCHAR(50),
    created_at        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- =============================================================
-- 6. INSERT SAMPLE DATA
-- =============================================================

-- Customers (20 records)
INSERT INTO CUSTOMERS (customer_id, first_name, last_name, email, phone, date_of_birth, account_open_date, kyc_status, risk_category, country, city) VALUES
('CUST001', 'Rajesh', 'Kumar', 'rajesh.kumar@email.com', '+91-9876543210', '1985-03-15', '2020-01-10', 'VERIFIED', 'LOW', 'India', 'Mumbai'),
('CUST002', 'Priya', 'Sharma', 'priya.sharma@email.com', '+91-9876543211', '1990-07-22', '2020-03-15', 'VERIFIED', 'LOW', 'India', 'Delhi'),
('CUST003', 'Amit', 'Patel', 'amit.patel@email.com', '+91-9876543212', '1988-11-08', '2019-06-20', 'VERIFIED', 'MEDIUM', 'India', 'Ahmedabad'),
('CUST004', 'Sneha', 'Reddy', 'sneha.reddy@email.com', '+91-9876543213', '1992-01-30', '2021-02-14', 'VERIFIED', 'LOW', 'India', 'Hyderabad'),
('CUST005', 'Vikram', 'Singh', 'vikram.singh@email.com', '+91-9876543214', '1983-05-12', '2018-09-01', 'VERIFIED', 'HIGH', 'India', 'Bangalore'),
('CUST006', 'Ananya', 'Iyer', 'ananya.iyer@email.com', '+91-9876543215', '1995-09-18', '2022-01-05', 'PENDING', 'LOW', 'India', 'Chennai'),
('CUST007', 'Rohit', 'Gupta', 'rohit.gupta@email.com', '+91-9876543216', '1987-12-25', '2019-11-20', 'VERIFIED', 'MEDIUM', 'India', 'Pune'),
('CUST008', 'Kavita', 'Joshi', 'kavita.joshi@email.com', '+91-9876543217', '1991-04-03', '2020-08-10', 'VERIFIED', 'LOW', 'India', 'Jaipur'),
('CUST009', 'Suresh', 'Nair', 'suresh.nair@email.com', '+91-9876543218', '1980-08-14', '2017-03-25', 'VERIFIED', 'HIGH', 'India', 'Kochi'),
('CUST010', 'Deepa', 'Menon', 'deepa.menon@email.com', '+91-9876543219', '1993-06-07', '2021-07-18', 'VERIFIED', 'LOW', 'India', 'Trivandrum'),
('CUST011', 'Arjun', 'Das', 'arjun.das@email.com', '+91-9876543220', '1986-02-28', '2019-04-12', 'VERIFIED', 'MEDIUM', 'India', 'Kolkata'),
('CUST012', 'Meera', 'Bhat', 'meera.bhat@email.com', '+91-9876543221', '1994-10-10', '2022-06-01', 'PENDING', 'LOW', 'India', 'Mangalore'),
('CUST013', 'Karthik', 'Rao', 'karthik.rao@email.com', '+91-9876543222', '1982-07-19', '2018-01-15', 'VERIFIED', 'HIGH', 'India', 'Mysore'),
('CUST014', 'Pooja', 'Mishra', 'pooja.mishra@email.com', '+91-9876543223', '1989-03-21', '2020-05-30', 'VERIFIED', 'LOW', 'India', 'Lucknow'),
('CUST015', 'Naveen', 'Verma', 'naveen.verma@email.com', '+91-9876543224', '1984-11-15', '2019-08-08', 'VERIFIED', 'MEDIUM', 'India', 'Chandigarh'),
('CUST016', 'Shalini', 'Kapoor', 'shalini.kapoor@email.com', '+91-9876543225', '1996-01-25', '2023-01-10', 'VERIFIED', 'LOW', 'India', 'Noida'),
('CUST017', 'Manoj', 'Tiwari', 'manoj.tiwari@email.com', '+91-9876543226', '1981-06-30', '2017-12-05', 'VERIFIED', 'HIGH', 'India', 'Varanasi'),
('CUST018', 'Ritu', 'Agarwal', 'ritu.agarwal@email.com', '+91-9876543227', '1990-12-12', '2021-03-22', 'VERIFIED', 'LOW', 'India', 'Indore'),
('CUST019', 'Sanjay', 'Deshpande', 'sanjay.deshpande@email.com', '+91-9876543228', '1978-04-08', '2016-10-15', 'VERIFIED', 'MEDIUM', 'India', 'Nagpur'),
('CUST020', 'Lakshmi', 'Pillai', 'lakshmi.pillai@email.com', '+91-9876543229', '1997-08-20', '2023-05-01', 'PENDING', 'LOW', 'India', 'Thiruvananthapuram');

-- Accounts (25 records — some customers have multiple accounts)
INSERT INTO ACCOUNTS (account_id, customer_id, account_type, currency, balance, interest_rate, status, opened_date, last_activity_date, branch_code) VALUES
('ACC001', 'CUST001', 'SAVINGS', 'INR', 125000.50, 0.0400, 'ACTIVE', '2020-01-10', '2024-12-01', 'MUM001'),
('ACC002', 'CUST001', 'CURRENT', 'INR', 450000.00, 0.0000, 'ACTIVE', '2020-06-15', '2024-11-28', 'MUM001'),
('ACC003', 'CUST002', 'SAVINGS', 'INR', 87500.75, 0.0400, 'ACTIVE', '2020-03-15', '2024-12-02', 'DEL001'),
('ACC004', 'CUST003', 'SAVINGS', 'INR', 235000.00, 0.0350, 'ACTIVE', '2019-06-20', '2024-11-30', 'AHM001'),
('ACC005', 'CUST003', 'FD', 'INR', 500000.00, 0.0725, 'ACTIVE', '2023-01-01', '2024-01-01', 'AHM001'),
('ACC006', 'CUST004', 'SAVINGS', 'INR', 56000.25, 0.0400, 'ACTIVE', '2021-02-14', '2024-12-01', 'HYD001'),
('ACC007', 'CUST005', 'SAVINGS', 'INR', 890000.00, 0.0350, 'ACTIVE', '2018-09-01', '2024-11-29', 'BLR001'),
('ACC008', 'CUST005', 'CURRENT', 'INR', 1250000.00, 0.0000, 'ACTIVE', '2019-01-15', '2024-12-02', 'BLR001'),
('ACC009', 'CUST006', 'SAVINGS', 'INR', 15000.00, 0.0400, 'ACTIVE', '2022-01-05', '2024-10-15', 'CHN001'),
('ACC010', 'CUST007', 'SAVINGS', 'INR', 345000.50, 0.0375, 'ACTIVE', '2019-11-20', '2024-12-01', 'PUN001'),
('ACC011', 'CUST008', 'SAVINGS', 'INR', 67800.00, 0.0400, 'ACTIVE', '2020-08-10', '2024-11-25', 'JAI001'),
('ACC012', 'CUST009', 'SAVINGS', 'INR', 1500000.00, 0.0350, 'ACTIVE', '2017-03-25', '2024-12-02', 'KOC001'),
('ACC013', 'CUST009', 'FD', 'INR', 2000000.00, 0.0750, 'ACTIVE', '2022-06-01', '2024-06-01', 'KOC001'),
('ACC014', 'CUST010', 'SAVINGS', 'INR', 42000.75, 0.0400, 'ACTIVE', '2021-07-18', '2024-11-30', 'TVM001'),
('ACC015', 'CUST011', 'SAVINGS', 'INR', 178000.00, 0.0375, 'ACTIVE', '2019-04-12', '2024-12-01', 'KOL001'),
('ACC016', 'CUST012', 'SAVINGS', 'INR', 23000.00, 0.0400, 'DORMANT', '2022-06-01', '2023-08-15', 'MNG001'),
('ACC017', 'CUST013', 'SAVINGS', 'INR', 567000.00, 0.0350, 'ACTIVE', '2018-01-15', '2024-12-02', 'MYS001'),
('ACC018', 'CUST014', 'SAVINGS', 'INR', 98000.50, 0.0400, 'ACTIVE', '2020-05-30', '2024-11-28', 'LKN001'),
('ACC019', 'CUST015', 'CURRENT', 'INR', 780000.00, 0.0000, 'ACTIVE', '2019-08-08', '2024-12-01', 'CHD001'),
('ACC020', 'CUST016', 'SAVINGS', 'INR', 34500.00, 0.0400, 'ACTIVE', '2023-01-10', '2024-11-20', 'NOI001'),
('ACC021', 'CUST017', 'SAVINGS', 'INR', 2100000.00, 0.0350, 'ACTIVE', '2017-12-05', '2024-12-02', 'VAR001'),
('ACC022', 'CUST018', 'SAVINGS', 'INR', 55000.25, 0.0400, 'ACTIVE', '2021-03-22', '2024-11-15', 'IND001'),
('ACC023', 'CUST019', 'SAVINGS', 'INR', 445000.00, 0.0375, 'ACTIVE', '2016-10-15', '2024-12-01', 'NAG001'),
('ACC024', 'CUST019', 'FD', 'INR', 1000000.00, 0.0700, 'ACTIVE', '2023-10-15', '2024-10-15', 'NAG001'),
('ACC025', 'CUST020', 'SAVINGS', 'INR', 18500.00, 0.0400, 'ACTIVE', '2023-05-01', '2024-09-30', 'TVM002');

-- Transactions (50 records)
INSERT INTO TRANSACTIONS (transaction_id, account_id, transaction_date, amount, transaction_type, category, merchant_name, channel, status, reference_number) VALUES
('TXN20241201001', 'ACC001', '2024-12-01 09:15:00', 5000.00, 'DEBIT', 'GROCERIES', 'BigBasket', 'UPI', 'COMPLETED', 'UPI241201001'),
('TXN20241201002', 'ACC001', '2024-12-01 11:30:00', 25000.00, 'CREDIT', 'SALARY', 'Employer Corp', 'NEFT', 'COMPLETED', 'NEFT241201001'),
('TXN20241201003', 'ACC003', '2024-12-01 10:00:00', 1500.00, 'DEBIT', 'FOOD', 'Zomato', 'UPI', 'COMPLETED', 'UPI241201002'),
('TXN20241201004', 'ACC004', '2024-12-01 14:20:00', 12000.00, 'DEBIT', 'SHOPPING', 'Amazon India', 'CARD', 'COMPLETED', 'CARD241201001'),
('TXN20241201005', 'ACC007', '2024-12-01 08:45:00', 3500.00, 'DEBIT', 'FUEL', 'HP Petrol', 'CARD', 'COMPLETED', 'CARD241201002'),
('TXN20241201006', 'ACC002', '2024-12-01 16:00:00', 50000.00, 'DEBIT', 'TRANSFER', 'Self Transfer', 'IMPS', 'COMPLETED', 'IMPS241201001'),
('TXN20241201007', 'ACC008', '2024-12-01 12:10:00', 8500.00, 'DEBIT', 'UTILITIES', 'Electricity Board', 'NACH', 'COMPLETED', 'NACH241201001'),
('TXN20241201008', 'ACC010', '2024-12-01 09:30:00', 2200.00, 'DEBIT', 'FOOD', 'Swiggy', 'UPI', 'COMPLETED', 'UPI241201003'),
('TXN20241201009', 'ACC012', '2024-12-01 15:45:00', 100000.00, 'CREDIT', 'INVESTMENT', 'MF Returns', 'NEFT', 'COMPLETED', 'NEFT241201002'),
('TXN20241201010', 'ACC015', '2024-12-01 11:00:00', 4500.00, 'DEBIT', 'ENTERTAINMENT', 'Netflix', 'CARD', 'COMPLETED', 'CARD241201003'),
('TXN20241202001', 'ACC001', '2024-12-02 08:00:00', 750.00, 'DEBIT', 'FOOD', 'Starbucks', 'UPI', 'COMPLETED', 'UPI241202001'),
('TXN20241202002', 'ACC003', '2024-12-02 10:30:00', 35000.00, 'DEBIT', 'SHOPPING', 'Flipkart', 'CARD', 'COMPLETED', 'CARD241202001'),
('TXN20241202003', 'ACC006', '2024-12-02 09:15:00', 2000.00, 'DEBIT', 'GROCERIES', 'DMart', 'UPI', 'COMPLETED', 'UPI241202002'),
('TXN20241202004', 'ACC007', '2024-12-02 13:00:00', 15000.00, 'CREDIT', 'REFUND', 'Amazon India', 'NEFT', 'COMPLETED', 'NEFT241202001'),
('TXN20241202005', 'ACC009', '2024-12-02 14:30:00', 500.00, 'DEBIT', 'FOOD', 'McDonalds', 'UPI', 'COMPLETED', 'UPI241202003'),
('TXN20241202006', 'ACC011', '2024-12-02 11:45:00', 6700.00, 'DEBIT', 'HEALTHCARE', 'Apollo Pharmacy', 'CARD', 'COMPLETED', 'CARD241202002'),
('TXN20241202007', 'ACC014', '2024-12-02 16:20:00', 1800.00, 'DEBIT', 'TRANSPORT', 'Uber', 'UPI', 'COMPLETED', 'UPI241202004'),
('TXN20241202008', 'ACC017', '2024-12-02 10:00:00', 45000.00, 'DEBIT', 'INSURANCE', 'LIC Premium', 'NACH', 'COMPLETED', 'NACH241202001'),
('TXN20241202009', 'ACC019', '2024-12-02 12:30:00', 25000.00, 'CREDIT', 'BUSINESS', 'Client Payment', 'RTGS', 'COMPLETED', 'RTGS241202001'),
('TXN20241202010', 'ACC021', '2024-12-02 15:00:00', 75000.00, 'DEBIT', 'INVESTMENT', 'MF SIP', 'NACH', 'COMPLETED', 'NACH241202002'),
('TXN20241203001', 'ACC001', '2024-12-03 09:00:00', 3200.00, 'DEBIT', 'SHOPPING', 'Myntra', 'UPI', 'COMPLETED', 'UPI241203001'),
('TXN20241203002', 'ACC002', '2024-12-03 10:15:00', 150000.00, 'CREDIT', 'BUSINESS', 'Invoice Payment', 'RTGS', 'COMPLETED', 'RTGS241203001'),
('TXN20241203003', 'ACC004', '2024-12-03 11:30:00', 950.00, 'DEBIT', 'FOOD', 'Dominos', 'UPI', 'COMPLETED', 'UPI241203002'),
('TXN20241203004', 'ACC005', '2024-12-03 14:00:00', 0.00, 'CREDIT', 'INTEREST', 'FD Interest', 'SYSTEM', 'COMPLETED', 'SYS241203001'),
('TXN20241203005', 'ACC008', '2024-12-03 08:30:00', 22000.00, 'DEBIT', 'RENT', 'Landlord', 'NEFT', 'COMPLETED', 'NEFT241203001'),
('TXN20241203006', 'ACC010', '2024-12-03 13:45:00', 1200.00, 'DEBIT', 'ENTERTAINMENT', 'BookMyShow', 'UPI', 'COMPLETED', 'UPI241203003'),
('TXN20241203007', 'ACC012', '2024-12-03 16:30:00', 200000.00, 'DEBIT', 'TRANSFER', 'Son Account', 'RTGS', 'COMPLETED', 'RTGS241203002'),
('TXN20241203008', 'ACC015', '2024-12-03 09:45:00', 5500.00, 'DEBIT', 'GROCERIES', 'Spencer', 'CARD', 'COMPLETED', 'CARD241203001'),
('TXN20241203009', 'ACC018', '2024-12-03 12:00:00', 18000.00, 'CREDIT', 'SALARY', 'Employer Inc', 'NEFT', 'COMPLETED', 'NEFT241203002'),
('TXN20241203010', 'ACC020', '2024-12-03 15:15:00', 800.00, 'DEBIT', 'TRANSPORT', 'Ola', 'UPI', 'COMPLETED', 'UPI241203004'),
('TXN20241204001', 'ACC001', '2024-12-04 09:30:00', 4500.00, 'DEBIT', 'UTILITIES', 'Jio Recharge', 'UPI', 'COMPLETED', 'UPI241204001'),
('TXN20241204002', 'ACC003', '2024-12-04 10:45:00', 7800.00, 'DEBIT', 'HEALTHCARE', 'Medplus', 'CARD', 'COMPLETED', 'CARD241204001'),
('TXN20241204003', 'ACC007', '2024-12-04 11:15:00', 2500.00, 'DEBIT', 'FOOD', 'Cafe Coffee Day', 'UPI', 'COMPLETED', 'UPI241204002'),
('TXN20241204004', 'ACC009', '2024-12-04 14:00:00', 1000.00, 'DEBIT', 'ENTERTAINMENT', 'Spotify', 'CARD', 'COMPLETED', 'CARD241204002'),
('TXN20241204005', 'ACC011', '2024-12-04 08:15:00', 15000.00, 'CREDIT', 'REFUND', 'Tax Refund', 'NEFT', 'COMPLETED', 'NEFT241204001'),
('TXN20241204006', 'ACC013', '2024-12-04 16:45:00', 0.00, 'CREDIT', 'INTEREST', 'FD Interest', 'SYSTEM', 'COMPLETED', 'SYS241204001'),
('TXN20241204007', 'ACC017', '2024-12-04 12:30:00', 8900.00, 'DEBIT', 'SHOPPING', 'Reliance Digital', 'CARD', 'COMPLETED', 'CARD241204003'),
('TXN20241204008', 'ACC019', '2024-12-04 09:00:00', 3500.00, 'DEBIT', 'FUEL', 'Indian Oil', 'CARD', 'COMPLETED', 'CARD241204004'),
('TXN20241204009', 'ACC021', '2024-12-04 13:15:00', 50000.00, 'CREDIT', 'BUSINESS', 'Rental Income', 'NEFT', 'COMPLETED', 'NEFT241204002'),
('TXN20241204010', 'ACC023', '2024-12-04 15:30:00', 6200.00, 'DEBIT', 'UTILITIES', 'Water Bill', 'NACH', 'COMPLETED', 'NACH241204001'),
('TXN20241205001', 'ACC001', '2024-12-05 08:45:00', 1800.00, 'DEBIT', 'TRANSPORT', 'Metro Card', 'UPI', 'COMPLETED', 'UPI241205001'),
('TXN20241205002', 'ACC004', '2024-12-05 10:00:00', 28000.00, 'DEBIT', 'INSURANCE', 'HDFC Life', 'NACH', 'COMPLETED', 'NACH241205001'),
('TXN20241205003', 'ACC006', '2024-12-05 11:30:00', 650.00, 'DEBIT', 'FOOD', 'Tea Post', 'UPI', 'COMPLETED', 'UPI241205002'),
('TXN20241205004', 'ACC008', '2024-12-05 14:15:00', 95000.00, 'CREDIT', 'SALARY', 'Employer Corp', 'NEFT', 'COMPLETED', 'NEFT241205001'),
('TXN20241205005', 'ACC010', '2024-12-05 09:30:00', 12500.00, 'DEBIT', 'SHOPPING', 'Croma', 'CARD', 'COMPLETED', 'CARD241205001'),
('TXN20241205006', 'ACC014', '2024-12-05 16:00:00', 3000.00, 'DEBIT', 'GROCERIES', 'More Supermarket', 'UPI', 'COMPLETED', 'UPI241205003'),
('TXN20241205007', 'ACC016', '2024-12-05 12:45:00', 500.00, 'DEBIT', 'FOOD', 'Street Food', 'UPI', 'FAILED', 'UPI241205004'),
('TXN20241205008', 'ACC020', '2024-12-05 10:30:00', 2200.00, 'DEBIT', 'ENTERTAINMENT', 'PVR Cinemas', 'UPI', 'COMPLETED', 'UPI241205005'),
('TXN20241205009', 'ACC022', '2024-12-05 13:00:00', 7500.00, 'DEBIT', 'HEALTHCARE', 'Fortis Hospital', 'CARD', 'COMPLETED', 'CARD241205002'),
('TXN20241205010', 'ACC025', '2024-12-05 15:45:00', 1500.00, 'DEBIT', 'TRANSPORT', 'Rapido', 'UPI', 'COMPLETED', 'UPI241205006');

-- =============================================================
-- 7. VERIFY DATA
-- =============================================================
SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM CUSTOMERS
UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS;
