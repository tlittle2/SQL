create or replace package report_utils_pkg
as
    type report_tab_t is table of string_utils_pkg.st_max_db_varchar2;

    c_tablespace_report  constant report_creation_parms.report_name%type := 'QR1036D2';
    c_astrology_report   constant report_creation_parms.report_name%type := 'QR1307D1';
    c_salary_data_report constant report_creation_parms.report_name%type := 'QR1031D1';
    c_glob_bin_report    constant report_creation_parms.report_name%type := 'GLOB_BIN';

    function generate_report(p_report_title in report_creation_parms.report_name%type)
    return report_tab_t pipelined;

    procedure create_control_report(p_report_title in report_creation_parms.report_name%type, p_bulk_limit in integer default 10000);

    procedure create_control_report(p_reports in t_str_array);

    function f_tablespace_report
    return report_creation_parms.report_name%type
    deterministic;

    function f_astrology_report
    return report_creation_parms.report_name%type
    deterministic;

    function f_salary_data_report
    return report_creation_parms.report_name%type
    deterministic;

    function f_glob_bin_report
    return report_creation_parms.report_name%type
    deterministic;

end report_utils_pkg;
