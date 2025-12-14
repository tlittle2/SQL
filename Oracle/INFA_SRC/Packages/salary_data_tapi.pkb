create or replace package body salary_data_tapi
is
    procedure ins(
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
    end ins;

    procedure upd1(
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
    update salary_data_stg
    set
    case_num = nvl(p_case_num, case_num),
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
    last_update_id = nvl(p_last_update_id, last_update_id);

    if sql%rowcount = 0
    then
        error_pkg.assert(1 = 2, string_utils_pkg.get_str('case_num %1 does not exist! please investigate', p_case_num));
    end if;

	exception
        when others then
        error_pkg.print_error('update_salary_data_stg1');
        raise;  
  end upd1;


    procedure upd2(
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
        error_pkg.print_error('update_salary_data_stg2');
        raise;
    end upd2;


    procedure del(p_case_num salary_data_stg.case_num%type)
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
    end del;

   function get_row(p_case_num salary_data_stg.case_num%type)
   return salary_data_stg%rowtype
   is
       l_returnvalue salary_data_stg%rowtype;
   begin
       select *
       into l_returnvalue
       from salary_data_stg
       where case_num = p_case_num;

       return l_returnvalue;

	exception
        when others then
        error_pkg.print_error('get_salary_data_stg_1');
        raise;
   end get_row;

end salary_data_tapi;
