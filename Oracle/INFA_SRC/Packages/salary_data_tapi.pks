create or replace package salary_data_tapi
is
    TYPE salary_data_tapi_rec IS RECORD(
    case_num       salary_data_stg.case_num%type
  , id             salary_data_stg.id%type
  , gender         salary_data_stg.gender%type
  , degree         salary_data_stg.degree%type
  , year_degree    salary_data_stg.year_degree%type
  , field          salary_data_stg.field%type
  , start_year     salary_data_stg.start_year%type
  , year           salary_data_stg.year%type
  , rank           salary_data_stg.rank%type
  , admin          salary_data_stg.admin%type
  , salary         salary_data_stg.salary%type
  , eff_date       salary_data_stg.eff_date%type
  , end_date       salary_data_stg.end_date%type
  , create_id      salary_data_stg.create_id%type
  , last_update_id salary_data_stg.last_update_id%type);

  TYPE salary_data_tapi_tab IS TABLE OF salary_data_tapi_rec;

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
  , p_last_update_id salary_data_stg.last_update_id%type default null);


    procedure upd(
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


   procedure del(p_case_num salary_data_stg.case_num%type);

   function get_row(p_case_num salary_data_stg.case_num%type)
   return salary_data_stg%rowtype;
end;
