create or replace package body sql_utils_pkg
as
    function is_sql_allowed(p_sql in varchar2)
    return boolean
    is
    begin
        return regexp_like(upper(trim(p_sql)), '^(create|alter|drop|grant|revoke)');
    end;
    
    
    procedure print_or_execute(p_sql IN VARCHAR2)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_sql);
        else
            execute immediate p_sql;
        end if;
    end;
    
    
    --given one or more tables, truncate the tables in the list
    procedure truncate_table(p_table_names in varchar2)
    is
        cursor tbls is
        select trim(regexp_substr( p_table_names, '[^,]+', 1, level )) value
        from dual
        connect by level <= length (p_table_names) - length(replace( p_table_names, ',')) + 1;
        
        tbl_name all_tables.table_name%type;
    
    begin
        for tbl in tbls
        loop
            select table_name
            into tbl_name
            from user_tables
            where table_name = tbl.value;
            
            print_or_execute('TRUNCATE TABLE ' || tbl.value);
        
        end loop;
        
    exception
        when no_data_found then
            if tbls%isopen
            then
                close tbls;
            end if;
            error_pkg.assert(1=2, 'PROVIDED INVALID TABLE! PLEASE INVESTIGATE');
            
    end truncate_table;
    
    
    procedure remove_data_from_partition(p_table_name IN USER_TABLES.TABLE_NAME%TYPE, p_partition_name IN USER_TAB_PARTITIONS.PARTITION_NAME%TYPE, p_drop IN BOOLEAN DEFAULT FALSE)
    is
    begin
        
        print_or_execute('ALTER TABLE '
                        || p_table_name
                        || case when p_drop then ' DROP ' else ' TRUNCATE '  end
                        || 'PARTITION '
                        || p_partition_name
                        || ' UPDATE GLOBAL INDEXES'
                        );
    
    end remove_data_from_partition;
    

end sql_utils_pkg;
