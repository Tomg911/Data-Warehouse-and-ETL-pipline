USE warehouse;
GO

DROP TABLE IF EXISTS bronze.crm_cust_info;
DROP TABLE IF EXISTS bronze.crm_prd_info;
DROP TABLE IF EXISTS bronze.crm_sales_details;
DROP TABLE IF EXISTS bronze.erp_cust_az12;
DROP TABLE IF EXISTS bronze.erp_loc_a101;
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(70),
    cst_firstname NVARCHAR(100),
    cst_lastname NVARCHAR(100),
    cst_marital_status NVARCHAR(100),
    cst_gndr NVARCHAR(100),
    cst_create_date DATE
);


GO

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(70),
    prd_nm NVARCHAR(70),
    prd_cost DECIMAL(10,2),
    prd_line NVARCHAR(70),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(20),
    sls_prd_key NVARCHAR(70),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2)
);
GO

CREATE TABLE bronze.erp_cust_az12 (
    CID NVARCHAR(20),
    BDATE DATE,
    GEN NVARCHAR(10)
);
GO

CREATE TABLE bronze.erp_loc_a101 (
    CID NVARCHAR(20),
    CNTRY NVARCHAR(50)
);
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID NVARCHAR(20),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(10)
);
GO



USE warehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE bronze.crm_cust_info;
    BULK INSERT bronze.crm_cust_info
    FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    TRUNCATE TABLE bronze.crm_prd_info;
    BULK INSERT bronze.crm_prd_info
    FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    use warehouse;

TRUNCATE TABLE bronze.crm__sales_details
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_crm\1 sales_details.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

    TRUNCATE TABLE bronze.erp_cust_az12;
    BULK INSERT bronze.erp_cust_az12
    FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    TRUNCATE TABLE bronze.erp_loc_a101;
    BULK INSERT bronze.erp_loc_a101
    FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'C:\Users\hp\Desktop\Python\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
END;
GO
EXEC bronze.load_bronze;


Select * from bronze.erp_px_cat_g1v2;
