# Banking Performance & Customer Insights Dashboard  
**Industry:** Retail & Corporate Banking  
**Audience:** Executives, Branch Managers, Customer Relationship Managers  
**Goal:** Provide clear visibility into bank performance metrics and customer behavior insights using Power BI.  

---

## 1. Dashboard Objectives  

**Primary Goals**  
1. **Performance & Growth:** Monitor deposits, loans, cards, and product mix across branches and cities.  
2. **Customer Health:** Track engagement, inactivity risk, and satisfaction.  
3. **Operational Efficiency:** Monitor SLAs, complaint resolution, and branch productivity.  
4. **Risk & Compliance:** Highlight anomalies, loan performance, and early warnings.  
5. **Actionability:** Provide drill-down navigation and guided narratives.  

---

## 2. Data Model  

**Star Schema Design**  

**Dimensions:**  
- `DimCustomer`: Customer demographics (`Customer ID`, `Age`, `Gender`, `City`)  
- `DimAccount`: Account attributes (`Account Type`, `Date Of Account Opening`, `Branch ID`)  
- `DimLoan`: (`Loan ID`, `Loan Type`, `Loan Term`)  
- `DimCard`: (`CardID`, `Card Type`)  
- `DimBranch`: (`Branch ID`)  
- `DimDate`: Unified calendar  

**Facts:**  
- `FactTransactions`: (`TransactionID`, `Transaction Date`, `Transaction Type`, `Transaction Amount`)  
- `FactAccountsSnapshot`: Periodic balances (`Account Balance`)  
- `FactLoans`: (`Loan ID`, `Loan Amount`, `Interest Rate`, `Loan Status`)  
- `FactCards`: (`CardID`, `Credit Limit`, `Credit Card Balance`, `Payment Due Date`)  
- `FactFeedback`: (`Feedback ID`, `Feedback Type`, `Resolution Status`, `Resolution Date`)  
- `FactRisk`: (`Anomaly` + derived scores)  

---

## 3. KPI Dictionary  

| KPI | Definition | Grain | Notes |
|---|---|---|---|
| Total Customers | Distinct count of `Customer ID` | Bank/Branch | |
| Active Customers (90d) | Customers with `Last Transaction Date ≥ Today-90` | Bank/Branch | |
| New Accounts | Count of accounts opened in period | Bank/Branch | |
| Total Deposits | Sum of `Account Balance` | Bank/Branch | |
| Total Loans | Sum of `Loan Amount` | Bank/Branch | |
| Loan-to-Deposit Ratio | Loans ÷ Deposits | Bank/Branch | Liquidity proxy |
| Weighted Avg Interest Rate | Loan amount weighted | Bank/Loan Type | Yield proxy |
| Transaction Volume/Value | Count & sum of txns | Bank/Branch | |
| Card Utilization % | Balance ÷ Limit | Bank/Branch | |
| Loan Approval Rate | % Approved / Applications | Bank/Branch | |
| Complaint Rate | % Complaints in Feedback | Bank/Branch | CX health |
| NPS Proxy | (% Praise – % Complaints) | Bank/Branch | Proxy metric |
| Avg Resolution Time | Days to resolve feedback | Bank/Branch | SLA |
| Churn Risk % | Inactive ≥180d | Bank/Branch | Retention |
| Anomaly Rate % | Customers flagged as anomaly | Bank/Branch | Risk |

---

## 4. 20-Page Dashboard Layout  

1. Executive Overview  
2. Customer 360 Overview  
3. Customer Profile (Drill-through)  
4. Acquisition & Onboarding  
5. Deposit Accounts  
6. Transactions – Volume & Value  
7. RFM & Engagement  
8. Loan Portfolio Overview  
9. Loan Risk & Early Warnings  
10. Credit Cards – Portfolio  
11. Branch Performance  
12. Geography & City Insights  
13. Cross-Sell Opportunities  
14. Churn & Retention  
15. Feedback & NPS Proxy  
16. Ops & SLA Monitoring  
17. Fraud & Anomaly Watch  
18. Revenue & Profitability (Placeholder)  
19. Data Quality & Coverage  
20. Glossary & Help  

