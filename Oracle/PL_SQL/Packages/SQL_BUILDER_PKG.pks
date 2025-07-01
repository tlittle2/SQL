create or replace PACKAGE SQL_BUILDER_PKG
AS
    type t_query is record (
    f_select     string_utils_pkg.st_max_pl_varchar2,
    f_from       string_utils_pkg.st_max_pl_varchar2,
    f_where      string_utils_pkg.st_max_pl_varchar2,
    f_group_by   string_utils_pkg.st_max_pl_varchar2,
    f_order_by   string_utils_pkg.st_max_pl_varchar2
	);

	  procedure set_from (p_query in out t_query,p_name in varchar2);

	  procedure add_select (p_query in out t_query,p_name in varchar2, p_separator CHAR DEFAULT ','); 

	  procedure add_from(p_query in out t_query,p_name in varchar2); 

	  procedure add_where(p_query in out t_query,p_name in varchar2, and_or IN BOOLEAN DEFAULT TRUE); --TRUE = and, FALSE = OR

	  procedure add_group_by(p_query in out t_query,p_name in varchar2); 

	  procedure add_order_by(p_query in out t_query,p_name in varchar2); 

	  -- get SQL text
	  function get_sql(p_query in t_query,
						p_include_where in boolean := true,
						p_include_group_by in boolean := true,
						p_include_order_by in boolean := true)
	  return string_utils_pkg.st_max_pl_varchar2; 


END SQL_BUILDER_PKG;
