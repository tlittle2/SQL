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

    function get_months_in_quarter
    return number
    deterministic
    is
    begin
        return g_months_in_quarter;
    end;

    function get_date_no_ts(p_date in date)
    return date
    deterministic
    is
        l_returvalue date := trunc(p_date);
    begin
        return l_returvalue;
    end get_date_no_ts;

    function get_curr_date
    return date
    deterministic
    is
        l_returvalue date :=get_date_no_ts(sysdate);
    begin
        return l_returvalue;
    end get_curr_date;


    function get_year_quarter(p_date in date)
    return infa_global.statement_prd_yr_qrtr%type
    is
        l_year number := extract(year from p_date);
        l_quarter number := get_quarter(p_date);
        l_returnvalue infa_global.statement_prd_yr_qrtr%type :=format_year_quarter(l_year, l_quarter);
    begin
        return l_returnvalue;

    end get_year_quarter;


    function get_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type, p_num_of_quarters in number)
    return infa_global.statement_prd_yr_qrtr%type
    is
        l_temp_date date := add_months(get_min_date_for_year_quarter(p_quarter), p_num_of_quarters * g_months_in_quarter);
        l_returnvalue infa_global.statement_prd_yr_qrtr%type := get_year_quarter(l_temp_date);
    begin

        return l_returnvalue;

    end get_year_quarter;


    function get_min_date_for_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type)
    return date
    is
        l_year number := parse_year_qrtr_for_year(p_quarter);
        l_quarter number := parse_year_qrtr_for_quarter(p_quarter);
        l_returnvalue date := to_date(l_year || '-' || ((l_quarter - 1) * g_months_in_quarter + 1) || '-01', 'YYYY-MM-DD');
    begin

        return l_returnvalue;

    end get_min_date_for_year_quarter;

    function get_max_date_for_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type)
    return date
    is
        l_returnvalue date := add_months(get_min_date_for_year_quarter(p_quarter), g_months_in_quarter)-1;
    begin

        return l_returnvalue;

    end get_max_date_for_year_quarter;


    function format_year_quarter(p_year in number, p_quarter in number)
    return infa_global.statement_prd_yr_qrtr%type
    is
        l_returnvalue infa_global.statement_prd_yr_qrtr%type := p_year || 'Q' ||  p_quarter;
    begin

        return l_returnvalue;

    end format_year_quarter;

    function trunc_quarter(p_date in date)
    return date
    deterministic
    is
        l_returnvalue date := trunc(p_date, 'Q');
    begin

        return l_returnvalue;

    end trunc_quarter;

    function get_quarter(p_date in date)
	return number
    is
       l_returnvalue number := to_char(p_date, 'Q');
    begin
       assert_pkg.is_true(l_returnvalue between 1 and 4, 'INVALID QUARTER NUMBER RETURNED. PLEASE INVESTIGATE');
       return l_returnvalue;
    end get_quarter;


    function get_quarter(p_month in number)
    return number
    is
        l_temp_date date;
        l_returnvalue number;
    begin
        assert_pkg.is_valid_month(p_month, 'not a valid month. please investigate');

        l_temp_date := to_date(extract(year from sysdate) || '-' || p_month || '-01', 'YYYY-MM-DD'); --only concerned with month, so current year will suffice as dummy year

        l_returnvalue := get_quarter(l_temp_date);

        return l_returnvalue;
    end get_quarter;


    function get_month_of_quarter(p_month in number)
    return number
    is
        l_returnvalue number;
    begin
        assert_pkg.is_valid_month(p_month, 'INVALID MONTH PROVIDED. PLEASE INVESTIGATE');

        case when p_month in (1,4,7,10) then l_returnvalue := 1;
             when p_month in (2,5,8,11) then l_returnvalue := 2;
                                        else l_returnvalue := 3;
	    end case;

	    return l_returnvalue;

	end get_month_of_quarter;

    function get_month_of_quarter(p_date in date)
    return number
    is
        l_returnvalue number := get_month_of_quarter(get_month(p_date));
    begin

        return l_returnvalue;

    end get_month_of_quarter;

    function is_month1_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if get_month_of_quarter(p_month)= 1
        then
            l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_month1_of_quarter;

    function is_month1_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if string_utils_pkg.int_to_bool(is_month1_of_quarter(get_month_of_quarter(p_date)))
	    then
	        l_returnvalue := string_utils_pkg.g_true;
        end if;

        return l_returnvalue;

    end is_month1_of_quarter;

    function is_month2_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if get_month_of_quarter(p_month) = 2
        then
            l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_month2_of_quarter;


    function is_month2_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if string_utils_pkg.int_to_bool(is_month2_of_quarter(get_month_of_quarter(p_date)))
	    then
            l_returnvalue := string_utils_pkg.g_true;
	    end if;

	   return l_returnvalue;

    end is_month2_of_quarter;

    function is_month3_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if get_month_of_quarter(p_month) = 3
        then
            l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_month3_of_quarter;


    function is_month3_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if string_utils_pkg.int_to_bool(is_month3_of_quarter(get_month_of_quarter(p_date)))
	    then
	        l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_month3_of_quarter;


    function get_month(p_date in date)
    return number
    is
        l_returnvalue number := to_number(to_char(p_date, 'MM'));
    begin
        return l_returnvalue;

    end get_month;

