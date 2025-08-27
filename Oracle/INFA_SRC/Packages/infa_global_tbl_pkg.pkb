create or replace package body infa_global_tbl_pkg
as
    procedure global_resync(p_run_dte in infa_global.run_dte%type, p_run_type in global_constants_pkg.g_regular_run%type := global_constants_pkg.g_special_run)
    is
       p_row infa_global%rowtype;
    begin
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');
        assert_pkg.is_not_null_nor_blank(p_run_dte, 'INVALID DATE PROVIDED. PLEASE CORRECT');

        p_row.statement_prd_yr_qrtr := date_utils_pkg.get_year_quarter(date_utils_pkg.trunc_quarter(p_run_dte));
        p_row.run_dte := trunc(p_run_dte);
        p_row.soq_dte := date_utils_pkg.trunc_quarter(p_run_dte);
        p_row.eoq_dte := add_months(date_utils_pkg.trunc_quarter(p_run_dte), date_utils_pkg.g_months_in_quarter)-1;
        p_row.last_update_dte := sysdate;
        p_row.last_updated_by :=  'GLOBAL_RESYNC';

        crud_pkg.update_global_row_logic(p_row, p_run_type);
        commit;

    exception
        when others then
        error_pkg.print_error('global_resync');
        raise;
    end global_resync;

	procedure global_rollover
	is
    l_rec_global infa_global%rowtype := crud_pkg.get_infa_global_row;
    l_out_global infa_global%rowtype;
	begin
        l_out_global.statement_prd_yr_qrtr := date_utils_pkg.get_year_quarter(sysdate);
        l_out_global.run_dte := add_months(date_utils_pkg.trunc_quarter(sysdate), date_utils_pkg.g_months_in_quarter);
        l_out_global.soq_dte := add_months(date_utils_pkg.trunc_quarter(sysdate), date_utils_pkg.g_months_in_quarter);
        l_out_global.eoq_dte := add_months(date_utils_pkg.trunc_quarter(l_rec_global.run_dte + 1), date_utils_pkg.g_months_in_quarter)-1;
        l_out_global.last_update_dte := sysdate;
        l_out_global.last_updated_by := 'GLOBAL_ROLLOVER';

        crud_pkg.update_global_row_logic(l_out_global, global_constants_pkg.g_regular_run);
        commit;

    end global_rollover;

end infa_global_tbl_pkg;
