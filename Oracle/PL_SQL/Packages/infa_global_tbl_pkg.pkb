create or replace package body infa_global_tbl_pkg
as
    procedure global_resync(p_run_dte in date, p_run_type IN CHAR := global_constants_pkg.g_special_run)
    is
       l_proc_name CONSTANT VARCHAR2(15) := 'GLOBAL_RESYNC';
    begin
        error_pkg.assert(p_run_type in (global_constants_pkg.g_special_run, global_constants_pkg.g_regular_run), 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');

        if p_run_type = global_constants_pkg.g_special_run
        then
            table_access_pkg.update_infa_global_fix_1(
               p_statement_prd_yr_qrtr => date_utils_pkg.get_year_quarter(trunc(p_run_dte, 'Q'))
             , p_run_dte => trunc(p_run_dte)
             , p_soq_dte => trunc(p_run_dte, 'Q')
             , p_eoq_dte => add_months(trunc(p_run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1
             , p_last_update_dte => sysdate
             , p_last_updated_by => l_proc_name
            );
        else
            table_access_pkg.update_infa_global_1(
              p_statement_prd_yr_qrtr => date_utils_pkg.get_year_quarter(trunc(p_run_dte, 'Q'))
            , p_run_dte => trunc(p_run_dte)
            , p_soq_dte => trunc(p_run_dte, 'Q')
            , p_eoq_dte => add_months(trunc(p_run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1
            , p_last_update_dte => sysdate
            , p_last_updated_by => l_proc_name
            );
        end if;
        
        commit;
    exception
        when others then
        error_pkg.print_error('global_resync');
        raise;
    end global_resync;

	procedure global_rollover
	is
    l_rec_global infa_global%rowtype;
	begin
        table_access_pkg.get_infa_global_row(l_rec_global);
        
        table_access_pkg.update_infa_global_1(
              p_statement_prd_yr_qrtr => date_utils_pkg.get_year_quarter(sysdate)
            , p_run_dte => add_months(trunc(sysdate, 'Q'), date_utils_pkg.get_months_in_quarter)
            , p_soq_dte => add_months(trunc(sysdate, 'Q'), date_utils_pkg.get_months_in_quarter)
            , p_eoq_dte => add_months(trunc(l_rec_global.run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1
            , p_last_update_dte => sysdate
            , p_last_updated_by => 'GLOBAL_ROLLOVER'
            );
 
 		commit;
    exception
        when others then
        error_pkg.print_error('global_rollover');
        raise;

	end global_rollover;

end infa_global_tbl_pkg;
