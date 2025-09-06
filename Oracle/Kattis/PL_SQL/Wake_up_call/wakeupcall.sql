DECLARE
    type collection_t is table of integer;
    
    lst1 collection_t := collection_t(10,17,3,8,3);
    sum1 integer;
    lst2 collection_t := collection_t(3,9,15,6,8);
    sum2 integer;

    ans varchar2(8);

    function getSum(p_collection collection_t)
    return integer
    is
        l_returnvalue integer := 0;
    begin
        for i in p_collection.first..p_collection.last
        loop
            l_returnvalue := l_returnvalue + p_collection(i);
        end loop;

        return l_returnvalue;
    end getSum;

BEGIN
    sum1 := getSum(lst1);
    sum2 := getSum(lst2);

    case
        when sum1 = sum2 then ans := 'Oh no';
        when sum1 > sum2 then ans := 'Button 1';
        else ans := 'Button 2';
    end case;

    dbms_output.put_line(ans);
END;
/
