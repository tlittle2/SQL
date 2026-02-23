create or replace package math_pkg
as
    c_zero constant number(1,0) := 0;

    function safe_divide(p_value1 in number, p_value2 in number)
    return number;

    function within_threshold_pct(p_value1 in number, p_value2 in number, p_pct in number)
    return string_utils_pkg.st_bool_num;

    function is_even(p_number in number)
    return boolean deterministic;

    function is_odd(p_number in number)
    return boolean deterministic;

    function null_to_zero(p_number in number)
    return number;


end math_pkg;
