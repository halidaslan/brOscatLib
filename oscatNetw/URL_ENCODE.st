FUNCTION URL_ENCODE
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=87*)
    pt_in  := ADR(IN);
    pt_out := ADR(URL_ENCODE);

    (* scan the input string and convert unallowed characters *)
    pos_in := 1;
    stop := LEN(IN);
    FOR pos_out := 1 TO 250 DO
    	IF pos_in > stop THEN
    		EXIT;
    	ELSIF IS_URLCHR(pt_in[pos_in]) THEN
    		pt_out[pos_out] := pt_in[pos_in];
    		(* increment IN by 1 *)
    		pos_in := pos_in + 1;
    	ELSE
    		(* cannot fit 3 digits, exit *)
    		IF pos_out > 248 THEN EXIT; END_IF
    		(* invalid character that needs to be converted *)
    		pt_out[pos_out] := 37;    (* start with % sign *)
    		pos_out := pos_out + 1;
    		(* need to add the two hex digits *)
    		tb := SHR(pt_in[pos_in],4);
    		IF tb > 9 THEN
    			pt_out[pos_out] := tb + 55;
    		ELSE
    			pt_out[pos_out] := tb + 48;
    		END_IF
    		pos_out := pos_out + 1;
    		tb := pt_in[pos_in] AND 16#0F;
    		IF tb > 9 THEN
    			pt_out[pos_out] := tb + 55;
    		ELSE
    			pt_out[pos_out] := tb + 48;
    		END_IF
    		(* increment IN and out because out has to move 3 digits *)
    		pos_in := pos_in + 1;
    	END_IF
    END_FOR

    (* terminate the output string *)
    pt_out[pos_out] := 0;

    (* revision history
    hm	27. apr. 2008	rev 1.0
    	original version

    ks	10. mai. 2008	rev 1.1
    	stringlength 250

    *)
END_FUNCTION
