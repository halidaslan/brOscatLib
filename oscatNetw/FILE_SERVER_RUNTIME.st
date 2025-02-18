FUNCTION_BLOCK FILE_SERVER_RUNTIME
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=154*)
    IF init = FALSE THEN
    	init := TRUE;
    	FSD.runtime.TIME_FILE_OPEN_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_CLOSE_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_READ_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_WRITE_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_TELL_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_SEEK_MIN := UDINT#99999999;
    	FSD.runtime.TIME_FILE_DELETE_MIN := UDINT#99999999;
    END_IF

    (* warten auf File_Server Befehl *)
    IF MODE = BYTE#0 THEN

    	(* neuen befehl erkannt *)
    	IF last_command = BYTE#0 AND COMMAND <> BYTE#0 THEN

    		(* read system time *)
    		start_tx := T_PLC_MS();

    	END_IF
    END_IF


    IF MODE = BYTE#1 THEN

    	(* read system time *)
    	stop_tx:=  T_PLC_MS();

    	runtime:= (stop_tx - start_tx);

    	CASE BYTE_TO_INT(COMMAND) OF

    	1:	FSD.runtime.TIME_FILE_OPEN_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_OPEN_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_OPEN_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_OPEN_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_OPEN_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	2:	FSD.runtime.TIME_FILE_CLOSE_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_CLOSE_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_CLOSE_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_CLOSE_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_CLOSE_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	3:	FSD.runtime.TIME_FILE_READ_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_READ_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_READ_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_READ_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_READ_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	4:	FSD.runtime.TIME_FILE_WRITE_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_WRITE_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_WRITE_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_WRITE_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_WRITE_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	5:	FSD.runtime.TIME_FILE_SEEK_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_SEEK_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_SEEK_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_SEEK_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_SEEK_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	6:	FSD.runtime.TIME_FILE_TELL_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_TELL_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_TELL_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_TELL_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_TELL_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	7:	FSD.runtime.TIME_FILE_DELETE_CUR := runtime; 			(* aktuelle laufzeit *)
    		IF FSD.runtime.TIME_FILE_DELETE_MAX < runtime THEN
    			FSD.runtime.TIME_FILE_DELETE_MAX := runtime;		(* neue max laufzeit *)
    		END_IF
    		IF FSD.runtime.TIME_FILE_DELETE_MIN > runtime THEN
    			FSD.runtime.TIME_FILE_DELETE_MIN := runtime;		(* neue min laufzeit *)
    		END_IF

    	END_CASE

    END_IF

    last_command := COMMAND;

    (* revision history

    ks	08. mar. 2016	rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
