FUNCTION_BLOCK TIMER_1
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=60*)
    IF E THEN
    	STOP := TOD_TO_TIME(START) + DURATION;
    	IF STOP > T#24h THEN STOP := STOP - T#24h; END_IF
    	Q := TIMECHECK(DT_TO_TOD(DTI), START, TIME_TO_TOD(STOP)) AND (SHR(BYTE#128, DAY_OF_WEEK(DT_TO_DATE(DTI))) AND DAY) > BYTE#0;
    ELSE
    	Q := FALSE; (* clear output when E is not true *)
    END_IF


    (*
    1.12.2006 hm		rev 1.1
    	corrected an error with pulse width = 0.

    25.12.2006 hm		rev 1.2
    	corrected an error when timer overflows.

    14.apr 2007 hm		rev 1.3
    	corrected an error while while output would not go active when START year would be 1970.
    	increase accuracy by checking every 100ms
    	added init section to compensate for timer overflow

    15.9.2007 hm		rev 1.4
    	replaced Time() with T_PLC_MS for compatibility and performance reasons

    hm	1. okt 2007		rev 1.5
    	corrected an error while output would not stay active over midnight.

    hm	17. jan 2008	rev 1.6
    	New code with better performance  
    	Output is now only active during the time of DAY it is supposed to 
    	no pulse is generated at power up

    hm	7. oct. 2008	rev 1.7
    	changed function weekday to day_of_week

    hm	23. oct. 2008	rev 2.0
    	new code, added input E, now days can be selected by bits in byte DAY

    hm	6. nov. 2008	rev 2.1
    	added default for input EN and input DAY

    hm 16. dec 2009	rev 2.2
    	fixed a bug over midnight

    *)
END_FUNCTION_BLOCK
