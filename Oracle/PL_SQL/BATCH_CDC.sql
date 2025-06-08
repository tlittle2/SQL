CREATE OR REPLACE PROCEDURE BATCH_CDC(p_table_owner IN ALL_TABLES.OWNER%TYPE
				    , p_stage_table IN ALL_TABLES.TABLE_NAME%TYPE
				    , p_cdc_table IN ALL_TABLES.TABLE_NAME%TYPE
				   , p_target_table IN ALL_TABLES.TABLE_NAME%TYPE)
									
AS

	type columns_list_t is table of ALL_TAB_COLUMNS.COLUMN_NAME%TYPE index by pls_integer;
	
	cdc_list columns_list_t;
	non_cdc_list columns_list_t;
	subtype dynamic_statement_st is VARCHAR2(4000);
    
    function print_line
    return varchar2
    is
    begin
        return lpad('-', 40 , '-');
    end;
    
    procedure print_collection(p_collection IN columns_list_t)
    	is
    	begin
	         for i in p_collection.FIRST..p_collection.LAST
	         loop
	         dbms_output.put_line(p_collection(i));
	         end loop;
    	end;
        
    function str_comma_sep(p_in_str IN VARCHAR2)
    RETURN VARCHAR2 DETERMINISTIC
    IS
    BEGIN
        RETURN p_in_str || ',';
    END;
     
    --given 2 tables, find a way to create a normalized schema check to ensure that the columns are consistent
	FUNCTION CHECK_SCHEMAS(p_source_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE
						  , p_target_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE)
	RETURN BOOLEAN
    	IS
    		v_differences NUMBER;
	BEGIN
	        with schema_check as (
	        select a.owner, a.table_name, a.column_name
	        , case nvl(substr(data_type, 1, instr(data_type, '(', 1)-1),data_type)
			WHEN 'DATE' THEN 'DATE'
			WHEN 'TIMESTAMP' then 'TIMESTAMP(' || a.data_scale || ')'
			WHEN 'FLOAT' then 'FLOAT(' || a.data_precision || ',' || a.data_scale || ')'
			WHEN 'NUMBER' then 'NUMBER(' || a.data_precision || ',' || a.data_scale || ')'
			WHEN 'VARCHAR' THEN 'TEXT(' || a.data_length || ')'
			WHEN 'VARCHAR2' THEN 'TEXT(' || a.data_length || ')'
			WHEN 'CHAR' THEN 'TEXT(' || a.data_length || ')'
			WHEN 'NVARCHAR2' THEN 'TEXT(' || a.data_length || ')'
			WHEN 'RAW' THEN 'TEXT(' || a.data_length || ')'
			ELSE a.data_type
		end as data_type
	        from all_tab_columns a
	        )
	        
	        select nvl(count(1), 1) into v_differences
	        from (
	            select column_name,data_type from schema_check where owner = p_table_owner and table_name = p_target_table
	            MINUS
	            select column_name,data_type from schema_check where owner = p_table_owner and table_name = p_source_table
	            UNION ALL
	            select column_name,data_type from schema_check where owner = p_table_owner and table_name = p_source_table
	            MINUS
	            select column_name,data_type from schema_check where owner = p_table_owner and table_name = p_target_table
	        );
	        
	        if v_differences > 0 
	        then
	            RETURN FALSE; 
	        else
	            RETURN TRUE;
	        end if;
    
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
    
    
    	procedure CREATE_VIEW_1(p_collection IN columns_list_t)
    	is
     	v_select dynamic_statement_st := 'CREATE TABLE vt1 as SELECT ROW_NUMBER() OVER( ORDER BY ';
    	begin
		for i in p_collection.FIRST..p_collection.LAST
		LOOP
			v_select := v_select || p_collection(i);
               		if i <> p_collection.LAST
               		then
                    		v_select := str_comma_sep(v_select);
               		else
                    		v_select := v_select || ',EFF_DATE) as row_id1, k.* from ' || p_table_owner || '.' || p_cdc_table;
               		end if;
          	END LOOP;
          
          	dbms_output.put_line(v_select);
          
    	end;
         
    	procedure CREATE_VIEW_2(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
    	is
		v_select dynamic_statement_st := 'CREATE TABLE vt2 as SELECT ROW_NUMBER() OVER( ORDER BY ';

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
               		v_where_clause dynamic_statement_st := ' where x2.row_id is null or ';
          	BEGIN
               		for i in p_collection.FIRST..p_collection.LAST
               		loop
	                    v_where_clause := v_where_clause
	                    || '(x1.' || p_collection(i) || ' <> ' || 'x2.' || p_collection(i) || ')'
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
                    		v_select := str_comma_sep(v_select);  
               		else
                    		v_select := v_select || ',x1.EFF_DATE) as row_id2, x1.* '
                            || ' from vt1 x1 left outer join vt1 x2'
                    		|| ' on x1.row_id=x2.row_id+1';
               		end if;
          	END LOOP;
          
            dbms_output.put_line(v_select || dynamicJoin(p_cdc_columns) || dynamicNotEqualClause(p_non_cdc_columns));
          end;
          
        PROCEDURE INSERT_INTO_CDC(p_cdc_columns IN columns_list_t)
        IS
            v_insert_statement dynamic_statement_st := 'INSERT INTO ' || p_table_owner || '.' || p_cdc_table 
                                                    || ' SELECT * FROM ' || p_table_owner || '.' || p_stage_table || ' a '
                                                    || ' WHERE (';
            v_cdc_columns_string dynamic_statement_st;
            v_cdc_columns_equality dynamic_statement_st;
        BEGIN
            for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
        	loop
                if i <> p_cdc_columns.LAST
                then
                    v_cdc_columns_string := str_comma_sep(v_cdc_columns_string || p_cdc_columns(i));
                    v_cdc_columns_equality := v_cdc_columns_equality || 'b.' || p_cdc_columns(i) || ' = a.' || p_cdc_columns(i) || ' and ';
                else
                    v_cdc_columns_string :=  v_cdc_columns_string || p_cdc_columns(i);
                    v_cdc_columns_equality := v_cdc_columns_equality || 'b.' || p_cdc_columns(i) || ' = a.' || p_cdc_columns(i);
                end if;
            end loop;
            
            v_insert_statement := v_insert_statement || v_cdc_columns_string || ') not in ' 
                                || '(select ' || v_cdc_columns_string || ' from ' || p_table_owner || '.' || p_cdc_table || ' b )'
                                || ' and exists (select 1 from '  || p_table_owner || '.' || p_cdc_table || ' b where '
                                || v_cdc_columns_equality
                                || ' and ((b.EFF_DATE <= a.EFF_DATE and b.END_DATE >= a.EFF_DATE) OR (b.EFF_DATE >= a.EFF_DATE and b.EFF_DATE <= a.END_DATE)))';
            
            dbms_output.put_line(v_insert_statement);
        
        END;
    
    	procedure MOVE_CDC_TO_STAGE(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
    	is
	        v_insert_statement dynamic_statement_st := 'INSERT INTO ' || p_table_owner || '.' || p_stage_table || '(';
	        v_select_statement dynamic_statement_st := 'SELECT ';
    	begin
        	for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
        	loop
	            v_insert_statement := str_comma_sep(v_insert_statement || p_cdc_columns(i));
	            v_select_statement := str_comma_sep(v_select_statement || 'x1.' || p_cdc_columns(i));
            
        	end loop;
        
        	for i in p_non_cdc_columns.FIRST..p_non_cdc_columns.LAST
        	loop
	            v_insert_statement := v_insert_statement || p_non_cdc_columns(i);
	            v_select_statement := v_select_statement || 'x1.' || p_non_cdc_columns(i);
            
            		if i = p_non_cdc_columns.LAST
            		THEN
		                v_insert_statement := v_insert_statement || ', EFF_DATE, END_DATE, CREATE_ID, LAST_UPDATE_ID)';
		                
		                v_select_statement := v_select_statement || ', x2.EFF_DATE, coalesce(x2.EFF_DATE-1, ''2100-12-31'') as END_DATE, x2.CREATE_ID, coalesce(x2.LAST_UPDATE_ID, x1.LAST_UPDATE_ID) as LAST_UPDATE_ID '
			               					 || ' FROM vt2 x1 LEFT OUTER JOIN vt2 x2 ON ';
	                
	                	for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
	                	loop
	                    		v_select_statement := v_select_statement || 'x1.' || p_cdc_columns(i) || ' = ' || 'x2.' || p_cdc_columns(i);
	                    		if i <> p_cdc_columns.LAST
	                    		then
	                         		v_select_statement := v_select_statement || ' and ';
	                    		else
	                        		v_select_statement := v_select_statement || ' and x1.row_id2 = x2.row_id2-1 ';
	                    		end if;
	                    
	               		end loop;
            		ELSE
		                v_insert_statement := str_comma_sep(v_insert_statement);
		                v_select_statement := str_comma_sep(v_select_statement);
            		end if;
            
        	end loop;
        
            dbms_output.put_line(v_insert_statement);
            dbms_output.put_line(v_select_statement);
    
        end;
        
        procedure REMOVE_FROM_TARGET(p_cdc_columns IN columns_list_t)
        is
            v_cdc_cols_string dynamic_statement_st;
            
            v_delete_string dynamic_statement_st:= 'DELETE FROM ' || p_table_owner || '.' || p_target_table || ' WHERE ';
        begin
            for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
            LOOP
               		if i <> p_cdc_columns.LAST
               		then
                    		v_cdc_cols_string := str_comma_sep(v_cdc_cols_string || p_cdc_columns(i));  
               		else
                    		v_cdc_cols_string := v_cdc_cols_string || p_cdc_columns(i);
               		end if;
          	END LOOP;
            v_delete_string := v_delete_string || '(' || v_cdc_cols_string || ') IN (SELECT '|| v_cdc_cols_string || ' FROM ' || p_table_owner || '.' || p_stage_table || ')';
            dbms_output.put_line(v_delete_string);
        
        end;
	

BEGIN
	IF CHECK_SCHEMAS(p_cdc_table, p_stage_table) AND CHECK_SCHEMAS(p_cdc_table, p_target_table)
    	THEN
	        dbms_output.put_line('CDC_COLUMNS');
	        dbms_output.put_line(print_line);
	        GATHER_CDC_COLUMNS(cdc_list);
	        print_collection(cdc_list);
	        
	        dbms_output.put_line(chr(10));
	     
	        dbms_output.put_line('NON_CDC_COLUMNS');
	        dbms_output.put_line(print_line);
	        GATHER_NON_CDC_COLUMNS(non_cdc_list);
	        print_collection(non_cdc_list);
            
            dbms_output.put_line(chr(10));
              
              dbms_output.put_line('INSERT');
	         dbms_output.put_line(print_line); 
              INSERT_INTO_CDC(cdc_list);
	     
	        dbms_output.put_line(chr(10));
	     
	         dbms_output.put_line('VIEW1');
	         dbms_output.put_line(print_line);
	         CREATE_VIEW_1(cdc_list);
	         
	         dbms_output.put_line(chr(10));
	         
	         dbms_output.put_line('VIEW2');
	         dbms_output.put_line(print_line);
	         CREATE_VIEW_2(cdc_list,non_cdc_list);
             
             dbms_output.put_line(chr(10));
             
             dbms_output.put_line('TRUNCATE');
	         dbms_output.put_line(print_line);
	         dbms_output.put_line('truncate table ' || p_table_owner || '.' || p_stage_table);
            
              
              dbms_output.put_line(chr(10));
	         
	         dbms_output.put_line('MOVE');
	         dbms_output.put_line(print_line);
	         MOVE_CDC_TO_STAGE(cdc_list,non_cdc_list);
             
             dbms_output.put_line(chr(10));
             
             dbms_output.put_line('REMOVE from TARGET');
	         dbms_output.put_line(print_line);
	         REMOVE_FROM_TARGET(cdc_list);
             
             dbms_output.put_line(chr(10));
             
	         dbms_output.put_line('INSERT FROM STAGE TO TARGET');
	         dbms_output.put_line(print_line);
	         dbms_output.put_line('INSERT INTO ' || p_table_owner || '.' || p_target_table || ' SELECT * FROM ' || p_table_owner || '.' || p_stage_table);
             

        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'SCHEMAS BETWEEN PROCESSING TABLES ARE NOT THE SAME. PLEASE INVESTIGATE');
            
        END IF;
	
END;
/

BEGIN
BATCH_CDC('INFA_SRC', 'SALARY_DATA_S', 'SALARY_DATA_CDC', 'SALARY_DATA');
END;
/


CREATE TABLE UPDATE_MATCH (
     TABLE_OWNER VARCHAR2(128) NOT NULL
     , TABLE_NAME VARCHAR2(128) NOT NULL
     , COLUMN_NAME VARCHAR2(128) NOT NULL
     , SORT_ORDER_NUMBER NUMBER(3,0) NOT NULL
	--, CONSTRAINT UPD_MATCH_PK PRIMARY KEY (TABLE_OWNER, TABLE_NAME, COLUMN_NAME)
);
