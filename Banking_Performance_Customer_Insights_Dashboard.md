# Banking Performance & Customer Insights Dashboard Blueprint

## Context
**Industry**: Retail & Corporate Banking  
**Goal**: Provide executives and managers with clear visibility into bank performance metrics and customer behavior insights  
**Audience**: Non-technical stakeholders (executives, branch managers, customer relationship managers)

---

## 1. Dashboard Objectives
1. **Performance & Growth** – Track deposits, loans, card utilization, and product mix by branch/city/customer segment.  
2. **Customer Health** – Monitor activity, recency, retention risk, and feedback quality (NPS proxy).  
3. **Operational Excellence** – Watch SLA/time-to-resolution, complaint rates, and branch productivity.  
4. **Risk & Compliance** – Flag anomalies, loan status trends, and early warning signals.  
5. **Actionability** – Provide drill-downs from bank → branch → customer → transaction.

---

## 2. Data Model (Star Schema)
### Dimensions
- **DimCustomer**: Customer demographics (`Customer ID`, `Age`, `Gender`, `City`)
- **DimAccount**: Account details (`Account Type`, `Date Of Account Opening`, `Branch ID`)
- **DimLoan**: Loan info (`Loan ID`, `Loan Type`, `Loan Term`)
- **DimCard**: Credit card details (`CardID`, `Card Type`)
- **DimBranch**: Branch metadata (`Branch ID`, Branch Name, Region)  
- **DimDate**: Master calendar

### Facts
- **FactTransactions**: (`TransactionID`, `Transaction Date`, `Transaction Amount`, `Type`)  
- **FactLoans**: (`Loan ID`, `Customer ID`, `Loan Amount`, `Interest Rate`, `Loan Status`)  
- **FactCards**: (`CardID`, `Credit Limit`, `Card Balance`, `Minimum Payment Due`)  
- **FactFeedback**: (`Feedback Type`, `Resolution Status`, `Resolution Date`)  
- **FactRisk**: (`Customer ID`, `Anomaly`)  
- **FactAccountsSnapshot**: Account balances snapshot

---

## 3. KPI Dictionary
| KPI | Definition | Grain | Notes |
|---|---|---|---|
| **Total Customers** | Distinct customers | Bank/Branch | Reach |
| **Active Customers (90d)** | Last txn within 90d | Bank/Branch | Engagement |
| **New Accounts** | Accounts opened | Bank/Branch | Acquisition |
| **Total Deposits** | SUM(Account Balance) | Bank/Branch | Liquidity |
| **Total Loans** | SUM(Loan Amount) | Bank/Loan Type | Loan book |
| **Loan-to-Deposit Ratio** | Loans / Deposits | Bank/Branch | Liquidity signal |
| **Approval Rate (Loans)** | % Approved loans | Bank/Branch | Underwriting |
| **Card Utilization** | Balances / Limits | Bank/Branch | Credit risk |
| **Complaint Rate** | Complaints / Total feedback | Branch | CX risk |
| **NPS Proxy** | (Praise - Complaint) / Total | Branch | Satisfaction |
| **Churn Risk** | % inactive ≥180d | Branch | Retention |
| **Anomaly Rate** | % flagged anomalies | Branch | Fraud risk |

---

## 4. 20-Page Layout (Navigation)
1. Executive Overview  
2. Customer 360 Overview  
3. Customer Profile (Drill-through)  
4. Acquisition & Onboarding  
5. Deposit Accounts  
6. Transactions (Vol & Value)  
7. RFM & Engagement  
8. Loan Portfolio Overview  
9. Loan Risk & Early Warnings  
10. Credit Cards – Portfolio  
11. Branch Performance  
12. City/Geography Insights  
13. Cross-Sell Opportunities  
14. Churn & Retention  
15. Feedback & NPS Proxy  
16. Ops & SLA Monitoring  
17. Fraud & Anomaly Watch  
18. Revenue & Profitability (Placeholder)  
19. Data Quality & Coverage  
20. Glossary & Help Page  

---

## 5. DAX Measures (Examples)
```DAX
Total Customers = DISTINCTCOUNT(Customers[Customer ID])

Active Customers (90d) =
VAR Cutoff = MAX('DimDate'[Date]) - 90
RETURN CALCULATE(DISTINCTCOUNT(Customers[Customer ID]), Customers[Last Transaction Date] >= Cutoff)

Total Deposits = SUM(FactAccountsSnapshot[Account Balance])
Total Loans = SUM(FactLoans[Loan Amount])
Loan-to-Deposit Ratio = DIVIDE([Total Loans], [Total Deposits])

Approval Rate % = DIVIDE(
    CALCULATE(COUNTROWS(FactLoans), FactLoans[Loan Status] = "Approved"),
    COUNTROWS(FactLoans)
)

Card Utilization % =
DIVIDE(SUM(FactCards[Credit Card Balance]), SUM(FactCards[Credit Limit]))

Complaint Rate % =
DIVIDE(
    CALCULATE(COUNTROWS(FactFeedback), FactFeedback[Feedback Type] = "Complaint"),
    COUNTROWS(FactFeedback)
)
```

---

## 6. Advanced Analytics Opportunities
- **Churn prediction** – Based on recency, frequency, monetary value, complaints, utilization.  
- **Cross-sell modeling** – Predict next best product (loan, card, savings).  
- **Fraud detection** – Leverage anomaly field + transaction velocity.  
- **Loan risk** – Predict closure/rejection.  
- **CX insights** – Text mining on feedback for themes.

---

## 7. Storytelling & Usability
- Headline metrics with contextual deltas (“Deposits up 3%, Complaints rising in Tucson”).  
- Guided bookmarks (Exec Monthly, Risk Watch, Growth Focus).  
- Call-to-action tiles (download customer list, escalate complaint, contact branch).  
- Consistent slicers: Date, Branch, City, Account Type, Loan Type, Gender.

---

## 8. Data Preparation & Governance
- **Split CSV into star schema** (Power Query script provided).  
- **Role-playing dates** with `USERELATIONSHIP`.  
- **RLS** by branch.  
- **Incremental refresh** for FactTransactions.  
- **Data quality dashboard** (null %, anomalies, refresh time).

---

## 9. Deliverables
- **20-page PBIX layout**  
- **DAX measures library**  
- **Power Query M script** for star schema  
- **README & Glossary** for KPI definitions  
- **Bookmark set** (Exec / Risk / Growth)  

---

## Next Steps
1. Load dataset into Power BI.  
2. Apply provided Power Query M script to split into dims/facts.  
3. Paste in DAX measures.  
4. Build pages 1–5 first (Exec, Customer 360, Transactions, Loans, Branch).  
5. Expand with churn, CX, anomaly insights.  
6. Connect GL & digital data later for profitability & adoption metrics.
