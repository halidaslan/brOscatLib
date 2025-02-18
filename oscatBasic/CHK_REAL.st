FUNCTION CHK_REAL
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=217*)
    pt ACCESS ADR(X);				(* move real to dword, real_to_dword does not work becasze it treats dword as a number on many systems *)
    tmp := ROL(pt,1);			(* rotate left foir easy checking, sign will be at lease significant digit *)
    IF DWORD_TO_UDINT(tmp) < 16#FF000000 THEN
    	CHK_REAL := 16#00;		(* normalized and denormalized numbers *)
    ELSIF tmp = 16#FF000000 THEN
    	CHK_REAL := 16#20;		(* X is +infinity see IEEE754 *)
    ELSIF tmp = 16#FF000001 THEN
    	CHK_REAL := 16#40;		(* X is -infinity see IEEE754 *)
    ELSE
    	CHK_REAL := 16#80;		(* X is NAN see IEEE754 *)
    END_IF


    (* revision history
    hm	 20. jan. 2011	rev 1.0
    	original version

    *)
END_FUNCTION
