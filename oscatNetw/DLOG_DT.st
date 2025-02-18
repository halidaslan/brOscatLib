FUNCTION_BLOCK DLOG_DT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=50*)
    CASE X.ADD_COM OF

    01:	(* ADD INFO *)
    	X.ID_MAX := X.ID_MAX + USINT#1;
    	id := WORD#16#0D01; (* Quelltype DT , Zieltype STRING *)
    02:	(* ADD HEADER *)
    	X.UCB.D_STRING := COLUMN;
    	X.UCB.D_HEAD := id;
    	X.UCB.D_MODE := 1;
    	UCB(DATA:=X.UCB); (* Daten eintragen *)
    03:	(* ADD DATA *)
    	X.UCB.D_STRING := DT_TO_STRF(DTI:=X.DTI,MS:=0,FMT:=FMT,LANG:=0);
    	X.UCB.D_HEAD := id;
    	X.UCB.D_MODE := 1;
    	UCB(DATA:=X.UCB); (* Daten eintragen *)
    	delta_last := X.DTI;
    04:	(* ADD DATA REQ *)
    	IF DELTA <> UDINT#0 THEN
    		IF DT_TO_UDINT(X.DTI) >= (DT_TO_UDINT(delta_last) + DELTA) THEN
    			X.ADD_DATA_REQ := TRUE;
    			delta_last := X.DTI;
    		END_IF
    	END_IF
    END_CASE

    (* revision history
    ks	01. jan. 2011	rev 1.0
    	original version

    ks	17. may. 2011	rev 1.1
    	COLUMN STRING(40), DELTA

    ks	25. july.   2011	rev 1.2
    	neue head information

    ks	19. apr.   2012	rev 1.3
    	code neu überarbeitet
    *)
END_FUNCTION_BLOCK
