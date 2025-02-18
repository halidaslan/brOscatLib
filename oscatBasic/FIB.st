FUNCTION FIB
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=50*)
    IF X < 0 OR X > 46 THEN
    	FIB := -1;
    ELSIF X < 2 THEN
    	FIB := X;
    	RETURN;
    ELSE
    	(* the fibonacci number is the sum of the two suceeding fibonaci numbers *)
    	(* we store the numbers alternatively in t1 and t2 depending on pt *)
    	t2 := 1;
    	WHILE X > 3 DO
    		X := X-2;
    		t1 := t1 + t2;
    		t2 := t1 + t2;
    	END_WHILE
    	IF X > 2 THEN t1 := t1 + t2; END_IF
    	FIB := t1 + t2;
    END_IF

    (* alternative code for very big numbers

    IF X < 31 THEN
    	FIB := 0.4472136 * (expn(1.618034,X) - expn(-0.618034,X));
    ELSE
    	FIB := 0.4472133 * expn(1.618034,X);
    END_IF

    *)

    (* revision history
    hm		27. dec 2007	rev 1.0
    	original version

    hm		2. jan 2008	rev 1.1
    	deleted unused variable pt

    hm		10. mar 2008	rev 1.2
    	changed output to dint instead of real

    hm		26. mar. 2008	rev 1.3
    	function now returns -1 for input < 0 or > 46

    *)
END_FUNCTION
