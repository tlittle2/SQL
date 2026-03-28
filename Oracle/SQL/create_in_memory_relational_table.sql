with function get_sep
return char deterministic
is
begin
    return '|';
end get_sep;

function get_concat_ws_default
return char deterministic
is
begin
    return ' ';
end get_concat_ws_default;

function concat_ws (p_sep     in varchar2,
                    p_value1  in varchar2,
                    p_value2  in varchar2  := get_concat_ws_default,
                    p_value3  in varchar2  := get_concat_ws_default)
return varchar2
is
    l_num integer;
    l_values sys.odcivarchar2list := sys.odcivarchar2list(p_value1, p_value2, p_value3);
    l_returnvalue varchar2(32767);
    g_concat_ws_default char(1) := get_concat_ws_default;
begin
    select nvl(count(column_value), 0)
    into l_num
    from table(l_values)
    where column_value is null;
    
    if l_num >= 1
    then
        return null;
    end if;
    
    for i in l_values.first..l_values.last
    loop
        if trim(l_values(i)) <> g_concat_ws_default
        then
            l_returnvalue := l_returnvalue || l_values(i) || p_sep;
        end if;
    end loop;
    
    l_returnvalue := substr(l_returnvalue, 1, length(l_returnvalue) - length(p_sep));
    return l_returnvalue;
end concat_ws;


function get_field(p_str in varchar2, p_occurrence in number)
return varchar2
is
   l_regex varchar2(10) := '[^'|| get_sep ||']+';
begin
    return regexp_substr(p_str, l_regex, 1, p_occurrence);
end get_field;


function get_control_table
return sys.odcivarchar2list
is
    type ct_record is record(
       filename varchar2(200),
       instance number(1,0),
       time varchar2(8)
    );
    type t_tab is table of ct_record;

    l_tab t_tab := t_tab(
    ct_record('file1', 1, '00:00:00'),
    ct_record('file1', 2, '02:00:00'),
    ct_record('file2', 1, '05:00:00')
    );
    
    l_returnvalue sys.odcivarchar2list := sys.odcivarchar2list();

begin
     for i in 1..l_tab.count
     loop
         l_returnvalue.extend;
         l_returnvalue(l_returnvalue.count) := concat_ws(get_sep, l_tab(i).filename, l_tab(i).instance, l_tab(i).time);
     end loop;
     
     return l_returnvalue;
end get_control_table;

select get_field(column_value, 1)
, get_field(column_value, 2)
, get_field(column_value, 3)
from table(get_control_table);
/






--############################################################################
with function get_sep
return char deterministic
is
begin
    return '|';
end get_sep;

function get_field(p_str in varchar2, p_occurrence in number)
return varchar2
is
   l_regex varchar2(10) := '[^'|| get_sep ||']+';
begin
    return regexp_substr(p_str, l_regex, 1, p_occurrence);
end get_field;

function set_delimited_string(p_filename in varchar2, p_instance number, p_time varchar2)
return varchar2
is
begin
    return p_filename || get_sep || p_instance || get_sep || p_time;
 
end set_delimited_string;

function get_control_table
return sys.odcivarchar2list
is
    type ct_record is record(
       filename varchar2(200),
       instance number(1,0),
       time varchar2(8)
    );
    
    type t_tab is table of ct_record;
    
    l_tab t_tab := t_tab(
    ct_record('file1', 1, '00:00:00'),
    ct_record('file1', 2, '02:00:00'),
    ct_record('file2', 1, '05:00:00')
    );
    
    l_returnvalue sys.odcivarchar2list := sys.odcivarchar2list();
begin
     for i in 1..l_tab.count
     loop
         l_returnvalue.extend;
         l_returnvalue(l_returnvalue.count) := set_delimited_string(l_tab(i).filename, l_tab(i).instance, l_tab(i).time);
     end loop;
     
     return l_returnvalue;
end get_control_table;

select get_field(column_value, 1)
, get_field(column_value, 2)
, get_field(column_value, 3)
from table(get_control_table);
/
