create or replace package math_pkg
as
    
    function safe_divide(p_value1 IN NUMBER, p_value2 IN NUMBER)
    RETURN NUMBER;

    function within_threshold_pct(p_value1 IN NUMBER, p_value2 IN NUMBER, p_pct IN NUMBER)
    return boolean;

    function within_threshold_pct_str(p_value1 IN NUMBER, p_value2 IN NUMBER, p_pct IN NUMBER)
    return VARCHAR2;

end math_pkg;
