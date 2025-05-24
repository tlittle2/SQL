DECLARE
	type t_cardNumber is table of number;

	subtype st_keylength is varchar2(1);
	type t_arr is table of t_cardNumber index by st_keylength;
	cards t_arr;

	subtype st_ansLength is varchar2(6);
	type t_ansArr is table of st_ansLength;
	ansArr t_ansArr := t_ansArr();
	
	greska constant st_ansLength := 'GRESKA';

	type t_cardsList is table of st_keylength;
	possibleCards t_cardsList := t_cardsList('P', 'K', 'H', 'T');

	ip varchar2(1000) := 'H02H10P11H02'; --user input

	procedure processInput(p_ipString IN VARCHAR2, p_collection IN OUT t_arr)
	is
	        v_Idx number := 1;
	    	const_sublength constant number :=3;
	    	v_word varchar2(3);
	    	v_key st_keylength;
	    	v_value varchar2(2);
    	begin
        	loop
			if v_Idx > length(p_ipString)
			then
				exit;
	    		end if;
	
	    		v_word := substr(p_ipString, v_Idx, const_sublength);
	    		v_key := substr(v_word, 1,1);
	    		v_value := to_number(substr(v_word, 2,2));
	    
	    		if NOT p_collection.EXISTS(v_key)
			then
				p_collection(v_key) := t_cardNumber();
	            	end if;
			
			p_collection(v_key).EXTEND;
	
			p_collection(v_key)(p_collection(v_key).COUNT) := v_value; --insert new key/value pair to the end of the list
	    				
	    		v_Idx:= v_Idx +const_sublength;
		
		end loop;
    	end;

	procedure checkOtherCards(p_collection IN OUT t_arr)
	is 
		v_idx st_keylength:= p_collection.FIRST;
    	begin
        	while v_idx is not null
		loop
			if v_idx not member of possibleCards then --if this card is not in the list of possible cards, add new collection with a sole value of 0
        			p_collection(v_idx) := t_cardNumber(0);
        		end if;
			v_idx := p_collection.NEXT(v_idx);
		end loop;
    	end;


	procedure processCollection(p_collection IN t_arr, p_ans IN OUT t_ansArr)
	is
		v_idx st_keylength := p_collection.FIRST;
		distinctCards t_cardNumber;
		mx CONSTANT number := 13;
	begin
        	while v_idx is not null
		loop
			p_ans.EXTEND;
            		distinctCards := t_cardNumber() multiset union distinct p_collection(v_idx); -- get the distinct values out of the nested table
			
			if distinctCards.COUNT < p_collection(v_idx).COUNT
			then
                		p_ans(p_ans.COUNT) := greska;
			
			elsif p_collection(v_idx).EXISTS(0)
			then
                		p_ans(p_ans.COUNT) := cast(mx as varchar2);
			
			else
                		p_ans(p_ans.COUNT) := cast(mx - p_collection(v_idx).LAST as varchar2);
			end if;
			
			v_idx := p_collection.NEXT(v_idx);
    		
		end loop;
    	end;

	procedure printInputCollection(p_collection in t_arr)
	is
		v_idx st_keylength := p_collection.FIRST;
    	begin
	        while v_idx is not null
		loop
			for i in p_collection(v_idx).FIRST..p_collection(v_idx).LAST
			loop
				dbms_output.put_line(v_idx || ' ' || p_collection(v_idx)(i));
	        	end loop;

        		v_idx := p_collection.NEXT(v_idx);
    		end loop;
	end;

	procedure printAns(p_answerCollection in t_ansArr)
	is
	begin
        	if greska member of p_answerCollection then
        		dbms_output.put_line(greska);
        	else	
	        	for i in p_answerCollection.FIRST..p_answerCollection.LAST
			LOOP
	                	dbms_output.put_line(p_answerCollection(i));
	            	end loop;
    		end if;
    	end;

BEGIN
	processInput(ip, cards);
	checkOtherCards(cards);
	--printInputCollection(cards);
	processCollection(cards,ansArr);
	printAns(ansArr);
END;
