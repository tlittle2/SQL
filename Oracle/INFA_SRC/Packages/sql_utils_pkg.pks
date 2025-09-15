create or replace package sql_utils_pkg
as
    g_schema_name constant all_tables.owner%type := 'INFA_SRC';

    type ref_cursor_t is ref cursor;

    c_open_cursor    constant char(1) := 'O'; --open ref/sys_refcursor
    c_close_cursor   constant char(1) := 'C'; --close ref/sys_refcursor

    function get_full_table_name(p_owner in all_tables.owner%type,p_table_name in all_tables.table_name%type)
    return varchar2
    deterministic;

    function get_partition_extension(p_partition_name in all_tab_partitions.partition_name%type)
    return varchar2
    deterministic;

    procedure truncate_table(p_table_names in varchar2);

    procedure remove_data_from_partition(p_table_name in user_tables.table_name%type, p_partition_name in user_tab_partitions.partition_name%type, p_drop in boolean default false);

    procedure reorg_table(p_table_name in user_tables.table_name%type);

    procedure dba_analyze_schema;

    procedure dba_analyze_table(p_table_name user_tables.table_name%type);

    procedure toggle_trigger(p_trigger_name in varchar2, p_turn_on in boolean default false);

    procedure recompile;


end;
