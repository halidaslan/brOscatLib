FUNCTION DAYS_IN_MONTH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=119*)
    DAYS_IN_MONTH := DAY_OF_YEAR(IDATE);
    IF LEAP_OF_DATE(IDATE) THEN
    	CASE DAYS_IN_MONTH OF
    		32..60	:	DAYS_IN_MONTH := 29;
    		92..121 :	DAYS_IN_MONTH := 30;
    		153..182:	DAYS_IN_MONTH := 30;
    		245..274:	DAYS_IN_MONTH := 30;
    		306..335:	DAYS_IN_MONTH := 30;
    	ELSE
    		DAYS_IN_MONTH := 31;
    	END_CASE
    ELSE
    	CASE DAYS_IN_MONTH OF
    		32..59	:	DAYS_IN_MONTH := 28;
    		91..120 :	DAYS_IN_MONTH := 30;
    		152..181:	DAYS_IN_MONTH := 30;
    		244..273:	DAYS_IN_MONTH := 30;
    		305..334:	DAYS_IN_MONTH := 30;
    	ELSE
    		DAYS_IN_MONTH := 31;
    	END_CASE
    END_IF



    (* revision history
    hm	27. mar. 2009		rev 1.0
    	original version

    *)
END_FUNCTION
