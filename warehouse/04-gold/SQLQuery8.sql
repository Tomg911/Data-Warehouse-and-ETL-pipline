


Print'=======================Gold layer=============================================================================='


Create view gold.dim_customer AS
select 
row_number() over (order by cst_id) as Customer_PK,
ci.cst_id as Custmer_id,
ci.cst_key as custmer_number,
ci.cst_firstname as custmer_firstname,
ci.cst_lastname as custmer_lastname,
ci.cst_marital_status,
ci.cst_create_date,
ca.BDATE,
case
when ci.cst_gndr = 'N/G' then GEN
when ci.cst_gndr IS NULL then GEN
else ci.cst_gndr
end as gender,
CNTRY as country
from 
silver.crm_cust_info as ci 
left join silver.erp_cust_az12 as ca on ci. cst_key = CID  
left join silver.erp_loc_a101 as el on ca.CID =el.CID;







create view gold.dim_product_info as
Select 
row_number () over (order by pi.prd_start_dt, pi.prd_key ) as sargate_key,
pi.prd_id As product_ID,
pi.cat_id As catogary_ID,
pi.prd_key,
pi.prd_nm as product_name,
pi.prd_cost as product_cost ,
pi.prd_line as product_line,
pi.prd_start_dt as  product_start_date,
pc.CAT as catogary,
pc.SUBCAT as sub_catogary,
pc.MAINTENANCE
from [silver].[crm_prd_info] as pi left join 
[silver].[erp_px_cat_g1v2] as pc on pc.ID = pi.cat_id where prd_end_dt is null -- filter out all historical data--;





select * from gold.dim_product_info;


create view gold.fact_sale as
select sls_ord_num as order_number,
dc.Customer_PK,
dp.sargate_key as sargate_pk ,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shiping_date,
sd.sls_due_dt as sales_due_date,
sd.sls_sales as sales,
sd.sls_quantity,
sd.sls_price
from [silver].[crm_sales_details] as sd left join [gold].[dim_product_info] as dp on sd.sls_prd_key = dp.prd_key
 left join [gold].[dim_customer] as dc on sd. sls_cust_id = dc.Custmer_id;












Print'===================================calculations========================================================'





select Custmer_id, count(*) as dup from(


select 
row_number() over (order by cst_id) as Customer_PK,
ci.cst_id as Custmer_id,
ci.cst_key as custmer_number,
ci.cst_firstname as custmer_firstname,
ci.cst_lastname as custmer_lastname,
ci.cst_marital_status,
ci.cst_create_date,
ca.BDATE,
case
when ci.cst_gndr = 'N/G' then GEN
when ci.cst_gndr IS NULL then GEN
else ci.cst_gndr
end as gender,
CNTRY as country
from 
silver.crm_cust_info as ci 
left join silver.erp_cust_az12 as ca on ci. cst_key = CID  
left join silver.erp_loc_a101 as el on ca.CID =el.CID) t1

group by Custmer_id
having count(*) >1;


select * from silver.crm_cust_info;
select*from [silver].[erp_cust_az12];
select * from silver.erp_loc_a101;



 
select 
 prd_id ,
replace(substring(prd_key,1,5),'-','_') as cat_id,
Substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) as prd_cost,
case 
when trim(upper(prd_line))='R'then 'road'
when trim(upper(prd_line)) ='S'then'other_sales'
when trim(upper(prd_line)) ='M'then'MoUntain'
when trim(upper(prd_line)) ='T'then'Touring' else 'n/g' end as prd_line,
prd_start_dt,
 prd_end_dt,
 lead(prd_start_dt) over (partition by  prd_key order by prd_start_dt) as alt_prd_end_dt
from bronze.crm_prd_info
where prd_key  in ('AC-HE-HL-U509-R','AC-HE-HL-U509') 
order by prd_id ASC;



select prd_key, count(*) from
(Select 
pi.prd_id,
pi.cat_id,
pi.prd_key,
pi.prd_nm,
pi.prd_cost,
pi.prd_line,
pi.prd_start_dt,
pc.CAT,
pc.SUBCAT,
pc.MAINTENANCE
from [silver].[crm_prd_info] as pi left join 
[silver].[erp_px_cat_g1v2] as pc on pc.ID = pi.cat_id where prd_end_dt is null -- filter out all historical data--
) t1 group by prd_key having  count(*) >1; 





SELECT *
FROM [silver].[crm_prd_info]
WHERE cat_id IN (
    SELECT id
    FROM [silver].[erp_px_cat_g1v2]
);


select * from [silver].[erp_px_cat_g1v2];
select * from [silver].[crm_prd_info];