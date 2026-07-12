/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    call Silver.load_silver;
=========
*/


create or replace procedure silver.load_silver()
language plpgsql
as $$
declare 
	start_time       TIMESTAMP;
    end_time         TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
begin 
	
	RAISE NOTICE '===========================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '===========================';

    batch_start_time := clock_timestamp();
    RAISE NOTICE 'Batch start time: %', batch_start_time;

    -------------------------------------------------------------------------
    -- Loading ERP Tables
    -------------------------------------------------------------------------
    RAISE NOTICE '---------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '---------------------------';

    -------------------------------------------------------------------------
    -- silver.crm_cust_info
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';

	RAISE NOTICE '>>Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	raise notice '>> Inserting Data Into: silver.crm_cust_info';
	insert into silver.crm_cust_info (
		cst_id,
		cst_key, 
		cst_firstname, 
		cst_lastname, 
		cst_marital_status,
		cst_gndr, 
		cst_create_date
	)
	select 
		t.cst_id 			   as cst_id,
		t.cst_key 			   as cst_key,
		trim(t.cst_firstname)  as cst_firstname,
		trim(t.cst_lastname)   as cst_lastname,
		case 
			when upper(trim(t.cst_marital_status)) = 'M' then 'Married'
			when upper(trim(t.cst_marital_status)) = 'S' then 'Single'
			else 'n/a'
		end as cst_marital_status,
		case 
			when upper(trim(t.cst_gndr)) = 'M' then 'Male'
			when upper(trim(t.cst_gndr)) = 'F' then 'Female'
			else 'n/a'
		end as cst_gndr,
		t.cst_create_date      as cst_create_date
	from (
		select
		*,
		row_number() over(partition by ci.cst_id order by ci.cst_create_date::date desc) as flag_last
		from bronze.crm_cust_info ci
		) t
	where t.flag_last = 1 and t.cst_id is not null;
	
	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';
	
	
	-- Insert Data Into Silver Product Info Table

	
	start_time := clock_timestamp();
	RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
	
	raise notice '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	raise notice '>> Inserting Data Into: silver.crm_prd_info';
	insert into silver.crm_prd_info (
		prd_id,
		cat_id, 
		prd_key, 
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	select 
		prd_id,
		replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
		substring(prd_key, 7, length(prd_key)) as prd_key,
		prd_nm,
		coalesce(prd_cost, 0) as prd_cost,
		case upper(trim(prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'Other Sales'
			when 'T' then 'Touring'
			else 'n/a'
		end as prd_line,
		prd_start_dt,
		cast(lead(prd_start_dt) 
			over (
				partition by prd_key 
				order by prd_start_dt)- interval '1 day' as date) as prd_end_dt
	from bronze.crm_prd_info;
	
	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';
		
	-- Insert Data Into Silver Sales Detail Table
	
	start_time := clock_timestamp();
	raise notice 'Start time %', start_time;
	RAISE NOTICE '------------------------------------------';
	RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
	insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	select
		sls_ord_num,
		sls_prd_key, 
		sls_cust_id,
		case 
			when sls_order_dt = 0 or length(cast(sls_order_dt as varchar)) != 8 then null 
			else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt,
		case 
			when sls_ship_dt = 0 or length(cast(sls_ship_dt as varchar)) != 8 then null 
			else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,
		case 
			when sls_due_dt = 0 or length(cast(sls_due_dt as varchar)) != 8 then null 
			else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,
		case 
			when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) 
			then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales,
		sls_quantity,
			case 
			when sls_price is null or sls_price <= 0
			then sls_sales / nullif(sls_quantity, 0)
			else sls_price
		end as sls_price
	from bronze.crm_sales_details;

	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';
	
	
	-- Silver ERP System tables
	-- Insert Into ERP Customer Subinfo

	start_time := clock_timestamp();
	raise notice 'Start time %', start_time;
	RAISE NOTICE '------------------------------------------';
	
	RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
	insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	select 
		case
			when cid ilike 'NAS%' then substring(cid, 4, length(cid)) 
			else cid
		end as cid,
		case 
			when bdate::date > current_date then null 
			else bdate::date
		end as bdate,
		case 
			when trim(gen) ilike 'M' then 'Male'
			when trim(gen) ilike 'F' then 'Female'
			when trim(gen) = '' or gen is null then 'n/a'
			else gen
		end as gen
	from bronze.erp_cust_az12 as ec;

	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';
	
	-- Insert Into ERP Customer Location
	
	start_time := clock_timestamp();
	raise notice 'Start time %', start_time;
	RAISE NOTICE '------------------------------------------';

	RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
	insert into silver.erp_loc_a101 (
		cid,
		cntry
	)
	select distinct
		replace(cid, '-', '') as cid,
		case
			when trim(cntry) = '' or cntry is null then 'n/a'
			when trim(cntry) in ('USA', 'US') then 'United States'
			when trim(cntry) = 'DE' then 'Germany'
			else trim(cntry)
			end as cntry
	from bronze.erp_loc_a101;

	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';
	
	-- Insert Into ERP Product subinfo
	
	start_time := clock_timestamp();
	raise notice 'Start time %', start_time;
	RAISE NOTICE '------------------------------------------';

	RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
	insert into silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance 
	)
	select
		id,
		cat,
		subcat,
		maintenance 
	from bronze.erp_px_cat_g1v2;

	end_time := clock_timestamp();
	raise notice 'End time %', end_time;
	raise notice 'Loading duration time %', end_time - start_time;
	RAISE NOTICE '------------------------------------------';

	-------------------------------------------------------------------------
    -- Batch end
    -------------------------------------------------------------------------
    batch_end_time := clock_timestamp();

    RAISE NOTICE '===========================';
    RAISE NOTICE 'Silver Layer Loaded Successfully';
    RAISE NOTICE 'Batch end time: %', batch_end_time;
    RAISE NOTICE 'Total silver loading time: %', batch_end_time - batch_start_time;
    RAISE NOTICE '===========================';
	
exception
	when others then
		raise notice 'Error in silver.load_silver %: ', sqlerrm;
		raise;
end;
$$;




