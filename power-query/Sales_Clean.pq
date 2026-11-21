// Sales_Clean - cleaning query (connection only, loaded to the Data Model)
let
    Source = Sales_Raw,
    Renamed = Table.RenameColumns(Source,{{"Revenue Goal","Revenue_Goal"},{"Margin","Margin_Pct"},{"Margin Goal","Margin_Goal_Pct"},{"Sales Quantity","Buyers"}}),
    DeptMap = [#"Eletrônicos"="Electronics", #"Vestuário"="Clothing", Casa="Home", Esportes="Sports", #"Acessórios"="Accessories", Brinquedo="Toys", Papelaria="Stationery"],
    Dept = Table.TransformColumns(Renamed,{{"Department", each Record.FieldOrDefault(DeptMap, Text.Trim(_), Text.Trim(_)), type text},{"Seller", Text.Trim, type text}}),
    SellerList = List.Buffer(List.Sort(List.Distinct(Dept[Seller]))),
    WithID = Table.AddColumn(Dept, "Seller_ID", each "S" & Text.PadStart(Text.From(List.PositionOf(SellerList,[Seller])+1),2,"0"), type text),
    Closed = Table.AddColumn(WithID, "Store_Closed", each if [Customers]=0 then 1 else 0, Int64.Type),
    OpenDay = Table.AddColumn(Closed, "Open_Day", each 1-[Store_Closed], Int64.Type),
    NoGoalClosed = Table.ReplaceValue(OpenDay, each [Store_Closed], null, (v, flag, n) => if flag = 1 then n else v, {"Revenue_Goal","Margin_Pct","Margin_Goal_Pct"}),
    Retyped = Table.TransformColumnTypes(NoGoalClosed, {{"Revenue_Goal", type number},{"Margin_Pct", type number},{"Margin_Goal_Pct", type number}}),
    Yr = Table.AddColumn(Retyped, "Year", each Date.Year([Date]), Int64.Type),
    Qtr = Table.AddColumn(Yr, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    MonNo = Table.AddColumn(Qtr, "Month_No", each Date.Month([Date]), Int64.Type),
    MonNm = Table.AddColumn(MonNo, "Month", each Date.ToText([Date], "MMM", "en-US"), type text),
    MonSt = Table.AddColumn(MonNm, "Month_Start", each Date.StartOfMonth([Date]), type date),
    WdNo = Table.AddColumn(MonSt, "Weekday_No", each Date.DayOfWeek([Date], Day.Monday)+1, Int64.Type),
    WdNm = Table.AddColumn(WdNo, "Weekday", each Date.ToText([Date], "ddd", "en-US"), type text),
    GP = Table.AddColumn(WdNm, "Gross_Profit", each if [Margin_Pct] = null then 0 else Number.Round([Revenue]*[Margin_Pct],2), type number),
    Gap = Table.AddColumn(GP, "Revenue_Gap", each if [Revenue_Goal] = null then null else Number.Round([Revenue]-[Revenue_Goal],2), type number),
    GMet = Table.AddColumn(Gap, "Goal_Met", each if [Store_Closed]=1 then null else if [Revenue] >= [Revenue_Goal] then 1 else 0, Int64.Type),
    MMet = Table.AddColumn(GMet, "Margin_Goal_Met", each if [Store_Closed]=1 then null else if [Margin_Pct] >= [Margin_Goal_Pct] then 1 else 0, Int64.Type),
    Ordered = Table.ReorderColumns(MMet, {"Date","Year","Quarter","Month_No","Month","Month_Start","Weekday_No","Weekday","Seller_ID","Seller","Department","Revenue","Revenue_Goal","Revenue_Gap","Goal_Met","Margin_Pct","Margin_Goal_Pct","Margin_Goal_Met","Gross_Profit","Buyers","Customers","Store_Closed","Open_Day"})
in
    Ordered
