create or replace package body global_constants_pkg
as

    function get_regular_run_flag
    return flag_st
    deterministic
	is
	begin
	    return g_regular_run;
	end get_regular_run_flag;


    function get_special_run_flag
    return flag_st
    deterministic
	is
	begin
	    return g_special_run;
	end get_special_run_flag;
    
    
    function get_record_is_updated_flag
    return flag_st
    deterministic
    is
    begin
        return g_record_is_updated;
    end get_record_is_updated_flag;
    
    function get_record_is_not_updated_flag
    return flag_st
    deterministic
    is
    begin
        return g_record_is_not_updated;
    end get_record_is_not_updated_flag;
    
    function get_record_is_being_processed_flag
    return flag_st
    deterministic
    is
    begin
        return g_record_is_being_processed;
    end get_record_is_being_processed_flag;

end global_constants_pkg;
