FUNCTION DST
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=121*)
    yr := YEAR_OF_DATE(DT_TO_DATE(UTC));
    ltc := DT_TO_UDINT(UTC);
    idate := DT_TO_UDINT(SET_DT(yr, 3, 31, 1, 0, 0));
    yr4 := SHR(5 * INT_TO_UDINT(yr), 2) + 1;
    DST := (idate - ((yr4 + 3) MOD 7) * 86400 <= ltc) AND (idate + (214 - (yr4) MOD 7) * 86400 > ltc);

    (*
    Equation used TO calculate the beginning OF European Summer TIME:
    Sunday (31 - (5*y/4 + 4) mod 7) March at 01.00 UTC
    (valid through 2099, courtesy of Robert H. van Gent, EC).

    European Summer Time ends (clocks go back) at 01.00 UTC on

        * 29 October 2006
        * 28 October 2007
        * 26 October 2008

    Equation used to calculate the end of European Summer Time:
    Sunday (31 - (5*y/4 + 1) mod 7) October at 01.00 UTC
    (validity AND credits as above).

    *)



    (* revision history
    hm	4. aug 2006	rev 1.0
    	original version

    hm	24. okt 2007	rev 1.1
    	deleted time_zone_offset input because DST is generally at 01:00 UTC and not mesz
    	uk starts 01:00 UTC and also greece

    hm	1. dec 2007	rev 1.2
    	changed code to improve performance

    hm	16. mar. 2008	rev 1.3
    	added type conversion to avoid warnings under codesys 3.0
    	code improvement for better performance

    hm	7. oct. 2008	rev 1.4
    	changed name of function year to year_of_date

    hm	24. jan. 2011	rev 1.5
    	improved performance
    *)


END_FUNCTION
