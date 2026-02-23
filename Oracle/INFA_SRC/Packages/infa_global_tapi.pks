create or replace package infa_global_tapi
is

   type infa_global_tapi_rec is record (
      statement_prd_yr_qrtr  infa_global.statement_prd_yr_qrtr%type default null
    , run_dte                infa_global.run_dte%type default null
    , soq_dte                infa_global.soq_dte%type default null
    , eoq_dte                infa_global.eoq_dte%type default null
    , last_update_dte        infa_global.last_update_dte%type default null
    , last_updated_by        infa_global.last_updated_by%type default null
    , BIN2_IND               infa_global.BIN2_IND%type default null
    , BIN3_IND               infa_global.BIN3_IND%type default null
    , BIN4_IND               infa_global.BIN4_IND%type default null
    , BIN5_IND               infa_global.BIN5_IND %type default null
    );


    type infa_global_tapi_tab is table of infa_global_tapi_rec;

    procedure update_infa_global(
      p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null
    , p_BIN2_IND              in infa_global.BIN2_IND%type default null
    , p_BIN3_IND              in infa_global.BIN3_IND%type default null
    , p_BIN4_IND              in infa_global.BIN4_IND%type default null
    , p_BIN5_IND              in infa_global.BIN5_IND %type default null
    );

    procedure update_infa_global_fix(
      p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null
    , p_BIN2_IND              in infa_global.BIN2_IND%type default null
    , p_BIN3_IND              in infa_global.BIN3_IND%type default null
    , p_BIN4_IND              in infa_global.BIN4_IND%type default null
    , p_BIN5_IND              in infa_global.BIN5_IND %type default null

    );

	procedure update_global_row_logic(
      p_run_type              in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run
    , p_statement_prd_yr_qrtr in infa_global.statement_prd_yr_qrtr%type default null
    , p_run_dte               in infa_global.run_dte%type default null
    , p_soq_dte               in infa_global.soq_dte%type default null
    , p_eoq_dte               in infa_global.eoq_dte%type default null
    , p_last_update_dte       in infa_global.last_update_dte%type default null
    , p_last_updated_by       in infa_global.last_updated_by%type default null
    , p_BIN2_IND              in infa_global.BIN2_IND%type default null
    , p_BIN3_IND              in infa_global.BIN3_IND%type default null
    , p_BIN4_IND              in infa_global.BIN4_IND%type default null
    , p_BIN5_IND              in infa_global.BIN5_IND %type default null
    );

	procedure update_global_row_logic(p_row      in infa_global%rowtype
                                    , p_run_type in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run);

    function get_infa_global_row
    return infa_global%rowtype;

	function get_global_fix_row
    return infa_global%rowtype;

	function get_global_row_logic(p_run_type in global_constants_pkg.g_special_run%type default global_constants_pkg.g_regular_run)
    return infa_global%rowtype;


end infa_global_tapi;
