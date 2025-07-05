create or replace package sql_utils_pkg
as
	
    procedure truncate_table(p_table_names in varchar2);
    
    procedure remove_data_from_partition(p_table_name IN USER_TABLES.TABLE_NAME%TYPE, p_partition_name IN USER_TAB_PARTITIONS.PARTITION_NAME%TYPE, p_drop IN BOOLEAN DEFAULT FALSE);
    
    procedure reorg_table(p_table_name in USER_TABLES.TABLE_NAME%TYPE);

end;
