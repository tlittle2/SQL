create or replace package body report_utils_pkg
AS
    type report_header_t is record(
        rpt_name string_utils_pkg.st_max_db_varchar2,
        rpt_date string_utils_pkg.st_max_db_varchar2,
        rpt_line1 string_utils_pkg.st_max_db_varchar2,
        rpt_columns string_utils_pkg.st_max_db_varchar2,
        rpt_line2 string_utils_pkg.st_max_db_varchar2
    );

    type column_list_t is table of all_tab_columns.column_name%type;

    subtype sep_st is char(1);
    c_space_separator     constant sep_st := ' ';
    c_comma_separator     constant sep_st := ',';
    c_pipe_separator      constant sep_st := '|';
    c_semicolon_separator constant sep_st := ';';

    g_rolling_header integer := 1;
    g_row_length INTEGER := 1;

--===========================================================================================================================================================================
    function get_report_parms(p_report_title in report_creation_parms.report_name%type)
    return report_creation_parms%rowtype
    is
        l_returnvalue report_creation_parms%rowtype;
    begin
        select *
        into l_returnvalue
        from report_creation_parms
        where report_name = p_report_title;

        return l_returnvalue;

    exception
        when no_data_found then
            raise;
    end get_report_parms;

    function generate_header(p_title in varchar2, p_pad in integer, p_col_list in column_list_t)
    return report_header_t
    is
        l_returnvalue report_header_t;

        function header_separator
        return varchar2 deterministic
        is
        begin
            return rpad('=', g_row_length, '=');
        end header_separator;

        function center_content(p_input_str in varchar2)
        return varchar2 deterministic
        is
            l_total_pad  INTEGER := G_ROW_LENGTH - LENGTH(p_input_str);
            l_left_pad   INTEGER := FLOOR(l_total_pad / 2);
        begin
            return rpad(lpad(p_input_str, length(p_input_str) + (l_left_pad), ' '), g_row_length, ' ');
        end center_content;

    begin
        for i in 1..p_col_list.count
        loop
            string_utils_pkg.add_str_token(l_returnvalue.rpt_columns, rpad(p_col_list(i), p_pad, c_space_separator), '');
        end loop;

        g_row_length := length(l_returnvalue.rpt_columns);

        l_returnvalue.rpt_name := center_content(concat('Report Name: ', p_title));
        l_returnvalue.rpt_date := center_content(concat('Report Date: ', TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM')));
        l_returnvalue.rpt_line1 := header_separator;
        l_returnvalue.rpt_line2 := header_separator;

        return l_returnvalue;

    exception
       when others then
           raise;
    end generate_header;

--===========================================================================================================================================================================

    function want_rolling_header(p_rolling_header in report_creation_parms.rolling_header%type)
    return boolean
    is
        l_returnvalue boolean := false;
    begin
        if p_rolling_header > 0
        then
           l_returnvalue := true;
        end if;

        return l_returnvalue;
    exception
       when others then
           raise;
    end want_rolling_header;

    function reached_rolling_header(p_max_count in integer)
    return boolean
    is
    begin
        if g_rolling_header = p_max_count
        then
            g_rolling_header := 1;
            return true;
        else
            g_rolling_header := g_rolling_header + 1;
            return false;
        end if;
    exception
       when others then
           raise;
    end reached_rolling_header;


--===========================================================================================================================================================================
    function is_string(p_data_type in number)
    return boolean
    is
        l_returnvalue boolean;
    begin
        if p_data_type in (1,96)
        then
            l_returnvalue := true;
        else
            l_returnvalue := false;
        end if;

        return l_returnvalue;
    end is_string;

    function is_number(p_data_type in number)
    return boolean
    is
        l_returnvalue boolean;
    begin
        if p_data_type = 2
        then
            l_returnvalue := true;
        else
            l_returnvalue := false;
        end if;

        return l_returnvalue;
    end is_number;

    function is_date(p_data_type in number)
    return boolean
    is
        l_returnvalue boolean;
    begin
        if p_data_type = 12
        then
            l_returnvalue := true;
        else
            l_returnvalue := false;
        end if;

        return l_returnvalue;
    end is_date;

--===========================================================================================================================================================================

    function general_report(p_report_title in report_creation_parms.report_name%type)
    return report_tab_t pipelined
    is
        l_cursor_id number;
        l_dummy number;

        l_col_cnt number;
        l_desc_tab DBMS_SQL.DESC_TAB;

        l_varchar2 string_utils_pkg.st_max_db_varchar2;
        l_col_number number;
        l_col_date date;

        l_output_str string_utils_pkg.st_max_db_varchar2;
        l_column_names column_list_t := column_list_t();

        l_report_parms report_creation_parms%rowtype;

        l_report_header report_header_t;

        procedure setup_and_define_columns
        is
        begin
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, l_report_parms.report_query, DBMS_SQL.NATIVE);
            dbms_sql.describe_columns(l_cursor_id, l_col_cnt, l_desc_tab);

            for i in 1..l_desc_tab.count
            loop
                l_column_names.extend;
                l_column_names(l_column_names.last) := l_desc_tab(i).col_name;

                if is_string(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(l_cursor_id, i, l_varchar2, l_desc_tab(i).col_max_len);

                elsif is_number(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(l_cursor_id, i, l_col_number);

                elsif is_date(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(l_cursor_id, i, l_col_date);
                end if;

                g_row_length := g_row_length + length(l_desc_tab(i).col_name);
            end loop;

        exception
            when others then
            raise;
        end setup_and_define_columns;

        function format_output(i in number)
        return varchar2
        is
            l_returnvalue string_utils_pkg.st_max_db_varchar2;
        begin

            if is_string(l_desc_tab(i).col_type)
            then
                dbms_sql.column_value(l_cursor_id, i, l_varchar2);
                l_returnvalue:= concat(l_output_str, rpad(l_varchar2, l_report_parms.padding, c_space_separator));

            elsif is_number(l_desc_tab(i).col_type)
            then
                dbms_sql.column_value(l_cursor_id, i, l_col_number);
                l_returnvalue:= concat(l_output_str, rpad(l_col_number,l_report_parms.padding, c_space_separator));

            elsif is_date(l_desc_tab(i).col_type)
            then
                dbms_sql.column_value(l_cursor_id, i, l_col_date);
                l_returnvalue := concat(l_output_str, rpad(l_col_date, l_report_parms.padding, c_space_separator));
            end if;

            return l_returnvalue;
        exception
            when others then
                raise;
        end format_output;

    begin --general_report
        l_report_parms := get_report_parms(p_report_title);

        setup_and_define_columns;

        l_report_header := generate_header(p_report_title,l_report_parms.padding,l_column_names);
        pipe row(l_report_header.rpt_name);
        pipe row(l_report_header.rpt_date);
        pipe row(l_report_header.rpt_line1);
        pipe row(l_report_header.rpt_columns);
        pipe row(l_report_header.rpt_line2);

        l_dummy := dbms_sql.execute(l_cursor_id);
        while dbms_sql.fetch_rows(l_cursor_id) > 0
        loop
            l_output_str := null;
            for i in 1..l_desc_tab.count
            loop
                l_output_str := format_output(i);
            end loop;

            if want_rolling_header(l_report_parms.rolling_header) and reached_rolling_header(l_report_parms.rolling_header)
            then
                PIPE ROW(l_report_header.rpt_line1);
                PIPE ROW(l_report_header.rpt_columns);
                PIPE ROW(l_report_header.rpt_line2);
            end if;

            pipe row (l_output_str);
        end loop;

        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        return;
    exception
        when no_data_found then
            assert_pkg.is_true(2=1, 'REPORT NAME NOT RECOGNIZED');
            if dbms_sql.is_open(l_cursor_id)
            then
                DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            end if;
        when others then
            if dbms_sql.is_open(l_cursor_id)
            then
                DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            end if;
    end general_report;
--===========================================================================================================================================================================

   function f_tablespace_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return 'QR1036D2';
   end f_tablespace_report;

   function f_astrology_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return 'QR1307D1';
   end f_astrology_report;

   function f_salary_data_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return 'QR1031D1';
   end f_salary_data_report;

--===========================================================================================================================================================================
end report_utils_pkg;
