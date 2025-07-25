create or replace package body regex_utils_pkg
as

    function get_regex_integer
    return varchar2 deterministic
    is
    begin
        return g_regex_integer;
    end get_regex_integer;

    function get_regex_integer_not
    return varchar2 deterministic
    is
    begin
        return g_regex_integer_not;
    end get_regex_integer_not;

    function get_regex_alpha
    return varchar2
    deterministic
    is
    begin
        return g_regex_alpha;

    end get_regex_alpha;

    function regex_alpha_not
    return varchar2
    deterministic
    is
    begin
        return g_regex_alpha_not;
    end regex_alpha_not;


    function get_regex_email_addresses
    return varchar2
    deterministic
    is
    begin
        return g_regex_email_addresses;
    end get_regex_email_addresses;

    function get_regex_cc_visa
    return varchar2
    deterministic
    is
    begin
        return g_regex_cc_visa;
    end get_regex_cc_visa;


end regex_utils_pkg;
