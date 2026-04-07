




print'==============================silver.crm_cust_info=======================================';
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver
AS
begin



Truncate table silver.crm_cust_info;  
Insert into silver.crm_cust_info ( cst_id,cst_key,
cst_firstname, 
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)
select  cst_id,cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname)as cst_lastname,
case 
when upper(trim(cst_marital_status)) ='M'then ' married'
when upper(trim(cst_marital_status)) ='S'then ' single'
else 'N/G'
end as cst_marital_status,
case 
when upper(trim(cst_gndr)) = 'F' then 'Female'
when upper(trim(cst_gndr)) ='M' then 'Male'
else 'N/G'
end as cst_gndr,
cst_create_date 
from(Select *, row_number() over (PARTITION BY cst_id order by cst_create_date desc) as dup
from bronze.crm_cust_info where cst_id is not NULL)t
where dup =1;



print'==============================silver.crm_prd_info=======================================';

Truncate table silver.crm_prd_info;
insert into silver.crm_prd_info(prd_id,cat_id, prd_key,prd_nm,
prd_cost, prd_line,prd_start_dt,prd_end_dt)
select 
prd_id,
replace(substring(prd_key,1,5),'-','_') as cat_id,
Substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) as prd_cost,
case 
when trim(upper(prd_line))='R'then 'road'
when trim(upper(prd_line)) ='S'then'other_sales'
when trim(upper(prd_line)) ='M'then'montain'
when trim(upper(prd_line)) ='T'then'Touring' else 'n/g' end as prd_line,
prd_start_dt,
 prd_end_dt
from bronze.crm_prd_info ; 




print'==============================silver.crm_sales_details=======================================';

Truncate table silver.crm_sales_details;

 insert into silver.crm_sales_details
  (sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)



  select 
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  cast(cast(sls_order_dt as nvarchar) as date) as sls_order_dt ,
  cast(cast(sls_ship_dt as nvarchar) as date) as sls_ship_dt,
  cast(cast(sls_due_dt as nvarchar) as date) as sls_due_dt,
 isnull (sls_sales,0) as sls_sales,
  isnull(sls_quantity,0) as sls_quantity,
  CAST(
    case 
        when sls_price is NULL then sls_sales / sls_quantity
        else sls_price
    end
AS DECIMAL(10,2)) AS sls_price
from bronze.crm_sales_details;

print'===============================silver.erp_cust_az12======================================';


Truncate table silver.erp_cust_az12;
Insert into silver.erp_cust_az12
    (CID,
    BDATE,
    GEN)
     select 
   case when CID like 'NAS%' then substring(CID,4,10)
   else CID
   end AS CID,
   case when BDATE > getdate() then null
        when BDATE < '1910' then null
   else  BDATE
end as BDATE,
  case 
   when trim(Upper(GEN))= 'F' then 'FEMALE'
   when trim( upper (GEN))= 'M' then 'MALE'
   when trim(upper(GEN))= 'NULL' then 'N/G'
   when trim(upper(GEN))=' ' then 'N/G'
   else trim(upper(GEN))
   end as GEN from bronze.erp_cust_az12;


print'=============================silver.erp_loc_a101========================================';

 
Truncate table silver.erp_loc_a101;

insert into silver.erp_loc_a101(CID,CNTRY)
   Select replace(CID,'-','') as CID,case 
   when trim(CNTRY) in ('US','USA') then 'United States'
   when trim(CNTRY)='' then Null
   when trim(CNTRY) ='DE' then 'Germany' 
   else CNTRY
   end CNTRY  from bronze.erp_loc_a101;

   
print'=============================silver.erp_px_cat_g1v2========================================';


Truncate table  silver.erp_px_cat_g1v2;

   insert into silver.erp_px_cat_g1v2(ID,CAT,SUBCAT,MAINTENANCE)
select * from [bronze].[erp_px_cat_g1v2]


END







