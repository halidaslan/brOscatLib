FUNCTION ARRAY_TREND
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=81*)
    stop := SHR(SIZE,2)-1;
    stop2 := SHR(stop,1);
    FOR i := 0 TO stop2 DO x := x - PT[i]; END_FOR
    IF EVEN(UINT_TO_INT(stop)) THEN
    	FOR i := stop2 TO stop DO x := x + PT[i]; END_FOR
    ELSE
    	FOR i := stop2 + 1 TO stop DO x := x + PT[i]; END_FOR
    END_IF
    ARRAY_TREND := x / UINT_TO_REAL(stop2 + 1);

    (* revision history
    hm	2 oct 2007	rev 1.0
    	original version

    hm	12 dec 2007	rev 1.1
    	changed code for better performance

    hm	16. mar. 2008	rev 1.2
    	changed type of input SIZE to uint

    hm	10. mar. 2009	rev 1.3
    	added type conversions for compatibility reasons
    *)
END_FUNCTION
