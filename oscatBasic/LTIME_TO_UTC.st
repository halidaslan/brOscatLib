FUNCTION LTIME_TO_UTC
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=128*)
    LTIME_TO_UTC := UDINT_TO_DT(DT_TO_UDINT(LOCAL_TIME) - INT_TO_UDINT(TIME_ZONE_OFFSET) * 60);
    IF DST THEN LTIME_TO_UTC := LTIME_TO_UTC - T#1h; END_IF

    (* revision history
    hm 5.7.2007		rev 1.0		
    	original version

    hm 5.11.2007		rev 1.1
    	replaced literal constant with variable because of error in möller ecp4 compiler

    hm	12.nov 2007	rev 1.2
    	changed Type of TIME_ZONE_OFFSET from time to int to allow for time zones with negative offset

    hm	8. dec 2007	rev 1.3
    	corrected a problem with TIME_ZONE_OFFSET

    hm	14. oct. 2008	rev 1.4
    	changed TIME_ZONE_OFFSET from int to real to allow for half hour offset

    hm	20. oct. 2006	rev 1.5
    	changed TIME_ZONE_OFFSET from Real to INT, now in Minutes

    hm	27. feb. 2009	rev 1.6
    	added type conversions to avoid warnings under codesys 3.0

    ks	13. nov. 2009	rev 1.7
    	corrected error in formula

    *)
END_FUNCTION
