create or replace package report_utils_pkg
as
    type report_tab_t is table of string_utils_pkg.st_max_db_varchar2;

    function f_tablespace_report
    return varchar2
    deterministic;

    function f_astrology_report
    return varchar2
    deterministic;

    function f_salary_data_report
    return varchar2
    deterministic;

    function general_report(p_report_title in varchar2 default null, p_padding in number default 20, p_select in varchar2)
    return report_tab_t pipelined;

    function create_trxn_file
    return report_tab_t pipelined;


end report_utils_pkg;
