create or replace package body string_utils_pkg
as

    m_nls_decimal_separator        varchar2(1);

    function bool_to_str(p_value in boolean)
    return st_bool_str_len
    is
    begin
        return case (p_value)
        when true then  'TRUE'
        when false then 'FALSE'
        else 'NULL'
        end;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
    end bool_to_str;


    function bool_to_int(p_condition in boolean)
    return st_bool_num
    is
        l_returnvalue st_bool_num := g_true;
    begin
        if not nvl(p_condition, false)
        then
            l_returnvalue := g_false;
        end if;

        return l_returnvalue;
    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
    end bool_to_int;


    function int_to_bool(p_value in integer)
    return boolean
    is
    begin
        assert_pkg.is_true(p_value in (g_true, g_false), 'invalid value provided. please investigate');
        return case (p_value)
        when g_true then true
        when g_false then false
        end;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
    end int_to_bool;

    function str_to_bool(p_str in varchar2)
    return boolean
    is
        l_returnvalue boolean := false;
    begin
        if lower(p_str) in ('y', 'yes', 'true', '1')
        then
            l_returnvalue := true;
        end if;

        return l_returnvalue;

    end str_to_bool;


    function str_to_bool_str(p_str in varchar2)
    return st_flag_len
    is
        l_returnvalue st_flag_len := g_no;
    begin
        if str_to_bool(p_str)
        then
            l_returnvalue := g_yes;
        end if;

        return l_returnvalue;
    end str_to_bool_str;

    function str_to_single_quoted_str(p_str in varchar2)
    return varchar2
    deterministic
    is
    begin
        return '''' || p_str || '''';
    end str_to_single_quoted_str;

    function char_at(p_str in varchar2, p_idx in integer, p_fail_on_null in boolean default false)
    return char
    deterministic
    is
    l_returnvalue char(1);
    begin
        l_returnvalue := substr(p_str, p_idx, 1);

        if p_fail_on_null
        then
            assert_pkg.is_not_null(l_returnvalue, 'NO SUCH INDEX. PLEASE INVESTIGATE');
        end if;

        return l_returnvalue;
    end char_at;




    procedure add_str_token(p_text in out varchar2, p_token in varchar2, p_separator in varchar2 := g_default_separator)
    is
    begin
        if p_text is null
        then
            p_text := p_token;
        else
            p_text := p_text || p_separator || p_token;
        end if;
    end add_str_token;


    procedure prepend_str_token(p_text in out varchar2, p_token in varchar2, p_separator in varchar2 := g_default_separator)
    is
    begin
        if p_text is null
        then
            p_text := p_token;
        else
            p_text := p_token || p_separator || p_text;
        end if;
    end prepend_str_token;


    function try_parse_date(p_str in varchar2, p_date_format in varchar2)
    return date
    is
        l_returnvalue DATE;
    begin
        l_returnvalue := to_date(p_str, p_date_format);

        return l_returnvalue;
    exception
        when others then
        l_returnvalue := null;
    end try_parse_date;

    function get_pretty_str(p_str in varchar2)
    return varchar2
    is
    begin
        return replace(initcap(trim(p_str)), '_', ' ');
    end get_pretty_str;

    function has_value_changed(p_old in varchar2, p_new in varchar2)
    return boolean
    is
        l_returnvalue boolean := false;
    begin
        if (p_old <> p_new) or (p_old is null and p_new is not null) or (p_old is not null and p_new is null)
        then
            l_returnvalue := true;
        end if;

        return l_returnvalue;

    end has_value_changed;

    function get_nth_token(p_text in varchar2, p_num in number, p_separator in varchar2)
    return varchar2
    is
        l_pos_begin pls_integer;
        l_pos_end pls_integer;
        l_returnvalue string_utils_pkg.st_max_pl_varchar2;
    begin
        if p_num <= 0
        then
            return null;
        elsif p_num = 1
        then
            l_pos_begin := 1;
        else
            l_pos_begin := instr(p_text, p_separator, 1, p_num-1);
        end if;

        l_pos_end := instr(p_text, p_separator, 1, p_num);

        if l_pos_end > 1
        then
            l_pos_end := l_pos_end -1;
        end if;

        if l_pos_begin > 0
        then
            if l_pos_end <=0
            then
                l_pos_end := length(p_text);
            end if;

            if p_num = 1
            then
                l_returnvalue := substr(p_text, l_pos_begin, l_pos_end - l_pos_begin + 1);
            else
                l_returnvalue := substr(p_text, l_pos_begin + 1, l_pos_end - l_pos_begin);
            end if;

        else
            l_returnvalue := null;

        end if;

        return l_returnvalue;

    exception
        when others then
        return null;
    end get_nth_token;


    function is_str_integer(p_str in varchar2)
    return boolean
    is
        l_returnvalue boolean :=regexp_instr(p_str, regex_utils_pkg.g_regex_integer_not) = 0;
    begin
        return l_returnvalue;
    end;

    function is_str_alpha(p_str in varchar2)
    return boolean
    is
        l_returnvalue boolean :=regexp_instr(p_str, regex_utils_pkg.g_regex_alpha_not) = 0;
    begin
        return l_returnvalue;
    end is_str_alpha;


    function is_str_alphanumeric(p_str in varchar2)
    return boolean
    is
        l_returnvalue boolean :=regexp_instr(p_str, regex_utils_pkg.g_regex_alphanumeric_not) = 0;
    begin
        return l_returnvalue;
    end is_str_alphanumeric;


    function get_nls_decimal_separator return varchar2
    as
    l_returnvalue varchar2(1);
    begin
        if m_nls_decimal_separator is null then
            begin
                select substr(value,1,1)
                into l_returnvalue
                from nls_session_parameters
                where parameter = 'NLS_NUMERIC_CHARACTERS';
            exception
                when no_data_found then
                    l_returnvalue:='.';
            end;

        m_nls_decimal_separator := l_returnvalue;
       end if;

       l_returnvalue := m_nls_decimal_separator;

       return l_returnvalue;

    end get_nls_decimal_separator;

    function is_str_number(p_str in varchar2, p_decimal_separator in varchar2 := null, p_thousand_separator in varchar2 := null)
    return boolean
    is
        l_number number;
        l_returnvalue boolean;
    begin
        begin
            if (p_decimal_separator is null) and (p_thousand_separator is null)
            then
                l_number := to_number(p_str);
            else
                l_number := to_number(replace(replace(p_str, p_thousand_separator, ''), p_decimal_separator, get_nls_decimal_separator));
            end if;

            l_returnvalue := true;

        exception
            when others then
                l_returnvalue := false;
        end;

        return l_returnvalue;

    end is_str_number;


    function remove_alpha(p_str in varchar2)
    return varchar2
    is
    begin
        return regexp_replace(p_str, regex_utils_pkg.g_regex_alpha, '');
    end remove_alpha;


    function remove_alphanumeric(p_str in varchar2)
    return varchar2
    is
    begin
        return regexp_replace(p_str, regex_utils_pkg.g_regex_alphanumeric, '');
    end remove_alphanumeric;


    function remove_numeric(p_str in varchar2)
    return varchar2
    is
    begin
        return regexp_replace(p_str, '[0-9,.]', '');
    end remove_numeric;



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
    return varchar2
    is
        l_returnvalue string_utils_pkg.st_max_pl_varchar2;

        function replace_str(p_value in varchar2, p_position in varchar2)
        return varchar2
        is
        begin
            return replace(l_returnvalue,p_position, nvl(p_value, '(blank)'));
        end;

    begin
        l_returnvalue := p_msg;

        l_returnvalue := replace_str(p_value1, '%1');
        l_returnvalue := replace_str(p_value2, '%2');
        l_returnvalue := replace_str(p_value3, '%3');
        l_returnvalue := replace_str(p_value4, '%4');
        l_returnvalue := replace_str(p_value5, '%5');
        l_returnvalue := replace_str(p_value6, '%6');
        l_returnvalue := replace_str(p_value7, '%7');
        l_returnvalue := replace_str(p_value8, '%8');
        l_returnvalue := replace_str(p_value9, '%9');
        l_returnvalue := replace_str(p_value10, '%10');
        l_returnvalue := replace_str(p_value11, '%11');
        l_returnvalue := replace_str(p_value12, '%12');
        l_returnvalue := replace_str(p_value13, '%13');
        l_returnvalue := replace_str(p_value14, '%14');
        l_returnvalue := replace_str(p_value15, '%15');

        return l_returnvalue;
    end get_str;

end string_utils_pkg;
