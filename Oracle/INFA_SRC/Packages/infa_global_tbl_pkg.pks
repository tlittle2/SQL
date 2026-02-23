create or replace package infa_global_tbl_pkg
as
    g_bin_on infa_global.bin2_ind%type  := 'Y';
    g_bin_off infa_global.bin2_ind%type := 'N';

    function get_global_bin_on
    return infa_global.bin2_ind%type
    deterministic;

    procedure global_resync(p_run_dte in infa_global.run_dte%type
                          , p_run_type in global_constants_pkg.g_regular_run%type default global_constants_pkg.g_special_run);

    procedure global_rollover;


end infa_global_tbl_pkg;
