create or replace procedure batch_cdc(p_table_owner in all_tables.owner%type
				    , p_stage_table in all_tables.table_name%type
				    , p_cdc_table in all_tables.table_name%type
				   , p_target_table in all_tables.table_name%type)
									
as
	type columns_list_t is table of all_tab_columns.column_name%type index by pls_integer;

	cdc_list columns_list_t;
	non_cdc_list columns_list_t;
	subtype dynamic_statement_st is VARCHAR2(10000);
    
    procedure print_or_execute(p_sql IN VARCHAR2)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_sql);
        else
            dbms_output.put_line(p_sql);
            execute immediate p_sql;
            commit;
        end if;
    end;
	
	procedure print_extra_line
	is
	begin
		dbms_output.put_line(chr(10));
	end;
    
    
    function get_full_table_name(p_table_name IN VARCHAR2)
    return varchar2
    deterministic
    is
    begin
        return p_table_owner || '.' || p_table_name;
    end;
    
    procedure step_separate(p_step_name in VARCHAR2)
    is
    begin
        dbms_output.put_line(p_step_name);
        dbms_output.put_line(lpad('=', 40 , '='));
    end step_separate;

    procedure print_collection(p_collection IN columns_list_t)
    is
    begin
        for i in p_collection.FIRST..p_collection.LAST
	    loop
            dbms_output.put_line(p_collection(i));
        end loop;
    end print_collection;

    
    --given 2 tables, ensure that the columns are consistent
	function check_schemas(p_source_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE
						  , p_target_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE)
	return boolean
    IS
        v_differences NUMBER;
	begin
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
			ELSE a.data_type end as data_type
            
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
	            RETURN FALSE;
	        end if;

	        RETURN TRUE;

	end check_schemas;

    procedure stg_to_cdc
    is
        sql_query_c1 sql_builder_pkg.t_query;
    begin
        sql_query_c1.f_select := sql_builder_pkg.g_select_all;
        sql_query_c1.f_from := get_full_table_name(p_stage_table);
    
        sql_utils_pkg.truncate_table(p_cdc_table);
        print_or_execute('INSERT INTO '
                        || get_full_table_name(p_cdc_table)
                        || ' '
                        || sql_builder_pkg.get_select(sql_query_c1)
                        || sql_builder_pkg.get_from(sql_query_c1)
                        );
    end stg_to_cdc;


	procedure gather_cdc_columns(p_collection in out nocopy columns_list_t)
	is
		cursor cdc_columns is
        	select sort_order_number
			, column_name
		from update_match where UPPER(table_owner) = UPPER(p_table_owner)
		and UPPER(table_name) = UPPER(p_target_table)
        	order by sort_order_number asc;
	begin

		for rec_cdc in cdc_columns
		loop
			p_collection(rec_cdc.sort_order_number) := rec_cdc.column_name; 
		end loop;

	end gather_cdc_columns;


	procedure gather_non_cdc_columns(p_collection in out nocopy columns_list_t)
	is
		cursor non_cdc_columns is
		select column_id, column_name from all_tab_columns where owner = UPPER(p_table_owner) and table_name = UPPER(p_target_table)
		AND COLUMN_NAME NOT IN ('EFF_DATE' , 'END_DATE' , 'CREATE_ID' , 'LAST_UPDATE_ID')
		and column_name not in (
          		select column_name from update_match where UPPER(table_owner) = UPPER(p_table_owner) and UPPER(table_name) = UPPER(p_target_table)
		) 
		order by column_id asc;
		
	begin
		for rec_non_cdc in non_cdc_columns
		loop
			p_collection(rec_non_cdc.column_id) := rec_non_cdc.column_name; 
		end loop;

	end gather_non_cdc_columns;

    procedure insert_into_cdc(p_cdc_columns in columns_list_t)
    is
        sql_query_cdc1 sql_builder_pkg.t_query;
        sql_query_tgt sql_builder_pkg.t_query;
        sql_query_cdc2 sql_builder_pkg.t_query;
        sql_query_where_in sql_builder_pkg.t_query;
        
        v_cdc_columns_equality dynamic_statement_st;
    begin
            sql_query_cdc1.f_from := get_full_table_name(p_cdc_table);
            
            sql_query_tgt.f_select := sql_builder_pkg.g_select_all;
            sql_query_tgt.f_from := get_full_table_name(p_target_table);
            
            sql_query_cdc2.f_select := '1';
            sql_query_cdc2.f_from := get_full_table_name(p_cdc_table);
    
            for i in p_cdc_columns.FIRST..p_cdc_columns.LAST
        	loop
                sql_builder_pkg.add_select(sql_query_cdc1,p_cdc_columns(i)); 
                sql_builder_pkg.add_where(sql_query_tgt,p_cdc_columns(i), ','); 
                sql_builder_pkg.add_select(sql_query_where_in, p_cdc_columns(i));
            
                if i <> p_cdc_columns.LAST
                then
                    string_utils_pkg.add_str_token(v_cdc_columns_equality, 'b.' || p_cdc_columns(i) || ' = a.' || p_cdc_columns(i) || ' and ', ' ');
                else
                    string_utils_pkg.add_str_token(v_cdc_columns_equality, 'b.' || p_cdc_columns(i) || ' = a.' || p_cdc_columns(i), ' ');
                end if;
            end loop;
            
            sql_query_cdc2.f_where := v_cdc_columns_equality;
                                
            print_or_execute('INSERT INTO '
                                || sql_query_cdc1.f_from
                                || ' '
                                || sql_builder_pkg.get_select(sql_query_tgt)
                                || sql_builder_pkg.get_from(sql_query_tgt)
                                || ' a '
                                || sql_builder_pkg.get_where_in(sql_query_where_in, true)
                                || '('
                                || sql_builder_pkg.get_select(sql_query_cdc1)
                                || sql_builder_pkg.get_from(sql_query_cdc1)
                                || ' b '
                                || ') and exists ('
                                || sql_builder_pkg.get_select(sql_query_cdc2)
                                || sql_builder_pkg.get_from(sql_query_cdc2)
                                || ' b'
                                || sql_builder_pkg.get_where(sql_query_cdc2)
                                || ' and ((b.EFF_DATE <= a.EFF_DATE and b.END_DATE >= a.EFF_DATE) OR (b.EFF_DATE >= a.EFF_DATE and b.EFF_DATE <= a.END_DATE)))'
                            );

    end insert_into_cdc;

    procedure move_cdc_to_stage(p_cdc_columns in columns_list_t, p_non_cdc_columns in columns_list_t)
    is
        sql_query_cdc_to_stg_insert sql_builder_pkg.t_query;
        sql_query_cdc_to_stg_select sql_builder_pkg.t_query;

        function create_view_1(p_collection in columns_list_t)
        return varchar2
        is
            sql_query_v1 sql_builder_pkg.t_query;
        begin
            for i in p_collection.FIRST..p_collection.LAST
            LOOP
                sql_builder_pkg.add_select(sql_query_v1,p_collection(i));
            
                if i = p_collection.LAST
                then
                    sql_builder_pkg.add_select(sql_query_v1,'EFF_DATE) as row_id, k.*');
                    sql_builder_pkg.add_from(sql_query_v1,get_full_table_name(p_cdc_table) || ' k)');
                end if;
            
            END LOOP;
            
            string_utils_pkg.prepend_str_token(sql_query_v1.f_select, 'with vt1 as (SELECT ROW_NUMBER() OVER( ORDER BY ', '');
            
            return sql_query_v1.f_select
                || sql_builder_pkg.get_from(sql_query_v1);

        end create_view_1;

        function CREATE_VIEW_2(p_cdc_columns IN columns_list_t, p_non_cdc_columns IN columns_list_t)
        return varchar2
        is
            sql_query_v2 sql_builder_pkg.t_query;
            
            function dynamicJoin(p_collection IN columns_list_t)
            return VARCHAR2
            is
                sql_query_join sql_builder_pkg.t_query;
            begin
                for i in p_collection.FIRST..p_collection.LAST
                loop
                    sql_builder_pkg.add_where(sql_query_join, 'x1.' || p_collection(i) || ' = ' || 'x2.' || p_collection(i), '');
                    
                    if i <> p_collection.LAST
                    then
                        string_utils_pkg.add_str_token(sql_query_join.f_where, ' and ', ''); --v_join_clause := v_join_clause || ' and ';
                    end if;
                
                end loop;
                
                string_utils_pkg.prepend_str_token(sql_query_join.f_where
                                                , ' and '
                                                , '');
                        
                return sql_query_join.f_where;
            
            end dynamicJoin;

            function dynamicNotEqualClause(p_collection IN columns_list_t)
            return varchar2
            is
                sql_query_v2_where sql_builder_pkg.t_query;
            begin
                for i in p_collection.FIRST..p_collection.LAST
                loop
                sql_query_v2_where.f_where := sql_query_v2_where.f_where 
                                                || '(x1.' || p_collection(i) || ' <> ' || 'x2.' || p_collection(i) || ')'
                                                || ' or ' 
                                                || '(x1.' || p_collection(i) || ' is null' || ' and ' || 'x2.' || p_collection(i) || ' is not null)'
                                                || ' or '
                                                || '(x1.' || p_collection(i) || ' is not null' || ' and' || ' x2.' || p_collection(i) || ' is null)';
                                            
                    if i <> p_collection.LAST
                    then
                        string_utils_pkg.add_str_token(sql_query_v2_where.f_where, ' OR ', '');  
                    end if;
                end loop;
                
                string_utils_pkg.prepend_str_token(sql_query_v2_where.f_where
                                                , ' where x2.row_id is null or '
                                                , '');
                
                return sql_query_v2_where.f_where;
                
            end dynamicNotEqualClause;

        begin
            for i in p_cdc_columns.first..p_cdc_columns.last
            loop
                sql_builder_pkg.add_select(sql_query_v2, 'x1.' || p_cdc_columns(i));
                
                if i = p_cdc_columns.LAST
                then
                sql_builder_pkg.add_select(sql_query_v2
                                        , 'x1.EFF_DATE) as row_id2, x1.* '
                                        || ' from vt1 x1 left outer join vt1 x2'
                                        || ' on x1.row_id=x2.row_id+1');
                end if;
            end loop;
            
            string_utils_pkg.prepend_str_token(sql_query_v2.f_select, ', vt2 as (SELECT ROW_NUMBER() OVER( ORDER BY ', '');
            
            return sql_query_v2.f_select
            || dynamicJoin(p_cdc_columns)
            || dynamicNotEqualClause(p_non_cdc_columns)
            || ')';

        end CREATE_VIEW_2;

    begin --move_cdc_to_stage
        for i in p_cdc_columns.first..p_cdc_columns.last
        loop
            sql_builder_pkg.add_select(sql_query_cdc_to_stg_insert, p_cdc_columns(i));
            sql_builder_pkg.add_select(sql_query_cdc_to_stg_select, 'x1.' || p_cdc_columns(i));
        end loop;

        for i in p_non_cdc_columns.first..p_non_cdc_columns.last
        loop
            sql_builder_pkg.add_select(sql_query_cdc_to_stg_insert, p_non_cdc_columns(i));
            sql_builder_pkg.add_select(sql_query_cdc_to_stg_select, 'x1.' || p_non_cdc_columns(i));
            
            if i = p_non_cdc_columns.last
            THEN
                sql_builder_pkg.add_select(sql_query_cdc_to_stg_insert, ' EFF_DATE, END_DATE, CREATE_ID, LAST_UPDATE_ID)');
                sql_builder_pkg.add_select(sql_query_cdc_to_stg_select, 'x1.EFF_DATE, coalesce(x2.EFF_DATE-1, to_date(''31-DEC-2100'')) as END_DATE, x2.CREATE_ID, coalesce(x2.LAST_UPDATE_ID, x1.LAST_UPDATE_ID) as LAST_UPDATE_ID '
                                                                    || ' FROM vt2 x1 LEFT OUTER JOIN vt2 x2 ON ');
                
                for i in p_cdc_columns.first..p_cdc_columns.last
	            loop
                    sql_builder_pkg.add_where(sql_query_cdc_to_stg_select,'x1.' || p_cdc_columns(i) || ' = ' || 'x2.' || p_cdc_columns(i), '');
                    
                    if i <> p_cdc_columns.LAST
	                then
                        string_utils_pkg.add_str_token(sql_query_cdc_to_stg_select.f_where, ' and ', '');
                    end if;
                end loop;
            end if;
            
        end loop;
        
        string_utils_pkg.add_str_token(sql_query_cdc_to_stg_select.f_where, 'and x1.row_id2 = x2.row_id2-1', '');
        
        string_utils_pkg.prepend_str_token(sql_query_cdc_to_stg_insert.f_select, 'INSERT INTO ' || get_full_table_name(p_stage_table) || '(', '');

        print_or_execute(sql_query_cdc_to_stg_insert.f_select
                        || create_view_1(p_cdc_columns)
                        || create_view_2(p_cdc_columns,p_non_cdc_columns)
                        || sql_builder_pkg.get_select(sql_query_cdc_to_stg_select)
                        || sql_query_cdc_to_stg_select.f_where
                        );
                                
    end move_cdc_to_stage;

    procedure remove_from_target(p_cdc_columns in columns_list_t)
    IS
        
        sql_query_tgt sql_builder_pkg.t_query;
        sql_query_stg sql_builder_pkg.t_query;
        
        sql_query_where_in sql_builder_pkg.t_query;
        
        sql_query dynamic_statement_st;    
    begin
        sql_builder_pkg.add_from(sql_query_tgt, get_full_table_name(p_target_table));
        sql_builder_pkg.add_from(sql_query_stg, get_full_table_name(p_stage_table));
        
        for i in p_cdc_columns.first..p_cdc_columns.last
        loop
            sql_builder_pkg.add_select(sql_query_where_in, p_cdc_columns(i));
        end loop;
        
        print_or_execute('DELETE '
                        || sql_builder_pkg.get_from(sql_query_tgt)
                        || sql_builder_pkg.get_where_in(sql_query_where_in)
                        || '('
                        || sql_builder_pkg.get_select(sql_query_where_in)
                        || sql_builder_pkg.get_from(sql_query_stg)
                        || ')'
                        );
    
    end remove_from_target;
    
    procedure insert_to_target
    is
        sql_query_c1 sql_builder_pkg.t_query;
    begin
        sql_builder_pkg.add_select(sql_query_c1, sql_builder_pkg.g_select_all);
        sql_builder_pkg.add_from(sql_query_c1, get_full_table_name(p_stage_table));
    
        print_or_execute('INSERT INTO ' 
                    || get_full_table_name(p_target_table)
                    || ' '
                    || sql_builder_pkg.get_sql(sql_query_c1));
    end insert_to_target;
        
