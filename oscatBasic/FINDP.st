FUNCTION FINDP
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=159*)
    ls := LEN(STR);
    lx := LEN(SRC);
    IF ls < lx OR lx = 0 THEN RETURN; END_IF
    stp := ls - lx + 1;
    FOR i := MAX(POS,1) TO stp DO
    	IF MID(STR,lx,i) = SRC THEN
    		FINDP := i;
    		RETURN;
    	END_IF
    END_FOR
    FINDP := 0;

    (* revision histroy
    hm	4. feb. 2008	rev 1.0
    	original release

    hm	29. feb 2008	rev 1.1
    	ADDED MAX(POS,1) in loop initialization

    hm	29. mar. 2008	rev 1.2
    	changed STRING to STRING(STRING_LENGTH)
    *)	

END_FUNCTION
