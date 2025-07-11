procedure manage_create_cursor(p_cur_op_flag IN CHAR
                                     , p_partition_type IN partition_table_parms.partition_type%type
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
                            select distinct to_char(last_day(to_date(p_begin_dte, l_default_format) + ROWNUM - 2), g_monthly_partition_date_format) as partition_key
                            ,               to_char(last_day(to_date(p_begin_dte, l_default_format) + ROWNUM - 1), g_monthly_partition_date_format) as high_value
                            from dual
                            connect by
                            level <= ((to_date(p_end_dte, l_default_date_format) - to_date(p_begin_dte, l_default_date_format)) + 1)
                            order by substr(high_value, 3,2), substr(high_value,1,2) asc
                        ) where partition_key <> high_value;
                            
                    
                    when g_quarterly_partition_flag then
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct date_utils_pkg.format_year_quarter(to_char(last_day(to_date(:p_begin_dte, l_default_date_format) + rownum - 1), 'YYYY'), to_char(last_day(to_date(:p_begin_dte, l_default_date_format) + rownum - 1), 'Q')) as partition_key
                            ,               date_utils_pkg.format_year_quarter(to_char(last_day(to_date(:p_begin_dte, l_default_date_format) + rownum + 1), 'YYYY'), to_char(last_day(to_date(:p_begin_dte, l_default_date_format) + rownum + 1), 'Q')) as high_value
                            from dual
                            connect by
                            level <= ((to_date(p_end_dte, l_default_date_format) - to_date(p_begin_dte, l_default_date_format)) )
                        )where partition_key <> high_value
                        order by partition_key asc;
                        
                        
                    when g_daily_partition_flag then
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct to_char((to_date(p_begin_dte, l_default_date_format) + ROWNUM -2), g_daily_partition_date_format) as partition_key
                            ,               to_char((to_date(p_begin_dte, l_default_date_format) + ROWNUM -1), g_daily_partition_date_format) as high_value
                            from dual
                            connect by
                            level <= ((to_date(p_end_dte, l_default_date_format) - to_date(p_begin_dte, l_default_date_format)) + 2)
                        )order by partition_key asc;
                    
                    
                    when g_annual_partition_flag then
                        open io_cursor for
                        select partition_key, high_value from (
                            select distinct to_char(last_day(to_date(p_begin_dte, l_default_date_format) + rownum - 1), g_annual_partition_date_format) as partition_key
                            ,               to_char(last_day(to_date(p_begin_dte, l_default_date_format) + rownum + 1), g_annual_partition_date_format) as high_value
                            from dual
                            connect by
                            level <= ((to_date(p_end_dte, l_default_date_format) - to_date(p_begin_dte, l_default_date_format)) + 1)
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
