create or replace PACKAGE BODY REPORT_UTILS_PKG
AS
    type report_header_t is record(
        rpt_name report_tab_str_len,
        rpt_date report_tab_str_len,
        rpt_line1 report_tab_str_len,
        rpt_columns report_tab_str_len,
        rpt_line2 report_tab_str_len
    );
    
    report_header report_header_t;
    
    type column_list_t is table of all_tab_columns.column_name%type;
    
    c_space_separator constant VARCHAR2(1) := ' ';
    c_comma_separator constant VARCHAR2(1) := ',';
    c_pipe_separator constant VARCHAR2(1) := '|';
    c_semicolon_separator constant VARCHAR2(1) := ';';
    
    g_row_length INTEGER;
    
    
--===========================================================================================================================================================================
    procedure generate_header(p_title in varchar2, p_pad in integer, p_col_list in column_list_t, p_report_header out report_header_t)
    is
        function header_separator
        return varchar2 deterministic
        is
        begin
            return rpad('=', g_row_length, '=');
        end;
        
        function center_content(p_input_str in varchar2)
        return varchar2 deterministic
        is
            l_total_pad  INTEGER := G_ROW_LENGTH - LENGTH(p_input_str);
            l_left_pad   INTEGER := FLOOR(l_total_pad / 2);
        begin
            return rpad(lpad(p_input_str, length(p_input_str) + (l_left_pad), ' '), g_row_length, ' ');
        end;
    
    begin
        p_report_header.rpt_name := center_content('Report Name: ' || p_title);
        p_report_header.rpt_date := center_content('Report Date: ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
        
        p_report_header.rpt_line1 := header_separator;
        
        for i in 1..p_col_list.count
        loop
            p_report_header.rpt_columns :=  p_report_header.rpt_columns || rpad(p_col_list(i), p_pad, c_space_separator);
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
    end;

    
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
        ||  rpad(to_char(end_date, 'mm/dd/yyyy'), c_rpt_pad, c_space_separator)
        /*||  rpad(create_id, c_rpt_pad, c_space_separator)
        ||  rpad(last_update_id, c_rpt_pad, c_space_separator)*/ as data
        from salary_data;
        
        rec_length salary_report%rowtype;
    
        col_list COLUMN_LIST_T := COLUMN_LIST_T('CASE_NUM','ID' , 'GENDER' , 'DEGREE' , 'YEAR_DEGREE' , 'FIELD' , 'START_YEAR' , 'YEAR' , 'RANK' , 'ADMIN' , 'SALARY' , 'EFF_DATE' , 'END_DATE' /*, 'CREATE_ID' , 'LAST_UPDATE_ID'*/);
        
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
        
        RETURN;
    
    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if salary_report%isopen then
            close salary_report;
        end if;
    end salary_data_report;

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
        v_rolling_header INTEGER := 0;
        
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
            
            if generate_rolling_header(v_rolling_header, p_max_count => 3)
            then
                PIPE ROW(report_header.rpt_line1);
                PIPE ROW(report_header.rpt_columns);
                PIPE ROW(report_header.rpt_line2);
            end if;
            PIPE ROW(rec.data);
            
            v_rolling_header := v_rolling_header + 1;
         end loop;
        
        return;
        
    exception
        when others then
        cleanup_pkg.exception_cleanup(false);
        if cur_astrology%isopen then
            close cur_astrology;
        end if;
    end astrology_report;
        
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
        
    end;
--===========================================================================================================================================================================


/*doesn't work for 2 reasons
    if the query being run is going to be a concatenated string, there is no automatic way for the process to know which columns are coming in (which makes displaying headers hard)
    if the query being run is a normal column based query, there is no predetermined way to know how to split the string up into a continuous concatenated string of data
*/

function general_report(input_cursor in sys_refcursor, p_report_title in varchar2 default null)
return report_tab_to pipelined
is
    cursor_number INTEGER;
    col_cnt INTEGER;
    col_descriptions DBMS_SQL.DESC_TAB2;
    col_value VARCHAR2(4000);  -- Adjust size as needed for longer column values
    row_count INTEGER := 0;
    max_int INTEGER := 32767;
    g_row_length INTEGER := 0;
    v_line report_tab_str_len; --v_rpt_str in package spec
    report_out GENERAL_REPORT_O;
    
begin
    
    /*cursor_number := dbms_sql.open_cursor;
    dbms_sql.parse(cursor_number, input_cursor, dbms_sql.native);

    -- describe columns and get the number of columns
    dbms_sql.describe_columns2(cursor_number, col_cnt, col_descriptions);

    if p_title is not null then
        generate_header(p_title,20, col_descriptions, report_header);
        pipe row(report_header.rpt_name);
        pipe row(report_header.rpt_date);
        pipe row(report_header.rpt_line1);
        --pipe row(report_header.rpt_columns);
        --pipe row(report_header.rpt_line2);
    end if;*/
    
    loop
        fetch input_cursor into v_line;
        exit when input_cursor%notfound;
        pipe row(general_report_o(v_line));
    end loop;

    return;
end;

--===========================================================================================================================================================================


end report_utils_pkg;
