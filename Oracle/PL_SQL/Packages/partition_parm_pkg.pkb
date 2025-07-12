create or replace package body partition_parm_pkg
AS
    type reconTable_t is table of partition_table_parm.table_name%type;
    
    function get_partition_name(p_partition_type in partition_table_parm.partition_type%type, p_date in date)
    return varchar2
    is
    begin
        error_pkg.assert(1=2, 'FUNCTION NOT CREATED');
    end get_partition_name;
    
    
    procedure debug_print_or_execute(p_sql IN VARCHAR2)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_sql);
        else
            execute immediate p_sql;
        end if;
    exception
        when others then
            error_pkg.print_error('debug_print_or_execute');
            raise;    
    end debug_print_or_execute;
    
    
    procedure check_partition_type(p_partition_type IN partition_table_parm.partition_type%type)
    is
    begin
        error_pkg.assert(p_partition_type in (g_daily_partition_flag, g_monthly_partition_flag, g_quarterly_partition_flag, g_annual_partition_flag), 'UNSUPPORTED PARTITION FLAG. PLEASE INVESTIGATE');
    end check_partition_type;
    
    
    procedure check_parm_table_updates (p_reconTable IN reconTable_t)
    is
        l_tableUpdateCount NUMBER;
    begin
        for i in p_reconTable.FIRST..p_reconTable.LAST
        loop
            select nvl(count(1), 0)
            into l_tableUpdateCount
            from partition_table_parm
            where table_name = p_reconTable(i)
            and upd_flag <> g_is_updated;
            
            error_pkg.assert(l_tableUpdateCount = 0, 'Record(s) from the PARM table have not been updated. Please investigate');
        
        end loop;
    
    exception
        when others then
            error_pkg.print_error('check_parm_table_updates');
            raise;
    end check_parm_table_updates;
    
    
    procedure populate_recon_table(p_table_name IN VARCHAR2, p_reconTable in out nocopy reconTable_t)
    is
    begin
        p_reconTable.EXTEND;
        p_reconTable(p_reconTable.LAST):= p_table_name;
    
    exception
        when others then
            error_pkg.print_error('check_indexes');
            raise;
    end populate_recon_table;
    
    
    procedure update_parm_table_progress(p_upd_flag_value IN CHAR, p_table_owner IN VARCHAR2, p_table_name IN VARCHAR2)
    is
    begin
        update partition_table_parm
        set upd_flag = p_upd_flag_value
        where table_owner = p_table_owner
        and table_name = p_table_name;
        
        commit;
        
    exception
        when others then
            error_pkg.print_error('update_parm_table_progress');
            raise;
    end update_parm_table_progress;
    
    
    procedure check_indexes
    is
        l_bad_idx_count NUMBER;
    begin
        select nvl(count(1), 0)
        into l_bad_idx_count
        from all_ind_partitions ind_part
        inner join all_indexes idxs
        on ind_part.index_name = idxs.index_name
        
        inner join partition_table_parm parm
        on idxs.table_owner = parm.table_owner
        and idxs.table_name = parm.table_name
        where ind_part.status = 'UNUSABLE' or idxs.status = 'UNUSABLE';
        
        error_pkg.assert(l_bad_idx_count = 0, 'UNUSABLE OR INVALID INDEXES HAVE BEEN DETECTED. PLEASE INVESTIGATE');
    exception
        when others then
        error_pkg.print_error('check_indexes');
        raise;
    end check_indexes;
    
    
    procedure retrieve_cutoff_dates(p_run_type          in char
                                  , p_begin_cutoff_dte out date)
    is
    begin
        error_pkg.assert(p_run_type in (global_constants_pkg.g_regular_run, global_constants_pkg.g_special_run), 'UNSUPPORTED RUNTYPE PASSED TO PROCEDURE. PLEASE CORRECT');
        
        if p_run_type = global_constants_pkg.g_regular_run
        then
            select run_dte
            into p_begin_cutoff_dte
            from infa_global;
        else
            select run_dte
            into p_begin_cutoff_dte
            from infa_global_fix;
        end if;
        
        error_pkg.assert(p_begin_cutoff_dte is not null or trim(p_begin_cutoff_dte) <> '', 'DATE RETRIEVED IS NOT VALID PLEASE INVESTIGATE');
        
    exception
        when others then
        error_pkg.print_error('retrieve_cutoff_dates');
        raise;
    end retrieve_cutoff_dates;
    

    procedure reset_partition_parm_table
    is
    begin
        update partition_table_parm
        set upd_flag = 'N';
        commit;
        
    exception
        when others then
        error_pkg.print_error('retrieve_cutoff_dates');
        raise;    
    end reset_partition_parm_table;
    
    procedure create_new_partitions(p_run_type IN CHAR, p_years_to_create IN INTEGER)
    is
        g_create_begin_dte DATE;
        g_create_end_dte DATE;
        
        type partition_creation_t is record(
            partition_key all_tab_partitions.partition_name%type,
            high_value all_tab_partitions.partition_name%type
        );
        
        function transform_max(p_partition_type in partition_table_parm.partition_type%type
                             , p_partition_prefix in partition_table_parm.partition_prefix%type
                             , p_high_value in all_tab_partitions.partition_name%type)
        return all_tab_partitions.partition_name%type
        is
        begin
            if p_partition_type = g_quarterly_partition_flag
            then
                return p_partition_prefix || substr(p_high_value,1,2) || g_max_part_suffix;
            else
                return p_partition_prefix || g_max_part_suffix;
                
            end if;
        end transform_max;
        
        
        function transform_split(p_partition_type in partition_table_parm.partition_type%type, p_high_value in all_tab_partitions.partition_name%type)
        return all_tab_partitions.partition_name%type
        is
        begin
            case p_partition_type
                when g_monthly_partition_flag
                then
                    return string_utils_pkg.get_str('to_date(%1, ''yyyy-mm-dd'')', string_utils_pkg.str_to_single_quoted_str(to_char(to_date(p_high_value, g_monthly_partition_date_format), 'yyyy-mm-dd')));
                    
                when g_daily_partition_flag
                then
                    return string_utils_pkg.get_str('to_date(%1, ''yyyy-mm-dd'')', string_utils_pkg.str_to_single_quoted_str(to_char(to_date(p_high_value, g_daily_partition_date_format), 'yyyy-mm-dd')));
                    
                else
                    return string_utils_pkg.str_to_single_quoted_str(p_high_value);
            end case;
                
        end transform_split;
        
        
        function partition_previously_created(p_table_owner     IN partition_table_parm.table_owner%type
                                            , p_table_name      IN partition_table_parm.table_name%type
                                            , p_partition_name  IN ALL_TAB_PARTITIONS.partition_name%type
                                             )
        return boolean
        is
            part_count NUMBER;
        begin
            select count(1)
            into part_count
            from all_tab_partitions
            where table_owner = p_table_owner
            and table_name = p_table_name
            and partition_name = p_partition_name;
            
            if part_count > 0
            then
                return true;
            else
                return false;
            end if;
        
        end partition_previously_created;
        
        procedure create_partition_statement(p_part_create_row in partition_creation_t, p_parm_table_row in partition_table_parm%rowtype)
        is
            l_partition_name all_tab_partitions.partition_name%type := p_parm_table_row.partition_prefix || p_part_create_row.partition_key;
            l_partMax all_tab_partitions.partition_name%type        := transform_max(p_parm_table_row.partition_type, p_parm_table_row.partition_prefix, p_part_create_row.high_value);
        begin
            
            if partition_previously_created(p_parm_table_row.table_owner, p_parm_table_row.table_name, l_partition_name)
            then
                debug_print_or_execute('select dummy from dual');
                
            end if;
            
            debug_print_or_execute(
            string_utils_pkg.get_str('ALTER TABLE %1 SPLIT PARTITION %2 AT (%3) INTO (PARTITION %4 TABLESPACE %5 PARTITION %6 TABLESPACE %7) UPDATE GLOBAL INDEXES'
                                    , sql_utils_pkg.get_full_table_name(p_parm_table_row.table_owner, p_parm_table_row.table_name)
                                    , l_partMax
                                    , transform_split(p_parm_table_row.partition_type, p_part_create_row.high_value)
                                    , l_partition_name
                                    , p_parm_table_row.tablespace_name
                                    , l_partMax
                                    , p_parm_table_row.tablespace_name)
                                  );
                                  
            
            --debug_print_or_execute('ALTER TABLE ' || p_parm_table_row.table_owner || '.' || p_parm_table_row.table_name
            --                     || ' SPLIT PARTITION ' || l_partMax
            --                     || ' AT '
            --                     || '('
            --                     || transform_split(p_parm_table_row.partition_type, p_part_create_row.high_value)
            --                     || ')'
            --                     || ' INTO '
            --                     || '( PARTITION ' || l_partition_name
            --                     || ' TABLESPACE ' || p_parm_table_row.tablespace_name
            --                     || ' partition ' || l_partMax
            --                     || ' TABLESPACE ' || p_parm_table_row.tablespace_name
            --                     || ') UPDATE GLOBAL INDEXES');
         exception
             when others then
             error_pkg.print_error('create_partition_statement');
             raise;
        end create_partition_statement;
        
        
        procedure manage_create_cursor(p_cur_op_flag IN CHAR
                                     , p_partition_type IN partition_table_parm.partition_type%type
                                     , p_begin_dte IN DATE
                                     , p_end_dte IN DATE
                                     , io_cursor IN OUT ref_cursor_t)
        is
            l_default_date_format CONSTANT VARCHAR2(9) := 'DD-MON-RR';
        begin
            check_partition_type(p_partition_type);
            
            if p_cur_op_flag = c_open_cursor
            then
                case p_partition_type
                    when g_monthly_partition_flag then
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct to_char(last_day(to_date(a.column_value, l_default_date_format)), g_monthly_partition_date_format) as partition_key
                            ,               to_char(last_day(to_date(b.column_value, l_default_date_format)), g_monthly_partition_date_format) as high_value
                                  from date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) a
                            inner join date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) b
                            on a.column_value + 1 = b.column_value
                        ) where partition_key <> high_value;
                            
                    
                    when g_quarterly_partition_flag then
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct date_utils_pkg.get_year_quarter(to_char(last_day(to_date(a.column_value, l_default_date_format)))) as partition_key
                            ,               date_utils_pkg.get_year_quarter(to_char(last_day(to_date(b.column_value, l_default_date_format)))) as high_value
                                  from date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) a
                            inner join date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) b
                            on a.column_value + 1 = b.column_value
                        )where partition_key <> high_value
                        order by partition_key asc;
                        
                        
                    when g_daily_partition_flag then --double check off by one error
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct to_char((to_date(a.column_value, l_default_date_format)), g_daily_partition_date_format) as partition_key
                            ,               to_char((to_date(b.column_value, l_default_date_format)), g_daily_partition_date_format) as high_value
                                  from date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) a
                            inner join date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) b
                            on a.column_value + 1 = b.column_value
                        )order by partition_key asc;
                    
                    
                    when g_annual_partition_flag then
                        open io_cursor for
                            select partition_key, high_value from (
                            select distinct to_char(last_day(to_date(a.column_value, l_default_date_format)), g_annual_partition_date_format) as partition_key
                            ,               to_char(last_day(to_date(b.column_value, l_default_date_format)), g_annual_partition_date_format) as high_value
                                  from date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) a
                            inner join date_utils_pkg.get_dates_between(p_begin_dte, p_end_dte) b
                            on a.column_value + 1 = b.column_value
                            order by partition_key asc
                        ) where partition_key <> high_value;
                
                end case;
                
            else
               cleanup_pkg.close_cursor(io_cursor);
            end if;
        
        exception
            when others then
            cleanup_pkg.close_cursor(io_cursor);
            error_pkg.print_error('manage_create_cursor');
            raise;
        
        end manage_create_cursor;
        
        
        procedure create_partitions
        is
            cursor partitions_to_create is
            select *
            from partition_table_parm
            where partitioned = g_is_partitioned
            and upd_flag <> g_is_updated
            order by table_name asc;
        
            l_create_cursor ref_cursor_t;
            l_part_create partition_creation_t;
            
            l_recontable reconTable_t := reconTable_t();
            
            l_create_end_dte DATE;
        
        begin
            l_create_end_dte := date_utils_pkg.calculate_new_date(date_utils_pkg.g_forwards_direction, g_create_begin_dte, p_years_to_create);
            
            for rec_parts in partitions_to_create
            loop
                populate_recon_table(rec_parts.table_name, l_recontable);
                
                manage_create_cursor(c_open_cursor, rec_parts.partition_type, g_create_begin_dte, l_create_end_dte, l_create_cursor);
                
                loop
                    fetch l_create_cursor into l_part_create;
                    exit when l_create_cursor%NOTFOUND;
                    
                    create_partition_statement(l_part_create, rec_parts);                
                end loop;
                
                manage_create_cursor(c_close_cursor, rec_parts.partition_type, g_create_begin_dte, l_create_end_dte, l_create_cursor);
                
                update_parm_table_progress(g_is_updated, rec_parts.table_owner, rec_parts.table_name);
            
            end loop;
            
            check_parm_table_updates(l_recontable);
            
        exception
           when others then
           cleanup_pkg.close_cursor(l_create_cursor);
           error_pkg.print_error('manage_create_cursor');
           raise;
        end create_partitions;
        
    begin
        retrieve_cutoff_dates(p_run_type, g_create_begin_dte);
        
        if p_run_type = global_constants_pkg.g_regular_run
        then
            g_create_begin_dte := add_months(trunc(g_create_begin_dte, 'YYYY'), date_utils_pkg.g_months_in_year);
            
        end if;
        
        dbms_output.put_line(string_utils_pkg.get_str('Creating Partitions starting from : %1',  g_create_begin_dte));
               
        create_partitions;
    
    exception
        when others then
            error_pkg.print_error('create_new_partitions');
            raise;
    end create_new_partitions;
        

    procedure remove_archive_partitions(p_run_type IN CHAR)
    is
        g_drop_begin_dte DATE;
        
        procedure manage_remove_cursor(p_cur_op_flag    in char
                                     , p_partition_type in partition_table_parm.partition_type%type
                                     , p_table_owner    in partition_table_parm.table_owner%type
                                     , p_table_name     in partition_table_parm.table_name%type
                                     , p_prefix         in partition_table_parm.partition_prefix%type
                                     , p_cutoff_dte     in date
                                     , io_cursor        in out ref_cursor_t
                                      )
        is
        begin
            check_partition_type(p_partition_type);
            
            if p_cur_op_flag = c_open_cursor
            then
                case p_partition_type
                    when g_monthly_partition_flag
                    then
                        open io_cursor for
                        select *
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, g_max_part_suffix_regex)
                        and to_date(substr(partition_name, length(p_prefix) + 1, length(partition_name)), g_monthly_partition_date_format) < p_cutoff_dte;
                        
                    when g_daily_partition_flag
                    then
                        open io_cursor for
                        select *
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, g_max_part_suffix_regex)
                        and to_char(substr(partition_name, length(p_prefix) + 1, length(partition_name)), g_daily_partition_date_format) < p_cutoff_dte;
                        
                    when g_quarterly_partition_flag
                    then
                        open io_cursor for
                        select *
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, g_max_part_suffix_regex)
                        and substr(partition_name, length(p_prefix) + 1, 4) || substr(partition_name, length(partition_name)) < to_char(to_date(p_cutoff_dte, 'DD-MON-RR'), 'YYYYQ');
                        
                    when g_annual_partition_flag
                    then
                        open io_cursor for
                        select *
                        from all_tab_partitions
                        where table_owner = p_table_owner
                        and table_name = p_table_name
                        and not regexp_like(partition_name, g_max_part_suffix_regex)
                        and substr(partition_name, length(p_prefix) + 1, 4) < p_cutoff_dte;
                        
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
        
        
        procedure remove_data_from_archive_partitions
        is
            cursor cur_dataToDestroy is
            select part.*, archive.years_to_keep
            from partition_table_parm part
            inner join archive_rules archive
            on part.table_owner = archive.table_owner
            and part.table_name = archive.table_name
            and part.partitioned = archive.partitioned
            where part.partitioned = g_is_partitioned
            and part.upd_flag <> g_is_updated
            and substr(part.table_name, 1, length(archive_rules_tbl_pkg.g_archive_table_prefix)) = archive_rules_tbl_pkg.g_archive_table_prefix
            order by part.table_name asc;
            
            l_droparchive_recontable reconTable_t := reconTable_t();
            
            l_archive_cursor ref_cursor_t;
            l_all_tab_parts all_tab_partitions%rowtype;
            
            l_drop_archive_begin_dte date;
        begin
            for rec_destroy in cur_dataToDestroy
            loop
                populate_recon_table(rec_destroy.table_name, l_droparchive_recontable);
                
                l_drop_archive_begin_dte := date_utils_pkg.calculate_new_date(date_utils_pkg.g_backwards_direction, g_drop_begin_dte, rec_destroy.years_to_keep);
                
                manage_remove_cursor(c_open_cursor, rec_destroy.partition_type, rec_destroy.table_owner, rec_destroy.table_name, rec_destroy.partition_prefix, l_drop_archive_begin_dte
                                   , l_archive_cursor);
                                   
                loop
                    fetch l_archive_cursor into l_all_tab_parts;
                    exit when l_archive_cursor%notfound;
                    
                    sql_utils_pkg.remove_data_from_partition(rec_destroy.table_name, l_all_tab_parts.partition_name, true);
                    
                end loop;
                
                manage_remove_cursor(c_close_cursor, rec_destroy.partition_type, rec_destroy.table_owner, rec_destroy.table_name, rec_destroy.partition_prefix, l_drop_archive_begin_dte
                                   , l_archive_cursor);
                                   
                update_parm_table_progress(g_is_updated, rec_destroy.table_owner, rec_destroy.table_name);
            
            end loop;
            
            check_parm_table_updates(l_droparchive_recontable);
            
        exception
            when others then
            cleanup_pkg.close_cursor(l_archive_cursor);
            error_pkg.print_error('remove_data_from_archive_partitions');
            raise;
        end remove_data_from_archive_partitions;
        
    begin
        retrieve_cutoff_dates(p_run_type, g_drop_begin_dte);
        remove_data_from_archive_partitions;
        
    exception
        when others then
            error_pkg.print_error('remove_archive_partitions');
            raise;
      
    end remove_archive_partitions;
    

end partition_parm_pkg;
