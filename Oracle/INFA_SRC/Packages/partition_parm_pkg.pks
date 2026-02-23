create or replace package partition_parm_pkg
as
    --currently only works for range partitions
    g_default_date_format CONSTANT VARCHAR2(9) := 'DD-MON-RR';

    g_daily_partition_flag            CONSTANT partition_table_parm.partition_type%type := 'D';
    g_daily_partition_date_format     CONSTANT CHAR(8) := 'YYYYMMDD';

    g_monthly_partition_flag          CONSTANT partition_table_parm.partition_type%type := 'M';
    g_monthly_partition_date_format   CONSTANT CHAR(4) := 'MMYY';

    g_quarterly_partition_flag        CONSTANT partition_table_parm.partition_type%type := 'Q';
    g_quarterly_partition_date_format CONSTANT CHAR(5) := 'YYYYQ';

    g_annual_partition_flag           CONSTANT partition_table_parm.partition_type%type := 'A';
    g_annual_partition_date_format    CONSTANT CHAR(4) := 'YYYY';


    g_is_partitioned                  CONSTANT global_constants_pkg.flag_st := 'Y';
    g_is_not_partitioned              CONSTANT global_constants_pkg.flag_st := 'N';

    g_max_part_suffix                 CONSTANT VARCHAR2(3) := 'MAX';
    g_max_part_suffix_regex           CONSTANT VARCHAR2(4) := g_max_part_suffix || '$';

    subtype st_part_len_max is varchar2(length(g_daily_partition_date_format) + 4); --can't be longer than partition_table_parm.partition_prefix%type + length of the longest date suffix

    procedure check_partition_type(p_partition_type IN partition_table_parm.partition_type%type);

    function get_partition_name(p_partition_type in partition_table_parm.partition_type%type
                              , p_prefix         in partition_table_parm.partition_prefix%type
                              , p_date           in date)
    return st_part_len_max;

    function decompose_partition_name(p_partition_type in partition_table_parm.partition_type%type
                                    , p_partition_name in varchar2
                                    , p_prefix         in partition_table_parm.partition_prefix%type)
    return st_part_len_max;

    function get_partition_for_table(p_table_owner in partition_table_parm.table_owner%type
                                   , p_table_name  in partition_table_parm.table_name%type
                                   , p_run_type    in global_constants_pkg.flag_st := global_constants_pkg.g_regular_run)
    return st_part_len_max;

    procedure create_new_partitions(p_run_type in global_constants_pkg.flag_st, p_years_to_create in INTEGER);

    procedure remove_archive_partitions(p_run_type in global_constants_pkg.flag_st);

end partition_parm_pkg;
