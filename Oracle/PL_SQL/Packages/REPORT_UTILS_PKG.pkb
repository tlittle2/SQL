create or replace PACKAGE BODY REPORT_UTILS_PKG
AS
    TYPE REPORT_HEADER_T IS RECORD(
        rpt_name report_tab_str_len,
        rpt_date report_tab_str_len,
        rpt_line1 report_tab_str_len,
        rpt_columns report_tab_str_len,
        rpt_line2 report_tab_str_len
    );
    
    
    REPORT_HEADER REPORT_HEADER_T;
    
    TYPE COLUMN_LIST_T is table of ALL_TAB_COLUMNS.COLUMN_NAME%TYPE;
    
    c_space_separator CONSTANT VARCHAR2(1) := ' ';
    c_comma_separator CONSTANT VARCHAR2(1) := ',';
    c_pipe_separator CONSTANT VARCHAR2(1) := '|';
    c_semicolon_separator CONSTANT VARCHAR2(1) := ';';
    
    g_row_length INTEGER;
    
    
--===========================================================================================================================================================================
    PROCEDURE GENERATE_HEADER(p_title IN VARCHAR2, p_pad IN INTEGER, p_col_list IN COLUMN_LIST_T, p_report_header OUT REPORT_HEADER_T)
    IS
        FUNCTION HEADER_SEPARATOR
        RETURN VARCHAR2 DETERMINISTIC
        IS
        BEGIN
            RETURN RPAD('=', g_row_length, '=');
        END;
        
        FUNCTION CENTER_CONTENT(p_input_str IN VARCHAR2)
        RETURN VARCHAR2 DETERMINISTIC
        IS
            --l_total_pad  INTEGER := G_ROW_LENGTH - LENGTH(p_input_str);
            --l_left_pad   INTEGER := FLOOR(l_total_pad / 2);
            --RETURN LPAD(p_input_str, round(g_row_length/2 ,0), ' ');  
        BEGIN
            RETURN RPAD(LPAD(p_input_str, LENGTH(p_input_str) + (FLOOR((g_row_length - LENGTH(p_input_str)) / 2)), ' '), g_row_length, ' ');
        END;
    
    BEGIN
        p_report_header.rpt_name := CENTER_CONTENT('Report Name: ' || p_title);
        p_report_header.rpt_date := CENTER_CONTENT('Report Date: ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MI:SS AM'));
        
        p_report_header.rpt_line1 := HEADER_SEPARATOR;
        
        for i in 1..p_col_list.COUNT
        LOOP
            p_report_header.rpt_columns :=  p_report_header.rpt_columns || rpad(p_col_list(i), p_pad, c_space_separator);
        END LOOP;
        
        p_report_header.rpt_line2 := HEADER_SEPARATOR;
        
    END GENERATE_HEADER;
    
--===========================================================================================================================================================================

	FUNCTION SALARY_DATA_REPORT(p_report_title IN VARCHAR2)
	RETURN report_tab_t PIPELINED
    IS
        c_rpt_pad CONSTANT INTEGER := 15;
        cursor salary_report is
        select 
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
        ||  rpad(to_char(EFF_DATE, 'MM/DD/YYYY'), c_rpt_pad, c_space_separator)
        ||  rpad(to_char(END_DATE, 'MM/DD/YYYY'), c_rpt_pad, c_space_separator)
        /*||  rpad(CREATE_ID, c_rpt_pad, c_space_separator)
        ||  rpad(LAST_UPDATE_ID, c_rpt_pad, c_space_separator)*/ as data
        from salary_data;
        
        rec_length salary_report%rowtype;
    
        col_list COLUMN_LIST_T := COLUMN_LIST_T('CASE_NUM','ID' , 'GENDER' , 'DEGREE' , 'YEAR_DEGREE' , 'FIELD' , 'START_YEAR' , 'YEAR' , 'RANK' , 'ADMIN' , 'SALARY' , 'EFF_DATE' , 'END_DATE' /*, 'CREATE_ID' , 'LAST_UPDATE_ID'*/);
        
    BEGIN
        --peek the first row to get length
        open salary_report;
        fetch salary_report into rec_length;
        g_row_length :=length(rec_length.data);
        close salary_report;
         
        GENERATE_HEADER(p_report_title,c_rpt_pad, col_list, REPORT_HEADER);
        
        PIPE ROW(REPORT_HEADER.rpt_name);
        PIPE ROW(REPORT_HEADER.rpt_date);
        PIPE ROW(REPORT_HEADER.rpt_line1);
        PIPE ROW(REPORT_HEADER.rpt_columns);
        PIPE ROW(REPORT_HEADER.rpt_line2);
                
        for rec in salary_report
        loop
            PIPE ROW(rec.data);
         end loop;
        
        RETURN;
    
    EXCEPTION
        WHEN OTHERS THEN
        cleanup_pkg.exception_cleanup(false);
        if salary_report%isopen then
            close salary_report;
        end if;
    END SALARY_DATA_REPORT;

--===========================================================================================================================================================================    
    
    FUNCTION ASTROLOGY_REPORT(p_report_title IN VARCHAR2)
	RETURN report_tab_t PIPELINED
    IS
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
        
    BEGIN
        --peek the first row to get length
        open cur_astrology;
        fetch cur_astrology into rec_length;
        g_row_length :=length(rec_length.data);
        close cur_astrology;
         
        GENERATE_HEADER(p_report_title,c_rpt_pad, col_list, REPORT_HEADER);
        
        PIPE ROW(REPORT_HEADER.rpt_name);
        PIPE ROW(REPORT_HEADER.rpt_date);
        PIPE ROW(REPORT_HEADER.rpt_line1);
        PIPE ROW(REPORT_HEADER.rpt_columns);
        PIPE ROW(REPORT_HEADER.rpt_line2);
                
        for rec in cur_astrology
        loop
            if v_rolling_header = 3
            then
                PIPE ROW(REPORT_HEADER.rpt_line1);
                PIPE ROW(REPORT_HEADER.rpt_columns);
                PIPE ROW(REPORT_HEADER.rpt_line2);
                v_rolling_header := 0;
            end if;
            PIPE ROW(rec.data);
            v_rolling_header := v_rolling_header + 1;
         end loop;
        
        RETURN;
        
    EXCEPTION
        WHEN OTHERS THEN
        cleanup_pkg.exception_cleanup(false);
        if cur_astrology%isopen then
            close cur_astrology;
        end if;
    end ASTROLOGY_REPORT;
        
--===========================================================================================================================================================================
    FUNCTION CREATE_TRXN_FILE
    RETURN report_tab_t PIPELINED
    IS
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
         
    EXCEPTION
        WHEN OTHERS THEN
        cleanup_pkg.exception_cleanup(false);
        if salary_details%isopen then
            close salary_details;
        end if;
        
    end;
--===========================================================================================================================================================================

END REPORT_UTILS_PKG;
