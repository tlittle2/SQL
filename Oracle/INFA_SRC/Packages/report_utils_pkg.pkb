create or replace package body report_utils_pkg
AS

--====================================================GLOBALS================================================================================================================

    type report_header_t is record(
        rpt_name    string_utils_pkg.st_max_db_varchar2,
        rpt_desc    string_utils_pkg.st_max_db_varchar2,
        rpt_date    string_utils_pkg.st_max_db_varchar2,
        rpt_line1   string_utils_pkg.st_max_db_varchar2,
        rpt_columns string_utils_pkg.st_max_db_varchar2,
        rpt_line2   string_utils_pkg.st_max_db_varchar2,
        rpt_footer  string_utils_pkg.st_max_db_varchar2
    );

    subtype st_type_codes is pls_integer;

    subtype sep_st is char(1);
    c_space_separator     constant sep_st := ' ';
    c_comma_separator     constant sep_st := ',';
    c_pipe_separator      constant sep_st := '|';
    c_semicolon_separator constant sep_st := ';';

    g_rolling_header_reset constant integer := 1;

    --==DONT TOUCH. USED FOR DYNAMIC CURSOR CREATION==
    g_varchar2 string_utils_pkg.st_max_db_varchar2;
    g_col_number number;
    g_col_date date;
    --==DONT TOUCH. USED FOR DYNAMIC CURSOR CREATION==

    c_tablespace_report  constant report_creation_parms.report_name%type := 'QR1036D2';
    c_astrology_report   constant report_creation_parms.report_name%type := 'QR1307D1';
    c_salary_data_report constant report_creation_parms.report_name%type := 'QR1031D1';
    c_glob_bin_report    constant report_creation_parms.report_name%type := 'GLOB_BIN';

--====================================================GET FORMATTING FROM TABLE==============================================================================================
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
        error_pkg.run_error_log(p_app_info => 'get_report_parms' , p_print => true, p_rollback => false, p_stop => true);
    end get_report_parms;

