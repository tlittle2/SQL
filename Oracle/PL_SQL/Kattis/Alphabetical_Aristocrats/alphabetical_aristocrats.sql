DECLARE
    subtype nameLength_st is VARCHAR2(50);
    type names_ip_t is table of nameLength_st;

    --names_ip names_ip_t := names_ip_t('van der Steen' ,'fakederSteenOfficial' ,'Groot Koerkamp' ,'Bakker' ,'van den Hecken the Younger' ,'de Waal' ,'vant Hek');
    names_ip names_ip_t := names_ip_t('var Emreis' ,'an Gleanna' ,'Terzieff Godefroy' ,'aep Ceallach' ,'of Rivia');

    type output_t is table of nameLength_st index by nameLength_st;
    ans output_t;

    l_index nameLength_st;

BEGIN
    for i in names_ip.FIRST..names_ip.LAST
    LOOP
        --first letter that is uppercase to the end of the string is the key, the whole name is the value
        ans(substr(names_ip(i), regexp_instr(names_ip(i), '[A-Z]'))) := names_ip(i); 
    END LOOP;

    l_index := ans.FIRST;
    while l_index is not null
    LOOP
        dbms_output.put_line(ans(l_index));
        l_index := ans.NEXT(l_index);
    END LOOP;

END;
