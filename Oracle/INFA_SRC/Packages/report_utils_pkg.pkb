create or replace package body report_utils_pkg
AS
    type report_header_t is record(
        rpt_name string_utils_pkg.st_max_db_varchar2,
        rpt_date string_utils_pkg.st_max_db_varchar2,
        rpt_line1 string_utils_pkg.st_max_db_varchar2,
        rpt_columns string_utils_pkg.st_max_db_varchar2,
        rpt_line2 string_utils_pkg.st_max_db_varchar2
    );

    report_header report_header_t;

    type column_list_t is table of all_tab_columns.column_name%type;

    c_space_separator constant VARCHAR2(1)     := ' ';
    c_comma_separator constant VARCHAR2(1)     := ',';
    c_pipe_separator constant VARCHAR2(1)      := '|';
    c_semicolon_separator constant VARCHAR2(1) := ';';

    g_rolling_header integer;
    g_row_length INTEGER := 1;

--===========================================================================================================================================================================
   function f_tablespace_report
   return varchar2
   deterministic
   is
   begin
       return 'select nvl(tablespace_name, ''(blank)'') as tablespace_name , sum(nvl(num_rows,0)) as volume from my_tables group by tablespace_name order by volume desc';
   end f_tablespace_report;

   function f_astrology_report
   return varchar2
   deterministic
   is
   begin
       return 'select * from astrology';
   end f_astrology_report;


   function f_salary_data_report
   return varchar2
   deterministic
   is
   begin
       return 'select CASE_NUM, ID, GENDER, DEGREE, YEAR_DEGREE, FIELD, START_YEAR, YEAR, to_char(eff_date, ''mm/dd/yyyy'') as eff_date from salary_data';
   end f_salary_data_report;


   procedure is_valid_query(p_query in varchar2)
   is
   begin
       assert_pkg.is_true(p_query in (f_salary_data_report,f_astrology_report,f_tablespace_report), 'INVALID QUERY PROVIDED. PLEASE CORRECT');
   end is_valid_query;


--===========================================================================================================================================================================


