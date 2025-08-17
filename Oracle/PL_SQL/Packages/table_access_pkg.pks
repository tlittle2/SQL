create or replace PACKAGE table_access_pkg
AS
/*                                                    GUIDE
                                                 ----------------
   any update/delete procedure whose postfix is _1 is a GLOBAL update of the table (all parameters are default null and the procedure body does not have a where clause)
   any update/delete procedure whose postfix is _2 is based on the primary key columns
   any update/delete procedure whose postfix is _3 or above is index columns
   
    For _2 and above, where clause parameters shall be required, and all other columns are default as null
        in procedure body, where clause will have required fields, and all other fields are default null
*/


--======================================================archive_rules======================================================================================================================

    PROCEDURE insert_archive_rules (
        p_table_owner        archive_rules.table_owner%TYPE DEFAULT NULL
      , p_table_name         archive_rules.table_name%TYPE DEFAULT NULL
      , p_partitioned        archive_rules.partitioned%TYPE DEFAULT NULL
      , p_years_to_keep      archive_rules.years_to_keep%TYPE DEFAULT NULL
      , p_upd_flag           archive_rules.upd_flag%TYPE DEFAULT NULL
      , p_archive_column_key archive_rules.archive_column_key%TYPE DEFAULT NULL
      , p_archive_group_key  archive_rules.archive_group_key%TYPE DEFAULT NULL
      , p_job_nbr            archive_rules.job_nbr%TYPE DEFAULT NULL);
      
    PROCEDURE update_archive_rules_1 (
        p_table_owner        archive_rules.table_owner%TYPE DEFAULT NULL
      , p_table_name         archive_rules.table_name%TYPE DEFAULT NULL
      , p_partitioned        archive_rules.partitioned%TYPE DEFAULT NULL
      , p_years_to_keep      archive_rules.years_to_keep%TYPE DEFAULT NULL
      , p_upd_flag           archive_rules.upd_flag%TYPE DEFAULT NULL
      , p_archive_column_key archive_rules.archive_column_key%TYPE DEFAULT NULL
      , p_archive_group_key  archive_rules.archive_group_key%TYPE DEFAULT NULL
      , p_job_nbr            archive_rules.job_nbr%TYPE DEFAULT NULL);
      
      
    PROCEDURE update_archive_rules_2 (
        p_table_owner        archive_rules.table_owner%TYPE
      , p_table_name         archive_rules.table_name%TYPE
      , p_partitioned        archive_rules.partitioned%TYPE DEFAULT NULL
      , p_years_to_keep      archive_rules.years_to_keep%TYPE DEFAULT NULL
      , p_upd_flag           archive_rules.upd_flag%TYPE DEFAULT NULL
      , p_archive_column_key archive_rules.archive_column_key%TYPE DEFAULT NULL
      , p_archive_group_key  archive_rules.archive_group_key%TYPE DEFAULT NULL
      , p_job_nbr            archive_rules.job_nbr%TYPE DEFAULT NULL);
      
      
    procedure delete_archive_rules_2(p_table_owner archive_rules.table_owner%type , p_table_name archive_rules.table_name%type);
      
--======================================================archive_rules======================================================================================================================

--======================================================salary_data_stg======================================================================================================================

    procedure insert_salary_data_stg(
    p_case_num       salary_data_stg.case_num%type default null
  , p_id             salary_data_stg.id%type default null
  , p_gender         salary_data_stg.gender%type default null
  , p_degree         salary_data_stg.degree%type default null
  , p_year_degree    salary_data_stg.year_degree%type default null
  , p_field          salary_data_stg.field%type default null
  , p_start_year     salary_data_stg.start_year%type default null
  , p_year           salary_data_stg.year%type default null
  , p_rank           salary_data_stg.rank%type default null
  , p_admin          salary_data_stg.admin%type default null
  , p_salary         salary_data_stg.salary%type default null
  , p_eff_date       salary_data_stg.eff_date%type default null
  , p_end_date       salary_data_stg.end_date%type default null
  , p_create_id      salary_data_stg.create_id%type default null
  , p_last_update_id salary_data_stg.last_update_id%type default null);
  
  
    procedure update_salary_data_stg_1(
    p_case_num       salary_data_stg.case_num%type default null
  , p_id             salary_data_stg.id%type default null
  , p_gender         salary_data_stg.gender%type default null
  , p_degree         salary_data_stg.degree%type default null
  , p_year_degree    salary_data_stg.year_degree%type default null
  , p_field          salary_data_stg.field%type default null
  , p_start_year     salary_data_stg.start_year%type default null
  , p_year           salary_data_stg.year%type default null
  , p_rank           salary_data_stg.rank%type default null
  , p_admin          salary_data_stg.admin%type default null
  , p_salary         salary_data_stg.salary%type default null
  , p_eff_date       salary_data_stg.eff_date%type default null
  , p_end_date       salary_data_stg.end_date%type default null
  , p_create_id      salary_data_stg.create_id%type default null
  , p_last_update_id salary_data_stg.last_update_id%type default null);


    procedure update_salary_data_stg_2(
    p_case_num       salary_data_stg.case_num%type
  , p_id             salary_data_stg.id%type default null
  , p_gender         salary_data_stg.gender%type default null
  , p_degree         salary_data_stg.degree%type default null
  , p_year_degree    salary_data_stg.year_degree%type default null
  , p_field          salary_data_stg.field%type default null
  , p_start_year     salary_data_stg.start_year%type default null
  , p_year           salary_data_stg.year%type default null
  , p_rank           salary_data_stg.rank%type default null
  , p_admin          salary_data_stg.admin%type default null
  , p_salary         salary_data_stg.salary%type default null
  , p_eff_date       salary_data_stg.eff_date%type default null
  , p_end_date       salary_data_stg.end_date%type default null
  , p_create_id      salary_data_stg.create_id%type default null
  , p_last_update_id salary_data_stg.last_update_id%type default null);
  
  
   procedure delete_salary_data_stg_2(p_case_num salary_data_stg.case_num%type);
   
   procedure get_salary_data_stg_1(p_case_num salary_data_stg.case_num%type, p_salary_stg_row in out salary_data_stg%rowtype);
   

