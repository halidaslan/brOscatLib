FUNCTION DEW_RH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=435*)
    DEW_RH := LIMIT(0.0, VC / DEW_CON(1.0, T), 100.0);

    (* code before rev 1.1
    DEW_RH := VC / dew_con(100,T) * 100;
    IF DEW_RH > 100 THEN DEW_RH := 100; END_IF
    *)

    (* revision history
    hm	29. apr 2007	rev 1.0
    	original version

    hm	2. 12. 2007	rev 1.1
    	new code for better performance

    hm	13. mar. 2009	rev 1.2
    	real constants updated to new systax using dot

    *)
END_FUNCTION