--====================================================HEADER FORMATTERS======================================================================================================
    function header_separator(p_row_length in number)
    return varchar2
    is
       l_chr char(1) := '=';
    begin
        return rpad(l_chr, p_row_length, l_chr);
    exception
        when others then
        error_pkg.run_error_log(p_app_info => 'get_report_parms' , p_print => true, p_rollback => false, p_stop => true);
    end header_separator;

    function center_content(p_input_str in varchar2, p_row_length in number)
    return varchar2
    is
        l_len        integer := length(p_input_str);
        l_total_pad  integer := p_row_length - l_len;
        l_left_pad   integer := floor(l_total_pad / 2);
    begin
        return rpad(lpad(p_input_str, l_len + (l_left_pad),c_space_separator), p_row_length,c_space_separator);
    exception
        when others then
        error_pkg.run_error_log(p_app_info => 'center_content' , p_print => true, p_rollback => false, p_stop => true);
    end center_content;

    function generate_header(p_title    in report_creation_parms.report_name%type
                           , p_pad      in report_creation_parms.padding%type
                           , p_col_list in DBMS_SQL.DESC_TAB
                           , p_desc     in report_creation_parms.report_description%type)
    return report_header_t
    is
        l_returnvalue report_header_t;
        l_row_length integer;
    begin
        for i in 1..p_col_list.count
        loop
            string_utils_pkg.add_str_token(l_returnvalue.rpt_columns, lpad(p_col_list(i).col_name, p_pad, c_space_separator), '');
        end loop;

        string_utils_pkg.add_str_token(l_returnvalue.rpt_columns, lpad(c_space_separator, p_pad, c_space_separator), '');

        l_row_length := length(l_returnvalue.rpt_columns);

        l_returnvalue.rpt_name := center_content(concat('Report Name: ', p_title), l_row_length);
        l_returnvalue.rpt_desc := center_content(concat('Report Description: ', p_desc), l_row_length);
        l_returnvalue.rpt_date := center_content(concat('Report Date: ', TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM')), l_row_length);
        l_returnvalue.rpt_line1 := header_separator(l_row_length);
        l_returnvalue.rpt_line2 := header_separator(l_row_length);
        l_returnvalue.rpt_footer := center_content('<<< End of Report >>>', l_row_length);

        return l_returnvalue;
    exception
       when others then
           error_pkg.run_error_log(p_app_info => 'generate_header' , p_print => true, p_rollback => false, p_stop => true);
    end generate_header;


    function generate_header(p_pad in report_creation_parms.padding%type, p_col_list in DBMS_SQL.DESC_TAB)
    return report_header_t
    is
        l_returnvalue report_header_t;
        l_row_length integer;
    begin
        for i in 1..p_col_list.count
        loop
            string_utils_pkg.add_str_token(l_returnvalue.rpt_columns, lpad(p_col_list(i).col_name, p_pad, c_space_separator), '');
        end loop;

        string_utils_pkg.add_str_token(l_returnvalue.rpt_columns, lpad(c_space_separator, p_pad, c_space_separator), '');

        l_row_length := length(l_returnvalue.rpt_columns);

        l_returnvalue.rpt_line1 := header_separator(l_row_length);
        l_returnvalue.rpt_line2 := header_separator(l_row_length);
        l_returnvalue.rpt_footer := center_content('<<< End of Report >>>', l_row_length);

        return l_returnvalue;
    exception
       when others then
           error_pkg.run_error_log(p_app_info => 'generate_header' , p_print => true, p_rollback => false, p_stop => true);
    end generate_header;

--====================================================ROLLING HEADERS========================================================================================================

    function want_rolling_header(p_rolling_header in report_creation_parms.rolling_header%type)
    return boolean
    is
    begin
        return p_rolling_header > 0;
    end want_rolling_header;

--====================================================DATA TYPE CHECKS=======================================================================================================
    function is_string(p_data_type in st_type_codes)
    return boolean
    is
    begin
        return p_data_type in (dbms_types.TYPECODE_VARCHAR,dbms_types.TYPECODE_CHAR);
   end is_string;

    function is_number(p_data_type in st_type_codes)
    return boolean
    is
    begin
        return p_data_type = dbms_types.TYPECODE_NUMBER;
    end is_number;

    function is_date(p_data_type in st_type_codes)
    return boolean
    is
    begin
        return p_data_type = dbms_types.TYPECODE_DATE;
    end is_date;

--====================================================HELPER FUNCTIONS=======================================================================================================

    function setup_and_define_columns(p_report_query in varchar2, p_cursor_id in number)
    return DBMS_SQL.DESC_TAB
    is
        l_col_cnt number;
        l_desc_tab DBMS_SQL.DESC_TAB;
    begin
        dbms_sql.parse(p_cursor_id, p_report_query, dbms_sql.native);
        dbms_sql.describe_columns(p_cursor_id, l_col_cnt, l_desc_tab);
        for i in 1..l_desc_tab.count
        loop
            if is_string(l_desc_tab(i).col_type)
            then
                dbms_sql.define_column(p_cursor_id, i, g_varchar2, l_desc_tab(i).col_max_len);
            elsif is_number(l_desc_tab(i).col_type)
            then
                dbms_sql.define_column(p_cursor_id, i, g_col_number);
            elsif is_date(l_desc_tab(i).col_type)
            then
                dbms_sql.define_column(p_cursor_id, i, g_col_date);
            end if;
        end loop;
        return l_desc_tab;
    exception
        when others then
        error_pkg.run_error_log(p_app_info => 'setup_and_define_columns' , p_print => true, p_rollback => false, p_stop => true);
    end setup_and_define_columns;


    function format_output(p_cursor_id in number, p_column_position in number, p_padding in integer, l_output_str in string_utils_pkg.st_max_db_varchar2, p_desc_tab in DBMS_SQL.DESC_TAB)
    return varchar2
    is
        l_returnvalue string_utils_pkg.st_max_db_varchar2;
    begin
        if is_string(p_desc_tab(p_column_position).col_type)
        then
            dbms_sql.column_value(p_cursor_id, p_column_position, g_varchar2);
            l_returnvalue:= concat(l_output_str, lpad(g_varchar2, p_padding, c_space_separator));

        elsif is_number(p_desc_tab(p_column_position).col_type)
        then
            dbms_sql.column_value(p_cursor_id, p_column_position, g_col_number);
            l_returnvalue:= concat(l_output_str, lpad(g_col_number, p_padding, c_space_separator));

        elsif is_date(p_desc_tab(p_column_position).col_type)
        then
            dbms_sql.column_value(p_cursor_id, p_column_position, g_col_date);
            l_returnvalue := concat(l_output_str, lpad(g_col_date, p_padding, c_space_separator));
        end if;
        return l_returnvalue;
    exception
        when others then
        error_pkg.run_error_log(p_app_info => 'format_output' , p_print => true, p_rollback => false, p_stop => true);
    end format_output;

    function get_max_col_length(p_desc_tab in DBMS_SQL.DESC_TAB)
    return integer
    is
        l_returnvalue integer := 0;
    begin
        for i in 1..p_desc_tab.count
        loop
            l_returnvalue := greatest(l_returnvalue, length(p_desc_tab(i).col_name));
        end loop;
        return l_returnvalue * 1.5;
    exception
        when others then
        error_pkg.run_error_log(p_app_info => 'get_max_col_length' , p_print => true, p_rollback => false, p_stop => true);
    end get_max_col_length;

    function cursor_has_rows(p_cursor_id in number)
    return boolean
    is
    begin
        return dbms_sql.fetch_rows(p_cursor_id) > 0;
    end cursor_has_rows;


--====================================================REPORT GENERATORS======================================================================================================

    function generate_report(p_report_title in report_creation_parms.report_name%type)
    return report_tab_t pipelined
    is
        l_cursor_id number;
        l_dummy number;
        l_desc_tab DBMS_SQL.DESC_TAB;
        l_output_str string_utils_pkg.st_max_db_varchar2;
        l_report_parms report_creation_parms%rowtype;
        l_report_header report_header_t;
        l_rolling_header integer := g_rolling_header_reset;
    begin
        l_report_parms := get_report_parms(p_report_title);
        l_cursor_id := dbms_sql.open_cursor;
        l_desc_tab := setup_and_define_columns(l_report_parms.report_query, l_cursor_id);
        l_report_header := generate_header(p_report_title,l_report_parms.padding,l_desc_tab,l_report_parms.report_description);

        pipe row(l_report_header.rpt_name);
        pipe row(l_report_header.rpt_desc);
        pipe row(l_report_header.rpt_date);
        pipe row(l_report_header.rpt_line1);
        pipe row(l_report_header.rpt_columns);
        pipe row(l_report_header.rpt_line2);

        l_dummy := dbms_sql.execute(l_cursor_id);
        while cursor_has_rows(l_cursor_id)
        loop
            l_output_str := null;
            for entry in 1..l_desc_tab.count
            loop
                l_output_str := format_output(l_cursor_id, entry, l_report_parms.padding, l_output_str, l_desc_tab);
            end loop;

            if want_rolling_header(l_rolling_header)
            then
                if l_rolling_header = l_report_parms.rolling_header
                then
                    PIPE ROW(l_report_header.rpt_line1);
                    PIPE ROW(l_report_header.rpt_columns);
                    PIPE ROW(l_report_header.rpt_line2);
                    l_rolling_header := g_rolling_header_reset;
                else
                    l_rolling_header := l_rolling_header + g_rolling_header_reset;
                end if;
            end if;
            pipe row (l_output_str);
        end loop;

        dbms_sql.close_cursor(l_cursor_id);

        pipe row (null);
        pipe row (l_report_header.rpt_footer);
        return;
    exception
        when no_data_found then
            sql_utils_pkg.close_cursor(l_cursor_id);
            assert_pkg.is_true(2=1, 'REPORT NAME ' || p_report_title || ' NOT RECOGNIZED'); --throw assert to have console show actual error
        when others then
            sql_utils_pkg.close_cursor(l_cursor_id);
            error_pkg.run_error_log(p_app_info => 'generate_report' , p_print => false, p_rollback => false, p_stop => true);
    end generate_report;

    function generate_report2(p_query in varchar2)
    --function generate_report2(p_query in sql_builder_pkg.t_query)
    return report_tab_t pipelined
    is
        l_cursor_id number;
        l_dummy number;
        l_desc_tab DBMS_SQL.DESC_TAB;
        l_output_str string_utils_pkg.st_max_db_varchar2;
        l_report_header report_header_t;
        l_padding integer;
    begin
        l_cursor_id := DBMS_SQL.OPEN_CURSOR;
        l_desc_tab := setup_and_define_columns(p_query, l_cursor_id);
        l_padding := get_max_col_length(l_desc_tab);
        l_report_header := generate_header(l_padding,l_desc_tab);

        pipe row(l_report_header.rpt_line1);
        pipe row(l_report_header.rpt_columns);
        pipe row(l_report_header.rpt_line2);

        l_dummy := dbms_sql.execute(l_cursor_id);
        while cursor_has_rows(l_cursor_id)
        loop
            l_output_str := null;
            for entry in 1..l_desc_tab.count
            loop
                l_output_str := format_output(l_cursor_id, entry, l_padding, l_output_str, l_desc_tab);
            end loop;
            pipe row (l_output_str);
        end loop;

        dbms_sql.close_cursor(l_cursor_id);

        return;
    exception
        when others then
        sql_utils_pkg.close_cursor(l_cursor_id);
        error_pkg.run_error_log(p_app_info => 'generate_report2' , p_print => true, p_rollback => false, p_stop => true);
    end generate_report2;


    procedure generate_cursor_report(p_query in sql_builder_pkg.t_query, p_cursor out sql_utils_pkg.ref_cursor_t)
    is
    begin
        open p_cursor for sql_builder_pkg.get_sql(p_query, true, true, true);
    exception
        when others then
            error_pkg.run_error_log(p_cursor => p_cursor, p_app_info => 'generate_cursor_report' , p_print => true, p_rollback => false, p_stop => true);
    end generate_cursor_report;

--====================================================LOAD SPOOLS TO TABLES==================================================================================================

   procedure create_control_report(p_report_title in report_creation_parms.report_name%type, p_bulk_limit in integer default 10000)
   is
       cursor cur_report is
        SELECT p_report_title as rep_id
       , ROWNUM       AS seq_number
       , sysdate      AS created_date
       , column_value AS text_line
       from TABLE (report_utils_pkg.generate_report(p_report_title));

       l_table control_reps_tapi.control_reps_tapi_tab := control_reps_tapi.control_reps_tapi_tab();
   begin
       control_reps_tapi.del(p_report_title);
       sql_utils_pkg.commit;

       open cur_report;
       loop
           fetch cur_report bulk collect into l_table limit p_bulk_limit;
           exit when l_table.count = 0;

           control_reps_tapi.ins_bulk(l_table);
           sql_utils_pkg.commit;
       end loop;
       close cur_report;

   exception
       when others then
           if cur_report%isopen
           then
               close cur_report;
           end if;
           error_pkg.run_error_log(p_app_info => 'create_control_report' , p_print => true, p_rollback => true, p_stop => true);
   end create_control_report;

   procedure create_control_report(p_reports in t_str_array)
   is
   begin
       for rpt in p_reports.first..p_reports.last
       loop
           report_utils_pkg.create_control_report(p_reports(rpt));
       end loop;
   exception
       when others then
       error_pkg.run_error_log(p_app_info => 'create_control_report_driver' , p_print => true, p_rollback => false, p_stop => true);
   end create_control_report;

--====================================================REPORT PARM CONSTANTS==================================================================================================

   function get_tablespace_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return c_tablespace_report;
   end get_tablespace_report;

   function get_astrology_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return c_astrology_report;
   end get_astrology_report;

   function get_salary_data_report
   return report_creation_parms.report_name%type
   deterministic
   is
   begin
       return c_salary_data_report;
   end get_salary_data_report;

    function get_glob_bin_report
    return report_creation_parms.report_name%type
    deterministic
    is
    begin
        return c_glob_bin_report;
    end get_glob_bin_report;

end report_utils_pkg;
