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
	
	PROCEDURE GATHER_CDC_COLUMNS(p_collection IN OUT NOCOPY columns_list_t)
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
	



	
	PROCEDURE GATHER_NON_CDC_COLUMNS(p_collection IN OUT NOCOPY columns_list_t)
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
    
    
    procedure createView1(p_collection IN columns_list_t)
    is
     v_select VARCHAR2(4000) := 'SELECT ROW_NUMBER() OVER( ORDER BY ';
    begin
          for i in p_collection.FIRST..p_collection.LAST
          LOOP
               v_select := v_select || p_collection(i);
               if i <> p_collection.LAST
               then
                    v_select := v_select || ',';     
               else
                    v_select := v_select || ',EFF_DATE) as row_id1, k.* from ' || p_table_owner || '.' || p_cdc_table;
               end if;
               
               
          END LOOP;
          dbms_output.put_line(v_select);
          
    end;
         
    procedure createView2(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
    is
          v_select VARCHAR2(4000) := 'SELECT ROW_NUMBER() OVER( ORDER BY ';
     
          function dynamicJoin(p_collection IN columns_list_t)
          return VARCHAR2
          is
               v_join_clause VARCHAR2(32767) := ' and ';
          begin
               for i in p_collection.FIRST..p_collection.LAST
               loop
                    v_join_clause := v_join_clause || 'x1.' || p_collection(i) || ' = ' || 'x2.' || p_collection(i);
                    if i <> p_collection.LAST
                    then
                         v_join_clause := v_join_clause || ' and ';
                    end if;
                    
               end loop;
               
               return v_join_clause;
     
          end;
          
          function dynamicNotEqualClause(p_collection IN columns_list_t)
          return VARCHAR2
          IS
               v_where_clause VARCHAR2(32767) := ' where x2.row_id is null or ';
          BEGIN
               for i in p_collection.FIRST..p_collection.LAST
               loop
                    v_where_clause:= v_where_clause ||
                    '(x1.' || p_collection(i) || ' <> ' || 'x2.' || p_collection(i) || ')'
                    || ' OR ' 
                    || '(x1.' || p_collection(i) || ' is null' || ' and ' || 'x2.' || p_collection(i) || ' is not null)'
                    || ' OR '
                    || '(x1.' || p_collection(i) || ' is not null' || ' and' || ' x2.' || p_collection(i) || ' is null)';
              
                    if i <> p_collection.LAST
                    then
                         v_where_clause := v_where_clause || ' OR ';  
                    end if;
               end loop;
               return v_where_clause;
          END;
    begin
          for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
          LOOP
               v_select := v_select || 'x1.' || p_cdc_columns(i);
               if i <> p_cdc_columns.LAST
               then
                    v_select := v_select || ',';     
               else
                    v_select := v_select || ',x1.EFF_DATE) as row_id2, x1.* from vt1 x1 left outer join vt1 x2'
                    || ' on x1.row_id=x2.row_id+1';
               end if;
               
               
          END LOOP;
          dbms_output.put_line(v_select || dynamicJoin(p_cdc_columns) || dynamicNotEqualClause(p_non_cdc_columns));
          
    end;
	

BEGIN
	CHECK_SCHEMAS(p_cdc_table, p_stage_table);
	CHECK_SCHEMAS(p_cdc_table, p_target_table);
	
	GATHER_CDC_COLUMNS(cdc_list);
     print_collection(cdc_list);
     
	GATHER_NON_CDC_COLUMNS(non_cdc_list);
     print_collection(non_cdc_list);
     
     dbms_output.put_line('VIEW1');
     dbms_output.put_line('--------------------------------');
     createView1(cdc_list);
     
     dbms_output.put_line(chr(10));
     
     dbms_output.put_line('VIEW2');
     dbms_output.put_line('--------------------------------');     
     createView2(cdc_list,non_cdc_list);
     
	
END;
/

CREATE TABLE UPDATE_MATCH (
     TABLE_OWNER VARCHAR2(128) NOT NULL
     , TABLE_NAME VARCHAR2(128) NOT NULL
     , COLUMN_NAME VARCHAR2(128) NOT NULL
     , SORT_ORDER_NUMBER NUMBER(3,0) NOT NULL
);