--===========================================================================================================================================================================
    procedure generate_header(p_title in varchar2, p_pad in integer, p_col_list in column_list_t, p_report_header out report_header_t)
    is
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
            string_utils_pkg.add_str_token(p_report_header.rpt_columns, rpad(p_col_list(i), p_pad, c_space_separator), '');
        end loop;

        g_row_length := length(p_report_header.rpt_columns);

        p_report_header.rpt_name := center_content('Report Name: ' || p_title);
        p_report_header.rpt_date := center_content('Report Date: ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
        p_report_header.rpt_line1 := header_separator;
        p_report_header.rpt_line2 := header_separator;

    end generate_header;

--===========================================================================================================================================================================

    function generate_rolling_header(p_max_count in integer)
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
    end generate_rolling_header;


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

    function general_report(p_report_title in varchar2 default null, p_padding in number default 20, p_rolling_header in integer default 0, p_select in varchar2)
    return report_tab_t pipelined
    is
        v_cursor_id number;
        v_dummy number;

        l_col_cnt number;
        l_desc_tab DBMS_SQL.DESC_TAB;

        l_varchar2 string_utils_pkg.st_max_db_varchar2;
        l_col_number number;
        l_col_date date;

        l_output_str string_utils_pkg.st_max_db_varchar2;
        l_column_names column_list_t := column_list_t();

        procedure setup_and_define_columns
        is
        begin
           v_cursor_id := DBMS_SQL.OPEN_CURSOR;
           DBMS_SQL.PARSE(v_cursor_id, p_select, DBMS_SQL.NATIVE);
           dbms_sql.describe_columns(v_cursor_id, l_col_cnt, l_desc_tab);
            for i in 1..l_desc_tab.count
            loop
                l_column_names.extend;
                l_column_names(l_column_names.last) := l_desc_tab(i).col_name;

                if is_string(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(v_cursor_id, i, l_varchar2, l_desc_tab(i).col_max_len); --match the max varchar2 possible for db table

                elsif is_number(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(v_cursor_id, i, l_col_number);

                elsif is_date(l_desc_tab(i).col_type)
                then
                    dbms_sql.define_column(v_cursor_id, i, l_col_date);
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
                dbms_sql.column_value(v_cursor_id, i, l_varchar2);
                l_returnvalue:= concat(l_output_str, rpad(l_varchar2, p_padding, c_space_separator));

            elsif is_number(l_desc_tab(i).col_type)
            then
                dbms_sql.column_value(v_cursor_id, i, l_col_number);
                l_returnvalue:= concat(l_output_str, rpad(l_col_number, p_padding, c_space_separator));

            elsif is_date(l_desc_tab(i).col_type)
            then
                dbms_sql.column_value(v_cursor_id, i, l_col_date);
                l_returnvalue := concat(l_output_str, rpad(l_col_date, p_padding, c_space_separator));
            end if;

            return l_returnvalue;
        end format_output;

    begin --general_report
        is_valid_query(p_select);

        g_rolling_header := 1; --don't touch this, required for rolling headers

        setup_and_define_columns;

        generate_header(p_report_title,p_padding,l_column_names, report_header);

        pipe row(report_header.rpt_name);
        pipe row(report_header.rpt_date);
        pipe row(report_header.rpt_line1);
        pipe row(report_header.rpt_columns);
        pipe row(report_header.rpt_line2);

        v_dummy := dbms_sql.execute(v_cursor_id);

        while dbms_sql.fetch_rows(v_cursor_id) > 0
        loop
            l_output_str := null;
            for i in 1..l_desc_tab.count
            loop
                l_output_str := format_output(i);
            end loop;

            if p_rolling_header > 0 and generate_rolling_header(p_rolling_header)
            then
                PIPE ROW(report_header.rpt_line1);
                PIPE ROW(report_header.rpt_columns);
                PIPE ROW(report_header.rpt_line2);
            end if;
            pipe row (l_output_str);
        end loop;

        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        return;

    exception
        when others then
            if dbms_sql.is_open(v_cursor_id)
            then
                DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
            end if;
    end general_report;

--===========================================================================================================================================================================

    function create_trxn_file
    return report_tab_t pipelined
    is
        c_rpt_pad CONSTANT INTEGER := 20;
        c_fixed_length CONSTANT INTEGER := 1300;
        rw_count INTEGER :=0;

        cursor salary_details is
        select
        rpad(
            rpad(CASE_NUM, c_rpt_pad, c_space_separator)
        ||  rpad(ID, c_rpt_pad, c_space_separator)
        ||  rpad(GENDER, c_rpt_pad, c_space_separator)
        ||  rpad(DEGREE, c_rpt_pad, c_space_separator)
        ||  rpad(YEAR_DEGREE, c_rpt_pad, c_space_separator)
        ||  rpad(FIELD, c_rpt_pad, c_space_separator)
        ||  rpad(START_YEAR, c_rpt_pad, c_space_separator)
        ||  rpad(YEAR, c_rpt_pad, c_space_separator)
        ||  rpad(RANK, c_rpt_pad, c_space_separator)
        ||  rpad(ADMIN, c_rpt_pad, c_space_separator)
        ||  rpad(SALARY, c_rpt_pad, c_space_separator)
        ||  rpad(EFF_DATE, c_rpt_pad, c_space_separator)
        ||  rpad(END_DATE, c_rpt_pad, c_space_separator)
        ||  rpad(CREATE_ID, c_rpt_pad, c_space_separator)
        ||  rpad(LAST_UPDATE_ID, c_rpt_pad, c_space_separator)
        , c_fixed_length, ' ') as trxn_data
        from salary_data;
    begin

        PIPE ROW(rpad('H F' || rpad(' ', 4, ' ') || 'transaction'  ||rpad(' ', 36, ' ') || to_char(SYSDATE, 'YYYYMMDDHHMMSS'), c_fixed_length, ' '));

        for rec in salary_details
        loop
            PIPE ROW(rec.trxn_data);
            rw_count := rw_count + 1;
        end loop;

        PIPE ROW(rpad('T ' || rw_count, c_fixed_length, c_space_separator));
        RETURN;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if salary_details%isopen then
            close salary_details;
        end if;

    end create_trxn_file;
--===========================================================================================================================================================================



end report_utils_pkg;
