create or replace package body math_pkg
as
    function safe_divide(p_value1 in number, p_value2 in number)
    return number
    is
        l_returnvalue number;
    begin
        if p_value1 = 0 or p_value2 = 0
        then
            l_returnvalue := 0;
        else
            l_returnvalue := p_value1 / p_value2;
        end if;

        return l_returnvalue;

    end safe_divide;

    function within_threshold_pct(p_value1 in number, p_value2 in number, p_pct in number) --for example, 90 (and 110) is within 10 percent of 100
    return string_utils_pkg.st_bool_num
    is
        l_pct_value number := nvl(p_value2, 0) * nvl(p_pct / 100, 0);
        l_returnvalue string_utils_pkg.st_bool_num := string_utils_pkg.g_false;
    begin
        if p_value1 between (p_value2 - l_pct_value) and (p_value2 + l_pct_value)
        then
            l_returnvalue := string_utils_pkg.g_true;
        end if;

        return l_returnvalue;

    end within_threshold_pct;


    function is_even(p_number in number)
    return boolean deterministic
    is
        l_returnvalue boolean := mod(p_number, 2) = 0;
    begin

        return l_returnvalue;

    end is_even;

    function is_odd(p_number in number)
    return boolean deterministic
    is
        l_returnvalue boolean := mod(p_number, 2) = 1;
    begin

        return l_returnvalue;

    end is_odd;



end math_pkg;
