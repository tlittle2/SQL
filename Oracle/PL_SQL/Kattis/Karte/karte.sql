DECLARE    
    type t_cardNumber is table of number;

    type t_arr is table of t_cardNumber index by varchar2(1);
	cards t_arr;

	type t_ansArr is table of varchar2(6);
	ansArr t_ansArr := t_ansArr();

	type t_cardsList is table of char(1);
	possibleCards t_cardsList := t_cardsList('P', 'K', 'H', 'T');

	ip varchar2(1000) := 'P01K02H03H04';

	greska constant varchar2(6) := 'GRESKA';

	procedure processInput(p_ipString IN VARCHAR2, p_collection IN OUT t_arr) is
        v_idxIdx number := 1;
    	const_sublength constant number :=3;
    	v_word varchar2(3);
    	v_key varchar2(1);
    	v_value varchar2(2);
    begin
        loop
        	if v_idxIdx > length(p_ipString) then
        		exit;
    		end if;

    		v_word := substr(p_ipString, v_idxIdx, const_sublength);
    		v_key := substr(v_word, 1,1);
    		v_value := to_number(substr(v_word, 2,2));
    
    		if NOT p_collection.EXISTS(v_key) then
                p_collection(v_key) := t_cardNumber();
            end if;

			p_collection(v_key).EXTEND;

			p_collection(v_key)(p_collection(v_key).COUNT) := v_value; --insert new key/value pair to the end of the list
    				
    		v_idxIdx:= v_idxIdx +const_sublength;
		end loop;
    end;

	procedure checkOtherCards(p_collection IN OUT t_arr) is 
		v_idx varchar2(1):= p_collection.FIRST;
    begin
        while v_idx is not null loop
        if v_idx not member of possibleCards then
        	p_collection(v_idx) := t_cardNumber(0);
        end if;
			v_idx := p_collection.NEXT(v_idx);
		end loop;
    end;


	procedure processCollection(p_collection IN t_arr, p_ans IN OUT t_ansArr) is
    v_idx varchar2(1) := cards.FIRST;
	distinctCards t_cardNumber;
	
	mx CONSTANT number := 13;

    begin
        while v_idx is not null loop
        	p_ans.EXTEND;
        	distinctCards := t_cardNumber();
            distinctCards := distinctCards multiset union distinct p_collection(v_idx);
			
			if distinctCards.COUNT < p_collection(v_idx).COUNT then
                p_ans(p_ans.COUNT) := greska;

			elsif p_collection(v_idx).EXISTS(0) then
                p_ans(p_ans.COUNT) := cast(mx as varchar2);
			else
                p_ans(p_ans.COUNT) := cast(mx - p_collection(v_idx).LAST as varchar2);

			end if;
			v_idx := p_collection.NEXT(v_idx);
    	end loop;
    end;

	procedure printCollection(p_collection in t_arr) is
        v_idx varchar2(1) := p_collection.FIRST;
    begin
        while v_idx is not null loop
		for i in p_collection(v_idx).FIRST..p_collection(v_idx).LAST loop
            dbms_output.put_line(v_idx || ' ' || p_collection(v_idx)(i));
        end loop;
        v_idx := p_collection.NEXT(v_idx);
    end loop;
    end;

BEGIN
    processInput(ip, cards);
	checkOtherCards(cards);
	printCollection(cards);
	processCollection(cards,ansArr);

	if greska member of ansArr then
        dbms_output.put_line(greska);
    else	
    	for i in ansArr.FIRST..ansArr.LAST LOOP
            dbms_output.put_line(ansArr(i));
        end loop;
	end if;

END;
