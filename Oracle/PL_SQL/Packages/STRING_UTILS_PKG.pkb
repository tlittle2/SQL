create or replace PACKAGE BODY STRING_UTILS_PKG
AS

	FUNCTION BOOL_TO_STR(p_value IN BOOLEAN)
	RETURN VARCHAR2
	IS
	BEGIN
		return CASE (p_value)
		WHEN TRUE THEN  'TRUE'
		WHEN FALSE THEN 'FALSE'
        ELSE 'NULL'
		end;
        
	EXCEPTION
		WHEN OTHERS THEN
		CLEANUP_PKG.exception_cleanup(FALSE);
	END;
    
    FUNCTION str_to_bool(p_str IN VARCHAR2)
    return boolean
    is
    begin
        if lower(p_str) in ('y', 'yes', 'true', '1')
        then
            return true;
        end if;
        
        return false;
    end;
    
    
    FUNCTION str_to_bool_str(p_str IN VARCHAR2)
    return varchar2
    is
    begin
        if str_to_bool(p_str)
        then
            return g_yes;
        end if;
        
        return g_no;
    end;
    
    procedure add_str_token(p_text IN OUT VARCHAR2, p_token IN VARCHAR2, p_separator IN VARCHAR2 := g_default_separator)
    is
    begin
        if p_text is null
        then   
            p_text := p_token;
        else
            p_text := p_text || p_separator || p_token;
        end if;
    end;
    
    
    function is_str_integer(p_str IN VARCHAR2)
    return boolean
    is
    begin
        return regexp_instr(p_str, '[^0-9]') = 0;
    end;
    
    
    function try_parse_date(p_str IN VARCHAR2, p_date_format IN VARCHAR2)
    return date
    is
    l_returnvalue DATE;
    begin
        l_returnvalue := to_date(p_str, p_date_format);
        
        return l_returnvalue;
    
    exception
        when others then
        l_returnvalue := null;
    end;


END STRING_UTILS_PKG;
