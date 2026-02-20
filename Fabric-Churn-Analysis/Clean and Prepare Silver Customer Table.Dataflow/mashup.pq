[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "silver_churn_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "surname", DestinationColumnName = "surname"], [SourceColumnName = "credit_score", DestinationColumnName = "credit_score"], [SourceColumnName = "geography", DestinationColumnName = "geography"], [SourceColumnName = "gender", DestinationColumnName = "gender"], [SourceColumnName = "age", DestinationColumnName = "age"], [SourceColumnName = "tenure", DestinationColumnName = "tenure"], [SourceColumnName = "balance", DestinationColumnName = "balance"], [SourceColumnName = "number_of_products", DestinationColumnName = "number_of_products"], [SourceColumnName = "has_credit_card", DestinationColumnName = "has_credit_card"], [SourceColumnName = "is_current_customer", DestinationColumnName = "is_current_customer"], [SourceColumnName = "estimated_salary", DestinationColumnName = "estimated_salary"], [SourceColumnName = "is_churned", DestinationColumnName = "is_churned"], [SourceColumnName = "age_bucket", DestinationColumnName = "age_bucket"], [SourceColumnName = "salary_bucket", DestinationColumnName = "salary_bucket"], [SourceColumnName = "tenure_bucket", DestinationColumnName = "tenure_bucket"], [SourceColumnName = "balance_bucket", DestinationColumnName = "balance_bucket"], [SourceColumnName = "credit_score_bucket", DestinationColumnName = "credit_score_bucket"], [SourceColumnName = "ingestion_date", DestinationColumnName = "ingestion_date"]}], DynamicSchema = false, UpdateMethod = [Kind = "Append"], TypeSettings = [Kind = "Table"]]]}]
shared silver_churn = let
  Source = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navigation 1" = Source{[workspaceId = "3b76ac3a-7116-4afb-ae8c-d85acd950cfd"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "16fe7a05-5174-44a6-bfc0-cc13431ff890"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "bronze.customer", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 3", {"RowNumber"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"CustomerId"}),
  #"Add column" = Table.TransformColumnTypes(Table.AddColumn(#"Removed duplicates", "age_bucket", each if [Age] < 20 then "Under 20"
        else if [Age] < 30 then "20-29"
        else if [Age] < 40 then "30-39"
        else if [Age] < 50 then "40-49"
        else if [Age] < 60 then "50-59"
        else "60+"), {{"age_bucket", type text}}),
  #"Add column 1" = Table.TransformColumnTypes(Table.AddColumn(#"Add column", "salary_bucket", each let
            salary = [EstimatedSalary]
        in
            if salary < 50000 then "<50k"
            else if salary < 100000 then "50k-100k"
            else if salary < 150000 then "100k-150k"
            else if salary < 200000 then "150k-200k"
            else "200k+"), {{"salary_bucket", type text}}),
  #"Add column 2" = Table.TransformColumnTypes(Table.AddColumn(#"Add column 1", "tenure_bucket", each if [Tenure] < 3 then "<3"
        else if [Tenure] < 6 then "3-5"
        else if [Tenure] < 10 then "6-9"
        else "10+"), {{"tenure_bucket", type text}}),
  #"Add column 3" = Table.TransformColumnTypes(Table.AddColumn(#"Add column 2", "balance_bucket", each let
            balance = [Balance]
        in
            if balance < 50000 then "<50k"
            else if balance < 100000 then "50k-100k"
            else if balance < 150000 then "100k-150k"
            else "150k+"), {{"balance_bucket", type text}}),
  #"Add column 4" = Table.TransformColumnTypes(Table.AddColumn(#"Add column 3", "credit_score_bucket", each let
            score = [CreditScore]
        in
            if score < 600 then "Poor"
            else if score < 650 then "Fair"
            else if score < 700 then "Good"
            else if score < 750 then "Great"
            else "Excellent"), {{"credit_score_bucket", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Add column 4", {{"CustomerId", "customer_id"}, {"Surname", "surname"}, {"CreditScore", "credit_score"}, {"Geography", "geography"}, {"Gender", "gender"}, {"Age", "age"}, {"Tenure", "tenure"}, {"Balance", "balance"}, {"NumOfProducts", "number_of_products"}, {"HasCrCard", "has_credit_card"}, {"IsActiveMember", "is_current_customer"}, {"EstimatedSalary", "estimated_salary"}, {"Exited", "is_churned"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed columns", {{"is_churned", type logical}, {"is_current_customer", type logical}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "ingestion_date", each DateTimeZone.UtcNow()), {{"ingestion_date", type datetime}})
in
  #"Added custom";
shared silver_churn_DataDestination = let
  Pattern = Fabric.Warehouse([HierarchicalNavigation = null, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "3b76ac3a-7116-4afb-ae8c-d85acd950cfd"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "3890b5bf-c226-4c57-af34-853aee4b19d4"]}[Data],
  TableNavigation = Navigation_2{[Item = "silver_churn", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
