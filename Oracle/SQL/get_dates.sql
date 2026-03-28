with function get_dates(p_start_date in date, p_end_date in date)
return sys.ODCIDateList
is
    l_returnvalue sys.ODCIDateList := sys.ODCIDateList();
begin
    for i in 0..p_end_date-p_start_date
    loop
        l_returnvalue.extend;
        l_returnvalue(l_returnvalue.count) := p_start_date + i;
    end loop;
    return l_returnvalue;
end;

select * from
table(get_dates(sysdate, sysdate + 7));
/

