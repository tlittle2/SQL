DECLARE
    type t_arr is table of integer;
    nums t_arr := t_arr(5,3,1);

BEGIN
    if nums(1) + nums(2) = nums(3)
    then
        dbms_output.put_line('Possible');
    elsif nums(1) - nums(2) = nums(3) or nums(2) - nums(1) = nums(3)
    then
        dbms_output.put_line('Possible');
    elsif nums(1) * nums(2) = nums(3)
    then
        dbms_output.put_line('Possible');
    elsif nums(1) / nums(2) = nums(3) or nums(2) / nums(1) = nums(3)
    then
        dbms_output.put_line('Possible');
    else
        dbms_output.put_line('Impossible');
    end if;

END;
