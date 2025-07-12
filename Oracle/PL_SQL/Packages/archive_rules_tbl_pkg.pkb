create or replace package body archive_rules_tbl_pkg 
as
    type date_container_t is RECORD(
          dateValue DATE
        , dateCount NUMBER
    );
        dateContainer date_container_t;
        c_default_date_value CONSTANT DATE := '01-JAN-1799';

    type string_container_t is RECORD(  
          strValue string_utils_pkg.st_max_pl_varchar2
        , strCount NUMBER
    );
        strContainer string_container_t;
        c_default_string_value CONSTANT VARCHAR2(4) := 'NULL';

    type number_container_t is RECORD(
          numValue NUMBER
        , numCount NUMBER
    );
        numberContainer number_container_t;
        c_default_number_value CONSTANT NUMBER := -1;


    FUNCTION is_string(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
    RETURN BOOLEAN 
    IS 
    BEGIN
        IF p_column_datatype IN ('CHAR', 'VARCHAR2', 'VARCHAR')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END is_string; 

    FUNCTION is_number(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
    RETURN BOOLEAN 
    IS 
    BEGIN
        IF p_column_datatype IN ('FLOAT', 'INTEGER', 'NUMBER')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END is_number; 

    FUNCTION is_date(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
    RETURN BOOLEAN 
    IS 
    BEGIN 
        IF p_column_datatype IN ('DATE', 'TIMESTAMP')
        THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END is_date;


    procedure debug_print_or_execute(p_sql IN VARCHAR2)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_sql);
        else
            execute immediate p_sql;
        end if;

    end debug_print_or_execute;

    procedure reset_archive_parm_table
    is
    begin
        update archive_rules
        set upd_flag = 'N';

        commit;

    end reset_archive_parm_table;
    


    PROCEDURE partitioned_append_to_archive(p_src_owner          IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_src_table          IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
                                          , p_arch_owner         IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_arch_table         IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_column_name        IN ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%TYPE)  
    IS
        v_column_datatype ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
        l_insert_select_query sql_builder_pkg.t_query;
        insert_cursor ref_cursor_t;
        
         procedure execute_insert(p_where_clause IN VARCHAR2)
        is
            l_insert_query sql_builder_pkg.t_query;
        begin
            dbms_output.put_line('inside insert procedure');
            sql_builder_pkg.add_select(l_insert_query, sql_builder_pkg.g_select_all);
            sql_builder_pkg.add_from(l_insert_query, sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table) || sql_utils_pkg.get_partition_extension(p_src_partition_name));
            sql_builder_pkg.add_where(l_insert_query, p_where_clause, '');
            
            debug_print_or_execute(
            string_utils_pkg.get_str('INSERT /*+ APPEND NOSORT NOLOGGING */ INTO %1 %2', sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table), sql_builder_pkg.get_sql(l_insert_query))
            );
        end execute_insert;
    BEGIN
        select data_type
        into v_column_datatype
        from all_tab_columns
        where owner = p_src_owner
        and table_name = p_src_table
        and upper(column_name) = upper(p_column_name);

        error_pkg.assert(v_column_datatype is not null, 'SOMETHING IS WRONG WITH THE COLUMN NAME SPECIFIED. PLEASE INVESTIGATE');
        error_pkg.assert(is_string(v_column_datatype) or is_number(v_column_datatype) or is_string(v_column_datatype), 'UNSUPPORTED COLUMN DATATYPE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
        
        if is_string(v_column_datatype)
        then
			sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_column_name, c_default_string_value));

        elsif is_number(v_column_datatype)
        then
			sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_column_name, c_default_number_value));


        elsif is_date(v_column_datatype)
        then
			sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_column_name, c_default_date_value));

        end if;
        
        sql_builder_pkg.add_from(l_insert_select_query, string_utils_pkg.get_str('%1 %2', sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name)));
        sql_builder_pkg.add_group_by(l_insert_select_query, p_column_name);
        sql_builder_pkg.add_order_by(l_insert_select_query, 'count(1)');

        open insert_cursor for sql_builder_pkg.get_sql(l_insert_select_query);

        LOOP
            if is_string(v_column_datatype)
            then
                fetch insert_cursor into strContainer;

            elsif is_number(v_column_datatype)
            then
                fetch insert_cursor into numberContainer;

            elsif is_date(v_column_datatype)
            then
                fetch insert_cursor into dateContainer;

            end if;

            exit when insert_cursor%NOTFOUND;

            if is_string(v_column_datatype)
            then
                --execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_string_value || ''') = ''' || strContainer.strValue || '''');
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_column_name, string_utils_pkg.str_to_single_quoted_str(c_default_string_value), string_utils_pkg.str_to_single_quoted_str(strContainer.strValue)));

            elsif is_number(v_column_datatype)
            then
                --execute_insert(' where nvl(' || p_column_name || ', ' || c_default_number_value || ') = ''' || numberContainer.numValue || '''');
				execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_column_name, c_default_number_value, numberContainer.numValue));

            elsif is_number(v_column_datatype)
            then
                --execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_date_value || ''') = ''' || dateContainer.dateValue || '''');
				execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_column_name, string_utils_pkg.str_to_single_quoted_str(c_default_date_value), string_utils_pkg.str_to_single_quoted_str(dateContainer.dateValue)));

            end if;

            commit;

            END LOOP;

        close insert_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            cleanup_pkg.exception_cleanup;
            cleanup_pkg.close_cursor(insert_cursor);
            error_pkg.print_error('partitioned_append_to_archive');
            raise;
    END partitioned_append_to_archive;


    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_time_column       in archive_rules.archive_column_key%type
                                            , p_group_column       in archive_rules.archive_column_key%type)
    is
    begin
        error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
    exception
        WHEN OTHERS THEN
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end unpartitioned_append_to_archive;


    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_key_column         in archive_rules.archive_column_key%type)
    is
    begin
	    error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
    exception
        WHEN OTHERS THEN
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end unpartitioned_append_to_archive;



    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default 250000)
    is
        type ref_cursor_t is ref cursor;

        l_insert_cursor ref_cursor_t;
        type rowid_table_t is table of rowid index by pls_integer;
        rowid_table rowid_table_t;

        l_select_query        sql_builder_pkg.t_query;

        l_insert_select_query sql_builder_pkg.t_query;

        l_select varchar2(10000) :=  string_utils_pkg.get_str('SELECT rowid FROM %1 %2', sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name));

        l_insert varchar2(20000) := string_utils_pkg.get_str('INSERT /*+ NOSORT NOLOGGING*/ INTO %1 SELECT * FROM %2 %3 where where rowid = :rwid', sql_utils_pkg.get_full_table_name(p_arch_owner,p_arch_table), sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name));
    begin

        sql_builder_pkg.add_select(l_select_query, 'rowid');
        sql_builder_pkg.add_from(l_select_query, string_utils_pkg.get_str('%1 %2', sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name)));

        sql_builder_pkg.add_select(l_insert_select_query, sql_builder_pkg.g_select_all);

        sql_builder_pkg.add_from(l_insert_select_query, string_utils_pkg.get_str('%1 %2',sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name)));
        sql_builder_pkg.add_where(l_insert_select_query, 'rowid = :rwid', '');


		debug_print_or_execute(string_utils_pkg.get_str('ALTER TABLE %1 NOLOGGING', sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table)));

        if not debug_pkg.get_debug_state
        then
            open l_insert_cursor for sql_builder_pkg.get_sql(l_select_query);
            loop
                fetch l_insert_cursor bulk collect into rowid_table limit p_bulk_limit;
                exit when rowid_table.COUNT = 0;

                forall rec_rowid in indices of rowid_table
                    execute immediate 'INSERT ' || '/*+ NOSORT NOLOGGING*/ INTO '
                                    || sql_utils_pkg.get_full_table_name(p_arch_owner,p_arch_table)
                                    || ' '
                                    || sql_builder_pkg.get_sql(l_insert_select_query) using rowid_table(rec_rowid);
                    commit;
            end loop;

            close l_insert_cursor;

        else
            dbms_output.put_line(sql_builder_pkg.get_select(l_insert_select_query));
            dbms_output.put_line(l_insert || ' bulk limit -> ' || p_bulk_limit);

        end if;
        
        debug_print_or_execute(string_utils_pkg.get_str('ALTER TABLE %1 LOGGING', sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table)));
        
    exception
        when others then
            rollback;
            execute immediate string_utils_pkg.get_str('ALTER TABLE %1 LOGGING', sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table));
            cleanup_pkg.close_cursor(l_insert_cursor);
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end partitioned_collect_to_archive;

    procedure unpartitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_bulk_limit         in integer default 250000)
    is
    begin
	    error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
        
    exception
        WHEN OTHERS THEN
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end unpartitioned_collect_to_archive;
    
    
    procedure run_archival(p_job_nbr IN archive_rules.job_nbr%type, p_partition_flag IN archive_rules.partitioned%type)
    is
    begin
	    error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
        
    exception
        WHEN OTHERS THEN
            error_pkg.print_error('run_archival');
            raise;

    end run_archival;

end archive_rules_tbl_pkg;
