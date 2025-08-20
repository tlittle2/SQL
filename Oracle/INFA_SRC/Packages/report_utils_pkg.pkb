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
    
    g_rolling_header integer := 0;

    type column_list_t is table of all_tab_columns.column_name%type;

    c_space_separator constant VARCHAR2(1) := ' ';
    c_comma_separator constant VARCHAR2(1) := ',';
    c_pipe_separator constant VARCHAR2(1) := '|';
    c_semicolon_separator constant VARCHAR2(1) := ';';

    g_row_length INTEGER := 0;


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
        p_report_header.rpt_name := center_content('Report Name: ' || p_title);
        p_report_header.rpt_date := center_content('Report Date: ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));

        p_report_header.rpt_line1 := header_separator;

        for i in 1..p_col_list.count
        loop
            string_utils_pkg.add_str_token(p_report_header.rpt_columns, rpad(p_col_list(i), p_pad, c_space_separator), '');
        end loop;

        p_report_header.rpt_line2 := header_separator;

    end generate_header;

--===========================================================================================================================================================================

    function generate_rolling_header(p_curr_count in out integer, p_max_count in integer)
    return boolean
    is
    begin
        if p_curr_count = p_max_count
        then
            p_curr_count := 0;
            return true;
        end if;

        return false;
    end generate_rolling_header;
--===========================================================================================================================================================================

    function salary_data_report(p_report_title in varchar2)
    return report_tab_t pipelined
    is
        c_rpt_pad constant integer := 15;
        cursor salary_report is
        select 
            rpad(case_num, c_rpt_pad, c_space_separator)
        ||  rpad(id, c_rpt_pad, c_space_separator)
        ||  rpad(gender, c_rpt_pad, c_space_separator)
        ||  rpad(degree, c_rpt_pad, c_space_separator)
        ||  rpad(year_degree, c_rpt_pad, c_space_separator)
        ||  rpad(field, c_rpt_pad, c_space_separator)
        ||  rpad(start_year, c_rpt_pad, c_space_separator)
        ||  rpad(year, c_rpt_pad, c_space_separator)
        ||  rpad(rank, c_rpt_pad, c_space_separator)
        ||  rpad(admin, c_rpt_pad, c_space_separator)
        ||  rpad(salary, c_rpt_pad, c_space_separator)
        ||  rpad(to_char(eff_date, 'mm/dd/yyyy'), c_rpt_pad, c_space_separator)
        /*||  rpad(to_char(end_date, 'mm/dd/yyyy'), c_rpt_pad, c_space_separator)
        ||  rpad(create_id, c_rpt_pad, c_space_separator)
        ||  rpad(last_update_id, c_rpt_pad, c_space_separator)*/ as data
        from salary_data_stg;

        rec_length salary_report%rowtype;

        col_list COLUMN_LIST_T := COLUMN_LIST_T('CASE_NUM' , 'ID' , 'GENDER' , 'DEGREE' , 'YEAR_DEGREE' , 'FIELD' , 'START_YEAR' , 'YEAR' , 'RANK' , 'ADMIN' , 'SALARY' , 'EFF_DATE' /*, 'END_DATE' , 'CREATE_ID' , 'LAST_UPDATE_ID'*/);

    begin
        --peek the first row to get length
        open salary_report;
        fetch salary_report into rec_length;
        g_row_length :=length(rec_length.data);
        close salary_report;

        generate_header(p_report_title,c_rpt_pad, col_list, report_header);

        PIPE ROW(report_header.rpt_name);
        PIPE ROW(report_header.rpt_date);
        PIPE ROW(report_header.rpt_line1);
        PIPE ROW(report_header.rpt_columns);
        PIPE ROW(report_header.rpt_line2);
        
        

        for rec in salary_report
        loop
            PIPE ROW(rec.data);
         end loop;

         PIPE ROW(report_header.rpt_line2);

        RETURN;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if salary_report%isopen then
            close salary_report;
        end if;
    end salary_data_report;
    
--===========================================================================================================================================================================
    function salary_data_report2(p_report_title in varchar2)
    return report_tab_t pipelined
    is
        c_rpt_pad constant integer := 15;
        
        cursor salary_report is
        select 
            rpad(case_num, c_rpt_pad, c_space_separator)
        ||  rpad(id, c_rpt_pad, c_space_separator)
        ||  rpad(gender, c_rpt_pad, c_space_separator)
        ||  rpad(degree, c_rpt_pad, c_space_separator)
        ||  rpad(year_degree, c_rpt_pad, c_space_separator)
        ||  rpad(field, c_rpt_pad, c_space_separator)
        ||  rpad(start_year, c_rpt_pad, c_space_separator)
        ||  rpad(year, c_rpt_pad, c_space_separator)
        ||  rpad(rank, c_rpt_pad, c_space_separator)
        ||  rpad(admin, c_rpt_pad, c_space_separator)
        ||  rpad(salary, c_rpt_pad, c_space_separator)
        ||  rpad(to_char(eff_date, 'mm/dd/yyyy'), c_rpt_pad, c_space_separator)
        as data
        from salary_data_stg;

        rec_length salary_report%rowtype;

        col_list COLUMN_LIST_T := COLUMN_LIST_T('CASE_NUM' , 'ID' , 'GENDER' , 'DEGREE' , 'YEAR_DEGREE' , 'FIELD' , 'START_YEAR' , 'YEAR' , 'RANK' , 'ADMIN' , 'SALARY' , 'EFF_DATE');

    begin
        --peek the first row to get length
        open salary_report;
        fetch salary_report into rec_length;
        g_row_length :=length(rec_length.data);
        close salary_report;

        generate_header(p_report_title,c_rpt_pad, col_list, report_header);

        PIPE ROW(report_header.rpt_name);
        PIPE ROW(report_header.rpt_date);
        PIPE ROW(report_header.rpt_line1);
        PIPE ROW(report_header.rpt_columns);
        PIPE ROW(report_header.rpt_line2);
        
        for rec in salary_report
        loop
            if generate_rolling_header(g_rolling_header, p_max_count => 20)
            then
                PIPE ROW(report_header.rpt_line1);
                PIPE ROW(report_header.rpt_columns);
                PIPE ROW(report_header.rpt_line2);
            end if;
            PIPE ROW(rec.data);

            g_rolling_header := g_rolling_header + 1;
         end loop;
         PIPE ROW(report_header.rpt_line2);

        RETURN;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if salary_report%isopen then
            close salary_report;
        end if;
    end salary_data_report2;



--===========================================================================================================================================================================    

    function astrology_report(p_report_title in varchar2)
    return report_tab_t pipelined
    is
        c_rpt_pad CONSTANT INTEGER := 20;
        
        cursor cur_astrology is
        select rpad(MONTH, c_rpt_pad, c_space_separator)
        ||  rpad(DAY_CUTOFF, c_rpt_pad, c_space_separator)
        ||  rpad(EARLY_SIGN, c_rpt_pad, c_space_separator)
        ||  rpad(LATE_SIGN, c_rpt_pad, c_space_separator) as data
        from astrology;
        
        rec_length cur_astrology%rowtype;
        
        col_list COLUMN_LIST_T := COLUMN_LIST_T('MONTH' , 'DAY_CUTOFF' , 'EARLY_SIGN' , 'LATE_SIGN');
    begin
        --peek the first row to get length
        open cur_astrology;
        fetch cur_astrology into rec_length;
        g_row_length :=length(rec_length.data);
        close cur_astrology;

        GENERATE_HEADER(p_report_title,c_rpt_pad, col_list, report_header);

        PIPE ROW(report_header.rpt_name);
        PIPE ROW(report_header.rpt_date);
        PIPE ROW(report_header.rpt_line1);
        PIPE ROW(report_header.rpt_columns);
        PIPE ROW(report_header.rpt_line2);

        for rec in cur_astrology
        loop

            if generate_rolling_header(g_rolling_header, p_max_count => 3)
            then
                PIPE ROW(report_header.rpt_line1);
                PIPE ROW(report_header.rpt_columns);
                PIPE ROW(report_header.rpt_line2);
            end if;
            PIPE ROW(rec.data);
            g_rolling_header := g_rolling_header + 1;
         end loop;

         PIPE ROW(report_header.rpt_line2);

        return;

    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if cur_astrology%isopen then
            close cur_astrology;
        end if;
    end astrology_report;

--===========================================================================================================================================================================
    function table_volume_report
    return report_tab_t pipelined
    is
        c_rpt_pad CONSTANT INTEGER := 20;

        cursor volume_report is
        with qry as(
            select nvl(tablespace_name, '(blank)') as tablespace_name
            , sum(nvl(num_rows,0)) as volume
            from my_tables
            group by tablespace_name
            order by volume desc
        )

        select 
        rpad(tablespace_name, c_rpt_pad, ' ')
        || rpad(volume, c_rpt_pad, ' ')
        as data
        from qry;

        rec_length volume_report%rowtype;

        col_list column_list_t := column_list_t('TABLESPACE_NAME', 'VOLUME');
    begin
        --peek the first row to get length
        open volume_report;
        fetch volume_report into rec_length;
        g_row_length :=length(rec_length.data);
        close volume_report;

        GENERATE_HEADER('VOLUME REPORT',c_rpt_pad, col_list, report_header);    

        pipe row(report_header.rpt_name);
        pipe row(report_header.rpt_date);
        pipe row(report_header.rpt_line1);
        pipe row(report_header.rpt_columns);
        pipe row(report_header.rpt_line2);

        for rec in volume_report
        loop
            pipe row(rec.data);
        end loop;

        PIPE ROW(report_header.rpt_line2);

        return;
    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if volume_report%isopen then
            close volume_report;
        end if;
    end table_volume_report;



--===========================================================================================================================================================================
    
    function general_report(p_report_title in varchar2 default null, p_padding in number default 20, p_select in varchar2)
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
        
        procedure define_columns
        is
        begin
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
        end define_columns;
        
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
        assert_pkg.is_true(substr(upper(p_select), 1, 6) = 'SELECT', 'PLEASE PROVIDE A SELECT STATEMENT');
    
        v_cursor_id := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_cursor_id, p_select, DBMS_SQL.NATIVE);
        dbms_sql.describe_columns(v_cursor_id, l_col_cnt, l_desc_tab);
        
        define_columns;
            
        generate_header(p_report_title,p_padding,l_column_names, report_header);    
        
        --pipe row('row length: ' || g_row_length);
        pipe row(report_header.rpt_name);
        pipe row(report_header.rpt_date);
        pipe row(report_header.rpt_line1);
        pipe row(report_header.rpt_columns);
        pipe row(report_header.rpt_line2);
        
        v_dummy := dbms_sql.execute(v_cursor_id);
        
        while dbms_sql.fetch_rows(v_cursor_id) > 0
        loop
            l_output_str := null;
            for i in 1..l_desc_tab.count loop
                l_output_str := format_output(i);
            end loop;
            
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
