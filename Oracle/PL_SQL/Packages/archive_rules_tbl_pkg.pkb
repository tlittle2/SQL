create or replace package body archive_rules_tbl_pkg 
as

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
        set upd_flag = 'N'
        
        commit;
    
    end reset_archive_parm_table;
    
   procedure archive_rules_preanalysis(p_number_of_runs in NUMBER, p_partitioned_flag IN partition_table_parm.partitioned%type)
   is
        TYPE jobParm_t is RECORD(
        table_owner partition_table_parm.table_owner%type,
        table_name  partition_table_parm.table_name%type,
        job_nbr     partition_table_parm.job_nbr%type);
        
        type parm_table_update_t is table of jobParm_t index by pls_integer;
        
        cursor cur_dataToArchive is --find a way to consider both the partition parm table AND the archive rules table (to ensure both tables agree)
            SELECT ROWNUM                          as rwnum
            , MOD(ROWNUM -1, p_number_of_runs) + 1 as job_nbr
            , v.num_rows                           as tbl_volume
            , parm_src.table_owner                 as src_table_owner
            , parm_src.table_name                  as src_table_name
            , parm_arch.table_owner                as arch_table_owner
            , parm_arch.table_name                 as arch_table_name
            from all_tables v
            
            inner join archive_rules parm_src
            on v.owner = parm_src.table_owner
            and v.table_name = parm_src.table_name
            
            inner join archive_rules parm_arch
            on parm_src.table_name = substr(parm_arch.table_name, instr(parm_arch.table_name, archive_rules_tbl_pkg.g_archive_table_prefix, 1), length(archive_rules_tbl_pkg.g_archive_table_prefix))
            and parm_src.partitioned = parm_arch.partitioned
            and parm_src.partition_type = parm_arch.partition_type
            where parm_src.partitioned = p_partition_flag
            and substr(parm_arch.table_name, 1, length(archive_rules_tbl_pkg.g_archive_table_prefix)) = archive_rules_tbl_pkg.g_archive_table_prefix
            
            order by job_nbr, tbl_volume asc;
            
            src_tables_update parm_table_update_t;
            arch_tables_update parm_table_update_t;
        
        procedure updateJobNbrs(p_collection IN parm_table_update_t, p_partition_flag IN partition_table_parm.partitioned%type))
        is
        begin
            
            forall i in indices of p_collection
            update archive_rules
            set job_nbr = p_collection(i).job_nbr
            where table_owner = p_collection(i).table_owner
            and table_name = p_collection(i).table_name
            and partitioned = p_partitioned_flag;
            
        end updateJobNbrs;
    
    BEGIN
        error_pkg.assert(p_partitioned_flag in (PARTITION_PARM_PKG.g_is_partitioned, PARTITION_PARM_PKG.g_is_not_partitioned);
    
        update partition_table_parm
        set job_nbr = null
        where partitioned = p_partition_flag;
        commit;
        
        for rec_archive in cur_dataToArchive
        loop
            src_tables_update(rec_archive.rwnum).table_owner := rec_archive.src_table_owner;
            src_tables_update(rec_archive.rwnum).table_name  := rec_archive.src_table_name;
            src_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
            
            src_tables_update(rec_archive.rwnum).table_owner := rec_archive.arch_table_owner;
            src_tables_update(rec_archive.rwnum).table_name  := rec_archive.arch_table_name;
            src_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
        
        end loop;
        
        updateJobNbrs(src_tables_update);
        updateJobNbrs(arch_tables_update);
        
        commit;

    END archive_rules_preanalysis;
    
    
    PROCEDURE partitioned_append_to_archive(p_src_owner          IN MY_PARM_TABLE.TABLE_OWNER%TYPE
                                          , p_src_table          IN MY_PARM_TABLE.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
                                          , p_arch_owner         IN MY_PARM_TABLE.TABLE_OWNER%TYPE
                                          , p_arch_table         IN MY_PARM_TABLE.TABLE_NAME%TYPE
                                          , p_key_column         IN ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%TYPE)  
    IS
        v_column_datatype ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
        insert_cursor sys_refcursor;
		
		l_insert_select_query sql_builder_pkg.t_query;
        
        type date_container_t is RECORD(
              dateValue DATE
            , dateCount NUMBER
        );
            dateContainer date_container_t;
            c_default_date_value CONSTANT DATE = '01-JAN-1799';
        
        type string_container_t is RECORD(
              strValue VARCHAR2(32767);
            , strCount NUMBER
        );
            strContainer string_container_t;
            c_default_string_value CONSTANT VARCHAR2 = 'NULL';
        
        type number_container_t is RECORD(
              numValue NUMBER
            , numCount NUMBER
        );
            numberContainer number_container_t;
            c_default_number_value CONSTANT NUMBER = -1;
            
            
        
        FUNCTION is_string(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
        RETURN BOOLEAN 
        IS 
        BEGIN
            IF p_column_datatype IN ('CHAR', 'VARCHAR2', 'VARCHAR')
            THEN
                RETURN TRUE;
            END IF;
            
            RETURN FALSE;
        END; 
        
        FUNCTION is_number(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
        RETURN BOOLEAN 
        IS 
        BEGIN
            IF p_column_datatype  IN ('FLOAT', 'INTEGER', 'NUMBER')
            THEN
                RETURN TRUE;
            END IF;
            
            RETURN FALSE;
        END; 
        
        FUNCTION is_date(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
        RETURN BOOLEAN 
        IS 
        BEGIN 
            IF p_column_datatype IN ('DATE', 'TIMESTAMP')
            THEN
                RETURN TRUE;
            END IF;
            
            RETURN FALSE;
        END;
        
        procedure execute_insert(p_where_clause IN VARCHAR2)
        is
		    l_insert_query sql_builder_pkg.t_query;
        begin
		    sql_builder_pkg.add_select(l_insert_query, sql_builder_pkg.g_select_all);
			sql_builder_pkg.add_from(l_insert_query, sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table) || sql_utils_pkg.get_partition_extension(p_src_partition_name));
			sql_builder_pkg.add_where(l_insert_query, p_where_clause);
		
            debug_print_or_execute(
            'INSERT /*+ APPEND NOSORT NOLOGGING */ INTO '
			|| sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table) 
			|| sql_builder_pkg.get_sql(l_insert_query);
            );
        end;
        
    BEGIN
        select data_type
        into v_column_datatype
        from all_tab_columns
        where owner = p_src_owner
        and table_name = p_src_table
        and upper(column_name) = upper(p_column_name);
        
        error_pkg.assert(v_column_datatype is not null, 'SOMETHING IS WRONG WITH THE COLUMN NAME SPECIFIED. PLEASE INVESTIGATE');
        
        error_pkg.assert(is_string(v_column_datatype) or is_number(v_column_datatype) or is_string(v_column_datatype), 'UNSUPPORTED COLUMN DATATYPE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
		
		sql_builder_pkg.add_from(l_insert_select_query, sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table) || sql_utils_pkg.get_partition_extension(p_src_partition_name));
		sql_builder_pkg.add_group_by(l_insert_select_query, p_column_name);
		sql_builder_pkg.add_order_by(l_insert_select_query, 'count(1)');
        
        if is_string(v_column_datatype)
        then
			sql_builder_pkg.add_select(l_insert_select_query,'SELECT NVL(' || p_column_name || ', ' || c_default_string_value || '), count(1)');
            
        elsif is_number(v_column_datatype)
        then
		    sql_builder_pkg.add_select(l_insert_select_query,'SELECT NVL(' || p_column_name || ', ' || c_default_number_value || '), count(1)');
            
        elsif is_date(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,'SELECT NVL(' || p_column_name || ', ' || c_default_date_value || '), count(1)');

        end if;
		
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
                execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_string_value || ''') = ''' || strContainer.strValue || '''');
                
            elsif is_number(v_column_datatype)
            then
                execute_insert(' where nvl(' || p_column_name || ', ' || c_default_number_value || ') = ''' || numberContainer.numValue || '''');
            
            elsif is_number(v_column_datatype)
            then
                execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_date_value || ''') = ''' || dateContainer.dateValue || '''');
            
            end if;
            
            commit;
            
        END LOOP;
        
        close insert_cursor;
    
    EXCEPTION
        WHEN OTHERS THEN
			exception_cleanup;
			cleanup_pkg.close_cursor(insert_cursor);
    END partitioned_append_to_archive;
                              
                              
                                       
    procedure remove_from_archive_rules(p_table_owner        IN archive_rules.table_owner%type
                                      , p_table_name         IN archive_rules.table_name%type)
    is
    begin
        delete from archive_rules
        where table_owner = p_table_owner
        and table_name = p_table_name;
        
        commit;
    
    end remove_from_archive_rules;
                                      
                                          
                                          
    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_key_column         in archive_rules.archive_column_key%type)
    is
    begin
    
    end unpartitioned_append_to_archive;
                                            
                                            
                                            
    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default 250000)
    is
		
        l_insert_cursor ref_cursor_t
        type rowid_table_t is table of rowid index by pls_integer;
        rowid_table rowid_table_t;
		
		l_select_query        sql_builder_pkg.t_query;
		
		l_insert_select_query sql_builder_pkg.t_query;
        
        --l_select varchar2(10000) := 'SELECT rowid FROM '
        --                          || sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table) || ' ' || sql_utils_pkg.get_partition_extension(p_src_partition_name);
        --                          
        --l_insert varchar2(20000) := 'INSERT ' || '/*+ NOSORT NOLOGGING*/'
        --                          || ' INTO '
        --                          || sql_utils_pkg.get_full_table_name(p_arch_owner,p_arch_table)
        --                          || 'SELECT * FROM '
        --                          || sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table)
        --                          || ' '
        --                          || sql_utils_pkg.get_partition_extension(p_src_partition_name);
        --                          || ' where rowid = :rwid';
                                  
    begin
	
		sql_builder_pkg.add_select(l_select_query, 'rowid');
		sql_builder_pkg.add_from(l_select_query, sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table) || ' ' || sql_utils_pkg.get_partition_extension(p_src_partition_name));
		
		sql_builder_pkg.add_select(l_insert_select_query, sql_builder_pkg.g_select_all);
		sql_builder_pkg.add_from(l_insert_select_query, sql_utils_pkg.get_full_table_name(p_src_owner,p_src_table) || ' ' || sql_utils_pkg.get_partition_extension(p_src_partition_name));
		sql_builder_pkg.add_where(l_insert_select_query, 'rowid = :rwid');
		
		
        debug_print_or_execute('ALTER TABLE ' || p_arch_owner || '.' || p_arch_table || ' NOLOGGING');
        
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
            dbms_output.put_line(l_select);
            dbms_output.put_line(l_insert || ' bulk limit -> ' || p_bulk_limit);
            
        end if;
        
        debug_print_or_execute('ALTER TABLE ' || p_arch_owner || '.' || p_arch_table || ' LOGGING');
    
    
    exception
        when others then
        rollback;
        execute immediate 'ALTER TABLE ' || p_arch_owner || '.' || p_arch_table || ' LOGGING'
        cleanup_pkg.close_cursor(l_insert_cursor);
        raise;
    
    end partitioned_collect_to_archive;
                                          
    procedure unpartitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_bulk_limit         in integer default 250000)
    is
    begin
    
    
    end unpartitioned_collect_to_archive;



end archive_rules_tbl_pkg;
