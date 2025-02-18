FUNCTION_BLOCK SRAMP
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=470*)
    (* read the system_time in microseconds *)
    cycle_time();

    (* assure range of inputs *)
    A_UP := MAX(0.0, A_UP);
    A_DN := MIN(0.0, A_DN);
    VU_MAX := MAX(0.0, VU_MAX);
    VD_MAX := MIN(0.0, VD_MAX);

    (* calculate the output offset *)
    IF RST OR NOT init THEN
    	init := TRUE;
    	Y := 0.0;
    	V := 0.0;
    ELSIF X = Y THEN
    	V := 0.0;
    ELSIF X > Y THEN
    	(* output is too low >> ramp up and brake at the end *)
    	(* accelerate the speed and limit to VU_MAX *)
    	V := MIN(V + A_UP * cycle_time.TC, VU_MAX);
    	(* calculate the max speed to be able to brake and select the lowest *)
    	V := MIN(SQRT((Y-X) * 2.0 * A_DN), V);
    	(* calculate the output and obey limits *)
    	Y := LIMIT(LIMIT_LOW, Y + MIN(V * cycle_time.TC, X-Y), LIMIT_HIGH);
    ELSIF X < Y THEN
    	(* output is too high >> ramp dn and brake at the end *)
    	(* accelerate the speed and limit to VD_MAX *)
    	V := MAX(V + A_DN * cycle_time.TC, VD_MAX);
    	(* calculate the max speed to be able to brake and select the lowest *)
    	V := MAX(-SQRT((Y-X) * 2.0 * A_UP), V);
    	(* calculate the output and obey limits *)
    	Y := LIMIT(LIMIT_LOW, Y + MAX(V * cycle_time.TC, X-Y), LIMIT_HIGH);
    END_IF


    (* revision history
    hm	13. mar. 2008	rev 1.0
    	original version

    hm	11. mar. 2009	rev 1.1
    	real constants updated to new systax using dot																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											

    *)



END_FUNCTION_BLOCK
