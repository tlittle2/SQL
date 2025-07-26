create or replace package body archive_rules_tbl_pkg 
as
    p_global_rec infa_global%rowtype;

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
    
    
    function get_base_tab_name_from_archive(p_table_name in varchar2)
    return varchar2
    is
    begin
        return substr(p_table_name, length(g_archive_table_prefix)+1,length(p_table_name));
    end get_base_tab_name_from_archive;
    
    
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
    
    function is_valid_data_type(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE)
    return boolean is
    begin
        if is_string(p_column_datatype) or is_number(p_column_datatype) or is_date(p_column_datatype)
        then
            return true;
        end if;
        return false;
    end is_valid_data_type;
    
    function check_schemas(p_source_owner in ALL_TAB_COLUMNS.owner%TYPE
                             , p_source_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE
                             , p_target_owner in ALL_TAB_COLUMNS.owner%TYPE
                             , p_target_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE)
    return boolean
    IS
        v_differences NUMBER;
    begin
        with schema_check as (
            select a.owner, a.table_name, a.column_name
            , case nvl(substr(data_type, 1, instr(data_type, '(', 1)-1),data_type)
            WHEN 'DATE'      THEN 'DATE'
            WHEN 'TIMESTAMP' then string_utils_pkg.get_str('TIMESTAMP(%1)', a.data_scale)
            WHEN 'FLOAT'     then string_utils_pkg.get_str('FLOAT(%1,%2)',  a.data_precision, a.data_scale)
            WHEN 'NUMBER'    then string_utils_pkg.get_str('NUMBER(%1,%2)', a.data_precision, a.data_scale)
            WHEN 'VARCHAR'   THEN string_utils_pkg.get_str('TEXT(%1)', a.data_length)
            WHEN 'VARCHAR2'  THEN string_utils_pkg.get_str('TEXT(%1)', a.data_length)
            WHEN 'CHAR'      THEN string_utils_pkg.get_str('TEXT(%1)', a.data_length)
            WHEN 'NVARCHAR2' THEN string_utils_pkg.get_str('TEXT(%1)', a.data_length)
            WHEN 'RAW'       THEN string_utils_pkg.get_str('RAW(%1)', a.data_length)
            ELSE a.data_type end as data_type
            , a.column_id
            from all_tab_columns a
        )

            select nvl(count(1), 1) into v_differences
            from (
                select column_name,data_type,column_id from schema_check where owner = p_target_owner and table_name = p_target_table
                MINUS
                select column_name,data_type,column_id from schema_check where owner = p_source_owner and table_name = p_source_table
                UNION ALL
                select column_name,data_type,column_id from schema_check where owner = p_source_owner and table_name = p_source_table
                MINUS
                select column_name,data_type,column_id from schema_check where owner = p_target_owner and table_name = p_target_table
            );

            dbms_output.put_line(v_differences);

            if v_differences > 0 
            then
                RETURN FALSE;
            end if;

            RETURN TRUE;

    end check_schemas;


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

  
    procedure check_parm_table_updates
	is
	l_count NUMBER;
	begin
	    select nvl(count(1),1)
		into l_count
		from archive_rules
		where UPD_FLAG =  global_constants_pkg.g_record_is_not_updated;
		
		assert_pkg.is_true(l_count = 0, 'SOME RECORDS WERE NOT UPDATED DURING ARCHIVAL. PLEASE INVESTIGATE');

	exception
	    when others then
	        raise;
	end check_parm_table_updates;
    
    
    procedure check_indexes
    is
        l_bad_idx_count NUMBER;
    begin
        select count(1)
        into l_bad_idx_count
        from (
        select idxs.table_name
        , ind_part.index_name
        , ind_part.partition_name
        , idxs.status as index_status
        , ind_part.status as index_partition_status
        from all_ind_partitions ind_part
        inner join all_indexes idxs on ind_part.index_name = idxs.index_name
        inner join partition_table_parm part_parm
        on idxs.table_owner = part_parm.table_owner
        and idxs.table_name = part_parm.table_name
        where ind_part.status = 'UNUSABLE' or idxs.status = 'UNUSABLE'
        );
        
        assert_pkg.is_true(l_bad_idx_count = 0, 'UNUSABLE OR INVALID INDEXES HAVE BEEN DETECTED. PLEASE INVESTIGATE');
        
    exception
        when others then
            error_pkg.print_error('check_indexes');
            raise;
    end check_indexes;
    
    procedure check_column_datatype(p_owner in all_tab_partitions.table_owner%type, p_table all_tab_partitions.table_name%type, p_column in all_tab_columns.column_name%type, p_column_datatype IN OUT NOCOPY all_tab_columns.data_type%type)
    is
    begin
        select data_type
        into p_column_datatype
        from all_tab_columns
        where owner = p_owner
        and table_name = p_table
        and upper(column_name) = upper(p_column);

        assert_pkg.is_true(p_column_datatype is not null, 'SOMETHING IS WRONG WITH THE COLUMN NAME SPECIFIED. PLEASE INVESTIGATE');
		assert_pkg.is_true(is_string(p_column_datatype) or is_number(p_column_datatype) or is_date(p_column_datatype), 'UNSUPPORTED COLUMN DATATYPE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
    
	exception
		when others then
		    raise;
	end check_column_datatype;
    

    PROCEDURE partitioned_append_to_archive(p_src_owner          IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_src_table          IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
                                          , p_arch_owner         IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_arch_table         IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_column_name        IN ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%TYPE)  
    IS
        v_column_datatype ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
        l_insert_select_query sql_builder_pkg.t_query;
        insert_cursor sql_utils_pkg.ref_cursor_t;
        
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
        check_column_datatype(p_src_owner, p_src_table, p_column_name, v_column_datatype);
        
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

            elsif is_date(v_column_datatype)
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
        l_insert_cursor sql_utils_pkg.ref_cursor_t;
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
    
    
    PROCEDURE run_partition_archival(p_move_run_mode IN CHAR, p_job_nbr IN archive_rules.JOB_NBR%type)
    is
        cursor cur_dataToArchive is
            select src.table_owner as src_table_owner
            , src.table_name as src_table_name
            , src.partitioned  as src_partitioned
            , src.years_to_keep as src_yrs_to_keep
            , src.archive_column_key as src_where_key
            , src.archive_group_key as src_group_key
            , arch.table_owner as arch_table_owner
            , arch.table_name as arch_table_name
            from archive_rules src
            inner join archive_rules arch
            on src.job_nbr = arch.job_nbr
            and src.partitioned = arch.partitioned
    		and src.UPD_FLAG = arch.UPD_FLAG
            and src.table_name = get_base_tab_name_from_archive(arch.table_name)
            where src.job_nbr = p_job_nbr
            and src.partitioned = partition_parm_pkg.g_is_partitioned
    		and src.UPD_FLAG =  global_constants_pkg.g_record_is_not_updated;
    		
    		type t_all_tab_parts is RECORD(
                source_table_owner all_tab_partitions.table_owner%type
              , source_table_name all_tab_partitions.table_name%type
              , source_partition_name all_tab_partitions.table_name%type
              , archive_table_owner all_tab_partitions.table_owner%type
              , archive_table_name all_tab_partitions.table_name%type
              , archive_partition_name all_tab_partitions.table_name%type);
            
    		v_all_tab_parts t_all_tab_parts;
    	  
    	    p_global_rec infa_global%rowtype;
            
            l_archive_cutoff_dte DATE;
            
            procedure partition_archive_prechecks
    		is
    		    l_column_datatype all_tab_columns.column_name%type;
                l_partitioned_table_in_parm partition_table_parm.partitioned%type;
                l_partitioned_table_in_db NUMBER;
                
                procedure check_parm_table_and_db(p_table_owner all_tab_partitions.table_owner%type, p_table_name all_tab_partitions.table_name%type)
                is
                begin
                    select partitioned
                    into l_partitioned_table_in_parm
                    from partition_table_parm
                    where table_owner = p_table_owner 
                    and table_name =  p_table_name;
                    
                    select count(table_name)
                    into l_partitioned_table_in_db
                    from all_tab_partitions
                    where table_owner = p_table_owner
                    and table_name = p_table_name;
                    
                    assert_pkg.is_true(l_partitioned_table_in_parm = partition_parm_pkg.g_is_partitioned, 'TABLE IS NOT PARTITIONED IN THE PARM TABLE. PLEASE INVESTIGATE');
                    assert_pkg.is_true(l_partitioned_table_in_db = 1, 'TABLE DOESNT EXIST AS PARTITIONED TABLE IN THE DATABASE. PLEASE INVESTIGATE');
                
                end check_parm_table_and_db;
                
    		begin
    		    assert_pkg.is_valid_run_mode(p_move_run_mode, 'INVALID RUN MODE PROVIDED. PLEASE CORRECT');
    		    
    		    for rec_dataToArchive in cur_dataToArchive
    		    loop
    		        assert_pkg.is_true(check_schemas(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name), string_utils_pkg.get_str('Table Schema for %1 and %2 are not consistent. Please investigate.', rec_dataToArchive.src_table_name, rec_dataToArchive.arch_table_name));
                    
                    check_parm_table_and_db(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name);
                    check_parm_table_and_db(rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name);
                    
                    --check group by column first, then the where clause so we can reuse variable for an extra check of the where clause
    				check_column_datatype(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.src_group_key, l_column_datatype);
    				check_column_datatype(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.src_where_key, l_column_datatype);
    				
                    error_pkg.assert(is_date(l_column_datatype) or (is_string(l_column_datatype) AND rec_dataToArchive.src_where_key in ('STATEMENT_PRD_YR_QRTR')), 'UNSUPPORTED COLUMN DATATYPE FOR WHERE CLAUSE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
    			end loop;
            exception
            when others then
                error_pkg.print_error('partition_archive_prechecks');
                raise;
            end partition_archive_prechecks;
    begin
        partition_archive_prechecks;
    	
        table_access_pkg.get_global_row_logic(p_global_rec, p_move_run_mode);
        
        for rec_dataToArchive in cur_dataToArchive
        loop
            error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
            
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, p_upd_flag => global_constants_pkg.g_record_is_being_processed);            
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name, p_upd_flag => global_constants_pkg.g_record_is_being_processed);
            commit;
            
            l_archive_cutoff_dte := date_utils_pkg.calculate_new_date(date_utils_pkg.g_backwards_direction,p_global_rec.run_dte, rec_dataToArchive.src_yrs_to_keep);
            
        end loop;
        
    exception
        when others then
            error_pkg.print_error('run_partition_archival');
            raise;
    end run_partition_archival;
    
    
    PROCEDURE run_non_partition_archival(p_move_run_mode IN CHAR, p_job_nbr IN archive_rules.JOB_NBR%type)
    is
        cursor cur_dataToArchive is
        select src.table_owner as src_table_owner
        , src.table_name as src_table_name
        , src.partitioned  as src_partitioned
        , src.years_to_keep as src_yrs_to_keep
        , src.archive_column_key as src_where_key
        , src.archive_group_key as src_group_key
        , arch.table_owner as arch_table_owner
        , arch.table_name as arch_table_name
        from archive_rules src
        inner join archive_rules arch
        on src.job_nbr = arch.job_nbr
        and src.partitioned = arch.partitioned
    	and src.UPD_FLAG = arch.UPD_FLAG
        and src.table_name = get_base_tab_name_from_archive(arch.table_name)
        where src.job_nbr = p_job_nbr
        and src.partitioned = partition_parm_pkg.g_is_not_partitioned
    	and src.UPD_FLAG = global_constants_pkg.g_record_is_not_updated;
        
        l_archive_cutoff_dte DATE;
            
        procedure archive_non_partition_prechecks
        is
            l_column_datatype all_tab_columns.column_name%type;
        begin
            assert_pkg.is_valid_run_mode(p_move_run_mode, 'INVALID RUN MODE PROVIDED. PLEASE CORRECT');
            
            for rec_dataToArchive in cur_dataToArchive
            loop
                assert_pkg.is_true(check_schemas(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name), string_utils_pkg.get_str('Table Schema for %1 and %2 are not consistent. Please investigate.', rec_dataToArchive.src_table_name, rec_dataToArchive.arch_table_name));
                
                --check group by column first, then the where clause so we can reuse variable for an extra check of the where clause (in the case of STATEMENT_PRD_YR_QRTR)
                check_column_datatype(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.src_group_key, l_column_datatype);
                check_column_datatype(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, rec_dataToArchive.src_where_key, l_column_datatype);
                
                error_pkg.assert(is_date(l_column_datatype) or (is_string(l_column_datatype) AND rec_dataToArchive.src_where_key in ('STATEMENT_PRD_YR_QRTR')), 'UNSUPPORTED COLUMN DATATYPE FOR WHERE CLAUSE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
            end loop;
        exception
            when others then
                raise;
        end archive_non_partition_prechecks;
    
    begin
        archive_non_partition_prechecks;
        
        table_access_pkg.get_global_row_logic(p_global_rec, p_move_run_mode);
        
        for rec_dataToArchive in cur_dataToArchive
        loop
            error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
            
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, p_upd_flag => global_constants_pkg.g_record_is_being_processed);
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name, p_upd_flag => global_constants_pkg.g_record_is_being_processed);
            commit;
            
            l_archive_cutoff_dte := date_utils_pkg.calculate_new_date(date_utils_pkg.g_backwards_direction,p_global_rec.run_dte, rec_dataToArchive.src_yrs_to_keep);
            
            
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.src_table_owner, rec_dataToArchive.src_table_name, p_upd_flag => global_constants_pkg.g_record_is_updated);
            table_access_pkg.update_archive_rules_2(rec_dataToArchive.arch_table_owner, rec_dataToArchive.arch_table_name, p_upd_flag => global_constants_pkg.g_record_is_updated);
            commit;
            
        end loop;
    end run_non_partition_archival;

end archive_rules_tbl_pkg;
