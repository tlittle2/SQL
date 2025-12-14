create or replace package string_utils_pkg
authid definer
as
    subtype st_max_pl_varchar2 is varchar2(32767);
    subtype st_max_db_varchar2 is varchar2(4000);
    subtype st_bool_str_len is varchar2(5);
    subtype st_flag_len is varchar2(1);
    subtype st_bool_num is number(1,0);

    g_yes                          constant st_flag_len := 'Y';
    g_no                           constant st_flag_len := 'N';

    g_false                        constant st_bool_num := 0;
    g_true                         constant st_bool_num := 1;

    g_default_separator            constant st_flag_len := ';';
    g_param_and_value_separator    constant st_flag_len := '=';

    g_line_feed                    constant st_flag_len := chr(10);
    g_new_line                     constant st_flag_len := chr(13);
    g_carriage_return              constant st_flag_len := chr(13);
    g_tab                          constant st_flag_len := chr(9);
    g_ampersand                    constant st_flag_len := chr(38);

    g_crlf                         constant varchar2(2) := g_carriage_return || g_line_feed;

    g_html_entity_carriage_return  constant varchar2(5) := chr(38) || '#13;';
    g_html_nbsp                    constant varchar2(6) := chr(38) || 'nbsp;';

    function bool_to_str(p_value in boolean)
    return st_bool_str_len;

    function str_to_bool(p_str in varchar2)
    return boolean;

    function bool_to_int(p_condition in boolean)
    return st_bool_num;

    function int_to_bool(p_value in integer)
    return boolean;


    function str_to_bool_str(p_str in varchar2)
    return st_flag_len;

    function str_to_single_quoted_str(p_str in varchar2)
    return varchar2
    deterministic;

    function char_at(p_str in varchar2, p_idx in integer, p_fail_on_null in boolean default false)
    return char
    deterministic;

    procedure add_str_token(p_text in out varchar2, p_token in varchar2, p_separator in varchar2 := g_default_separator);

    procedure prepend_str_token(p_text in out varchar2, p_token in varchar2, p_separator in varchar2 := g_default_separator);

    function try_parse_date(p_str in varchar2, p_date_format in varchar2)
    return date;

    function get_nth_token(p_text in varchar2, p_num in number, p_separator in varchar2)
    return varchar2;

    function get_pretty_str(p_str in varchar2)
    return varchar2;

    function has_value_changed(p_old in varchar2, p_new in varchar2)
    return boolean;




    function is_str_integer(p_str in varchar2)
    return boolean;

    function is_str_number(p_str in varchar2, p_decimal_separator in varchar2 := null, p_thousand_separator in varchar2 := null)
    return boolean;

    function is_str_alpha(p_str in varchar2)
    return boolean;

    function is_str_alphanumeric(p_str in varchar2)
    return boolean;


    function remove_alpha(p_str in varchar2)
    return varchar2;

    function remove_alphanumeric(p_str in varchar2)
    return varchar2;

    function remove_numeric(p_str in varchar2)
    return varchar2;

    function contains(p_str in varchar2, p_seq in varchar2)
    return boolean;

    function is_null_or_blank(p_value in varchar2)
    return boolean;



    function get_str (p_msg    in varchar2,
                      p_value1 in varchar2 := null,
                      p_value2 in varchar2 := null,
                      p_value3 in varchar2 := null,
                      p_value4 in varchar2 := null,
                      p_value5 in varchar2 := null,
                      p_value6 in varchar2 := null,
                      p_value7 in varchar2 := null,
                      p_value8 in varchar2 := null,
                      p_value9 in varchar2 := null,
                      p_value10 in varchar2 := null,
                      p_value11 in varchar2 := null,
                      p_value12 in varchar2 := null,
                      p_value13 in varchar2 := null,
                      p_value14 in varchar2 := null,
                      p_value15 in varchar2 := null
                      )
    return varchar2;

end string_utils_pkg;
