/*
Usage:
DECLARE
    cursorContainer SYS_REFCURSOR;
BEGIN
    OPEN cursorContainer FOR SELECT deptno, dname FROM scott.dept;
    generate_report_from_ref_cursor(cursorContainer, 'Dept Rpt');
END;
/

Things to fix in below code:
1. Find a way to line up column with data in a straight line for each column
2. Find a way to dynamically allocate header separation (by '-')

*/

CREATE OR REPLACE PROCEDURE generate_report_from_ref_cursor (input_cursor IN OUT SYS_REFCURSOR, reportName IN VARCHAR2) IS
    cursor_number INTEGER;
    col_cnt INTEGER;
    col_descriptions DBMS_SQL.DESC_TAB;
    col_value VARCHAR2(4000);  -- Adjust size as needed for longer column values
    row_count INTEGER := 0;
    max_int INTEGER := 32767;
    g_row_length INTEGER := 0;
    --SUBTYPE max_varchar2_t IS VARCHAR2 (32767); 
BEGIN
    -- Convert REF CURSOR to a DBMS_SQL cursor number
    cursor_number := DBMS_SQL.to_cursor_number(input_cursor);

    -- Describe columns and get the number of columns
    DBMS_SQL.describe_columns(cursor_number, col_cnt, col_descriptions);

    -- Define each column dynamically based on its type
    FOR i IN 1 .. col_cnt LOOP
        DBMS_SQL.define_column(cursor_number, i, col_value, max_int);  -- Adjust max size
    END LOOP;

	DBMS_OUTPUT.put_line('Report Name: ' || reportName);
	DBMS_OUTPUT.put_line('Date of Report: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS') || CHR(10));
        
    -- Print column headers
    FOR i IN 1 .. col_cnt LOOP
        DBMS_OUTPUT.put(col_descriptions(i).col_name || RPAD(' ', length(col_descriptions(i).col_name))); --pad by length of the column
		g_row_length:= g_row_length + length(RPAD(' ', length(col_descriptions(i).col_name)));
    END LOOP;
    
	DBMS_OUTPUT.put_line(chr(10) || RPAD('-', g_row_length*2, '-'));

    -- Fetch each row and output the column values
    WHILE DBMS_SQL.fetch_rows(cursor_number) > 0 LOOP
        --row_count := row_count + 1;
        
        FOR i IN 1 .. col_cnt LOOP
            DBMS_SQL.column_value(cursor_number, i, col_value);
            DBMS_OUTPUT.put(col_value || RPAD(' ', length(col_descriptions(i).col_name)));  --pad by length of the column
        END LOOP;
        
        DBMS_OUTPUT.put_line('');  -- New line for each row
    END LOOP;

    -- Close the cursor
    DBMS_SQL.close_cursor(cursor_number);

    -- Display row count
    --DBMS_OUTPUT.put_line('Total Rows: ' || row_count);
EXCEPTION
    WHEN OTHERS THEN
        -- Ensure the cursor is closed in case of an exception
        IF DBMS_SQL.is_open(cursor_number) THEN
            DBMS_SQL.close_cursor(cursor_number);
        END IF;
        RAISE;
END generate_report_from_ref_cursor;
