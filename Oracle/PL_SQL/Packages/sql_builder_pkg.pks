create or replace package sql_builder_pkg
as
    type t_query is record (
    f_select     string_utils_pkg.st_max_pl_varchar2,
    f_from       string_utils_pkg.st_max_pl_varchar2,
    f_where      string_utils_pkg.st_max_pl_varchar2,
    f_group_by   string_utils_pkg.st_max_pl_varchar2,
    f_order_by   string_utils_pkg.st_max_pl_varchar2
    );

      procedure set_from (p_query in out t_query,p_name in varchar2);

      procedure add_select (p_query in out t_query,p_name in varchar2, p_separator CHAR DEFAULT ','); 
      
      function get_select(p_query in t_query)
      return varchar2 deterministic;

      procedure add_from(p_query in out t_query,p_name in varchar2); 
      
      function get_from(p_query in t_query)
      return varchar2 deterministic;

      procedure add_where(p_query in out t_query,p_name in varchar2, p_separator IN VARCHAR2); --TRUE = and, FALSE = OR
      
      function get_where(p_query in t_query)
      return varchar2 deterministic;
      
      function get_where_in(p_query in out t_query, p_negate IN BOOLEAN DEFAULT FALSE)
      return varchar2 deterministic;

      procedure add_group_by(p_query in out t_query,p_name in varchar2); 

      procedure add_order_by(p_query in out t_query,p_name in varchar2); 

      -- get SQL text
      function get_sql(p_query in t_query,
    					p_include_where in boolean := true,
    					p_include_group_by in boolean := true,
    					p_include_order_by in boolean := true)
      return string_utils_pkg.st_max_pl_varchar2;
      
end sql_builder_pkg;
