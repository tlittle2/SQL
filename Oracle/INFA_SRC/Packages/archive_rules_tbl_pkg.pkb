create or replace package body archive_rules_tbl_pkg 
as
    g_global_rec infa_global%rowtype;
    
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

    function get_archive_table_prefix
    return varchar2 deterministic
    is
    begin
        return g_archive_table_prefix;
    end get_archive_table_prefix;

    function get_base_tab_name_from_archive(p_table_name in varchar2)
    return varchar2
    is
    begin
        return substr(p_table_name, length(g_archive_table_prefix)+1,length(p_table_name));
    end get_base_tab_name_from_archive;


    function get_arch_prefix_from_tab(p_table_name in varchar2)
    return varchar2
    is
    begin
        return substr(p_table_name, 1, length(archive_rules_tbl_pkg.g_archive_table_prefix));
    end get_arch_prefix_from_tab;


    function get_arch_table(p_table_name in archive_rules.table_name%type)
    return archive_rules%rowtype
    is
    l_returnvalue archive_rules%rowtype;
    begin
        select *
        into l_returnvalue 
        from archive_rules
        where table_name = concat(g_archive_table_prefix, p_table_name);

        return l_returnvalue;

    exception
        when no_data_found then
        raise;
    end get_arch_table;


    FUNCTION is_string(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
    RETURN BOOLEAN 
    IS 
    BEGIN
        IF p_column_datatype IN ('CHAR', 'VARCHAR2', 'VARCHAR', 'NVARCHAR2')
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

    procedure is_valid_data_type(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE)
    is
    begin
        assert_pkg.is_not_null(p_column_datatype, 'SOMETHING IS WRONG WITH THE COLUMN NAME SPECIFIED. PLEASE INVESTIGATE');
        assert_pkg.is_true(is_string(p_column_datatype) or is_number(p_column_datatype) or is_date(p_column_datatype), 'INVALID DATATYPE PASSED. PLEASE INVESTIGATE');
    end is_valid_data_type;

    procedure check_schemas(p_source_owner in ALL_TAB_COLUMNS.owner%TYPE
                             , p_source_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE
                             , p_target_owner in ALL_TAB_COLUMNS.owner%TYPE
                             , p_target_table IN ALL_TAB_COLUMNS.TABLE_NAME%TYPE)
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

            assert_pkg.is_equal_to_zero(v_differences,string_utils_pkg.get_str('%1 differences in table schemas between %2 and %3', v_differences, p_source_table, p_target_table));

    exception
        when others then
            error_pkg.print_error('check_schemas');
            raise;
    end check_schemas;

    procedure check_parm_table_updates(p_job_nbr in archive_rules.job_nbr%type)
    is
    l_count NUMBER;
    begin
        select nvl(count(1),1)
        into l_count
        from archive_rules
        where job_nbr = p_job_nbr
        and UPD_FLAG =  global_constants_pkg.g_record_is_not_updated;

        assert_pkg.is_equal_to_zero(l_count, 'SOME RECORDS WERE NOT UPDATED DURING ARCHIVAL. PLEASE INVESTIGATE');

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

        assert_pkg.is_equal_to_zero(l_bad_idx_count, 'UNUSABLE OR INVALID INDEXES HAVE BEEN DETECTED. PLEASE INVESTIGATE');

    exception
        when others then
            error_pkg.print_error('check_indexes');
            raise;
    end check_indexes;

    function get_column_datatype(p_owner in all_tab_partitions.table_owner%type, p_table all_tab_partitions.table_name%type, p_column in all_tab_columns.column_name%type)
    return all_tab_columns.data_type%type
    is
    p_column_datatype all_tab_columns.data_type%type;
    begin
        select data_type
        into p_column_datatype
        from all_tab_columns
        where owner = p_owner
        and table_name = p_table
        and upper(column_name) = upper(p_column);

        is_valid_data_type(p_column_datatype);

        return p_column_datatype; 
    exception
        when others then
            raise;
    end get_column_datatype;
    
--===============================================================drivers==============================================================================================================
    
    PROCEDURE run_purge(p_run_mode IN global_constants_pkg.g_regular_run%type, p_job_nbr IN archive_rules.JOB_NBR%type)
    is
        cursor runPurge is
        SELECT
        a.table_owner arch_table_owner
      , a.table_name arch_table_name
      , p.table_owner part_table_owner
      , p.table_name part_table_name
      , a.years_to_keep
      , a.archive_column_key
      , a.archive_group_key
      , nvl(p.partitioned, partition_parm_pkg.g_is_not_partitioned) as partitioned
      , p.partition_type
      , p.partition_prefix
      FROM
      archive_rules a
      left outer join partition_table_parm p
      on a.table_owner = p.table_owner
      and a.table_name = p.table_name
      where a.job_nbr = p_job_nbr;
    
    begin
        error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
    exception
        when others then
            error_pkg.print_error('run_purge');
            raise;
    end run_purge;
    
    
    PROCEDURE run_archival(p_move_run_mode IN global_constants_pkg.g_regular_run%type, p_job_nbr IN archive_rules.JOB_NBR%type)
    is
        l_column_datatype all_tab_columns.column_name%type;
        l_archive_cutoff_dte DATE;
        
        cursor runArchival is
        select b.*
        , a.years_to_keep, a.archive_column_key, a.archive_group_key
        , p.partitioned, p.partition_type, p.partition_prefix
        from archive_rules a
        inner join base_archive_table_match b
        on a.table_owner = b.base_table_owner
        and a.table_name = b.base_table_name
        left outer join partition_table_parm p
        on b.base_table_owner = p.table_owner
        and b.base_table_name = p.table_name
        where a.job_nbr = p_job_nbr
        and a.upd_flag = global_constants_pkg.g_record_is_not_updated;
        
        procedure partition_archive_prechecks
        is
        begin
            for rec_archival in runArchival
            loop
                check_schemas(rec_archival.base_table_owner, rec_archival.base_table_name, rec_archival.archive_table_owner, rec_archival.archive_table_name);
                
                l_column_datatype:= get_column_datatype(rec_archival.base_table_owner, rec_archival.base_table_name, rec_archival.ARCHIVE_GROUP_KEY); --> really acts as a dummy assignment
                l_column_datatype:= get_column_datatype(rec_archival.base_table_owner, rec_archival.base_table_name, rec_archival.ARCHIVE_COLUMN_KEY);
                
                assert_pkg.is_true(is_date(l_column_datatype) or (is_string(l_column_datatype) AND rec_archival.ARCHIVE_COLUMN_KEY in ('STATEMENT_PRD_YR_QRTR')), 'UNSUPPORTED COLUMN DATATYPE FOR WHERE CLAUSE FOR THIS PROCEDURE. PLEASE INVESTIGATE');
            end loop;
        
        end partition_archive_prechecks;
    
    begin
        assert_pkg.is_valid_run_mode(p_move_run_mode, 'INVALID RUN MODE PROVIDED. PLEASE CORRECT');
        partition_archive_prechecks;
        
        g_global_rec := infa_global_tapi.get_global_row_logic(p_move_run_mode);
        
        for rec_archival in runArchival
        loop
            l_archive_cutoff_dte := date_utils_pkg.calculate_new_date(g_global_rec.run_dte, rec_archival.YEARS_TO_KEEP);
            
            if rec_archival.PARTITIONED = partition_parm_pkg.g_is_partitioned
            then
                run_partitioned_archival(
                p_BASE_TABLE_OWNER     => rec_archival.BASE_TABLE_OWNER
               , p_BASE_TABLE_NAME     => rec_archival.BASE_TABLE_NAME
               , p_ARCHIVE_TABLE_OWNER => rec_archival.ARCHIVE_TABLE_OWNER
               , p_ARCHIVE_TABLE_NAME  => rec_archival.ARCHIVE_TABLE_NAME
               , p_cutoff_dte          => l_archive_cutoff_dte
               , p_ARCHIVE_GROUP_KEY   => rec_archival.ARCHIVE_GROUP_KEY
               , p_PARTITION_TYPE      => rec_archival.PARTITION_TYPE
               , p_PARTITION_PREFIX    => rec_archival.PARTITION_PREFIX);
            else
                 run_nonpartitioned_archival(
                 p_BASE_TABLE_OWNER    => rec_archival.BASE_TABLE_OWNER
               , p_BASE_TABLE_NAME     => rec_archival.BASE_TABLE_NAME
               , p_ARCHIVE_TABLE_OWNER => rec_archival.ARCHIVE_TABLE_OWNER
               , p_ARCHIVE_TABLE_NAME  => rec_archival.ARCHIVE_TABLE_NAME
               , p_YEARS_TO_KEEP       => rec_archival.YEARS_TO_KEEP
               , p_ARCHIVE_COLUMN_KEY  => rec_archival.ARCHIVE_COLUMN_KEY
               , p_ARCHIVE_GROUP_KEY   => rec_archival.ARCHIVE_GROUP_KEY);
               
            end if;
            
            archive_rules_tapi.upd(rec_archival.base_table_owner, rec_archival.base_table_name, p_upd_flag => global_constants_pkg.g_record_is_updated);            
            archive_rules_tapi.upd(rec_archival.archive_table_owner, rec_archival.archive_table_name, p_upd_flag => global_constants_pkg.g_record_is_updated);
            sql_utils_pkg.commit;
        end loop;
        
        check_parm_table_updates(p_job_nbr);
    
    exception
        when others then
            error_pkg.print_error('run_archival');
            raise;
    end run_archival;
    
--===============================================================drivers==============================================================================================================


    
--===============================================================partitioned==========================================================================================================

        procedure manage_remove_cursor(p_cur_op_flag         in sql_utils_pkg.st_cursor_flag
                                     , p_partition_type      in partition_table_parm.partition_type%type
                                     , p_table_owner         in partition_table_parm.table_owner%type
                                     , p_table_name          in partition_table_parm.table_name%type
                                     , p_ARCHIVE_TABLE_OWNER in archive_rules.table_owner%type
                                     , p_ARCHIVE_TABLE_NAME  in archive_rules.table_name%type
                                     , p_prefix              in partition_table_parm.partition_prefix%type
                                     , p_cutoff_dte          in date
                                     , p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type
                                     , io_cursor             in out sql_utils_pkg.ref_cursor_t
                                      )
        is
            l_partition_date_container varchar2(8);
        begin
            partition_parm_pkg.check_partition_type(p_partition_type);

            if p_cur_op_flag = sql_utils_pkg.c_open_cursor
            then
                case p_partition_type
                    when partition_parm_pkg.g_monthly_partition_flag
                    then
                        open io_cursor for
                        select table_owner as source_table_owner
                        , table_name as source_table_name
                        , partition_name as source_partition_name
                        , p_ARCHIVE_TABLE_OWNER as archive_table_owner
                        , p_ARCHIVE_TABLE_NAME as archive_table_name
                        , p_ARCHIVE_GROUP_KEY as group_by_column
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, partition_parm_pkg.g_max_part_suffix_regex)
                        and to_date(partition_parm_pkg.decompose_partition_name(partition_parm_pkg.g_monthly_partition_flag, partition_name, p_prefix), partition_parm_pkg.g_monthly_partition_date_format) < p_cutoff_dte;

                    when partition_parm_pkg.g_daily_partition_flag
                    then
                        open io_cursor for
                        select table_owner as source_table_owner
                        , table_name as source_table_name
                        , partition_name as source_partition_name
                        , p_ARCHIVE_TABLE_OWNER as archive_table_owner
                        , p_ARCHIVE_TABLE_NAME as archive_table_name
                        , p_ARCHIVE_GROUP_KEY as group_by_column
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, partition_parm_pkg.g_max_part_suffix_regex)
                        and to_char(partition_parm_pkg.decompose_partition_name(partition_parm_pkg.g_daily_partition_flag, partition_name, p_prefix), partition_parm_pkg.g_daily_partition_date_format) < p_cutoff_dte;

                    when partition_parm_pkg.g_quarterly_partition_flag
                    then
                        open io_cursor for
                        select table_owner as source_table_owner
                        , table_name as source_table_name
                        , partition_name as source_partition_name
                        , p_ARCHIVE_TABLE_OWNER as archive_table_owner
                        , p_ARCHIVE_TABLE_NAME as archive_table_name
                        , p_ARCHIVE_GROUP_KEY as group_by_column
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, partition_parm_pkg.g_max_part_suffix_regex)
                        and partition_parm_pkg.decompose_partition_name(partition_parm_pkg.g_quarterly_partition_flag, partition_name, p_prefix) < to_char(to_date(p_cutoff_dte, partition_parm_pkg.g_default_date_format), partition_parm_pkg.g_quarterly_partition_date_format);

                    when partition_parm_pkg.g_annual_partition_flag
                    then
                        open io_cursor for
                        select table_owner as source_table_owner
                        , table_name as source_table_name
                        , partition_name as source_partition_name
                        , p_ARCHIVE_TABLE_OWNER as archive_table_owner
                        , p_ARCHIVE_TABLE_NAME as archive_table_name
                        , p_ARCHIVE_GROUP_KEY as group_by_column
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, partition_parm_pkg.g_max_part_suffix_regex)
                        and partition_parm_pkg.decompose_partition_name(partition_parm_pkg.g_quarterly_partition_flag, partition_name, p_prefix) < p_cutoff_dte;

                end case;
            else
                cleanup_pkg.close_cursor(io_cursor);
            end if;

        exception
            when others then
            cleanup_pkg.close_cursor(io_cursor);
            error_pkg.print_error('manage_remove_cursor');
            raise;
        end manage_remove_cursor;


    procedure run_partitioned_archival(p_BASE_TABLE_OWNER    in archive_rules.table_owner%type,
                                       p_BASE_TABLE_NAME     in archive_rules.table_name%type,
                                       p_ARCHIVE_TABLE_OWNER in archive_rules.table_owner%type,
                                       p_ARCHIVE_TABLE_NAME  in archive_rules.table_name%type,
                                       p_cutoff_dte          in date,
                                       p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type,
                                       p_PARTITION_TYPE      in partition_table_parm.partition_type%type,
                                       p_PARTITION_PREFIX    in partition_table_parm.partition_prefix%type)
    is
        type t_all_tab_parts is RECORD(
          source_table_owner archive_rules.table_owner%type
        , source_table_name archive_rules.table_name%type
        , source_partition_name all_tab_partitions.partition_name%type
        , archive_table_owner archive_rules.table_owner%type
        , archive_table_name archive_rules.table_name%type
        , group_by_column archive_rules.archive_group_key%type
        );
      
        v_all_tab_parts t_all_tab_parts;
        
        part_ref_cursor_t sql_utils_pkg.ref_cursor_t;
        
    begin
        manage_remove_cursor(sql_utils_pkg.c_open_cursor, p_PARTITION_TYPE
                           , p_BASE_TABLE_OWNER, p_BASE_TABLE_NAME
                           , p_ARCHIVE_TABLE_OWNER, p_ARCHIVE_TABLE_NAME
                           , p_PARTITION_PREFIX, p_cutoff_dte, p_ARCHIVE_GROUP_KEY
                           , part_ref_cursor_t);
        
        if p_ARCHIVE_GROUP_KEY is not null
        then            
            loop
                fetch part_ref_cursor_t into v_all_tab_parts;
                exit when part_ref_cursor_t%notfound;
                partitioned_append_to_archive(
                    p_src_owner           => v_all_tab_parts.source_table_owner
                  , p_src_table           => v_all_tab_parts.source_table_name
                  , p_src_partition_name  => v_all_tab_parts.source_partition_name
                  , p_arch_owner          => v_all_tab_parts.archive_table_owner
                  , p_arch_table          => v_all_tab_parts.archive_table_name
                  , p_group_column        => v_all_tab_parts.group_by_column);
            end loop;
        
        else
            loop
                fetch part_ref_cursor_t into v_all_tab_parts;
                exit when part_ref_cursor_t%notfound;
                partitioned_collect_to_archive(
                    p_src_owner           => v_all_tab_parts.source_table_owner
                  , p_src_table           => v_all_tab_parts.source_table_name
                  , p_src_partition_name  => v_all_tab_parts.source_partition_name
                  , p_arch_owner          => v_all_tab_parts.archive_table_owner
                  , p_arch_table          => v_all_tab_parts.archive_table_name);
            end loop;
        
        end if;
        
        manage_remove_cursor(sql_utils_pkg.c_close_cursor, p_PARTITION_TYPE
                           , p_BASE_TABLE_OWNER, p_BASE_TABLE_NAME
                           , p_ARCHIVE_TABLE_OWNER, p_ARCHIVE_TABLE_NAME
                           , p_PARTITION_PREFIX, p_cutoff_dte,p_ARCHIVE_GROUP_KEY
                           , part_ref_cursor_t);

    exception
        when others then
            cleanup_pkg.close_cursor(part_ref_cursor_t);
            error_pkg.print_error('run_partitioned_archival');
            raise;
    end run_partitioned_archival;
    
        


    PROCEDURE partitioned_append_to_archive(p_src_owner          IN archive_rules.TABLE_OWNER%TYPE
                                          , p_src_table          IN archive_rules.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
                                          , p_arch_owner         IN archive_rules.TABLE_OWNER%TYPE
                                          , p_arch_table         IN archive_rules.TABLE_NAME%TYPE
                                          , p_group_column       IN archive_rules.ARCHIVE_COLUMN_KEY%TYPE)  
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
        v_column_datatype := get_column_datatype(p_src_owner, p_src_table, p_group_column);

        if is_string(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_string_value));

        elsif is_number(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_number_value));

        elsif is_date(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_date_value));
        end if;

        sql_builder_pkg.add_from(l_insert_select_query, string_utils_pkg.get_str('%1 %2', sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table), sql_utils_pkg.get_partition_extension(p_src_partition_name)));
        sql_builder_pkg.add_group_by(l_insert_select_query, p_group_column);
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
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, string_utils_pkg.str_to_single_quoted_str(c_default_string_value), string_utils_pkg.str_to_single_quoted_str(strContainer.strValue)));

            elsif is_number(v_column_datatype)
            then
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, c_default_number_value, numberContainer.numValue));
            
            elsif is_date(v_column_datatype)
            then
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, string_utils_pkg.str_to_single_quoted_str(c_default_date_value), string_utils_pkg.str_to_single_quoted_str(dateContainer.dateValue)));
                
            end if;

            sql_utils_pkg.commit;

        END LOOP;
        close insert_cursor;

    EXCEPTION
        WHEN OTHERS THEN
            cleanup_pkg.exception_cleanup;
            cleanup_pkg.close_cursor(insert_cursor);
            error_pkg.print_error('partitioned_append_to_archive');
            raise;
    END partitioned_append_to_archive;
    

    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default c_bulk_limit)
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
                    sql_utils_pkg.commit;
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
            error_pkg.print_error('partitioned_collect_to_archive');
            raise;
    end partitioned_collect_to_archive;
    
