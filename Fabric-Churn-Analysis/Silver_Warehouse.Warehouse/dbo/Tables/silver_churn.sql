CREATE TABLE [dbo].[silver_churn] (

	[customer_id] int NULL, 
	[surname] varchar(8000) NULL, 
	[credit_score] int NULL, 
	[geography] varchar(8000) NULL, 
	[gender] varchar(8000) NULL, 
	[age] int NULL, 
	[tenure] int NULL, 
	[balance] float NULL, 
	[number_of_products] int NULL, 
	[has_credit_card] int NULL, 
	[is_current_customer] bit NULL, 
	[estimated_salary] float NULL, 
	[is_churned] bit NULL, 
	[age_bucket] varchar(8000) NULL, 
	[salary_bucket] varchar(8000) NULL, 
	[tenure_bucket] varchar(8000) NULL, 
	[balance_bucket] varchar(8000) NULL, 
	[credit_score_bucket] varchar(8000) NULL, 
	[ingestion_date] datetime2(6) NULL
);