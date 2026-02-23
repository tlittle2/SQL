create or replace package qa_pkg
as
    subtype ut_boolean is boolean; --all unit test package functions should be using this as their return type
    subtype st_bool_num is number(1,0);
    subtype st_flag_len is char(1);

    g_yes                          constant st_flag_len := 'Y';
    g_no                           constant st_flag_len := 'N';

    g_false                        constant st_bool_num := 0;
    g_true                         constant st_bool_num := 1;


    procedure assert(p_condition in boolean, p_error_message in varchar2);

    procedure take_full_table_backup(p_table_name in user_tables.table_name%type);

    procedure run_unit_tests(p_pkg_name user_source.name%type);

    procedure truncate_table(p_table_name in varchar2);

    procedure generate_pin_numbers(p_low in integer, p_high in integer);

    function generate_pin_numbers(p_low in integer, p_high in integer)
    return t_str_array pipelined;

    procedure generate_contract_numbers(p_low in integer, p_high in integer);

    function generate_contract_numbers(p_low in integer, p_high in integer)
    return t_str_array pipelined;

end qa_pkg;
