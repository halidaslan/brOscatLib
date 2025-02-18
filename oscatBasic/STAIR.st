FUNCTION STAIR
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=304*)
    IF D > 0.0 THEN
    	STAIR := DINT_TO_REAL(REAL_TO_DINT(X / D)) * D;
    ELSE
    	STAIR := X;
    END_IF



    (* revision history
    hm	28 jan 2007		rev 1.0
    	original version

    hm	27 dec 2007		rev 1.1
    	changed code for better performance

    hm	6. jan 2008		rev 1.2
    	further performance improvement

    hm	26. oct. 2008		rev 1.3
    	optimized code

    hm	10. mar. 2009	rev 1.4
    	real constants updated to new systax using dot

    *)
END_FUNCTION
