DECLARE
    type lkp_t is table of varchar2(32767);
    
    --ip lkp_t := lkp_t('C', 'C++', 'c', 'c#');
    --ip lkp_t := lkp_t('MySQL', 'MySql');
    --ip lkp_t := lkp_t('cryptography', 'blockchain', 'Artificial intelligence', 'Machine-Learning', 'Linux');
    lst lkp_t := lkp_t();

BEGIN
    for i in ip.first..ip.last
    loop
        ip(i) := upper(replace(ip(i), '-', ' '));
    end loop;

    lst := lst multiset union distinct ip;

    dbms_output.put_line(lst.count);
    
END;
/
