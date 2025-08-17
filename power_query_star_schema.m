// ===============================================
// Power BI Star Schema Builder (from 'Raw' query)
// Assumes you already loaded the CSV into a query named Raw
// ===============================================

// --- Helper: ensure Date type ---
let
    Source = Raw,

    // 1) Type casting (adjust types if your locale differs)
    Typed =
        Table.TransformColumnTypes(
            Source,
            {
                {"Customer ID", Int64.Type},
                {"Age", Int64.Type},
                {"Gender", type text},
                {"City", type text},
                {"Account Type", type text},
                {"Account Balance", type number},
                {"Date Of Account Opening", type date},
                {"Last Transaction Date", type date},
                {"TransactionID", type text},
                {"Transaction Date", type date},
                {"Transaction Type", type text},
                {"Transaction Amount", type number},
                {"Loan ID", type text},
                {"Loan Amount", type number},
                {"Loan Type", type text},
                {"Loan Term", Int64.Type},
                {"Interest Rate", type number},
                {"Loan Status", type text},
                {"CardID", type text},
                {"Card Type", type text},
                {"Credit Limit", type number},
                {"Credit Card Balance", type number},
                {"Minimum Payment Due", type number},
                {"Payment Due Date", type date},
                {"Last Credit Card Payment Date", type date},
                {"Feedback ID", type text},
                {"Feedback Date", type date},
                {"Feedback Type", type text},
                {"Resolution Status", type text},
                {"Resolution Date", type date},
                {"Branch ID", Int64.Type},
                {"Anomaly", Int64.Type}
            },
            "en-US"
        ),

    // -----------------------------------------------
    // DIMENSIONS
    // -----------------------------------------------
    DimCustomer0 =
        Table.Distinct(
            Table.SelectColumns(
                Typed,
                {"Customer ID", "Age", "Gender", "City"}
            )
        ),
    DimCustomer = Table.Sort(DimCustomer0, {{"Customer ID", Order.Ascending}}),

    DimAccount0 =
        Table.Distinct(
            Table.SelectColumns(
                Typed,
                {"Customer ID", "Account Type", "Date Of Account Opening", "Last Transaction Date", "Branch ID"}
            )
        ),
    DimAccount = Table.Sort(DimAccount0, {{"Customer ID", Order.Ascending}}),

    DimLoan0 =
        Table.Distinct(
            Table.SelectColumns(
                Typed,
                {"Loan ID", "Loan Type", "Loan Term"}
            )
        ),
    DimLoan = Table.Sort(DimLoan0, {{"Loan ID", Order.Ascending}}),

    DimCard0 =
        Table.Distinct(
            Table.SelectColumns(
                Typed,
                {"CardID", "Card Type"}
            )
        ),
    DimCard = Table.Sort(DimCard0, {{"CardID", Order.Ascending}}),

    DimBranch0 =
        Table.Distinct(
            Table.SelectColumns(
                Typed,
                {"Branch ID"}
            )
        ),
    // Placeholder columns for future enrichment (e.g., Branch Name, Region)
    DimBranch1 = Table.AddColumn(DimBranch0, "Branch Name", each null, type text),
    DimBranch = Table.AddColumn(DimBranch1, "Region", each null, type text),

    // -----------------------------------------------
    // FACTS
    // -----------------------------------------------
    FactTransactions =
        Table.SelectColumns(
            Typed,
            {"TransactionID", "Customer ID", "Transaction Date", "Transaction Type", "Transaction Amount"}
        ),

    FactLoans =
        Table.SelectColumns(
            Typed,
            {"Loan ID", "Customer ID", "Loan Amount", "Interest Rate", "Loan Status"}
        ),

    FactCards =
        Table.SelectColumns(
            Typed,
            {"CardID", "Customer ID", "Credit Limit", "Credit Card Balance", "Minimum Payment Due", "Payment Due Date", "Last Credit Card Payment Date"}
        ),

    FactFeedback =
        Table.SelectColumns(
            Typed,
            {"Feedback ID", "Customer ID", "Feedback Type", "Feedback Date", "Resolution Status", "Resolution Date", "Branch ID"}
        ),

    FactRisk =
        Table.SelectColumns(
            Typed,
            {"Customer ID", "Anomaly", "Branch ID"}
        ),

    // Optional: Accounts snapshot (current-state as-of refresh)
    FactAccountsSnapshot =
        Table.SelectColumns(
            Typed,
            {"Customer ID", "Account Type", "Account Balance", "Branch ID"}
        ),

    // -----------------------------------------------
    // DATE DIMENSION (min to max across all date fields)
    // -----------------------------------------------
    DateCols =
        {
            Table.Column(Typed, "Transaction Date"),
            Table.Column(Typed, "Date Of Account Opening"),
            Table.Column(Typed, "Last Transaction Date"),
            Table.Column(Typed, "Payment Due Date"),
            Table.Column(Typed, "Last Credit Card Payment Date"),
            Table.Column(Typed, "Feedback Date"),
            Table.Column(Typed, "Resolution Date")
        },
    AllDatesList = List.RemoveNulls(List.Combine(DateCols)),
    MinDate = Date.From(List.Min(AllDatesList)),
    MaxDate = Date.From(List.Max(AllDatesList)),
    DateList = List.Dates(MinDate, Duration.Days(MaxDate - MinDate) + 1, #duration(1,0,0,0)),

    DimDate0 = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    DimDate1 = Table.TransformColumnTypes(DimDate0, {{"Date", type date}}),
    DimDate2 = Table.AddColumn(DimDate1, "Year", each Date.Year([Date]), Int64.Type),
    DimDate3 = Table.AddColumn(DimDate2, "Month Number", each Date.Month([Date]), Int64.Type),
    DimDate4 = Table.AddColumn(DimDate3, "Month Name", each Date.MonthName([Date]), type text),
    DimDate5 = Table.AddColumn(DimDate4, "Quarter", each "Q" & Number.ToText(Date.QuarterOfYear([Date])), type text),
    DimDate6 = Table.AddColumn(DimDate5, "Year-Month", each Date.ToText([Date], "yyyy-MM"), type text),
    DimDate = Table.AddColumn(DimDate6, "Day", each Date.Day([Date]), Int64.Type)

in
    [
        // Expose as record so you can right-click each table and "Enable Load"
        DimCustomer = DimCustomer,
        DimAccount = DimAccount,
        DimLoan = DimLoan,
        DimCard = DimCard,
        DimBranch = DimBranch,
        FactTransactions = FactTransactions,
        FactLoans = FactLoans,
        FactCards = FactCards,
        FactFeedback = FactFeedback,
        FactRisk = FactRisk,
        FactAccountsSnapshot = FactAccountsSnapshot,
        DimDate = DimDate
    ]