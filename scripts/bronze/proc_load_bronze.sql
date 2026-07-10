/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `COPY INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time       TIMESTAMP;
    end_time         TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time   TIMESTAMP;
BEGIN
    RAISE NOTICE '===========================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '===========================';

    batch_start_time := clock_timestamp();
    RAISE NOTICE 'Batch start time: %', batch_start_time;

    -------------------------------------------------------------------------
    -- Loading CRM Tables
    -------------------------------------------------------------------------
    RAISE NOTICE '---------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '---------------------------';

    -------------------------------------------------------------------------
    -- bronze.crm_cust_info
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';

    COPY bronze.crm_cust_info (
        cst_id,              -- id client
        cst_key,             -- key client
        cst_firstname,       -- name
        cst_lastname,        -- lastname
        cst_marital_status,  -- family status
        cst_gndr,            -- gender
        cst_create_date
    )
    FROM 'C:\pg_import\source_crm\cust_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- bronze.crm_prd_info
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';

    COPY bronze.crm_prd_info (
        prd_id,        -- ID продукта, уникальный идентификатор товара
        prd_key,       -- Ключ продукта, бизнес-ключ из CRM/источника
        prd_nm,        -- Название продукта
        prd_cost,      -- Стоимость продукта, должна быть больше 0
        prd_line,      -- Линейка продукта / категория / тип продукта
        prd_start_dt,  -- Дата начала действия записи
        prd_end_dt     -- Дата окончания действия записи
    )
    FROM 'C:\pg_import\source_crm\prd_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- bronze.crm_sales_details
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';

    COPY bronze.crm_sales_details (
        sls_ord_num,   -- Номер заказа
        sls_prd_key,   -- Ключ продукта / код товара
        sls_cust_id,   -- ID клиента
        sls_order_dt,  -- Дата оформления заказа
        sls_ship_dt,   -- Дата отгрузки / отправки заказа
        sls_due_dt,    -- Плановая дата доставки / срок выполнения
        sls_sales,     -- Общая сумма продажи
        sls_quantity,  -- Количество проданного товара
        sls_price      -- Цена за единицу товара
    )
    FROM 'C:\pg_import\source_crm\sales_details.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- Loading ERP Tables
    -------------------------------------------------------------------------
    RAISE NOTICE '---------------------------';
    RAISE NOTICE 'Loading ERP System';
    RAISE NOTICE '---------------------------';

    -------------------------------------------------------------------------
    -- bronze.erp_cust_az12
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';

    COPY bronze.erp_cust_az12 (
        cid,    -- Customer ID / идентификатор клиента из ERP
        bdate,  -- Birth date / дата рождения клиента
        gen     -- Gender / пол клиента
    )
    FROM 'C:\pg_import\source_erp\CUST_AZ12.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- bronze.erp_loc_a101
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';

    COPY bronze.erp_loc_a101 (
        cid,    -- Customer ID / идентификатор клиента из ERP
        cntry   -- Country / страна клиента
    )
    FROM 'C:\pg_import\source_erp\loc_a101.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- bronze.erp_px_cat_g1v2
    -------------------------------------------------------------------------
    start_time := clock_timestamp();

    RAISE NOTICE 'Start time: %', start_time;
    RAISE NOTICE '------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

    COPY bronze.erp_px_cat_g1v2 (
        id,           -- Product ID / идентификатор продукта
        cat,          -- Category / категория продукта
        subcat,       -- Subcategory / подкатегория продукта
        maintenance   -- Maintenance flag / признак обслуживания
    )
    FROM 'C:\pg_import\source_erp\PX_CAT_G1V2.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    end_time := clock_timestamp();

    RAISE NOTICE 'End time: %', end_time;
    RAISE NOTICE 'Loading duration time: %', end_time - start_time;
    RAISE NOTICE '------------------------------------------';

    -------------------------------------------------------------------------
    -- Batch end
    -------------------------------------------------------------------------
    batch_end_time := clock_timestamp();

    RAISE NOTICE '===========================';
    RAISE NOTICE 'Bronze Layer Loaded Successfully';
    RAISE NOTICE 'Batch end time: %', batch_end_time;
    RAISE NOTICE 'Total bronze loading time: %', batch_end_time - batch_start_time;
    RAISE NOTICE '===========================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in bronze.load_bronze: %', SQLERRM;
        RAISE;
END;
$$;
