create or replace package global_constants_pkg
AS
    subtype flag_st is CHAR(1);
    
    --constants for specifying if processing is a regularly scheduled run or a special run
    g_regular_run CONSTANT flag_st := 'R';
    g_special_run CONSTANT flag_st := 'S';
    
    --constants for tables with columns for specifying the state of a record
    g_record_is_updated         CONSTANT flag_st := 'Y';
    g_record_is_not_updated     CONSTANT flag_st := 'N';
    g_record_is_being_processed CONSTANT flag_st := 'E';

    function get_regular_run_flag
    return flag_st
    deterministic;

    function get_special_run_flag
    return flag_st
    deterministic;
    
    function get_record_is_updated_flag
    return flag_st
    deterministic;
    
    function get_record_is_not_updated_flag
    return flag_st
    deterministic;
    
    function get_record_is_being_processed_flag
    return flag_st
    deterministic;

end global_constants_pkg;
