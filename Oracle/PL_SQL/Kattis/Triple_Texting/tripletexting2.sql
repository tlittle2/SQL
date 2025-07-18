DECLARE
    subtype ipLength is varchar2(99);
    type t_arr is table of ipLength index by pls_integer;

    type c_arr is table of pls_integer index by ipLength;
    occur c_arr := c_arr();

    function processInput return t_arr is
        a t_arr := t_arr();
        const_split CONSTANT INTEGER := 3;
        ip ipLength := 'trevortrevertrevor';
        len integer := 1;
        maxlength integer := floor(length(ip)/const_split);
    begin
        for i in 1..const_split
        loop
            a(i) := substr(ip, len, maxlength);
            len := len + maxlength;
        end loop;
        return a;
    end processInput;

    procedure createOccurrenceArray(a IN t_arr, occurArray IN OUT c_arr) IS
    BEGIN
         for i in a.FIRST..a.LAST
         loop
             if not occurArray.EXISTS(a(i)) then --if current word from processInput array does not exists in occurrence array, add it
             occurArray(a(i)) := 1;
             else
             occurArray(a(i)) := occurArray(a(i)) + 1;
             end if;
         end loop;
    END createOccurrenceArray;

    function findAnswer(occurArray IN c_arr) return ipLength is
        tmpKey ipLength := occurArray.FIRST;
    begin
        while tmpKey is not null
        loop
            if occurArray(tmpKey) > 1
            then
                return tmpKey;
                exit;
            end if;
                
            tmpKey := occurArray.NEXT(tmpKey);
        end loop;
    end findAnswer;
	
BEGIN
    createOccurrenceArray(processInput, occur);
    dbms_output.put_line(findAnswer(occur));
END;
