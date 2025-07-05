create or replace package body sql_utils_pkg
as
    function is_sql_allowed(p_sql in varchar2)
    return boolean
    is
    begin
        return regexp_like(lower(trim(p_sql)), '^(create|alter|drop|grant|revoke)');
    end;
    
    procedure reset_sql_statement(p_sql IN OUT NOCOPY VARCHAR2)
    is
    begin
        p_sql := null;
    end reset_sql_statement;
    
    
    procedure print_or_execute(p_sql IN VARCHAR2, p_print_and_execute IN BOOLEAN DEFAULT FALSE)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_sql);
        else
            if p_print_and_execute
            then
                dbms_output.put_line(p_sql);
            end if;
            
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
        
        l_tbl_name all_tables.table_name%type;
    
    begin
        for tbl in tbls
        loop
            select table_name
            into l_tbl_name
            from user_tables
            where table_name = tbl.value;
            
            error_pkg.assert(l_tbl_name is not null, 'PROVIDED INVALID TABLE! PLEASE INVESTIGATE');
            
            print_or_execute('TRUNCATE TABLE ' || l_tbl_name);
        
        end loop;
        
    exception
        when others then
            if tbls%isopen
            then
                close tbls;
            end if;
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
    
    
    procedure reorg_table(p_table_name in USER_TABLES.TABLE_NAME%TYPE)
    is
        l_tablecount NUMBER;
        l_row_movement_flag boolean := false;
        
        l_partitioned USER_TABLES.PARTITIONED%TYPE;
        l_row_movement USER_TABLES.ROW_MOVEMENT%TYPE;
        
        l_sql_statement VARCHAR2(1000);
        
        cursor idxs is
        select distinct index_name
        , status
        , degree
        from user_indexes
        where table_name = p_table_name
        and upper(index_name) not like '%SYS%';
    
    begin
        error_pkg.assert(p_table_name is not null, 'Table name is null. Processing halted.');
        
        select count(1)
        into l_tablecount
        from user_tables
        where table_name = p_table_name;
        
        error_pkg.assert(l_tablecount > 0, 'Table does not exist. Processing halted.');
        
        select partitioned
        , row_movement
        into l_partitioned, l_row_movement
        from user_tables
        where table_name = p_table_name;
        
        error_pkg.assert(upper(trim(l_partitioned)) <> 'YES', 'Table is partitioned. Processing halted.');
        
        if upper(trim(l_row_movement)) = 'DISABLED'
        then
            l_row_movement_flag := TRUE;
            l_sql_statement := 'ALTER TABLE ' || p_table_name || ' enable row movement';
            print_or_execute(l_sql_statement);
        end if;
        
        reset_sql_statement(l_sql_statement);
        l_sql_statement := 'ALTER TABLE ' || p_table_name || ' move';
        print_or_execute(l_sql_statement);
        
        for rec in idxs
        loop
            reset_sql_statement(l_sql_statement);
            l_sql_statement := 'alter index ' || rec.index_name || ' rebuild parallel (degree ' || rec.degree || ' instances 1) ';
            print_or_execute(l_sql_statement);
        end loop;
        
        if l_row_movement_flag
        then
            reset_sql_statement(l_sql_statement);
            l_sql_statement := 'alter index ' || p_table_name || ' disable row movement';
            print_or_execute(l_sql_statement); 
            
        end if;
         
    end reorg_table;
    

end sql_utils_pkg;
