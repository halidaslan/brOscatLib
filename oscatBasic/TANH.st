FUNCTION TANH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=69*)
    IF X > 20.0 THEN
    	TANH := 1.0;
    ELSIF X < -20.0 THEN
    	TANH := -1.0;
    ELSE
    	TANH := 1.0 - 2.0 / (EXP(2.0 * X) + 1.0);
    END_IF


    (* revision hisdtory
    hm		12.1.2007		rev 1.0
    	original version

    hm		1.12.2007		rev 1.1
    	changed code to improve performance

    hm		10. mar 2008	rev 1.2
    	corrected an error in formula
    	extended range of valid inputs to +/- INV

    hm 10. mar. 2009	rev 1.3
    	real constants updated to new systax using dot																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											

    *)
END_FUNCTION
