create or replace package regex_utils_pkg
as
	subtype st_regex_len is varchar2(255);
	
	g_regex_integer        constant st_regex_len  := '[0-9]';
	g_regex_integer_not    constant st_regex_len  := '[^0-9]';

	g_regex_alpha          constant st_regex_len := '[A-Z|a-z]';
	g_regex_alpha_not      constant st_regex_len := '[^A-Z|a-z]';

	g_regex_alphanumeric       constant st_regex_len := '[a-z|A-Z|0-9]';
	g_regex_alphanumeric_not   constant st_regex_len := '[^a-z|A-Z|0-9]';

	g_regex_email_addresses  constant st_regex_len := '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$';
	g_regex_cc_visa          constant st_regex_len := '^4[0-9]{12}(?:[0-9]{3})?$';


	function get_regex_integer
	return varchar2 deterministic;

	function get_regex_integer_not
	return varchar2 deterministic;

	function get_regex_alpha
	return varchar2
	deterministic;

	function regex_alpha_not
	return varchar2
	deterministic;


	function get_regex_email_addresses
	return varchar2
	deterministic;

	function get_regex_cc_visa
	return varchar2
	deterministic;
	
end regex_utils_pkg;
