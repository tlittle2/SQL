create or replace package body assert_pkg
as
    procedure assert(p_condition in boolean, p_error_message in varchar2)
    is
    begin
        if not nvl(p_condition, false) then
            debug_pkg.debug_off;
            raise_application_error (-20000, p_error_message);
        end if;
    end assert;

	procedure is_valid_run_mode(p_run_mode in char, p_error_message in varchar2)
	is
	begin
	    assert(p_run_mode in (global_constants_pkg.g_special_run, global_constants_pkg.g_regular_run), p_error_message);
	end is_valid_run_mode;

	procedure is_not_null_nor_blank(p_val in varchar2, p_error_message in varchar2)
	is
	begin
	    assert(p_val is not null or trim(p_val) <> '', p_error_message);
	end is_not_null_nor_blank;


	procedure is_null(p_val in varchar2, p_error_message in varchar2)
	is
	begin
	    assert(p_val is null, p_error_message);
	end is_null;


	procedure is_not_null(p_val in varchar2, p_error_message in varchar2)
	is
	begin
	    assert(p_val is not null, p_error_message);
	end is_not_null;


	procedure is_true(p_condition in boolean, p_error_message in varchar2)
	is
	begin
	    assert(p_condition, p_error_message);
	end is_true;


	procedure is_false(p_condition in boolean, p_error_message in varchar2)
	is
	begin
	    assert(not p_condition, p_error_message);
	end is_false;

	procedure is_date_in_range(p_date_in IN DATE, p_low_date in date, p_high_date in date, p_error_message in varchar2)
	is
	begin
	    assert(p_date_in between trunc(p_low_date) and trunc(p_high_date), p_error_message);
	end is_date_in_range;


	procedure is_val_equal_to_val(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 = p_val_2, p_error_message);
	end is_val_equal_to_val;

	procedure is_val_greater_than_val(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 > p_val_2, p_error_message);
	end is_val_greater_than_val;


	procedure is_val_less_than_val(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 < p_val_2, p_error_message);
	end is_val_less_than_val;

end assert_pkg;
