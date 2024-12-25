DECLARE
  sentence varchar(100):= 'Im not suspicious, Eh?';

BEGIN
    if substr(sentence, -3) = 'eh?' then
		dbms_output.put_line('Canadian!');
    else
    	dbms_output.put_line('Imposter!');
    end if;

END;
