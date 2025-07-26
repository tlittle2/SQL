create or replace package infa_global_tbl_pkg
as
    
    procedure global_resync(p_run_dte in date, p_run_type IN CHAR := global_constants_pkg.g_special_run);

    procedure global_rollover;


end infa_global_tbl_pkg;
