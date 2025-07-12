create or replace package body table_access_pkg
AS
    procedure insert_salary_data_stg(
    p_CASE_NUM       salary_data_stg.CASE_NUM%type DEFAULT NULL
  , p_ID             salary_data_stg.ID%type DEFAULT NULL
  , p_GENDER         salary_data_stg.GENDER%type DEFAULT NULL
  , p_DEGREE         salary_data_stg.DEGREE%type DEFAULT NULL
  , p_YEAR_DEGREE    salary_data_stg.YEAR_DEGREE%type DEFAULT NULL
  , p_FIELD          salary_data_stg.FIELD%type DEFAULT NULL
  , p_START_YEAR     salary_data_stg.START_YEAR%type DEFAULT NULL
  , p_YEAR           salary_data_stg.YEAR%type DEFAULT NULL
  , p_RANK           salary_data_stg.RANK%type DEFAULT NULL
  , p_ADMIN          salary_data_stg.ADMIN%type DEFAULT NULL
  , p_SALARY         salary_data_stg.SALARY%type DEFAULT NULL
  , p_EFF_DATE       salary_data_stg.EFF_DATE%type DEFAULT NULL
  , p_END_DATE       salary_data_stg.END_DATE%type DEFAULT NULL
  , p_CREATE_ID      salary_data_stg.CREATE_ID%type DEFAULT NULL
  , p_LAST_UPDATE_ID salary_data_stg.LAST_UPDATE_ID%type DEFAULT NULL)
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


    procedure update_salary_data_stg(
    p_CASE_NUM       salary_data_stg.CASE_NUM%type
  , p_ID             salary_data_stg.ID%type DEFAULT NULL
  , p_GENDER         salary_data_stg.GENDER%type DEFAULT NULL
  , p_DEGREE         salary_data_stg.DEGREE%type DEFAULT NULL
  , p_YEAR_DEGREE    salary_data_stg.YEAR_DEGREE%type DEFAULT NULL
  , p_FIELD          salary_data_stg.FIELD%type DEFAULT NULL
  , p_START_YEAR     salary_data_stg.START_YEAR%type DEFAULT NULL
  , p_YEAR           salary_data_stg.YEAR%type DEFAULT NULL
  , p_RANK           salary_data_stg.RANK%type DEFAULT NULL
  , p_ADMIN          salary_data_stg.ADMIN%type DEFAULT NULL
  , p_SALARY         salary_data_stg.SALARY%type DEFAULT NULL
  , p_EFF_DATE       salary_data_stg.EFF_DATE%type DEFAULT NULL
  , p_END_DATE       salary_data_stg.END_DATE%type DEFAULT NULL
  , p_CREATE_ID      salary_data_stg.CREATE_ID%type DEFAULT NULL
  , p_LAST_UPDATE_ID salary_data_stg.LAST_UPDATE_ID%type DEFAULT NULL)
    is
    begin
    update salary_data_stg
    set
    CASE_NUM = nvl(p_CASE_NUM, CASE_NUM),
    ID = nvl(p_ID, ID),
    GENDER = nvl(p_GENDER, GENDER),
    DEGREE = nvl(p_DEGREE, DEGREE),
    YEAR_DEGREE = nvl(p_YEAR_DEGREE, YEAR_DEGREE),
    FIELD = nvl(p_FIELD, FIELD),
    START_YEAR = nvl(p_START_YEAR, START_YEAR),
    YEAR = nvl(p_YEAR, YEAR),
    RANK = nvl(p_RANK, RANK),
    ADMIN = nvl(p_ADMIN, ADMIN),
    SALARY = nvl(p_SALARY, SALARY),
    EFF_DATE = nvl(p_EFF_DATE, EFF_DATE),
    END_DATE = nvl(p_END_DATE, END_DATE),
    CREATE_ID = nvl(p_CREATE_ID, CREATE_ID),
    LAST_UPDATE_ID = nvl(p_LAST_UPDATE_ID, LAST_UPDATE_ID)
    where CASE_NUM = p_CASE_NUM;

    if sql%rowcount = 0
    then
        error_pkg.assert(1 = 2, string_utils_pkg.get_str('CASE_NUM %1 DOES NOT EXIST! PLEASE INVESTIGATE', p_CASE_NUM));
    end if;

	exception
        when others then
        error_pkg.print_error('update_salary_data_stg');
        raise;

    end update_salary_data_stg;


    procedure delete_salary_data_stg(p_CASE_NUM salary_data_stg.CASE_NUM%type)
    is
    begin
    delete from salary_data_stg
    where CASE_NUM = p_CASE_NUM;

    if sql%rowcount = 0
    then
        error_pkg.assert(1 = 2, string_utils_pkg.get_str('CASE_NUM %1 DOES NOT EXIST! PLEASE INVESTIGATE', p_CASE_NUM));
    end if;

    exception
        when others then
        error_pkg.print_error('delete_salary_data_stg');
        raise;
    end delete_salary_data_stg;


end table_access_pkg;
