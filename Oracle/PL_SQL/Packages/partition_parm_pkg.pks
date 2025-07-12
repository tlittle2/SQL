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

    g_is_updated                      CONSTANT CHAR(1) := 'Y';

    c_open_cursor                      CONSTANT CHAR(1) := 'O';
    c_close_cursor                     CONSTANT CHAR(1) := 'C';

    g_max_part_suffix                 CONSTANT VARCHAR2(3) := 'MAX';
    g_max_part_suffix_regex           CONSTANT VARCHAR2(4) := g_max_part_suffix || '$';

    type ref_cursor_t is ref cursor;
    
    function get_partition_name(p_partition_type in partition_table_parm.partition_type%type, p_date in date)
    return varchar2;

    procedure reset_partition_parm_table;

    procedure create_new_partitions(p_run_type IN CHAR, p_years_to_create IN INTEGER);

    procedure remove_archive_partitions(p_run_type IN CHAR);

end partition_parm_pkg;
