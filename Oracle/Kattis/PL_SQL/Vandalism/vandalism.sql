DECLARE
    type lkp_t is table of char(1);
    mstr lkp_t := lkp_t('U', 'A', 'P', 'C');

    ip varchar2(4) := 'UAC';

    ipList lkp_t := lkp_t();
    diffs lkp_t := lkp_t();

BEGIN
    for i in 1..length(ip)
    loop
        ipList.extend;
        ipList(ipList.last) := substr(ip, i, 1);
    end loop;

    diffs := mstr multiset except ipList;

    for i in diffs.first..diffs.last
    loop
        dbms_output.put_line(diffs(i));
    end loop;

END;
/
