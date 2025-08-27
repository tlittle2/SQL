create or replace package infa_global_tbl_pkg
as
    
    procedure global_resync(p_run_dte in infa_global.run_dte%type, p_run_type in global_constants_pkg.g_regular_run%type := global_constants_pkg.g_special_run);

    procedure global_rollover;


end infa_global_tbl_pkg;
