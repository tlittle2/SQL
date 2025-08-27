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
    return boolean
    is
        l_pct_value number := nvl(p_value2, 0) * nvl(p_pct / 100, 0);
        l_returnvalue boolean := false;
    begin
        if p_value1 between (p_value2 - l_pct_value) and (p_value2 + l_pct_value)
        then
            l_returnvalue := true;
        end if;

        return l_returnvalue;

    end within_threshold_pct;

    function within_threshold_pct_str(p_value1 in number, p_value2 in number, p_pct in number)
    return varchar2
    is
    begin
        return string_utils_pkg.bool_to_str(within_threshold_pct(p_value1, p_value2 , p_pct));
    end within_threshold_pct_str;


end math_pkg;
