FUNCTION MONTH_OF_DATE
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=130*)
    MONTH_OF_DATE := DAY_OF_YEAR(IDATE);
    IF MONTH_OF_DATE < 32 THEN
    	MONTH_OF_DATE := 1;
    ELSIF LEAP_OF_DATE(IDATE) THEN
    	MONTH_OF_DATE := (MONTH_OF_DATE * 53 + 1668) / 1623;
    ELSE
    	MONTH_OF_DATE := (MONTH_OF_DATE * 53 + 1700) / 1620;
    END_IF


    (* code for rev 1.2
    MONTH_OF_DATE := DAY_OF_YEAR(IDATE);
    IF LEAP_OF_DATE(IDATE) THEN
    	CASE MONTH_OF_DATE OF
    		1..31 	:	MONTH_OF_DATE := 1;
    		32..60	:	MONTH_OF_DATE := 2;
    		61..91	:	MONTH_OF_DATE := 3;
    		92..121 :	MONTH_OF_DATE := 4;
    		122..152:	MONTH_OF_DATE := 5;
    		153..182:	MONTH_OF_DATE := 6;
    		183..213:	MONTH_OF_DATE := 7;
    		214..244:	MONTH_OF_DATE := 8;
    		245..274:	MONTH_OF_DATE := 9;
    		275..305:	MONTH_OF_DATE := 10;
    		306..335:	MONTH_OF_DATE := 11;
    		336..366:	MONTH_OF_DATE := 12;
    	END_CASE
    ELSE
    	CASE MONTH_OF_DATE OF
    		1..31 	:	MONTH_OF_DATE := 1;
    		32..59	:	MONTH_OF_DATE := 2;
    		60..90	:	MONTH_OF_DATE := 3;
    		91..120 :	MONTH_OF_DATE := 4;
    		121..151:	MONTH_OF_DATE := 5;
    		152..181:	MONTH_OF_DATE := 6;
    		182..212:	MONTH_OF_DATE := 7;
    		213..243:	MONTH_OF_DATE := 8;
    		244..273:	MONTH_OF_DATE := 9;
    		274..304:	MONTH_OF_DATE := 10;
    		305..334:	MONTH_OF_DATE := 11;
    		335..365:	MONTH_OF_DATE := 12;
    	END_CASE
    END_IF
    *)


    (* revision history
    hm	1. aug 2006	rev 1.0
    	original version	

    hm	1. okt 2007	rev 1.1
    	replaced old code (string conversion) with mathematics
    	the execution time is now multiple times faster.

    hm	7. oct. 2008	rev 1.2
    	changed name of function from month to MONTH_OF_DATE

    hm	27. mar. 2009	rev 1.3
    	new improved code

    *)
END_FUNCTION