---

## 5. Navigation & Usability  

- **Global slicers:** Date, Branch ID, City, Account Type, Loan Type, Card Type, Gender  
- **Drill hierarchy:** Bank → Branch → City → Customer → Transaction  
- **Drill-through pages:** Customer Profile, Branch Detail  
- **Bookmarks:** Executive Monthly, Risk Watch, Growth Focus  

---

## 6. Core DAX Measures  

```DAX
-- Customers
Total Customers = DISTINCTCOUNT(Customers[Customer ID])
Active Customers (90d) =
VAR Cutoff = MAX('Date'[Date]) - 90
RETURN CALCULATE(DISTINCTCOUNT(Customers[Customer ID]), Customers[Last Transaction Date] >= Cutoff)

-- Deposits & Loans
Total Deposits = SUM(Accounts[Account Balance])
Total Loans = SUM(Loans[Loan Amount])
Loan-to-Deposit Ratio = DIVIDE([Total Loans], [Total Deposits])
Weighted Avg Interest Rate =
DIVIDE(SUMX(Loans, Loans[Loan Amount] * Loans[Interest Rate]), [Total Loans])

-- Transactions
Txn Count = COUNTROWS(Transactions)
Txn Amount = SUM(Transactions[Transaction Amount])

-- Cards
Card Utilization % =
DIVIDE(SUM(Cards[Credit Card Balance]), SUM(Cards[Credit Limit]))

-- Loans Process
Approval Rate % =
DIVIDE(CALCULATE(COUNTROWS(Loans), Loans[Loan Status] = "Approved"), COUNTROWS(Loans))

-- CX & Ops
Complaint Rate % =
DIVIDE(CALCULATE(COUNTROWS(Feedback), Feedback[Feedback Type] = "Complaint"), COUNTROWS(Feedback))
NPS Proxy % =
DIVIDE([Praise], [Total Feedback]) - DIVIDE([Complaints], [Total Feedback])
Avg Time to Resolution =
AVERAGEX(FILTER(Feedback, NOT ISBLANK(Feedback[Resolution Date])),
DATEDIFF(Feedback[Feedback Date], Feedback[Resolution Date], DAY))
```

---

## 7. Advanced Analytics Opportunities  

- **Churn prediction** using RFM + feedback + balances  
- **Cross-sell models** for Next Best Product  
- **Fraud detection** using anomalies and txn velocity  
- **Loan risk early warning** using status + inactivity  
- **CX NLP** if comments are added later  

---

## 8. Storytelling Principles  

- **Headline metrics:** highlight deltas MoM/YoY  
- **Comparative context:** rank branches, show variance vs targets  
- **Guided questions:** "Where did approvals drop?", "Who is at churn risk?"  
- **Action tiles:** “Download Save List”, “Email Branch Manager”  

---

## 9. Data Preparation & Governance  

1. Parse dates, set numeric types  
2. Split wide table into fact/dim queries  
3. Set relationships & inactive role-playing dates  
4. Add branch-level RLS  
5. Incremental refresh for large txn tables  
6. Disable auto date/time  
7. Add glossary & tooltips  

---

## 10. Thresholds & Alerts  

- **LDR > 90%** → amber, >100% → red  
- **Approval Rate < 70%** → alert  
- **Complaint Rate > 10%** → amber, >20% → red  
- **Resolution > 5 days** → amber, >10 days → red  
- **Card Utilization > 80%** → risk  
- **Inactive Customers > 25%** → save-campaign  

---

## 11. Deliverables  

- 20-page Power BI .pbix  
- DAX measure library  
- ERD of star schema  
- Glossary page  
- Refresh runbook  

---

# ✅ Next Steps  

1. Build star schema in Power BI (split CSV into facts/dims).  
2. Create core DAX measures.  
3. Lay out first 5 pages (Exec, Customer 360, Transactions, Loans, Branch).  
4. Add drill-through Customer Profile.  
5. Wire placeholders for profitability and digital adoption.  

---
