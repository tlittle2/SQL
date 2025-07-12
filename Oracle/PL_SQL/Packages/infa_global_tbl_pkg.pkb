create or replace package body infa_global_tbl_pkg
as
    procedure global_resync(p_run_dte in date, p_run_type IN CHAR := global_constants_pkg.g_special_run)
    is
       l_proc_name VARCHAR2(15) := 'GLOBAL_RESYNC';
    begin
        error_pkg.assert(p_run_type in (global_constants_pkg.g_special_run, global_constants_pkg.g_regular_run), 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');

        if p_run_type = global_constants_pkg.g_special_run
        then
            update infa_global_fix
            set statement_prd_yr_qrtr = date_utils_pkg.get_year_quarter(trunc(p_run_dte, 'Q'))
              , run_dte = trunc(p_run_dte)
              , soq_dte = trunc(p_run_dte, 'Q')
              , eoq_dte = add_months(trunc(p_run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1
              , last_update_dte = sysdate
              , last_updated_by = l_proc_name;
        else
            update infa_global
            set statement_prd_yr_qrtr = date_utils_pkg.get_year_quarter(trunc(p_run_dte, 'Q'))
              , run_dte = trunc(p_run_dte)
              , soq_dte = trunc(p_run_dte, 'Q')
              , eoq_dte = add_months(trunc(p_run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1
              , last_update_dte = sysdate
              , last_updated_by = l_proc_name;

        end if;

        commit;


    end global_resync;

    procedure global_rollover
    is
    begin
        update infa_global
        set statement_prd_yr_qrtr = date_utils_pkg.get_year_quarter(add_months(trunc(run_dte, 'Q'), date_utils_pkg.get_months_in_quarter))
        , run_dte = add_months(trunc(run_dte, 'Q'), date_utils_pkg.get_months_in_quarter)
        , soq_dte = add_months(trunc(run_dte, 'Q'), date_utils_pkg.get_months_in_quarter)
        , eoq_dte = add_months(add_months(trunc(run_dte + 1, 'Q'), date_utils_pkg.get_months_in_quarter)-1, date_utils_pkg.get_months_in_quarter)
        , last_update_dte = sysdate
        , last_updated_by = 'GLOBAL_ROLLOVER';

        commit;

    end global_rollover;

end infa_global_tbl_pkg;
