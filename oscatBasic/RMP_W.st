FUNCTION_BLOCK RMP_W
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=267*)
    (* generate ramp *)
    rmp(DIR := UP, E := E, TR := PT, RMP := OUT);

    (* SET or reset operation *)
    IF RST THEN
    	OUT := 0;
    ELSIF SET THEN
    	OUT := 65535;
    END_IF

    (* checks for outputs stable and reset or SET BUSY flag *)
    LOW := OUT = 0;
    HIGH := OUT = 65535;
    BUSY := NOT (LOW OR HIGH) AND E;


    (* revision history:

    hm 4.10.2006		rev 1.1
    	added the BUSY output which signals that the ramp is running.

    hm 22.1.2007		rev 1.2
    	deleted unused variable step

    hm	17.9.2007		rev 1.3
    	replaced time() with t_plc_ms() for compatibility reasons

    hm	28. sep 2007	rev 1.4
    	added outputs on and off
    	BUSY is now disabled while en is false
    	new coding for higher accuracy and performance

    hm	5. oct 2007	rev 1.5
    	added statements to allow for PT to be t#0s output jumps to max or min immediately

    hm	2. dec 2007	rev 1.6
    	corrected an error in calculation of step response

    hm	25. dec 2007	rev 1.7
    	corrected an error while step response was too slow for fast rise times

    hm	16. oct. 2008	rev 1.8
    	improved performance

    hm	18. oct. 2008	rev 1.9
    	renamed inout EN to E for compatibility reasons

    hm	23. oct. 2008	rev 2.0
    	new code using _RMP_W
    *)

END_FUNCTION_BLOCK
