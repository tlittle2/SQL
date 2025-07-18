CREATE OR REPLACE PROCEDURE BATCH_CDC(p_table_owner IN ALL_TABLES.OWNER%TYPE
                                    , p_stage_table IN ALL_TABLES.TABLE_NAME%TYPE
                                    , p_cdc_table IN ALL_TABLES.TABLE_NAME%TYPE
                                    , p_target_table IN ALL_TABLES.TABLE_NAME%TYPE)
                                    
AS
    c_debug_mode CONSTANT BOOLEAN := TRUE;

    type columns_list_t is table of ALL_TAB_COLUMNS.COLUMN_NAME%TYPE index by pls_integer;
    
    cdc_list columns_list_t;
    non_cdc_list columns_list_t;
    subtype dynamic_statement_st is VARCHAR2(10000);
    
    procedure step_separate(p_step_name in VARCHAR2)
    is
    begin
        dbms_output.put_line(p_step_name);
        dbms_output.put_line(lpad('-', 40 , '-'));
    end step_separate;
    
    procedure print_collection(p_collection IN columns_list_t)
    is
    begin
        for i in p_collection.FIRST..p_collection.LAST
        loop
            dbms_output.put_line(p_collection(i));
        end loop;
    end print_collection;
        
    function str_comma_sep(p_in_str IN VARCHAR2)
    RETURN VARCHAR2 DETERMINISTIC
    IS
    BEGIN
        RETURN p_in_str || ',';
    END str_comma_sep;
    
    procedure run_commit
    is
    begin
        dbms_output.put_line('COMMIT;');
    end run_commit;
     
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
            WHEN 'RAW' THEN 'RAW(' || a.data_length || ')'
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
            
            dbms_output.put_line(v_differences);
            
            if v_differences > 0 
            then
                RETURN TRUE; 
            end if;
            
            RETURN FALSE;
            
    END CHECK_SCHEMAS;
    
    PROCEDURE STG_TO_CDC
    IS
    BEGIN
        if c_debug_mode
            then
                dbms_output.put_line('TRUNCATE TABLE '|| p_table_owner || '.' || p_cdc_table);
                dbms_output.put_line('INSERT INTO '|| p_table_owner || '.' || p_cdc_table || ' SELECT * FROM ' || p_stage_table);
                run_commit;
            else
                execute immediate 'TRUNCATE TABLE '|| p_table_owner || '.' || p_cdc_table;
                execute immediate 'INSERT INTO '|| p_table_owner || '.' || ' SELECT * FROM ' || p_stage_table;
                commit;
            end if;
    END STG_TO_CDC;
    
    
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
    
    END GATHER_CDC_COLUMNS;
    

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
    
    END GATHER_NON_CDC_COLUMNS;
    
    PROCEDURE INSERT_INTO_CDC(p_cdc_columns IN columns_list_t)
    IS
        v_insert_statement dynamic_statement_st;
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

            --7/13/25 -> change where clause to IN from NOT IN
            v_insert_statement := 'INSERT INTO ' || p_table_owner || '.' || p_cdc_table 
                                || ' SELECT * FROM ' || p_table_owner || '.' || p_target_table || ' a '
                                || ' WHERE (' || v_cdc_columns_string || ') in '
                                || '(select ' || v_cdc_columns_string || ' from ' || p_table_owner || '.' || p_cdc_table || ' b )'
                                || ' and exists (select 1 from '  || p_table_owner || '.' || p_cdc_table || ' b where '
                                || v_cdc_columns_equality
                                || ' and ((b.EFF_DATE <= a.EFF_DATE and b.END_DATE >= a.EFF_DATE) OR (b.EFF_DATE >= a.EFF_DATE and b.EFF_DATE <= a.END_DATE)))';
            
            if c_debug_mode
            then
                dbms_output.put_line(v_insert_statement);
                run_commit;
            else
                execute immediate v_insert_statement;
                commit;
            end if;
        
        END INSERT_INTO_CDC;
        
        procedure TRUNCATE_STAGE
        is
            v_trunc_statement dynamic_statement_st := 'truncate table ' || p_table_owner || '.' || p_stage_table;
        begin
            if c_debug_mode
            then
            dbms_output.put_line(v_trunc_statement);
            else
            execute immediate v_trunc_statement;
            end if;
        end TRUNCATE_STAGE;
    
        PROCEDURE MOVE_CDC_TO_STAGE(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
        IS
            v_insert_statement dynamic_statement_st := 'INSERT INTO ' || p_table_owner || '.' || p_stage_table || '(';
            v_select_statement dynamic_statement_st := 'SELECT ';
            
            FUNCTION CREATE_VIEW_1(p_collection IN columns_list_t)
            return varchar2
            is
            v_select dynamic_statement_st;
            begin
                for i in p_collection.FIRST..p_collection.LAST
                LOOP
                    v_select := v_select || p_collection(i);
                    if i <> p_collection.LAST
                    then
                        v_select := str_comma_sep(v_select);
                    else
                        v_select := v_select || ',EFF_DATE) as row_id, k.* from ' || p_table_owner || '.' || p_cdc_table || ' k';
                    end if;
                
                END LOOP;
              
                return 'with vt1 as (SELECT ROW_NUMBER() OVER( ORDER BY ' || v_select || ')';
              
            end CREATE_VIEW_1;
         
            function CREATE_VIEW_2(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
            return varchar2
            is
                v_select dynamic_statement_st := ', vt2 as (SELECT ROW_NUMBER() OVER( ORDER BY ';
            
                function dynamicJoin(p_collection IN columns_list_t)
                return VARCHAR2
                is
                    v_join_clause dynamic_statement_st;
                begin
                    for i in p_collection.FIRST..p_collection.LAST
                    loop
                        v_join_clause := v_join_clause || 'x1.' || p_collection(i) || ' = ' || 'x2.' || p_collection(i);
                        if i <> p_collection.LAST
                        then
                            v_join_clause := v_join_clause || ' and ';
                        end if;
                    end loop;
                    
                    return ' and ' || v_join_clause;
                end dynamicJoin;
                  
                function dynamicNotEqualClause(p_collection IN columns_list_t)
                return VARCHAR2
                is
                    v_where_clause dynamic_statement_st;
                begin
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
                    return ' where x2.row_id is null or ' || v_where_clause;
                end dynamicNotEqualClause;
            
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
                
                return v_select || dynamicJoin(p_cdc_columns) || dynamicNotEqualClause(p_non_cdc_columns) || ')';
              
            end CREATE_VIEW_2;
            
        BEGIN
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
                    v_select_statement := v_select_statement || ', x1.EFF_DATE, coalesce(x2.EFF_DATE-1, to_date(''31-DEC-2100'')) as END_DATE, x2.CREATE_ID, coalesce(x2.LAST_UPDATE_ID, x1.LAST_UPDATE_ID) as LAST_UPDATE_ID '
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
        
            if c_debug_mode
            then
                dbms_output.put_line(v_insert_statement);
                dbms_output.put_line(CREATE_VIEW_1(p_cdc_columns));
                dbms_output.put_line(CREATE_VIEW_2(p_cdc_columns,p_non_cdc_columns));
                dbms_output.put_line(v_select_statement || ';');
                run_commit;
            else
                execute immediate v_insert_statement
                                || CREATE_VIEW_1(p_cdc_columns)
                                || CREATE_VIEW_2(p_cdc_columns,p_non_cdc_columns)
                                || v_select_statement;
                commit;
            end if;
    
        END MOVE_CDC_TO_STAGE;
        
        PROCEDURE REMOVE_FROM_TARGET(p_cdc_columns IN columns_list_t)
        IS
            v_cdc_cols_string dynamic_statement_st;
            v_delete_string dynamic_statement_st;
        BEGIN
        
            for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
            LOOP
                       if i <> p_cdc_columns.LAST
                       then
                            v_cdc_cols_string := str_comma_sep(v_cdc_cols_string || p_cdc_columns(i));  
                       else
                            v_cdc_cols_string := v_cdc_cols_string || p_cdc_columns(i);
                       end if;
              END LOOP;
            
            v_delete_string := 'DELETE FROM ' || p_table_owner || '.' || p_target_table
                            || ' WHERE ' || '(' || v_cdc_cols_string || ') IN '||
                            '(SELECT '|| v_cdc_cols_string || ' FROM ' || p_table_owner || '.' || p_stage_table || ')';
            
            if c_debug_mode
            then
                dbms_output.put_line(v_delete_string || '; ');
                run_commit;
            else
                execute immediate v_delete_string;
                commit;
            end if;
        END REMOVE_FROM_TARGET;
        
        procedure INSERT_TO_TARGET
        is
            v_insert_statement dynamic_statement_st := 'INSERT INTO ' || p_table_owner || '.' || p_target_table || ' SELECT * FROM ' || p_table_owner || '.' || p_stage_table;
        begin
            if c_debug_mode
            then
                dbms_output.put_line(v_insert_statement);
                run_commit;
            else
                execute immediate v_insert_statement;
                commit;
            end if;

        end INSERT_TO_TARGET;
        
        

BEGIN
    IF CHECK_SCHEMAS(p_cdc_table, p_stage_table) OR CHECK_SCHEMAS(p_cdc_table, p_target_table)
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'SCHEMAS BETWEEN PROCESSING TABLES ARE NOT THE SAME. PLEASE INVESTIGATE');
    END IF;
    
    step_separate('CDC_COLUMNS');
    GATHER_CDC_COLUMNS(cdc_list);
    print_collection(cdc_list);
    dbms_output.put_line(chr(10));
    
    step_separate('NON_CDC_COLUMNS');
    GATHER_NON_CDC_COLUMNS(non_cdc_list);
    print_collection(non_cdc_list);
    dbms_output.put_line(chr(10));
    
    
    step_separate('STG_TO_CDC');
    STG_TO_CDC;
    dbms_output.put_line(chr(10));
    
    step_separate('INSERT_FROM_MSTR');
    INSERT_INTO_CDC(cdc_list);
    dbms_output.put_line(chr(10));

    
    step_separate('TRUNCATE');
    TRUNCATE_STAGE;
    dbms_output.put_line(chr(10));
    
    step_separate('MOVE');
    MOVE_CDC_TO_STAGE(cdc_list,non_cdc_list);
    dbms_output.put_line(chr(10));
    
    step_separate('REMOVE from TARGET');
    REMOVE_FROM_TARGET(cdc_list);    
    dbms_output.put_line(chr(10));
    
    step_separate('INSERT FROM STAGE TO TARGET');
    INSERT_TO_TARGET;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR IN PROGRAM');
    raise;
    
END BATCH_CDC;
/


BEGIN
BATCH_CDC('INFA_SRC', 'SALARY_DATA_STG', 'SALARY_DATA_CDC', 'SALARY_DATA');
END;
/


CREATE TABLE UPDATE_MATCH (
     TABLE_OWNER VARCHAR2(128) NOT NULL
     , TABLE_NAME VARCHAR2(128) NOT NULL
     , COLUMN_NAME VARCHAR2(128) NOT NULL
     , SORT_ORDER_NUMBER NUMBER(3,0) NOT NULL
    --, CONSTRAINT UPD_MATCH_PK PRIMARY KEY (TABLE_OWNER, TABLE_NAME, COLUMN_NAME)
);
