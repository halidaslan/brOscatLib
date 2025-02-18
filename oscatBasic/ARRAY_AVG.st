FUNCTION ARRAY_AVG
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=76*)
    stop := SHR(SIZE,2)-1;
    ARRAY_AVG := PT[0];
    FOR i := 1 TO stop DO
    	ARRAY_AVG := ARRAY_AVG + PT[i];
    END_FOR
    ARRAY_AVG := ARRAY_AVG / UINT_TO_REAL(stop + 1);


    (* revision history
    hm	2. oct 2007		rev 1.0
    	original version

    hm	12. dec 2007	rev 1.1
    	chaged code for better performance

    hm	16. mar. 2008	rev 1.2
    	changed input SIZE to uint

    hm	10. mar. 2009	rev 1.3
    	added type conversion for compatibility reasons
    *)
END_FUNCTION
