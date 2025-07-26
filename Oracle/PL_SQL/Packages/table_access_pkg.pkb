create or replace package body table_access_pkg
as
--======================================================archive_rules======================================================================================================================
    procedure update_archive_rules (
        p_table_owner        archive_rules.table_owner%type
      , p_table_name         archive_rules.table_name%type
      , p_partitioned        archive_rules.partitioned%type default null
      , p_years_to_keep      archive_rules.years_to_keep%type default null
      , p_upd_flag           archive_rules.upd_flag%type default null
      , p_archive_column_key archive_rules.archive_column_key%type default null
      , p_archive_group_key  archive_rules.archive_group_key%type default null
      , p_job_nbr            archive_rules.job_nbr%type default null)
      is
      begin
        update archive_rules
        set
          partitioned = nvl(p_partitioned, partitioned)
        , years_to_keep = nvl(p_years_to_keep, years_to_keep)
        , upd_flag = nvl(p_upd_flag, upd_flag)
        , archive_column_key = nvl(p_archive_column_key, archive_column_key)
        , archive_group_key = nvl(p_archive_group_key, archive_group_key)
        , job_nbr = nvl(p_job_nbr, job_nbr)
        where table_owner = p_table_owner
        and table_name = p_table_name;
    end update_archive_rules;
    
    
    procedure insert_archive_rules (
        p_table_owner        archive_rules.table_owner%type default null
      , p_table_name         archive_rules.table_name%type default null
      , p_partitioned        archive_rules.partitioned%type default null
      , p_years_to_keep      archive_rules.years_to_keep%type default null
      , p_upd_flag           archive_rules.upd_flag%type default null
      , p_archive_column_key archive_rules.archive_column_key%type default null
      , p_archive_group_key  archive_rules.archive_group_key%type default null
      , p_job_nbr            archive_rules.job_nbr%type default null)
      is
      begin
          insert into archive_rules values ( p_table_owner
                                         , p_table_name
                                         , p_partitioned
                                         , p_years_to_keep
                                         , p_upd_flag
                                         , p_archive_column_key
                                         , p_archive_group_key
                                         , p_job_nbr );

    end insert_archive_rules;
    
    procedure delete_archive_rules (
        p_table_owner archive_rules.table_owner%type
      , p_table_name  archive_rules.table_name%type)
    is
    begin
        delete from archive_rules
        where
                table_owner = p_table_owner
            and table_name = p_table_name;

    end delete_archive_rules;
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
  , p_last_update_id salary_data_stg.last_update_id%type default null)
    is
    begin
        insert into salary_data_stg values(
          p_case_num
        , p_id
        , p_gender
        , p_degree
        , p_year_degree
        , p_field
        , p_start_year
        , p_year
        , p_rank
        , p_admin
        , p_salary
        , p_eff_date
        , p_end_date
        , p_create_id
        , p_last_update_id
        );
    exception
        when others then
        error_pkg.print_error('insert_salary_data_stg');
        raise;
    end insert_salary_data_stg;


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
  , p_last_update_id salary_data_stg.last_update_id%type default null)
    is
    begin
    update salary_data_stg
    set
    id = nvl(p_id, id),
    gender = nvl(p_gender, gender),
    degree = nvl(p_degree, degree),
    year_degree = nvl(p_year_degree, year_degree),
    field = nvl(p_field, field),
    start_year = nvl(p_start_year, start_year),
    year = nvl(p_year, year),
    rank = nvl(p_rank, rank),
    admin = nvl(p_admin, admin),
    salary = nvl(p_salary, salary),
    eff_date = nvl(p_eff_date, eff_date),
    end_date = nvl(p_end_date, end_date),
    create_id = nvl(p_create_id, create_id),
    last_update_id = nvl(p_last_update_id, last_update_id)
    where case_num = p_case_num;

    if sql%rowcount = 0
    then
        error_pkg.assert(1 = 2, string_utils_pkg.get_str('case_num %1 does not exist! please investigate', p_case_num));
    end if;

	exception
        when others then
        error_pkg.print_error('update_salary_data_stg');
        raise;

    end update_salary_data_stg_1;


    procedure delete_salary_data_stg_1(p_case_num salary_data_stg.case_num%type)
    is
    begin
    delete from salary_data_stg
    where case_num = p_case_num;

    if sql%rowcount = 0
    then
        error_pkg.assert(1 = 2, string_utils_pkg.get_str('case_num %1 does not exist! please investigate', p_case_num));
    end if;

    exception
        when others then
        error_pkg.print_error('delete_salary_data_stg');
        raise;
    end delete_salary_data_stg_1;
    
   procedure get_salary_data_stg_1(p_case_num salary_data_stg.case_num%type, p_salary_stg_row in out salary_data_stg%rowtype)
   is
   begin
       select *
       into p_salary_stg_row
       from salary_data_stg
       where case_num = p_case_num;
   end get_salary_data_stg_1;
   
--======================================================salary_data_stg======================================================================================================================


--================================================================_infa_global============================================================================================================
    procedure update_infa_global(
      p_statement_prd_yr_qrtr infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte infa_global.run_dte%type default null
    , p_soq_dte infa_global.soq_dte%type default null
    , p_eoq_dte infa_global.eoq_dte%type default null
    , p_last_update_dte infa_global.last_update_dte%type default null
    , p_last_updated_by infa_global.last_updated_by%type default null)
    is
    begin
        update infa_global
    	set
    	  statement_prd_yr_qrtr = nvl(p_statement_prd_yr_qrtr, statement_prd_yr_qrtr)
        , run_dte = nvl(p_run_dte, run_dte)
        , soq_dte = nvl(p_soq_dte, soq_dte)
        , eoq_dte = nvl(p_eoq_dte, eoq_dte)
        , last_update_dte = nvl(p_last_update_dte, last_update_dte)
        , last_updated_by = nvl(p_last_updated_by, last_updated_by);
    	
    end update_infa_global;
--================================================================_infa_global============================================================================================================

end table_access_pkg;
