create or replace package body math_pkg
as
    function safe_divide(p_value1 IN NUMBER, p_value2 IN NUMBER)
    RETURN NUMBER
    is
    begin
        if p_value1 = 0 or p_value2 = 0
        then
            return 0;
        else
            return p_value1 / p_value2;
        end if;
    end safe_divide;

    function within_threshold_pct(p_value1 IN NUMBER, p_value2 IN NUMBER, p_pct IN NUMBER) --for example, 90 (and 110) is within 10 percent of 100
    return boolean
    is
        v_pct_value NUMBER := nvl(p_value2, 0) * nvl(p_pct / 100, 0);
    begin
        if p_value1 between (p_value2 - v_pct_value) and (p_value2 + v_pct_value)
        then
            return true;
        end if;

        return false;
    end within_threshold_pct;

    function within_threshold_pct_str(p_value1 IN NUMBER, p_value2 IN NUMBER, p_pct IN NUMBER)
    return VARCHAR2
    is
    begin
        return string_utils_pkg.bool_to_str(within_threshold_pct(p_value1, p_value2 , p_pct));    
    end within_threshold_pct_str;
    

end math_pkg;
