DECLARE
    type arr_t is table of varchar2(4);
    arr1 arr_t;
    arr2 arr_t;

    subtype st_iptype is varchar2(4);
    
    ip1 st_iptype := '1111';
    ip2 st_iptype := '1234';

    procedure populateCollection(p_ipString IN VARCHAR2, p_collection IN OUT arr_t)
    is
    begin
        p_collection := arr_t();
        for i in 1..length(p_ipString)
        loop
            p_collection.EXTEND;
            p_collection(i):= substr(p_ipString, i, 1);
        end loop;
    end populateCollection;

    function answer(p_collection1 IN arr_t, p_collection2 IN arr_t)
    return INTEGER
    IS
        c integer:= 0;
    begin
        for i in 1..p_collection1.COUNT
        loop
            if p_collection1(i) <> p_collection2(i)
            then
                c:= c + 1;
            end if;
        end loop;
        
        return power(2,c);
    end answer;

BEGIN
    populateCollection(ip1, arr1);
    populateCollection(ip2, arr2);

    dbms_output.put_line(answer(arr1,arr2));
END;
