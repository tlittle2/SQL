create or replace PACKAGE STRING_UTILS_PKG
AUTHID DEFINER
AS
    subtype st_max_pl_varchar2 is VARCHAR2(32767);
    
    g_yes                          constant varchar2(1) := 'Y';
    g_no                           constant varchar2(1) := 'N';
    
    g_default_separator            constant varchar2(1) := ';';

	FUNCTION BOOL_TO_STR(p_value IN BOOLEAN)
    RETURN VARCHAR2;
    
    function str_to_bool (p_str in varchar2)
    return boolean;
    
    FUNCTION str_to_bool_str(p_str IN VARCHAR2)
    return varchar2;
    
    procedure add_str_token(p_text IN OUT VARCHAR2, p_token IN VARCHAR2, p_separator IN VARCHAR2 := g_default_separator);
    
    function is_str_integer(p_str IN VARCHAR2)
    return boolean;
    
    function try_parse_date(p_str IN VARCHAR2, p_date_format IN VARCHAR2)
    return date;

END STRING_UTILS_PKG;
