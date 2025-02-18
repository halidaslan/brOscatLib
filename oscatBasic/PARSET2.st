FUNCTION_BLOCK PARSET2
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=467*)
    (* init sequence *)
    IF NOT init THEN
    	init := TRUE;
    	Pset(TC:=TC, X01:=X01, X02:=X02, X03:=X03, X04:=X04, X11:=X11, X12:=X12, X13:=X13, X14:=X14, X21:=X21, X22:=X22, X23:=X23, X24:=X24, X31:=X31, X32:=X32, X33:=X33, X34:=X34);
    END_IF
    IF ABS(X) < L1 THEN
    	Pset(A0 := FALSE, A1 := FALSE);
    ELSIF ABS(X) < L2 THEN
    	Pset(A0 := TRUE, A1 := FALSE);
    ELSIF ABS(X) < L3 THEN
    	Pset(A0 := FALSE, A1 := TRUE);
    ELSE
    	Pset(A0 := TRUE, A1 := TRUE);
    END_IF
    P1 := Pset.P1;
    P2 := Pset.P2;
    P3 := Pset.P3;
    P4 := Pset.P4;

    (* revision history
    hm		3.11.2007		rev 1.0
    	original version

    *)

END_FUNCTION_BLOCK