--======================================================================================================================================================================================

    function parse_year_qrtr_for_quarter(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return number
    is
        l_returnvalue number;
    begin
        assert_pkg.is_true(string_utils_pkg.char_at(p_year_qrtr, 5) = 'Q' and length(p_year_qrtr) = 6, 'POTENTIALLY INVALID TYPE. PLEASE INVESTIGATE');

        l_returnvalue := to_number(string_utils_pkg.char_at(p_year_qrtr, 6));

        assert_pkg.is_true(l_returnvalue between 1 and 4, 'INVALID QUARTER RETURNED. PLEASE INVESTIGATE');

        return l_returnvalue;
    end parse_year_qrtr_for_quarter;


    function is_quarter1(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if parse_year_qrtr_for_quarter(p_year_qrtr) = 1
	    then
	        l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_quarter1;

    function is_quarter1(p_date in date)
    return string_utils_pkg.st_bool_num
    is
       l_year_qrtr infa_global.statement_prd_yr_qrtr%type := get_year_quarter(p_date);
       l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
       if string_utils_pkg.int_to_bool(is_quarter1(l_year_qrtr))
       then
           l_returnvalue := string_utils_pkg.g_true;
       end if;

       return l_returnvalue;

    end is_quarter1;


    function is_quarter2(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if parse_year_qrtr_for_quarter(p_year_qrtr) = 2
	    then
	        l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_quarter2;

    function is_quarter2(p_date in date)
    return string_utils_pkg.st_bool_num
    is
       l_year_qrtr infa_global.statement_prd_yr_qrtr%type := get_year_quarter(p_date);
       l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
       if string_utils_pkg.int_to_bool(is_quarter2(l_year_qrtr))
       then
           l_returnvalue := string_utils_pkg.g_true;
       end if;

       return l_returnvalue;

    end is_quarter2;


    function is_quarter3(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if parse_year_qrtr_for_quarter(p_year_qrtr) = 3
	    then
	        l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_quarter3;


    function is_quarter3(p_date in date)
    return string_utils_pkg.st_bool_num
    is
       l_year_qrtr infa_global.statement_prd_yr_qrtr%type := get_year_quarter(p_date);
       l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
       if string_utils_pkg.int_to_bool(is_quarter3(l_year_qrtr))
       then
           l_returnvalue := string_utils_pkg.g_true;
       end if;

       return l_returnvalue;

    end is_quarter3;


    function is_quarter4(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num
    is
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if parse_year_qrtr_for_quarter(p_year_qrtr) = 4
	    then
	        l_returnvalue := string_utils_pkg.g_true;
	    end if;

	    return l_returnvalue;

    end is_quarter4;


    function is_quarter4(p_date in date)
    return string_utils_pkg.st_bool_num
    is
       l_year_qrtr infa_global.statement_prd_yr_qrtr%type := get_year_quarter(p_date);
       l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
       if string_utils_pkg.int_to_bool(is_quarter4(l_year_qrtr))
       then
           l_returnvalue := string_utils_pkg.g_true;
       end if;

       return l_returnvalue;

    end is_quarter4;


    function parse_year_qrtr_for_year(p_year_qrtr infa_global.statement_prd_yr_qrtr%type)
    return number
    is
        l_returnvalue number;
    begin
        assert_pkg.is_true(string_utils_pkg.char_at(p_year_qrtr, 5) = 'Q' and length(p_year_qrtr) = 6, 'POTENTIALLY INVALID TYPE. PLEASE INVESTIGATE');

        l_returnvalue := to_number(substr(p_year_qrtr, 1,4));

        return l_returnvalue;
    end parse_year_qrtr_for_year;

--======================================================================================================================================================================================


    function calculate_new_date(p_input_date    in date
                              , p_years_to_keep in NUMBER)
    return date
    is
        l_returnvalue date;
    begin
        assert_pkg.is_not_null_nor_blank(p_input_date, 'DATE VALUE PASSED IS NOT VALID. PLEASE INVESTIGATE');

        l_returnvalue := add_months(p_input_date, date_utils_pkg.g_months_in_year * (sign(p_years_to_keep) * p_years_to_keep));

        return l_returnvalue;

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
        assert_pkg.is_true(p_direction in (g_backwards_direction,g_forwards_direction), 'Please specify a direction to generate dates for!');

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
        l_days number := trunc(to_date(p_end_date) - to_date(p_start_date));
    begin
        if l_days >= 0 then
            for i in 0 .. l_days
            loop
                pipe row(p_start_date + i);
            end loop;
        end if;

        return;

    end get_dates_between;

    function get_date_table(p_calendar_string in varchar2,p_from_date in date := null,p_to_date in date := null)
    return date_table_t pipelined
    is
        l_from_date    date := coalesce(p_from_date, sysdate);
        l_to_date      date := coalesce(p_to_date, add_months(l_from_date,12));
        l_date_after   date;
        l_next_date    date;
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
        l_returnvalue string_utils_pkg.st_max_pl_varchar2 := format_time(p_to_date - p_from_date);
    begin

        return l_returnvalue;

    end format_time;


    function format_time(p_days in number)
    return varchar2
    is
        l_days number;
        l_hours number;
        l_minutes number;
        l_seconds number;
        l_sign varchar2(6) := '';
        l_returnvalue string_utils_pkg.st_max_pl_varchar2;
    begin
        l_days := nvl(trunc(p_days), 0);
        l_hours := nvl(((p_days - l_days) * 24), 0);
        l_minutes := nvl((l_hours - trunc(l_hours)) * 60,0);
        l_seconds := nvl((l_minutes - trunc(l_minutes)) * 60,0);

        if p_days < 0
        then
            l_sign := 'minus ';
        end if;

        l_days := abs(l_days);
        l_hours := trunc(abs(l_hours));
        l_minutes := round(abs(l_minutes));
        l_seconds := round(abs(l_seconds));

        if l_minutes = 60
        then
            l_hours := l_hours + 1;
            l_minutes := 0;
        end if;

        if l_days > 0
        then
            if l_hours = 0
            then
                l_returnvalue := string_utils_pkg.get_str('%1 days', l_days);
            else
                l_returnvalue := string_utils_pkg.get_str('%1 days %2 hours %3 minutes ', l_days, l_hours, l_minutes);
            end if;

        elsif l_hours > 0
        then
            if l_minutes = 0
            then
                l_returnvalue := string_utils_pkg.get_str('%1 hours', l_hours);
            else
                l_returnvalue := string_utils_pkg.get_str('%1 hours, %2 minutes', l_hours, l_minutes);
            end if;

        elsif l_minutes > 0
        then
            if l_seconds = 0
            then
                l_returnvalue := string_utils_pkg.get_str('%1 minutes, %2 seconds', l_minutes, l_seconds);
            else
                l_returnvalue := string_utils_pkg.get_str('%1 seconds', l_seconds);

            end if;
        end if;

        l_returnvalue := l_sign || l_returnvalue;

        return l_returnvalue;

    end format_time;

end date_utils_pkg;
