DECLARE
   subtype extension_t is varchar2(10);
   word varchar2(100);
   extension extension_t;
   
   ans extension_t;
   
   function char_at(p_str in varchar2, p_idx in integer)
   return char
   is
   begin
       return substr(p_str, p_idx, 1);
   end char_at;
   
   procedure append(p_str in out nocopy varchar2, p_add in varchar2)
   is
   begin
       p_str := p_str || p_add;
   end;
   
      
BEGIN
    word := :x;
    for i in reverse 1..length(word)
    loop
       append(extension,char_at(word, i));
       if char_at(word, i) = '.'
       then
           exit;
        end if;
    end loop;
    
    for i in reverse 1..length(extension)
    loop
        append(ans ,char_at(extension, i));
    end loop;
    
    dbms_output.put_line(ans);
    
END;
/
