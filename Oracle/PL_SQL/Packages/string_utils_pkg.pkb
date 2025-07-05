create or replace package body string_utils_pkg
as

    function bool_to_str(p_value in boolean)
    return varchar2
    is
    begin
    	return case (p_value)
    	when true then  'TRUE'
    	when false then 'FALSE'
        else 'NULL'
    	end;
        
    exception
    	when others then
    	cleanup_pkg.exception_cleanup(false);
    end;
    
    function str_to_bool(p_str in varchar2)
    return boolean
    is
    begin
        if lower(p_str) in ('y', 'yes', 'true', '1')
        then
            return true;
        end if;
        
        return false;
    end;
    
    
    function str_to_bool_str(p_str in varchar2)
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
    
    
    function get_str (p_msg    in varchar2,
                      p_value1 in varchar2 := null,
                      p_value2 in varchar2 := null,
                      p_value3 in varchar2 := null,
                      p_value4 in varchar2 := null,
                      p_value5 in varchar2 := null,
                      p_value6 in varchar2 := null,
                      p_value7 in varchar2 := null,
                      p_value8 in varchar2 := null)
    return varchar2
    IS
        v_returnvalue string_utils_pkg.st_max_pl_varchar2;
    
        FUNCTION replace_str(p_value IN VARCHAR2, p_position IN VARCHAR2)
        RETURN VARCHAR2 IS
        BEGIN
            RETURN replace(v_returnvalue,p_position, nvl(p_value, '(blank)'));
        END;
    
    BEGIN
        v_returnvalue := p_msg;
    
        v_returnvalue := replace_str(p_value1, '%1');
        v_returnvalue := replace_str(p_value2, '%2');
        v_returnvalue := replace_str(p_value3, '%3');
        v_returnvalue := replace_str(p_value4, '%4');
        v_returnvalue := replace_str(p_value5, '%5');
        v_returnvalue := replace_str(p_value6, '%6');
        v_returnvalue := replace_str(p_value7, '%7');
        v_returnvalue := replace_str(p_value8, '%8');
        
        return v_returnvalue;
    END;

end string_utils_pkg;
