// Sales_Raw - reads the Kaggle CSV (connection only). Change the path to where you saved the file.
let
    Source = Csv.Document(File.Contents("D:\claude life\01_Projects\02_Department_Store_Sales\01_Raw_Data\department_store_dataset.csv"),[Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted,{{"Seller", type text},{"Department", type text},{"Revenue", type number},{"Revenue Goal", type number},{"Margin", type number},{"Margin Goal", type number},{"Date", type date},{"Sales Quantity", Int64.Type},{"Customers", Int64.Type}}, "en-US")
in
    Typed
