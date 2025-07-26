create or replace PACKAGE table_access_pkg
AS
--======================================================archive_rules======================================================================================================================
        PROCEDURE update_archive_rules (
        p_table_owner        archive_rules.table_owner%TYPE
      , p_table_name         archive_rules.table_name%TYPE
      , p_partitioned        archive_rules.partitioned%TYPE DEFAULT NULL
      , p_years_to_keep      archive_rules.years_to_keep%TYPE DEFAULT NULL
      , p_upd_flag           archive_rules.upd_flag%TYPE DEFAULT NULL
      , p_archive_column_key archive_rules.archive_column_key%TYPE DEFAULT NULL
      , p_archive_group_key  archive_rules.archive_group_key%TYPE DEFAULT NULL
      , p_job_nbr            archive_rules.job_nbr%TYPE DEFAULT NULL);
      
      PROCEDURE insert_archive_rules (
        p_table_owner        archive_rules.table_owner%TYPE DEFAULT NULL
      , p_table_name         archive_rules.table_name%TYPE DEFAULT NULL
      , p_partitioned        archive_rules.partitioned%TYPE DEFAULT NULL
      , p_years_to_keep      archive_rules.years_to_keep%TYPE DEFAULT NULL
      , p_upd_flag           archive_rules.upd_flag%TYPE DEFAULT NULL
      , p_archive_column_key archive_rules.archive_column_key%TYPE DEFAULT NULL
      , p_archive_group_key  archive_rules.archive_group_key%TYPE DEFAULT NULL
      , p_job_nbr            archive_rules.job_nbr%TYPE DEFAULT NULL);
      
      
      procedure delete_archive_rules(p_table_owner archive_rules.table_owner%type , p_table_name archive_rules.table_name%type);
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
  
  
   procedure delete_salary_data_stg_1(p_case_num salary_data_stg.case_num%type);
   
   procedure get_salary_data_stg_1(p_case_num salary_data_stg.case_num%type, p_salary_stg_row in out salary_data_stg%rowtype);
   

--======================================================salary_data_stg======================================================================================================================
    
    
--================================================================_infa_global============================================================================================================
    
    procedure update_infa_global(
      p_statement_prd_yr_qrtr infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte infa_global.run_dte%type default null
    , p_soq_dte infa_global.soq_dte%type default null
    , p_eoq_dte infa_global.eoq_dte%type default null
    , p_last_update_dte infa_global.last_update_dte%type default null
    , p_last_updated_by infa_global.last_updated_by%type default null
    );
    
--================================================================_infa_global============================================================================================================

END table_access_pkg;
