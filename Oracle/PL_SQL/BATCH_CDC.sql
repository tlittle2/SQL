CREATE OR REPLACE PROCEDURE BATCH_CDC(p_table_owner IN ALL_TABLES.OWNER%TYPE
									, p_stage_table IN ALL_TABLES.TABLE_NAME%TYPE
									, p_cdc_table IN ALL_TABLES.TABLE_NAME%TYPE
									, p_target_table IN ALL_TABLES.TABLE_NAME%TYPE)
									
AS

	type columns_list_t is table of ALL_TAB_COLUMNS.COLUMN_NAME%TYPE index by pls_integer;
	
	cdc_list columns_list_t;
	non_cdc_list columns_list_t;

	PROCEDURE CHECK_SCHEMAS(p_source_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE
						  , p_target_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE)
	IS
	BEGIN
		null;
	END CHECK_SCHEMAS;
	
	PROCEDURE GATHER_CDC_COLUMNS(p_collection IN OUT columns_list_t)
	IS
		cursor cdc_columns is
        select sort_order_number
		, column_name
		from update_match where UPPER(table_owner) = UPPER(p_table_owner)
		and UPPER(table_name) = UPPER(p_target_table)
        order by sort_order_number asc;
	BEGIN
	
		for rec_cdc in cdc_columns
		loop
			p_collection(rec_cdc.sort_order_number) := rec_cdc.column_name; 
		end loop;
	
	END;
	



	
	PROCEDURE GATHER_NON_CDC_COLUMNS(p_collection IN OUT columns_list_t)
	IS
		cursor non_cdc_columns is
		select column_id, column_name from all_tab_columns where owner = UPPER(p_table_owner) and table_name = UPPER(p_target_table)
		AND COLUMN_NAME NOT IN ('EFF_DATE' , 'END_DATE' , 'CREATE_ID' , 'LAST_UPDATE_ID')
		and column_name not in (
          select column_name from update_match where UPPER(table_owner) = UPPER(p_table_owner) and UPPER(table_name) = UPPER(p_target_table)
		) 
		
		order by column_id asc;
	BEGIN
	
		for rec_non_cdc in non_cdc_columns
		loop
			p_collection(rec_non_cdc.column_id) := rec_non_cdc.column_name; 
		end loop;
	
	END;
	
	procedure print_collection(p_collection IN columns_list_t)
    is
    begin
         for i in p_collection.FIRST..p_collection.LAST
         loop
         dbms_output.put_line(p_collection(i));
         end loop;
    end;
	

BEGIN
	CHECK_SCHEMAS(p_cdc_table, p_stage_table);
	CHECK_SCHEMAS(p_cdc_table, p_target_table);
	
	GATHER_CDC_COLUMNS(cdc_list);
     print_collection(cdc_list);
     
	GATHER_NON_CDC_COLUMNS(non_cdc_list);
     print_collection(non_cdc_list);

  --more stuff to add later
     
	
END;
/
