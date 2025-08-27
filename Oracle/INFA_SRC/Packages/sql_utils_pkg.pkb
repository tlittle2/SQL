create or replace package body sql_utils_pkg
as
    function is_sql_allowed(p_sql in varchar2)
    return boolean
    is
    begin
        return regexp_like(lower(trim(p_sql)), '^(create|alter|drop|grant|revoke)');
    end is_sql_allowed;

    procedure reset_sql_statement(p_sql in out nocopy varchar2)
    is
    begin
        p_sql := null;
    end reset_sql_statement;

    procedure print_or_execute(p_sql in varchar2, p_print_and_execute in boolean default false)
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
    end print_or_execute;


    function get_full_table_name(p_owner in all_tables.owner%type,p_table_name in all_tables.table_name%type)
    return varchar2
    deterministic
    is
    begin
        return string_utils_pkg.get_str('%1.%2', p_owner, p_table_name);
        --return p_owner || '.' || p_table_name;
    end get_full_table_name;

    function get_partition_extension(p_partition_name in all_tab_partitions.partition_name%type)
    return varchar2
    deterministic
    is
    begin
        return string_utils_pkg.get_str('PARTITION (%1) ', p_partition_name);
        --return 'PARTITION (' || p_partition_name || ')';
    end get_partition_extension;

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

            assert_pkg.is_not_null(l_tbl_name, 'PROVIDED INVALID TABLE! PLEASE INVESTIGATE');

            print_or_execute(string_utils_pkg.get_str('TRUNCATE TABLE %1', l_tbl_name));

        end loop;

    exception
        when others then
            if tbls%isopen
            then
                close tbls;
            end if;
    end truncate_table;


    procedure remove_data_from_partition(p_table_name in user_tables.table_name%type, p_partition_name in user_tab_partitions.partition_name%type, p_drop in boolean default false)
    is
    begin

        print_or_execute(string_utils_pkg.get_str('ALTER TABLE %1 %2 PARTITION %3 UPDATE GLOBAL INDEXES'
                                                , p_table_name
                                                , case when p_drop then 'DROP' else 'TRUNCATE'  end
                                                , p_partition_name));

    end remove_data_from_partition;


    procedure reorg_table(p_table_name in user_tables.table_name%type)
    is
        l_tablecount number;
        l_row_movement_flag boolean := false;

        l_partitioned user_tables.partitioned%type;
        l_row_movement user_tables.row_movement%type;

        l_sql_statement varchar2(1000);

        cursor idxs is
        select distinct index_name
        , status
        , degree
        from user_indexes
        where table_name = p_table_name
        and upper(index_name) not like '%SYS%';

    begin
        assert_pkg.is_not_null(p_table_name, 'Table name is null. Processing halted.');

        select count(1)
        into l_tablecount
        from user_tables
        where table_name = p_table_name;

        --error_pkg.assert(l_tablecount > 0, 'Table does not exist. Processing halted.');
        assert_pkg.is_greater_than(l_tablecount, 0, 'Table does not exist. Processing halted.');

        select partitioned
        , row_movement
        into l_partitioned, l_row_movement
        from user_tables
        where table_name = p_table_name;

        error_pkg.assert(upper(trim(l_partitioned)) <> 'YES', 'Table is partitioned. Processing halted.');

        if upper(trim(l_row_movement)) = 'DISABLED'
        then
            l_row_movement_flag := TRUE;
            l_sql_statement := string_utils_pkg.get_str('ALTER TABLE %1 enable row movement', p_table_name);
            print_or_execute(l_sql_statement);
        end if;

        reset_sql_statement(l_sql_statement);
        l_sql_statement := string_utils_pkg.get_str('ALTER TABLE %1 move', p_table_name);
        print_or_execute(l_sql_statement);

        for rec in idxs
        loop
            reset_sql_statement(l_sql_statement);
            l_sql_statement := string_utils_pkg.get_str('ALTER INDEX %1 rebuild parallel (degree %2 instances 1)', rec.index_name, rec.degree);
            print_or_execute(l_sql_statement);
        end loop;

        if l_row_movement_flag
        then
            reset_sql_statement(l_sql_statement);
            l_sql_statement := string_utils_pkg.get_str('ALTER TABLE %1 disable row movement', p_table_name);
            print_or_execute(l_sql_statement);

        end if;

    exception
        when others then
        if idxs%isopen
        then
            close idxs;
        end if;

    end reorg_table;


    procedure dba_analyze_schema
    is
    begin
        dbms_stats.gather_schema_stats(
            ownname=>g_schema_name,
            method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO',
            degree => dbms_stats.auto_degree,
            estimate_percent => dbms_stats.auto_sample_size,
            cascade => true
        );
    end;


    procedure dba_analyze_table(p_table_name user_tables.table_name%type)
    is
    begin
        dbms_stats.gather_table_stats(
            ownname => g_schema_name,
            tabname => p_table_name,
            estimate_percent => dbms_stats.auto_sample_size,
            method_opt => 'FOR ALL INDEXED COLUMNS SIZE AUTO'
        );
    end;


    procedure recompile
    is
        cursor invalid_objects is
        select *
        from user_objects
        where status = 'INVALID';

        l_stmnt varchar2(200);
    begin
        for rec in invalid_objects
        loop
            case upper(rec.object_type)
                when 'PROCEDURE'    then l_stmnt := string_utils_pkg.get_str('alter %1 %2 compile', rec.object_type, rec.object_name);
                when 'PACKAGE BODY' then l_stmnt := string_utils_pkg.get_str('alter package %1 compile body', rec.object_name);
                when 'PACKAGE'      then l_stmnt := string_utils_pkg.get_str('alter package %1 compile package', rec.object_name);
                when 'TRIGGER'      then l_stmnt := string_utils_pkg.get_str('alter %1 %2 compile', rec.object_type, rec.object_name);
                else l_stmnt := null;
            end case;

            if l_stmnt is not null
            then
                execute immediate l_stmnt;
            end if;

        end loop;
    end recompile;

end sql_utils_pkg;
