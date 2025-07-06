create or replace package date_utils_pkg
as
    type date_table_t is table of date;
    
    function get_forward_flag
    return char deterministic;
    
    function get_backward_flag
    return char deterministic;

    function get_year_quarter(p_date in date)
    return varchar2;
    
    function format_year_quarter(p_year in number, p_quarter in number)
    return varchar2;
    
    function get_quarter(p_month in number)
    return number;
    
    function get_month(p_date in date)
    return number;
    
    function parse_year_qrtr_for_quarter(p_year_qrtr IN VARCHAR2)
    return number;
    
    function format_time(p_days in number)
    return varchar2;
    
    function format_time(p_from_date in date, p_to_date in date)
    return varchar2;
    

    function get_range_of_dates(p_start_date in date, p_num_of_days in number, p_direction in char)
    return date_table_t pipelined;
    
    function get_dates_between(p_start_date in date, p_end_date in date)
    return date_table_t pipelined;
    
    function get_date_table(p_calendar_string in varchar2,p_from_date in date := null,p_to_date in date := null)
    return date_table_t pipelined;


end date_utils_pkg;
