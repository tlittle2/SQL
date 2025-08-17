create or replace package body sql_builder_pkg
AS

	procedure set_from(p_query in out t_query,p_name in varchar2)
	is
	begin
		p_query.f_from := p_name;

	end set_from;

	procedure add_select(p_query in out t_query,p_name in varchar2, p_separator CHAR DEFAULT ',')
	is
	begin
		if p_query.f_select is null
		then
			p_query.f_select := p_name;
		else
			p_query.f_select := p_query.f_select || p_separator || p_name;
		end if;
	end add_select;
    
    function get_select(p_query in t_query)
    return varchar2 deterministic
    is
    begin
        return 'SELECT ' ||  p_query.f_select;
    end get_select;

	procedure add_from(p_query in out t_query,p_name in varchar2)
	is
	begin
		if p_query.f_from is null
		then
			STRING_UTILS_PKG.add_str_token(p_query.f_from, p_name,''); --p_query.f_from := p_name;
		else
            STRING_UTILS_PKG.add_str_token(p_query.f_from, p_name, ','); --p_query.f_from := p_query.f_from || ', ' || p_name;
		end if;
	end add_from;
    
    function get_from(p_query in t_query)
    return varchar2 deterministic
    is
    begin
        return ' FROM ' || p_query.f_from;    
    end get_from;

	procedure add_where(p_query in out t_query,p_name in varchar2, p_separator IN VARCHAR2)
	is
	begin
		if p_query.f_where is null
		then
            STRING_UTILS_PKG.add_str_token(p_query.f_where, '(' || p_name || ')','');
		else
            STRING_UTILS_PKG.add_str_token(p_query.f_where, '(' || p_name || ')', p_separator);
		end if;
	end add_where;
    
    function get_where(p_query in t_query)
    return varchar2 deterministic
    is
    begin
        return ' WHERE ' || p_query.f_where;
    end get_where;
    
    function get_where_in(p_query in out t_query, p_negate IN BOOLEAN DEFAULT FALSE)
    return varchar2 deterministic
    is
    begin
        error_pkg.assert(p_query.f_select is not null, 'NO LIST OF COLUMNS TO PERFORM OPERATION ON. PLEASE INVESTIGATE');
    
        sql_builder_pkg.add_where(p_query, p_query.f_select, ''); --format select to become where clause
        
        if p_negate
        then
            return get_where(p_query) || ' NOT IN ';    
        else
            return get_where(p_query) || ' IN ';    
        end if;
    end get_where_in;


	procedure add_group_by(p_query in out t_query,p_name in varchar2)
	is
	begin
		if p_query.f_group_by is null
		then
            STRING_UTILS_PKG.add_str_token(p_query.f_group_by,p_name, '');  --p_query.f_group_by := p_name;
		else
            STRING_UTILS_PKG.add_str_token(p_query.f_group_by,p_name, ',');  --p_query.f_group_by := p_query.f_group_by || ', ' || p_name;
		end if;

	end add_group_by; 


	procedure add_order_by(p_query in out t_query,p_name in varchar2)
	is
	begin
		if p_query.f_order_by is null
		then
			STRING_UTILS_PKG.add_str_token(p_query.f_order_by,p_name, '');   --p_query.f_order_by := p_name;
		else
            STRING_UTILS_PKG.add_str_token(p_query.f_order_by,p_name, ',');   --p_query.f_order_by := p_query.f_order_by || ', ' || p_name;
		end if;

	end add_order_by; 


	function get_sql(p_query in t_query,
					 p_include_where in boolean := true,
					 p_include_group_by in boolean := true,
					 p_include_order_by in boolean := true)
	return string_utils_pkg.st_max_pl_varchar2
	is
		l_sql_statement string_utils_pkg.st_max_pl_varchar2 := get_select(p_query) || ' ' || get_from(p_query);
	begin

		if p_query.f_where is not null and p_include_where
		then
			l_sql_statement := l_sql_statement || get_where(p_query);
		end if;

		if p_query.f_group_by is not null and p_include_group_by
		then
			l_sql_statement := l_sql_statement || ' group by ' || p_query.f_group_by;
		end if;

		if p_query.f_order_by is not null and p_include_order_by
		then
			l_sql_statement := l_sql_statement || ' order by ' || p_query.f_order_by;
		end if;

		return l_sql_statement;

	end get_sql;

end sql_builder_pkg;
