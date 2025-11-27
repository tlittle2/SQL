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

    procedure is_valid_month(p_month in number, p_error_message in varchar2)
    is
    begin
        assert_pkg.is_true(p_month between date_utils_pkg.g_min_calendar_value and date_utils_pkg.g_months_in_year, p_error_message);
    end is_valid_month;

    procedure is_valid_quarter(p_quarter in integer, p_error_message in varchar2)
    is
    begin
        assert(p_quarter between date_utils_pkg.g_min_calendar_value and date_utils_pkg.g_quarters_in_year, p_error_message);
    end is_valid_quarter;


    procedure is_valid_year_quarter(p_year_quarter infa_global.statement_prd_yr_qrtr%type, p_error_message in varchar2)
    is
    begin
        assert_pkg.is_true(string_utils_pkg.char_at(p_year_quarter, 5) = date_utils_pkg.g_year_quarter_sep and length(p_year_quarter) = 6, p_error_message);
    end is_valid_year_quarter;

    procedure is_valid_month_of_quarter(p_month in integer, p_error_message in varchar2)
	is
	begin
        assert(p_month between date_utils_pkg.g_min_calendar_value and date_utils_pkg.g_months_in_quarter, p_error_message);
	end is_valid_month_of_quarter;

	procedure is_date_in_range(p_date_in IN DATE, p_low_date in date, p_high_date in date, p_error_message in varchar2)
	is
	begin
	    assert(p_date_in between trunc(p_low_date) and trunc(p_high_date), p_error_message);
	end is_date_in_range;


	procedure is_equal_to(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 = p_val_2, p_error_message);
	end is_equal_to;


    procedure is_equal_to_zero(p_val_1 in number,p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 = 0, p_error_message);
	end is_equal_to_zero;

	procedure is_greater_than(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 > p_val_2, p_error_message);
	end is_greater_than;


	procedure is_less_than(p_val_1 in number, p_val_2 in number, p_error_message in varchar2)
	is
	begin
	    assert(p_val_1 < p_val_2, p_error_message);
	end is_less_than;

end assert_pkg;

