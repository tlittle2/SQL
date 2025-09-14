create or replace package date_utils_pkg
as
    type yr_qrtr_table_t is table of infa_global.statement_prd_yr_qrtr%type;

    g_months_in_year number(2,0) := 12;
    g_months_in_quarter number(1,0) := 3;
    g_quarters_in_year number(1,0) := 4;

    function get_months_in_year
    return number
    deterministic;

    function get_months_in_quarter
    return number
    deterministic;

    function get_min_date_for_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type)
    return date;

    function get_max_date_for_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type)
    return date;

    function get_date_no_ts(p_date in date)
    return date
    deterministic;

    function get_curr_date
    return date
    deterministic;

	function get_year_quarter(p_date in date)
    return infa_global.statement_prd_yr_qrtr%type;

    function get_year_quarter(p_quarter in infa_global.statement_prd_yr_qrtr%type, p_num_of_quarters in number)
    return infa_global.statement_prd_yr_qrtr%type;

    function format_year_quarter(p_year in number, p_quarter in number)
    return infa_global.statement_prd_yr_qrtr%type;

    function trunc_quarter(p_date in date)
    return date
    deterministic;

    function get_quarter(p_date in date)
	return number;

    function get_quarter(p_month in number)
	return number;

    function get_month(p_date in date)
    return number;


--================================================================================================================
    function get_month_of_quarter(p_date in date)
    return number;

    function get_month_of_quarter(p_month in number)
    return number;

    function is_month1_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_month1_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num;

    function is_month2_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_month2_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num;

    function is_month3_of_quarter(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_month3_of_quarter(p_month in number)
    return string_utils_pkg.st_bool_num;

--================================================================================================================

    function parse_year_qrtr_for_quarter(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return number;

    function parse_year_qrtr_for_year(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return number;

    function is_quarter1(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num;

    function is_quarter1(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_quarter2(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num;

    function is_quarter2(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_quarter3(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num;

    function is_quarter3(p_date in date)
    return string_utils_pkg.st_bool_num;

    function is_quarter4(p_year_qrtr in infa_global.statement_prd_yr_qrtr%type)
    return string_utils_pkg.st_bool_num;

    function is_quarter4(p_date in date)
    return string_utils_pkg.st_bool_num;

--================================================================================================================


     --calculate_cutoff_date
    function calculate_new_date(p_input_date    in date
                              , p_years_to_keep in NUMBER)
    return date;

    function get_range_of_dates(p_start_date in date, p_num_of_days in number)
    return t_date_array pipelined;

    function get_dates_between(p_start_date in date, p_end_date in date)
    return t_date_array pipelined;

    function get_year_quarters(p_quarter in infa_global.statement_prd_yr_qrtr%type, p_num_of_quarters in number)
    return yr_qrtr_table_t
    pipelined;

    function get_date_table(p_calendar_string in varchar2,p_from_date in date := null,p_to_date in date := null)
    return t_date_array pipelined;

    function format_time(p_days in number)
    return varchar2;

    function format_time(p_from_date in date, p_to_date in date)
    return varchar2;


end date_utils_pkg;
