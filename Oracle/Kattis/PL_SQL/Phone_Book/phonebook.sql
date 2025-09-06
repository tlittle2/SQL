DECLARE
    phone_number_length constant integer := 20;
    ip varchar2(phone_number_length) := '+3912345';

    prefix_length constant integer := 3;
    country_code varchar2(prefix_length) := substr(ip, 1, prefix_length);

    digits varchar2(phone_number_length - prefix_length) := substr(ip, prefix_length + 1, length(ip));

BEGIN
    if country_code = '+39' and length(digits) in (9,10)
    then
        dbms_output.put_line('yes');
    else
        dbms_output.put_line('no');
    end if;


END;
/
