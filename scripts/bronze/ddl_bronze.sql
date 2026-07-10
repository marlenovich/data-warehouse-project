/*
 	DDL Script: Create Bronze Tables
    Script Purporse: 
    	This script creates tables in 'bronze' schema, dropping existing table
    	if they already exists.
    	Run this script to re-define the DDL structure of Bronze tables
 */

-- Create table bronze.crm
drop table if exists bronze.crm_cust_info cascade;
create table bronze.crm_cust_info (
	cst_id 			   BIGINT,  		-- id client
	cst_key 		   VARCHAR(50),					-- key client
	cst_firstname      VARCHAR(50),					-- name
	cst_lastname 	   VARCHAR(50), 				-- lastname
	cst_marital_status VARCHAR(2),					-- family status
	cst_gndr 		   VARCHAR(2),					-- gender
	cst_create_date    DATE default current_date 	-- created date
);


drop table if exists bronze.crm_prd_info;
create table bronze.crm_prd_info (
	prd_id 	  	 BIGINT,							-- ID продукта, уникальный идентификатор товара
	prd_key 	 VARCHAR(50),						-- Ключ продукта, бизнес-ключ из CRM/источника
	prd_nm 		 VARCHAR(50),						-- Название продукта
	prd_cost 	 SMALLINT,							-- Стоимость продукта, должна быть больше 0
	prd_line 	 VARCHAR(2),						-- Линейка продукта / категория / тип продукта
	prd_start_dt DATE default current_date,			-- Дата начала действия записи, по умолчанию текущая дата
	prd_end_dt   DATE default current_date			-- Дата окончания действия записи, по умолчанию текущая дата
);

drop table if exists bronze.crm_sales_details;
create table bronze.crm_sales_details (
	sls_ord_num  VARCHAR(50),			-- Номер заказа
	sls_prd_key  VARCHAR(50),		-- Ключ продукта / код товара
	sls_cust_id  BIGINT,			-- ID клиента
	sls_order_dt INT,				-- Дата оформления заказа
	sls_ship_dt  INT,				-- Дата отгрузки / отправки заказа
	sls_due_dt 	 INT,				-- Плановая дата доставки / срок выполнения
	sls_sales 	 BIGINT,			-- Общая сумма продажи
	sls_quantity INT ,				-- Количество проданного товара
	sls_price 	 DECIMAL(10,2)		-- Цена за единицу товара
);


-- Create table bronze.erp

drop table if exists bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
	--CID,	BDATE,	GEN
	cid 	VARCHAR(50), 	-- Customer ID / идентификатор клиента из ERP
	bdate   VARCHAR(50),	-- Birth date / дата рождения клиента			
	gen 	VARCHAR(10)		-- Gender / пол клиента
);


drop table if exists bronze.erp_loc_a101;
create table bronze.erp_loc_a101 (
	-- CID,  CNTRY
	cid 	VARCHAR(50),    -- Customer ID / идентификатор клиента из ERP
	cntry   VARCHAR(50)		-- Country / страна клиента
);


drop table if exists bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2(
	-- ID,	CAT, SUBCAT, MAINTENANCE
	id  		VARCHAR(50),  	-- Product ID / идентификатор продукта
	cat 		VARCHAR(50),    -- Category / категория продукта
	subcat 		varchar(50), 	-- Subcategory / подкатегория продукта
	maintenance varchar(50)		-- Maintenance flag / признак обслуживания
);






