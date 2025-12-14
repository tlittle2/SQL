create or replace package partition_table_parm_tapi
is

	-- insert
	procedure ins (
	 p_TABLE_OWNER      in PARTITION_TABLE_PARM.TABLE_OWNER%type
	,p_TABLE_NAME       in PARTITION_TABLE_PARM.TABLE_NAME%type
	,p_PARTITION_TYPE   in PARTITION_TABLE_PARM.PARTITION_TYPE%type default null 
	,p_TABLESPACE_NAME  in PARTITION_TABLE_PARM.TABLESPACE_NAME%type default null 
	,p_UPD_FLAG         in PARTITION_TABLE_PARM.UPD_FLAG%type default null 
	,p_PARTITIONED      in PARTITION_TABLE_PARM.PARTITIONED%type default null 
	,p_PARTITION_PREFIX in PARTITION_TABLE_PARM.PARTITION_PREFIX%type default null);

	-- update
	procedure upd (
	 p_TABLE_OWNER      in PARTITION_TABLE_PARM.TABLE_OWNER%type
	,p_TABLE_NAME       in PARTITION_TABLE_PARM.TABLE_NAME%type
	,p_PARTITION_TYPE   in PARTITION_TABLE_PARM.PARTITION_TYPE%type default null 
	,p_TABLESPACE_NAME  in PARTITION_TABLE_PARM.TABLESPACE_NAME%type default null 
	,p_UPD_FLAG         in PARTITION_TABLE_PARM.UPD_FLAG%type default null 
	,p_PARTITIONED      in PARTITION_TABLE_PARM.PARTITIONED%type default null 
	,p_PARTITION_PREFIX in PARTITION_TABLE_PARM.PARTITION_PREFIX%type default null);

    -- delete
	procedure del(
	 p_TABLE_OWNER in PARTITION_TABLE_PARM.TABLE_OWNER%type
	,p_TABLE_NAME  in PARTITION_TABLE_PARM.TABLE_NAME%type);

end partition_table_parm_tapi;
