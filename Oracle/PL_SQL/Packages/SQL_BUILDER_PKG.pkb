create or replace PACKAGE BODY SQL_BUILDER_PKG
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

	procedure add_where(p_query in out t_query,p_name in varchar2, and_or IN BOOLEAN DEFAULT TRUE)
	is
	begin
		if p_query.f_where is null
		then
            STRING_UTILS_PKG.add_str_token(p_query.f_where, '(' || p_name || ')','');    --p_query.f_where := '(' || p_name || ')';
		else
            if and_or then
                STRING_UTILS_PKG.add_str_token(p_query.f_where,' and (' || p_name || ')', '');  --p_query.f_where := p_query.f_where || ' and (' || p_name || ')';
            else
                STRING_UTILS_PKG.add_str_token(p_query.f_where,' or (' || p_name || ')', '');   --p_query.f_where := p_query.f_where || ' or (' || p_name || ')';
            end if;
            
		end if;
	end add_where;


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
		l_sql_statement string_utils_pkg.st_max_pl_varchar2 := 'select ' || p_query.f_select || ' from ' || p_query.f_from;
	begin

		if p_query.f_where is not null and p_include_where
		then
			l_sql_statement := l_sql_statement || ' where ' || p_query.f_where;
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

END SQL_BUILDER_PKG;
