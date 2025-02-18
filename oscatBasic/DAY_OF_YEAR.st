FUNCTION DAY_OF_YEAR
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=117*)
    DAY_OF_YEAR := UDINT_TO_INT((DATE_TO_UDINT(IDATE) / UDINT#86400) MOD UDINT#1461);
    IF DAY_OF_YEAR > 729 THEN
    	IF DAY_OF_YEAR > 1095 THEN DAY_OF_YEAR := DAY_OF_YEAR - 1095; ELSE DAY_OF_YEAR := DAY_OF_YEAR - 729; END_IF
    ELSIF DAY_OF_YEAR > 364 THEN
    	DAY_OF_YEAR := DAY_OF_YEAR - 364;
    ELSE
    	DAY_OF_YEAR := DAY_OF_YEAR + 1;
    END_IF


    (*
    DAY_OF_YEAR := DWORD_TO_INT((DATE_TO_DWORD(IDATE) - DATE_TO_DWORD(YEAR_BEGIN(YEAR_OF_DATE(IDATE)))) / 86400) + 1;
    *)


    (* revivision history
    hm	4. aug. 2007		rev 1.0
    	original version

    hm	1. oct. 2007		rev 1.1
    	added compatibility to STEP7

    hm	4. jan. 2008		rev 1.2
    	changed code for better performance

    hm	7. oct. 2008		rev 1.3
    	changed name of function year to year_of_date

    hm	28. jan. 2011	rev 1.4
    	improved code
    *)
END_FUNCTION
