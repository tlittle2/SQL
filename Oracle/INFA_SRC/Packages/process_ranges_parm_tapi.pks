create or replace package process_ranges_parm_tapi
is
   type PROCESS_RANGES_PARM_tapi_rec is record (
   PROCESS_NAME  PROCESS_RANGES_PARM.PROCESS_NAME%type
   ,LOWER_BOUND  PROCESS_RANGES_PARM.LOWER_BOUND%type
   ,RUN_TOTAL  PROCESS_RANGES_PARM.RUN_TOTAL%type
   ,UPPER_BOUND  PROCESS_RANGES_PARM.UPPER_BOUND%type
   ,RUN_NUMBER  PROCESS_RANGES_PARM.RUN_NUMBER%type);
   
   type PROCESS_RANGES_PARM_tapi_tab is table of PROCESS_RANGES_PARM_tapi_rec;

    type process_ranges_parm_bounds_t is record(
    lower_bound process_ranges_parm.lower_bound%type,
    upper_bound process_ranges_parm.upper_bound%type
    );

-- insert
procedure ins (
p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type
,p_RUN_TOTAL   in PROCESS_RANGES_PARM.RUN_TOTAL%type default null 
,p_RUN_NUMBER  in PROCESS_RANGES_PARM.RUN_NUMBER%type default null
,p_LOWER_BOUND in PROCESS_RANGES_PARM.LOWER_BOUND%type default null 
,p_UPPER_BOUND in PROCESS_RANGES_PARM.UPPER_BOUND%type default null);

-- update
procedure upd (
p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type
,p_RUN_TOTAL   in PROCESS_RANGES_PARM.RUN_TOTAL%type default null 
,p_RUN_NUMBER  in PROCESS_RANGES_PARM.RUN_NUMBER%type
,p_LOWER_BOUND in PROCESS_RANGES_PARM.LOWER_BOUND%type default null 
,p_UPPER_BOUND in PROCESS_RANGES_PARM.UPPER_BOUND%type default null);

-- delete
procedure del (p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type);


function get_process_ranges_parm_row(p_process_name in process_ranges_parm.process_name%type
                                   , p_run_number   in process_ranges_parm.run_number%type)
return process_ranges_parm%rowtype;


end process_ranges_parm_tapi;
