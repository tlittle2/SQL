create type t_str_array as table of varchar2(4000); --whatever the max length allowed for DDL is
/

create type t_date_array as table of date;
/

create type t_num_array as table of number;
/
