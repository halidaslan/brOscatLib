FUNCTION_BLOCK CSV_PARSER_BUF
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=147*)
    IF RUN > 0 THEN
    	IF state = 0 THEN (* Auswertung neu beginnen *)

    		pv := ADR(VALUE);
    		pv := 0; (* VALUE = '' *)
    		pve := pv + INT_TO_DWORD(STRING_LENGTH);
    		i := UDINT_TO_INT(OFFSET);
    		size := UINT_TO_INT(PT.size) - 1;
    		RESULT := 0;
    		state := 5; (* Befehl in Arbeit (Busy) *)
    		step := 0; (* Auswertung neu beginnen *)

    		(* ---------------- Debug-Message -----------------------*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'CPF: Startindex: ~1';
    			LOG_CL.PRINTF[1] := INT_TO_STRING(i);
    			LOG_MSG();
    		END_IF*)
    		(* -----------------------------------------------------------------*)

    	END_IF

    	watchdog(IN:=FALSE,PT:=T#1ms); (* Timer neustarten *)
    	watchdog.IN := TRUE;

    	WHILE (state = 5) DO (* Schleife solange kein Ergebnis *)

    		watchdog(); (* Timer aktualisieren *)

    		IF watchdog.Q THEN (* watchdog ausgelöst *)
    			state := 5;
    			EXIT;
    		ELSIF i > size THEN (* kein weiteres zeichen vorhanden *)
    			state := 10; (* nichts gefunden - Daten-Ende erreicht *)
    			EXIT;
    		ELSE

    			c := PT.BUFFER[i]; (* neues Zeichen aus Buffer lesen *)
    			eof := i + 1 = PT.size; (* End of File *)

    			v_add := 0;

    			IF c = SEP THEN (* Neues Element erkannt *)
    				state := 1;
    				x := TRUE;
    			ELSIF c >= 32 THEN (* Element erkannt *)
    				v_add := c; (* Zeichen ablegen *)
    				IF eof THEN
    					state := 2; (* Element und Zeilenende erkannt *)
    				ELSE
    					x := TRUE;
    				END_IF
    			ELSE
    				IF x THEN
    					state := 2; (* Element und Zeilenende erkannt *)
    					x := FALSE;
    				END_IF
    			END_IF

    			IF v_add > 0  AND pv < pve THEN (* Zeichen zu VALUE-String hinzufügen *)
    				pv := v_add; (* Zeichen eintragen *)
    				pv := pv + 1;
    				pv := 0; (* String-Terminierung eintragen *)
    			END_IF

    			i := i + 1; (* Datenzeiger erhöhen *)

    		END_IF
    	END_WHILE

    	CASE state OF
    	01:	(* Element gefunden *)
    		RESULT := 1; (* Element gefunden *)
    		OFFSET := i; (* OFFSET uebernehmen *)
    		RUN := 0;
    		state := 0;
    	02:	(* Element gefunden *)
    		RESULT := 2; (* Element und Zeilenende erkannt *)
    		OFFSET := i; (* OFFSET uebernehmen *)
    		RUN := 0;
    		state := 0;

    	05:	RESULT := 5; (* in Arbeit *)

    	10:	(* Indexüberschreitung - Bufferende *)
    		RESULT := 10; (* nichts gefunden - Datenende erreicht *)
    		OFFSET := i; (* OFFSET uebernehmen *)
    		RUN := 0;
    		state := 0;
    	END_CASE

    	(* ---------------- Debug-Message -----------------------*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'CPF: intern RESULT ~1 , state ~2, step ~3 , OFFSET ~4, RUN ~5';
    		LOG_CL.PRINTF[1] := BYTE_TO_STRING(RESULT);
    		LOG_CL.PRINTF[2] := BYTE_TO_STRING(state);
    		LOG_CL.PRINTF[3] := INT_TO_STRING(step);
    		LOG_CL.PRINTF[4] := UDINT_TO_STRING(OFFSET);
    		LOG_CL.PRINTF[5] := BYTE_TO_STRING(RUN);
    		LOG_MSG();
    	END_IF*)
    	(* -----------------------------------------------------------------*)

    END_IF

    (* ---------------- Debug-Message -----------------------*)
    (*IF _debug_enable THEN
    	IF step_last <> step THEN
    		LOG_CL.NEW_MSG := 'IPB: step: ~1';
    		LOG_CL.PRINTF[1]  := INT_TO_STRING(step);
    		LOG_MSG();
    	END_IF
    	step_last := step;
    END_IF*)
    (* -----------------------------------------------------------------*)

    (* revision history
    ks	01. oct. 2010	rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
