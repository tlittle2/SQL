create or replace package body regex_utils_pkg
as

    function get_regex_integer
    return varchar2 deterministic
    is
    begin
        return g_regex_integer;
    end;

    function get_regex_integer_not
    return varchar2 deterministic
    is
    begin
        return g_regex_integer_not;
    end;

    function get_regex_alpha
    return varchar2
    deterministic
    is
    begin
        return g_regex_alpha;

    end;

    function regex_alpha_not
    return varchar2
    deterministic
    is
    begin
        return g_regex_alpha_not;
    end;


    function get_regex_email_addresses
    return varchar2
    deterministic
    is
    begin
        return g_regex_email_addresses;
    end;

    function get_regex_cc_visa
    return varchar2
    deterministic
    is
    begin
        return g_regex_cc_visa;
    end;


end regex_utils_pkg;
