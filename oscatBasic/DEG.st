FUNCTION DEG
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=46*)
    DEG := MODR(57.29577951308232 * RAD, 360.0);

    (* revision history
    hm	4. aug 2006	rev 1.0
    	original version

    hm 16. oct 2007	rev 1.1
    	added modr statement which prohibits DEG to become bigger than 360

    hm	10. mar. 2009	rev 1.2
    	real constants updated to new systax using dot
    *)
END_FUNCTION