--===============================================================partitioned==========================================================================================================
    
--===========================================================non-partitioned==========================================================================================================

    procedure run_nonpartitioned_archival(p_BASE_TABLE_OWNER    in archive_rules.table_owner%type,
                                          p_BASE_TABLE_NAME     in archive_rules.table_name%type,
                                          p_ARCHIVE_TABLE_OWNER in archive_rules.table_owner%type,
                                          p_ARCHIVE_TABLE_NAME  in archive_rules.table_name%type,
                                          p_YEARS_TO_KEEP       in archive_rules.years_to_keep%type,
                                          p_ARCHIVE_COLUMN_KEY  in archive_rules.archive_column_key%type,
                                          p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type)
    is
    begin
    
        error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');

    exception
        when others then
            error_pkg.print_error('run_partitioned_archival');
            raise;
    end run_nonpartitioned_archival;



    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_time_column      in archive_rules.archive_column_key%type
                                            , p_timeframe        in date
                                            , p_group_column     in archive_rules.archive_column_key%type)
    is
        v_column_datatype ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
        l_insert_select_query sql_builder_pkg.t_query;
        insert_cursor sql_utils_pkg.ref_cursor_t;

        procedure execute_insert(p_where_clause IN VARCHAR2)
        is
            l_insert_query sql_builder_pkg.t_query;
        begin
            dbms_output.put_line('inside insert procedure');
            sql_builder_pkg.add_select(l_insert_query, sql_builder_pkg.g_select_all);
            sql_builder_pkg.add_from(l_insert_query, sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table));
            sql_builder_pkg.add_where(l_insert_query, p_where_clause, '');

            debug_print_or_execute(
            string_utils_pkg.get_str('INSERT /*+ APPEND NOSORT NOLOGGING */ INTO %1 %2', sql_utils_pkg.get_full_table_name(p_arch_owner, p_arch_table), sql_builder_pkg.get_sql(l_insert_query))
            );

        end execute_insert;

    BEGIN
        v_column_datatype := get_column_datatype(p_src_owner, p_src_table, p_group_column);

        if is_string(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_string_value));

        elsif is_number(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_number_value));

        elsif is_date(v_column_datatype)
        then
            sql_builder_pkg.add_select(l_insert_select_query,string_utils_pkg.get_str('NVL(%1,%2), count(1)', p_group_column, c_default_date_value));
        end if;

        sql_builder_pkg.add_from(l_insert_select_query, sql_utils_pkg.get_full_table_name(p_src_owner, p_src_table));
        sql_builder_pkg.add_where(l_insert_select_query, string_utils_pkg.get_str('%1 < %2', p_time_column, string_utils_pkg.str_to_single_quoted_str(p_timeframe)), '');
        sql_builder_pkg.add_group_by(l_insert_select_query, p_time_column);
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
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, string_utils_pkg.str_to_single_quoted_str(c_default_string_value), string_utils_pkg.str_to_single_quoted_str(strContainer.strValue)));

            elsif is_number(v_column_datatype)
            then
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, c_default_number_value, numberContainer.numValue));

            elsif is_date(v_column_datatype)
            then
                execute_insert(string_utils_pkg.get_str('WHERE NVL(%1,%2) = %3', p_group_column, string_utils_pkg.str_to_single_quoted_str(c_default_date_value), string_utils_pkg.str_to_single_quoted_str(dateContainer.dateValue)));

            end if;

            sql_utils_pkg.commit;

        END LOOP;

        close insert_cursor;
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
                                            , p_ARCHIVE_COLUMN_KEY  in archive_rules.archive_column_key%type
                                            , p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type)
    is
    begin
        error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');
    exception
        WHEN OTHERS THEN
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end unpartitioned_append_to_archive;


    procedure unpartitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_bulk_limit         in integer default c_bulk_limit)
    is
    begin
        error_pkg.assert(1=2, 'PROCEDURE IS NOT BUILT YET');

    exception
        WHEN OTHERS THEN
            error_pkg.print_error('unpartitioned_append_to_archive');
            raise;
    end unpartitioned_collect_to_archive;
    
--===========================================================non-partitioned==========================================================================================================

end archive_rules_tbl_pkg;
