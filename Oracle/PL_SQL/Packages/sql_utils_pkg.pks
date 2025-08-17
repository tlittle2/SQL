create or replace package sql_utils_pkg
as
    g_schema_name CONSTANT all_tables.owner%type := 'INFA_SRC';

    type ref_cursor_t is ref cursor;
    c_open_cursor                      CONSTANT CHAR(1) := 'O'; --open ref/sys_refcursor
    c_close_cursor                     CONSTANT CHAR(1) := 'C'; --close ref/sys_refcursor

    function get_full_table_name(p_owner IN all_tables.owner%type,p_table_name IN all_tables.table_name%type)
    return varchar2
    deterministic;

    function get_partition_extension(p_partition_name in all_tab_partitions.partition_name%type)
    return varchar2
    deterministic;

    procedure truncate_table(p_table_names in varchar2);

    procedure remove_data_from_partition(p_table_name IN USER_TABLES.TABLE_NAME%TYPE, p_partition_name IN USER_TAB_PARTITIONS.PARTITION_NAME%TYPE, p_drop IN BOOLEAN DEFAULT FALSE);

    procedure reorg_table(p_table_name in USER_TABLES.TABLE_NAME%TYPE);

    procedure dba_analyze_schema;

    procedure dba_analyze_table(p_table_name USER_TABLES.TABLE_NAME%TYPE);

    procedure recompile;


end;
