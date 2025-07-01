/*
Columns in MY_PARM_TABLE
	  TABLE_OWNER VARCHAR2(128)
	, TABLE_NAME VARCHAR2(128)
	, PARTITIONED CHAR(1)
	, TABLESPACE_NAME VARCHAR2(30)
	, PARTITION_TYPE CHAR(1)
	, PARTITION_PREFIX CHAR(1)
	, YEARS_TO_KEEP NUMBER(3,0)
	, UPD_FLAG CHAR(1)
	, ARCHIVE_COLUMN_KEY VARCHAR2(128);
		
*/

PROCEDURE INSERT_APPEND(p_src_owner          IN MY_PARM_TABLE.TABLE_OWNER%TYPE
		      , p_src_table          IN MY_PARM_TABLE.TABLE_NAME%TYPE
          	      , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
          	      , p_arch_owner         IN MY_PARM_TABLE.TABLE_OWNER%TYPE
          	      , p_arch_table         IN MY_PARM_TABLE.TABLE_NAME%TYPE
          	      , p_key_column         IN MY_PARM_TABLE.ARCHIVE_COLUMN_KEY%TYPE
			)  
IS
	v_column_datatype ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
	insert_cursor sys_refcursor;
	
	type date_container_t is RECORD(
		  dateValue DATE
		, dateCount NUMBER
	);
		dateContainer date_container_t;
		c_default_date_value CONSTANT DATE = '01-JAN-1799';
	
	type string_container_t is RECORD(
		  strValue VARCHAR2(32767);
		, strCount NUMBER
	);
		strContainer string_container_t;
		c_default_string_value CONSTANT VARCHAR2 = 'NULL';
	
	type number_container_t is RECORD(
		  numValue NUMBER
		, numCount NUMBER
	);
		numberContainer number_container_t;
		c_default_number_value CONSTANT NUMBER = -1;
		
		
	
	FUNCTION is_string(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
	RETURN BOOLEAN 
	IS 
	BEGIN
		IF p_column_datatype IN ('CHAR', 'VARCHAR2', 'VARCHAR')
		THEN
			RETURN TRUE;
		END IF;
		
		RETURN FALSE;
	END; 
 
	FUNCTION is_number(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
	RETURN BOOLEAN 
	IS 
	BEGIN
		IF p_column_datatype  IN ('FLOAT', 'INTEGER', 'NUMBER')
		THEN
			RETURN TRUE;
		END IF;
		
		RETURN FALSE;
	END; 
 
	FUNCTION is_date(p_column_datatype IN ALL_TAB_COLUMNS.DATA_TYPE%TYPE) 
	RETURN BOOLEAN 
	IS 
	BEGIN 
		IF p_column_datatype IN ('DATE', 'TIMESTAMP')
		THEN
			RETURN TRUE;
		END IF;
		
		RETURN FALSE;
	END;
	
	procedure UNSUPPORTED_DATATYPE
	is
	begin
		RAISE_APPLICATION_ERROR(-20001, 'UNSUPPORTED DATATYPE FOR THIS PROCEDURE!');
	end;
	
	
	procedure execute_insert(p_where_clause IN VARCHAR2)
	is
	begin
		execute immediate 'INSERT /*+ APPEND NOSORT NOLOGGING */'
		|| ' INTO ' || p_arch_owner || '.' || p_arch_table
		|| ' SELECT * FROM ' || p_src_owner || '.' || p_src_table || ' PARTITION ( ' || p_src_partition_name || ')'
		|| p_where_clause;
	
	end;
		
BEGIN
	select data_type
	into v_column_datatype
	from all_tab_columns
	where owner = p_src_owner
	and table_name = p_src_table
	and upper(column_name) = upper(p_column_name);
	
	
	if is_string(v_column_datatype)
	then
		open insert_cursor for 'SELECT NVL(' || p_column_name || ', ' || c_default_string_value || '), count(1)'
		|| ' from ' || p_src_owner || '.' || p_src_table || ' PARTITION (' || p_src_partition_name || ')'
		|| ' group by ' || p_column_name
		|| ' order by count(1) desc';
		
		
	elsif is_number(v_column_datatype)
	then
		open insert_cursor for 'SELECT NVL(' || p_column_name || ', ' || c_default_number_value || '), count(1)'
		|| ' from ' || p_src_owner || '.' || p_src_table || ' PARTITION (' || p_src_partition_name || ')'
		|| ' group by ' || p_column_name
		|| ' order by count(1) desc';
		
	elsif is_date(v_column_datatype)
	then
		open insert_cursor for 'SELECT NVL(' || p_column_name || ', ' || c_default_date_value || '), count(1)'
		|| ' from ' || p_src_owner || '.' || p_src_table || ' PARTITION (' || p_src_partition_name || ')'
		|| ' group by ' || p_column_name
		|| ' order by count(1) desc';
	
	else
		UNSUPPORTED_DATATYPE;
		
	end if;
	
	
	LOOP
		if is_string(v_column_datatype)
		then
			fetch insert_cursor into strContainer;
		
		elsif is_number(v_column_datatype)
		then
			fetch insert_cursor into numberContainer;
		
		elsif is_date(v_column_datatype)
		then
			fetch insert_cursor into dateContainer;
		
		else
			UNSUPPORTED_DATATYPE;
		end if;
	
    		exit when insert_cursor%NOTFOUND;
		
		if is_string(v_column_datatype)
		then
			execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_string_value || ''') = ''' || strContainer.strValue || '''');
			
		elsif is_number(v_column_datatype)
		then
			execute_insert(' where nvl(' || p_column_name || ', ' || c_default_number_value || ') = ''' || numberContainer.numValue || '''');
		
		elsif is_number(v_column_datatype)
		then
			execute_insert(' where nvl(' || p_column_name || ', ''' || c_default_date_value || ''') = ''' || dateContainer.dateValue || '''');
		
		else
			UNSUPPORTED_DATATYPE;
		end if;
		
		commit;
		
	END LOOP;
	
	close insert_cursor;
	
EXCEPTION
	when NO_DATA_FOUND THEN
	RAISE_APPLICATION_ERROR(-20002, 'COLUMN NAME ' || p_column_name
	|| ' DOES NOT EXIST IN ' || p_src_owner || '.' || p_src_table || '!');

	WHEN OTHERS THEN
		rollback;

		if insert_cursor%ISOPEN
		THEN
			close insert_cursor;	
		end if;
END;
