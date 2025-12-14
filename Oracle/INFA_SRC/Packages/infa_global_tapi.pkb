create or replace package body infa_global_tapi
as

    procedure update_infa_global(
      p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null)
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
    exception
        when others then
        error_pkg.print_error('update_infa_global');
        raise;
    end update_infa_global;


    procedure update_infa_global_fix(
      p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null)
    is
    begin
        update infa_global_fix
    	set
    	  statement_prd_yr_qrtr = nvl(p_statement_prd_yr_qrtr, statement_prd_yr_qrtr)
        , run_dte = nvl(p_run_dte, run_dte)
        , soq_dte = nvl(p_soq_dte, soq_dte)
        , eoq_dte = nvl(p_eoq_dte, eoq_dte)
        , last_update_dte = nvl(p_last_update_dte, last_update_dte)
        , last_updated_by = nvl(p_last_updated_by, last_updated_by);
    exception
        when others then
        error_pkg.print_error('update_infa_global_fix');
        raise;
    end update_infa_global_fix;
    

	procedure update_global_row_logic(
      p_run_type in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run
    , p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null)
    is
    begin
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');
        
        if p_run_type = global_constants_pkg.g_special_run
        then
            update_infa_global_fix(
              p_statement_prd_yr_qrtr => p_statement_prd_yr_qrtr
            , p_run_dte               => p_run_dte
            , p_soq_dte               => p_soq_dte
            , p_eoq_dte               => p_eoq_dte
            , p_last_update_dte       => p_last_update_dte
            , p_last_updated_by       => p_last_updated_by
            );
        else
            update_infa_global(
              p_statement_prd_yr_qrtr => p_statement_prd_yr_qrtr
            , p_run_dte               => p_run_dte
            , p_soq_dte               => p_soq_dte
            , p_eoq_dte               => p_eoq_dte
            , p_last_update_dte       => p_last_update_dte
            , p_last_updated_by       => p_last_updated_by
            );
        end if;
    exception
        when others then
        error_pkg.print_error('update_global_row_logic');
        raise;
    end update_global_row_logic;


	procedure update_global_row_logic(p_row      in infa_global%rowtype
                                    , p_run_type in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run)
    is
    begin 
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');

        if p_run_type = global_constants_pkg.g_special_run
        then
            update infa_global_fix set row = p_row;
        else
            update infa_global set row = p_row;

        end if;
    exception
        when others then
        error_pkg.print_error('update_global_row_logic');
        raise;
    end update_global_row_logic;


    function get_infa_global_row
    return infa_global%rowtype
    is
        l_returnvalue infa_global%rowtype;
    begin
        select *
        into l_returnvalue
        from infa_global;

        return l_returnvalue;
    exception
        when others then
        raise;
    end get_infa_global_row;

	function get_global_fix_row
    return infa_global%rowtype
    is
        l_returnvalue infa_global%rowtype;
    begin
        select *
        into l_returnvalue
        from infa_global_fix;

        return l_returnvalue;

    exception
        when others then
        raise;
    end get_global_fix_row;
    

	function get_global_row_logic(p_run_type in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run)
    return infa_global%rowtype
    is
        l_returnvalue infa_global%rowtype;
    begin
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');

        if p_run_type = global_constants_pkg.g_special_run
		then
		    l_returnvalue:= get_global_fix_row;
		else
            l_returnvalue:= get_infa_global_row;
		end if;

        return l_returnvalue;

    exception
        when others then
        raise;
    end get_global_row_logic;


end infa_global_tapi;
