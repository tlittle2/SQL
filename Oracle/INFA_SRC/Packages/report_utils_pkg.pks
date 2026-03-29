create or replace package report_utils_pkg
as
    type report_tab_t is table of string_utils_pkg.st_max_db_varchar2;
    
    function generate_report(p_report_title in report_creation_parms.report_name%type)
    return report_tab_t pipelined;
    
    function generate_report2(p_query in varchar2)
    --function generate_report2(p_query in sql_builder_pkg.t_query)
    return report_tab_t pipelined;
    
    procedure generate_cursor_report(p_query in sql_builder_pkg.t_query, p_cursor out sql_utils_pkg.ref_cursor_t);

    procedure create_control_report(p_report_title in report_creation_parms.report_name%type, p_bulk_limit in integer default 10000);
    
    procedure create_control_report(p_reports in t_str_array);

    function get_tablespace_report
    return report_creation_parms.report_name%type
    deterministic;

    function get_astrology_report
    return report_creation_parms.report_name%type
    deterministic;

    function get_salary_data_report
    return report_creation_parms.report_name%type
    deterministic;
    
    function get_glob_bin_report
    return report_creation_parms.report_name%type
    deterministic;
    
end report_utils_pkg;
