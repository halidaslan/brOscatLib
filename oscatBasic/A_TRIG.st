FUNCTION_BLOCK A_TRIG
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=188*)
    D := IN - last_in;
    Q := ABS(D) > RES;
    IF Q THEN last_in := IN; END_IF
    D := IN - last_in;


    (* revision history

    hm 	16. jul. 2008	rev 1.0
    	original version released

    hm	25. oct. 2008	rev 1.1
    	code optimization
    	a_trig now also works for RES = 0

    *)
END_FUNCTION_BLOCK
