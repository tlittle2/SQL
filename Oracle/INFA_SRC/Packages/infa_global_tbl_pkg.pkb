create or replace package body infa_global_tbl_pkg
as
    function get_global_bin_on
    return infa_global.bin2_ind%type
    deterministic
    is
    begin
       return g_bin_on;
    end get_global_bin_on;

    procedure global_resync(p_run_dte in infa_global.run_dte%type, p_run_type in global_constants_pkg.g_regular_run%type default global_constants_pkg.g_special_run)
    is
        p_row infa_global%rowtype;
        l_quarter infa_global.statement_prd_yr_qrtr%type;
    begin
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');
        assert_pkg.is_not_null_nor_blank(p_run_dte, 'INVALID DATE PROVIDED. PLEASE CORRECT');

        l_quarter := date_utils_pkg.get_year_quarter(p_run_dte);

        infa_global_tapi.update_global_row_logic(
              p_run_type
            , p_statement_prd_yr_qrtr => l_quarter
            , p_run_dte               => trunc(p_run_dte)
            , p_soq_dte               => date_utils_pkg.get_min_date_for_year_quarter(l_quarter)
            , p_eoq_dte               => date_utils_pkg.get_max_date_for_year_quarter(l_quarter)
            , p_last_update_dte       => sysdate
            , p_last_updated_by       => 'GLOBAL_RESYNC'
        );
        sql_utils_pkg.commit;

    exception
        when others then
        error_pkg.print_error('global_resync');
        raise;
    end global_resync;

    procedure global_rollover
    is
    begin
        global_resync(date_utils_pkg.trunc_quarter(sysdate), global_constants_pkg.g_regular_run);
    exception
        when others then
        error_pkg.print_error('global_rollover');
        raise;
    end global_rollover;

end infa_global_tbl_pkg;
