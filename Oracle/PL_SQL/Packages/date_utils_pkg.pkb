create or replace package body date_utils_pkg
as
    
    function get_forward_flag
    return char deterministic
    is 
    begin
        return g_forwards_direction;
    end get_forward_flag;
    
    function get_backward_flag
    return char deterministic
    is
    begin
        return g_backwards_direction;
    end get_backward_flag;
    
    function get_months_in_year
    return number
    deterministic
    is
    begin
        return g_months_in_year;
    end get_months_in_year;

    function get_year_quarter(p_date in date)
    return varchar2
    is
        p_year number := extract(year from p_date);
        p_quarter number := to_char(p_date, 'Q');
    begin
        return format_year_quarter(p_year, p_quarter);
    
    end get_year_quarter;


    function format_year_quarter(p_year in number, p_quarter in number)
    return varchar2
    is
    begin
        return p_year || 'Q' ||  p_quarter;

    end format_year_quarter;


    function get_quarter(p_month in number)
    return number
    is
    begin
        error_pkg.assert(p_month between 1 and 12, 'not a valid month');
        return case
            when p_month in (1,2,3)    then 1
            when p_month in (4,5,6)    then 2
            when p_month in (7,8,9)    then 3
            when p_month in (10,11,12) then 4
            end;
    end get_quarter;
    
    function get_month(p_date in date)
    return number
    is
    begin
        return to_number(to_char(p_date, 'MM'));
    end get_month;
    
    
    function parse_year_qrtr_for_quarter(p_year_qrtr IN VARCHAR2)
    return number
    is
    begin
        return to_number(string_utils_pkg.get_nth_token(p_year_qrtr, 2, 'Q'));
    end parse_year_qrtr_for_quarter;
    
        
    function calculate_new_date(p_calc_mode      in char
                                  , p_input_date    in date
                                  , p_years_to_keep in NUMBER)
    return date
    is
    begin
        error_pkg.assert(p_input_date is not null or trim(p_input_date) <> '', 'DATE VALUE PASSED IS NOT VALID. PLEASE INVESTIGATE');
        
        if p_calc_mode = date_utils_pkg.g_backwards_direction
        then
            return add_months(p_input_date, - (date_utils_pkg.g_months_in_year * p_years_to_keep));
        else
            return add_months(p_input_date,   (date_utils_pkg.g_months_in_year * p_years_to_keep));
            
        end if;
    exception
        when others then
            error_pkg.print_error('calculate_cutoff_date');
            raise; 
    end calculate_new_date;
    
    function get_range_of_dates(p_start_date in date, p_num_of_days in number, p_direction in char)
    return date_table_t pipelined
    is
        date_table date_table_t;
    begin
        error_pkg.assert(p_direction in (g_backwards_direction,g_forwards_direction), 'Please specify a direction to generate dates for!');
        
        if p_direction = g_backwards_direction then
            for i in 0..p_num_of_days
            loop
                pipe row(p_start_date - i);
            end loop;
        else
            for i in 0..p_num_of_days
            loop
                pipe row(p_start_date + i);
            end loop;
            
        end if;
        return;
        
    end get_range_of_dates;
    
    
    function get_dates_between(p_start_date in date, p_end_date in date)
    return date_table_t pipelined
    is
        date_table date_table_t;
        v_days number := trunc(to_date(p_end_date) - to_date(p_start_date));
    begin
        if v_days >= 0 then
            for i in 0 .. v_days
            loop
                pipe row(p_start_date + i);
            end loop;
        end if;
        
        return;
        
    end get_dates_between;
    
    function get_date_table(p_calendar_string in varchar2,p_from_date in date := null,p_to_date in date := null)
    return date_table_t pipelined
    is
        l_from_date                    date := coalesce(p_from_date, sysdate);
        l_to_date                      date := coalesce(p_to_date, add_months(l_from_date,12));
        l_date_after                   date;
        l_next_date                    date;
    begin
        l_date_after := l_from_date - 1;
        loop
            dbms_scheduler.evaluate_calendar_string (
                calendar_string   => p_calendar_string,
                start_date        => l_from_date,
                return_date_after => l_date_after,
                next_run_date     => l_next_date
            );
            
            exit when l_next_date > l_to_date;
            
            pipe row (l_next_date);
            l_date_after := l_next_date;
        end loop;
        return;
    end get_date_table;
    
    
    
    function format_time(p_from_date in date, p_to_date in date)
    return varchar2
    is
    begin
        return format_time(p_to_date - p_from_date);
    end format_time;
    
    
    function format_time(p_days in number)
    return varchar2
    is
        v_days number;
        v_hours number;
        v_minutes number;
        v_seconds number;
        v_sign varchar2(6) := '';
        v_returnvalue string_utils_pkg.st_max_pl_varchar2;
    begin
        v_days := nvl(trunc(p_days), 0);
        v_hours := nvl(((p_days - v_days) * 24), 0);
        v_minutes := nvl((v_hours - trunc(v_hours)) * 60,0);
        v_seconds := nvl((v_minutes - trunc(v_minutes)) * 60,0);
        
        if p_days < 0 
        then
            v_sign := 'minus ';
        end if;
        
        v_days := abs(v_days);
        v_hours := trunc(abs(v_hours));
        v_minutes := round(abs(v_minutes));
        v_seconds := round(abs(v_seconds));
        
        if v_minutes = 60
        then
            v_hours := v_hours + 1;
            v_minutes := 0;
        end if;
        
        if v_days > 0
        then
            if v_hours = 0
            then
                v_returnvalue := string_utils_pkg.get_str('%1 days', v_days);
            else
                v_returnvalue := string_utils_pkg.get_str('%1 days %2 hours %3 minutes ', v_days, v_hours, v_minutes);
            end if;
        
        elsif v_hours > 0
        then
            if v_minutes = 0
            then
                v_returnvalue := string_utils_pkg.get_str('%1 hours', v_hours);
            else
                v_returnvalue := string_utils_pkg.get_str('%1 hours, %2 minutes', v_hours, v_minutes);
            end if;
        
        elsif v_minutes > 0
        then
            if v_seconds = 0
            then
                v_returnvalue := string_utils_pkg.get_str('%1 minutes, %2 seconds', v_minutes, v_seconds);
            else
                v_returnvalue := string_utils_pkg.get_str('%1 seconds', v_seconds);
                
            end if;
        end if;
                
        v_returnvalue := v_sign || v_returnvalue;
        
        return v_returnvalue;
    
    end format_time;

end date_utils_pkg;
