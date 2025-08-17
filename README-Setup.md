# Power BI Starter Kit — Comprehensive Banking Dashboard

This pack contains:
- `power_query_star_schema.m` — builds a star schema from your **Raw** query
- `dax_measures.txt` — KPI measures ready to paste
- This README — setup & modeling guide

## How to Use

1) **Load your CSV** into Power BI and name the query **Raw**. Ensure all headers match the dataset.
2) Create a **Blank Query**, open **Advanced Editor**, and paste the content of `power_query_star_schema.m`.  
   - It returns a **record** containing all target tables. Right‑click each table value → **Convert to Table** → **Enable Load**.
3) Rename the tables:
   - `DimCustomer`, `DimAccount`, `DimLoan`, `DimCard`, `DimBranch`, `DimDate`
   - `FactTransactions`, `FactLoans`, `FactCards`, `FactFeedback`, `FactRisk`, `FactAccountsSnapshot`
4) Set **DimDate** as the *Date Table* (Model view → Table tools).
5) Create relationships (One-to-Many):
   - `DimCustomer[Customer ID]` → each Fact’s `Customer ID`
   - `DimBranch[Branch ID]` → `DimAccount[Branch ID]` and Facts containing `Branch ID`
   - `DimLoan[Loan ID]` → `FactLoans[Loan ID]`
   - `DimCard[CardID]` → `FactCards[CardID]`
   - `DimDate[Date]` → Active to `FactTransactions[Transaction Date]`
     - Create *inactive* relationships to `Date Of Account Opening`, `Feedback Date`, `Resolution Date`, `Payment Due Date`, `Last Credit Card Payment Date` and activate via `USERELATIONSHIP` in measures where needed.
6) Create a **Measures** table and paste `dax_measures.txt` into it.
7) Build pages using the 20-page layout in our plan. Start with:
   - Executive Overview, Customer 360, Transactions, Loans, Branch Performance.
8) Add **RLS** by Branch ID as needed.
9) Configure **Incremental Refresh** for `FactTransactions` by `Transaction Date` (optional but recommended).

## Notes
- **NIM/Profitability** requires GL/ALM data. Keep placeholders ready.
- For **Accounts snapshot**, current script uses “as of now” balances. If you get historical daily balances, replace the snapshot with a proper periodic snapshot fact.
- If you add **Branch names/regions**, enrich `DimBranch` columns and re‑point visuals accordingly.