BEGIN
    error_pkg.assert(check_schemas(p_cdc_table, p_stage_table) and check_schemas(p_cdc_table, p_target_table), 'SCHEMAS BETWEEN PROCESSING TABLES ARE NOT THE SAME. PLEASE INVESTIGATE');
    
    --debug_pkg.debug_on;
	
    step_separate('CDC_COLUMNS');
    gather_cdc_columns(cdc_list);
	print_collection(cdc_list);
	
	print_extra_line;

    step_separate('NON_CDC_COLUMNS');
	gather_non_cdc_columns(non_cdc_list);
	print_collection(non_cdc_list);
    
	print_extra_line;

    step_separate('STG_TO_CDC --> Lets assume that data is loaded into CDC first (before stg)');
    --stg_to_cdc;
    print_extra_line;

    step_separate('INSERT_FROM_MSTR');
    insert_into_cdc(cdc_list);
    print_extra_line;


    step_separate('TRUNCATE');
    sql_utils_pkg.truncate_table(p_stage_table);
    print_extra_line;

    step_separate('MOVE');
	move_cdc_to_stage(cdc_list,non_cdc_list);
    print_extra_line;

    step_separate('REMOVE from TARGET');
	remove_from_target(cdc_list);    
    print_extra_line;

    step_separate('INSERT FROM STAGE TO TARGET');
    INSERT_TO_TARGET;
    
    --debug_pkg.debug_off;

exception
    when others then
    cleanup_pkg.exception_cleanup(true);
    dbms_output.put_line('error in program');
    raise;

end batch_cdc;
