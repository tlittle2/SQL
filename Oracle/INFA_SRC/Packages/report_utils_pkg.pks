create or replace package report_utils_pkg
as
    type report_tab_t is table of string_utils_pkg.st_max_db_varchar2;

    function general_report(p_report_title in report_creation_parms.report_name%type)
    return report_tab_t pipelined;

    function f_tablespace_report
    return report_creation_parms.report_name%type
    deterministic;

    function f_astrology_report
    return report_creation_parms.report_name%type
    deterministic;

    function f_salary_data_report
    return report_creation_parms.report_name%type
    deterministic;

    function create_trxn_file
    return report_tab_t pipelined;


end report_utils_pkg;

