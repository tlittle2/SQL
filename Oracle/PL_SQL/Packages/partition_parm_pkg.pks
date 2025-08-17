create or replace package partition_parm_pkg
as
    --currently only works for range partitions

    g_daily_partition_flag            CONSTANT CHAR(1) := 'D';
    g_daily_partition_date_format     CONSTANT CHAR(8) := 'YYYYMMDD';

    g_monthly_partition_flag          CONSTANT CHAR(1) := 'M';
    g_monthly_partition_date_format   CONSTANT CHAR(4) := 'MMYY';

    g_quarterly_partition_flag        CONSTANT CHAR(1) := 'Q';

    g_annual_partition_flag           CONSTANT CHAR(1) := 'A';
    g_annual_partition_date_format    CONSTANT CHAR(4) := 'YYYY';


    g_is_partitioned                  CONSTANT CHAR(1) := 'Y';
    g_is_not_partitioned              CONSTANT CHAR(1) := 'N';

    g_max_part_suffix                 CONSTANT VARCHAR2(3) := 'MAX';
    g_max_part_suffix_regex           CONSTANT VARCHAR2(4) := g_max_part_suffix || '$';
    
    function get_partition_name(p_partition_type IN partition_table_parm.partition_type%type, p_prefix in partition_table_parm.partition_prefix%type, p_date in date)
    return varchar2;
    
    function get_partition_for_table(p_table_owner IN partition_table_parm.table_owner%type, p_table_name IN partition_table_parm.table_name%type, p_run_type global_constants_pkg.flag_st := global_constants_pkg.g_regular_run)
    return varchar2;

    procedure create_new_partitions(p_run_type IN CHAR, p_years_to_create IN INTEGER);

    procedure remove_archive_partitions(p_run_type IN CHAR);

end partition_parm_pkg;
