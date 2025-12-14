create or replace package body process_ranges_parm_tapi
is
    -- insert
    procedure ins (
    p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type
    ,p_RUN_TOTAL   in PROCESS_RANGES_PARM.RUN_TOTAL%type default null 
    ,p_RUN_NUMBER  in PROCESS_RANGES_PARM.RUN_NUMBER%type default null
    ,p_LOWER_BOUND in PROCESS_RANGES_PARM.LOWER_BOUND%type default null 
    ,p_UPPER_BOUND in PROCESS_RANGES_PARM.UPPER_BOUND%type default null )
    is
    begin
        insert into PROCESS_RANGES_PARM(
        PROCESS_NAME
        ,LOWER_BOUND
        ,RUN_TOTAL
        ,UPPER_BOUND
        ,RUN_NUMBER
        ) values (
        p_PROCESS_NAME
        ,p_LOWER_BOUND
        ,p_RUN_TOTAL
        ,p_UPPER_BOUND
        ,p_RUN_NUMBER
        );
    end ins;
    
    -- update
    procedure upd (p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type
    ,p_RUN_TOTAL   in PROCESS_RANGES_PARM.RUN_TOTAL%type default null 
    ,p_RUN_NUMBER  in PROCESS_RANGES_PARM.RUN_NUMBER%type
    ,p_LOWER_BOUND in PROCESS_RANGES_PARM.LOWER_BOUND%type default null 
    ,p_UPPER_BOUND in PROCESS_RANGES_PARM.UPPER_BOUND%type default null)
    is
    begin
        update PROCESS_RANGES_PARM set
        LOWER_BOUND = nvl(p_LOWER_BOUND, lower_bound)
        ,RUN_TOTAL = nvl(p_RUN_TOTAL, run_total)
        ,UPPER_BOUND = nvl(p_UPPER_BOUND, upper_bound)
        where PROCESS_NAME = p_PROCESS_NAME
        and RUN_NUMBER = p_RUN_NUMBER;
    end upd;
    
    
    -- del
    procedure del (p_PROCESS_NAME in PROCESS_RANGES_PARM.PROCESS_NAME%type)
    is
    begin
        delete from PROCESS_RANGES_PARM
        where PROCESS_NAME = p_PROCESS_NAME;
    end del;




    function get_process_ranges_parm_row(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type)
    return process_ranges_parm%rowtype
    is
        l_returnvalue process_ranges_parm%rowtype;
    begin
        assert_pkg.is_true(
            p_process_name in (
                process_preanalysis_pkg.c_process_salaries
                ), 'CONSTANT NOT RECOGNIZED! PLEASE INVESTIGATE!'
        );

        select *
        into l_returnvalue
        from process_ranges_parm
        where process_name = p_process_name
        and run_number = p_run_number;

        assert_pkg.is_not_null_nor_blank(l_returnvalue.lower_bound, 'INVALID LOWER BOUND RETREIVED. PLEASE INVESTIGATE');
        assert_pkg.is_not_null_nor_blank(l_returnvalue.upper_bound, 'INVALID UPPER BOUND RETREIVED. PLEASE INVESTIGATE');

        return l_returnvalue;

    exception
        --TODO: do something more creative here
        when others then
            raise;
    end get_process_ranges_parm_row;

end process_ranges_parm_tapi;