--======================================================salary_data_stg======================================================================================================================


--======================================================PARTITION_TABLE_PARM=================================================================================================================

    PROCEDURE update_partition_table_parm_1 (
        p_table_owner      partition_table_parm.table_owner%TYPE DEFAULT NULL
      , p_table_name       partition_table_parm.table_name%TYPE DEFAULT NULL
      , p_partitioned      partition_table_parm.partitioned%TYPE DEFAULT NULL
      , p_tablespace_name  partition_table_parm.tablespace_name%TYPE DEFAULT NULL
      , p_partition_type   partition_table_parm.partition_type%TYPE DEFAULT NULL
      , p_partition_prefix partition_table_parm.partition_prefix%TYPE DEFAULT NULL
      , p_upd_flag         partition_table_parm.upd_flag%TYPE DEFAULT NULL);

    PROCEDURE update_partition_table_parm_2 (
        p_table_owner      partition_table_parm.table_owner%TYPE
      , p_table_name       partition_table_parm.table_name%TYPE
      , p_partitioned      partition_table_parm.partitioned%TYPE DEFAULT NULL
      , p_tablespace_name  partition_table_parm.tablespace_name%TYPE DEFAULT NULL
      , p_partition_type   partition_table_parm.partition_type%TYPE DEFAULT NULL
      , p_partition_prefix partition_table_parm.partition_prefix%TYPE DEFAULT NULL
      , p_upd_flag         partition_table_parm.upd_flag%TYPE DEFAULT NULL);
    
--======================================================PARTITION_TABLE_PARM=================================================================================================================
    
    
--================================================================infa_global/infa_global_fix============================================================================================================
    
    procedure update_infa_global_1(
      p_statement_prd_yr_qrtr infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte infa_global.run_dte%type default null
    , p_soq_dte infa_global.soq_dte%type default null
    , p_eoq_dte infa_global.eoq_dte%type default null
    , p_last_update_dte infa_global.last_update_dte%type default null
    , p_last_updated_by infa_global.last_updated_by%type default null);
    
    procedure get_infa_global_row(p_rec_global IN OUT NOCOPY infa_global%rowtype);
    
    
    procedure update_infa_global_fix_1(
      p_statement_prd_yr_qrtr infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte infa_global.run_dte%type default null
    , p_soq_dte infa_global.soq_dte%type default null
    , p_eoq_dte infa_global.eoq_dte%type default null
    , p_last_update_dte infa_global.last_update_dte%type default null
    , p_last_updated_by infa_global.last_updated_by%type default null);
    
    procedure get_global_fix_row(p_rec_global_fix IN OUT NOCOPY infa_global_fix%rowtype);
    
    procedure get_global_row_logic(p_rec_global IN OUT NOCOPY infa_global%rowtype, p_run_type IN CHAR := global_constants_pkg.g_regular_run);
    
--================================================================infa_global/infa_global_fix============================================================================================================


--================================================================process_ranges_parm====================================================================================================================
    PROCEDURE update_process_ranges_parm_2 (
        p_process_name process_ranges_parm.process_name%TYPE
      , p_run_number   process_ranges_parm.run_number%TYPE
      , p_run_total    process_ranges_parm.run_total%TYPE DEFAULT NULL
      , p_lower_bound  process_ranges_parm.lower_bound%TYPE DEFAULT NULL
      , p_upper_bound  process_ranges_parm.upper_bound%TYPE DEFAULT NULL);
      
    type process_ranges_parm_bounds_t is record(
        lower_bound process_ranges_parm.lower_bound%type,
        upper_bound process_ranges_parm.upper_bound%type);
    
    procedure get_process_ranges_bounds(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type, p_parms out process_ranges_parm_bounds_t);


--================================================================process_ranges_parm====================================================================================================================

END table_access_pkg;
