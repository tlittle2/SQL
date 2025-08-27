create or replace package math_pkg
as

    function safe_divide(p_value1 in number, p_value2 in number)
    return number;

    function within_threshold_pct(p_value1 in number, p_value2 in number, p_pct in number)
    return boolean;

    function within_threshold_pct_str(p_value1 in number, p_value2 in number, p_pct in number)
    return varchar2;

end math_pkg;
