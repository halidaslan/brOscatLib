FUNCTION_BLOCK INI_PARSER_FILE
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=164*)
    IF RUN > 0 THEN

    	IF state = 0 THEN (* Auswertung neu beginnen *)
    		pv := ADR(VALUE);
    		pv := 0; (* VALUE = '' *)
    		pve := pv + INT_TO_DWORD(STRING_LENGTH);
    		pk := ADR(KEY);
    		pk := 0; (* KEY = '' *)
    		pke := pk + INT_TO_DWORD(STRING_LENGTH);

    		i := OFFSET;
    		RESULT := 0;
    		state := 5; (* Befehl in Arbeit (Busy) *)
    		step := 0; (* Auswertung neu beginnen *)

    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'IPF: Startindex: ~1';
    			LOG_CL.PRINTF[1] := UDINT_TO_STRING(i);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    	END_IF

    	watchdog(IN:=FALSE,PT:=T#1ms); (* Timer neustarten *)
    	watchdog.IN := TRUE;

    	WHILE (state = 5) DO (* Schleife solange kein Ergebnis *)

    		mode := 1;
    		FB(mode:=mode,FSD:=FSD,PT:=PT,FILENAME:=FILENAME,POS:=i );
    		e:=FB.ERROR;
    		c:=FB.DATA;

    		eof := i + 1 = FSD.FILE_SIZE; (* End of File *)

    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'IPF: mode: ~1, error: ~2 , >~7<>~3< ~4 step ~5 index ~6';
    			LOG_CL.PRINTF[1] := BYTE_TO_STRING(mode);
    			LOG_CL.PRINTF[2] := BYTE_TO_STRING(e);
    			LOG_CL.PRINTF[3] := BYTE_TO_STRING(c);
    			LOG_CL.PRINTF[4] := BOOL_TO_STRING(eof);
    			LOG_CL.PRINTF[5] := INT_TO_STRING(step);
    			LOG_CL.PRINTF[6] := UDINT_TO_STRING(i);
    			LOG_CL.PRINTF[7] := CHR_TO_STRING(c);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    		watchdog(); (* Timer aktualisieren *)

    		IF mode > 0 OR watchdog.Q THEN (* Baustein noch aktiv, oder watchdog ausgelöst *)
    			state := 5;
    			EXIT;
    		ELSIF e > 0 THEN (* File_error oder kein weiteres zeichen vorhanden *)
    			state := 10; (* nichts gefunden - Daten-Ende erreicht *)
    			EXIT;
    		ELSE

    			k_add := 0;
    			v_add := 0;

    			CASE step OF

    			0: (* noch kein Modus erkannt *)
    				IF c = 91 THEN (* mit "[" vergleichen *)
    					step := 200; (* Modus für Section aktivieren *)
    				ELSIF c = 59 OR c = 35 THEN (* mit ";" und '#' vergleichen *)
    					step := 100; (* Modus für Kommentar aktivieren *)
    				ELSIF c > 32 THEN (* KEY erkannt *)
    					k_add := c; (* Zeichen ablegen *)
    					step := 300; (* KEY auswertung starten *)
    				END_IF
    			100: (* Kommentar erkannt -> Zeilenende suchen *)
    				IF c < 32 THEN (* prüfe auf Steuerzeichen *)
    					state  := 3; (* Beenden -> Kommentar wurde gefunden *)
    				END_IF
    			200: (* Sections-start erkannt -> Sectionsende suchen *)
    				IF c = 93 THEN (* mit "]" vergleichen *)
    					IF pk > ADR(KEY) > 0 THEN (* innerhalb von [] muss sich mindestens ein Zeichen befinden *)
    						state  := 1; (* Beenden -> Section wurde gefunden *)
    					ELSE
    						pk := ADR(KEY);
    						pk := 0; (* KEY = '' *)
    						step := 0; (* fehlerhafte Section-Zeile vorhanden -> weitersuchen *)
    					END_IF
    				ELSIF c < 32 OR eof THEN (* Steuerzeichen - fehlerhafte Section-Zeile -> weitersuchen *)
    					pk := ADR(KEY);
    					pk := 0; (* KEY = '' *)
    					step := 0;
    				ELSE
    					k_add := c; (* Zeichen ablegen *)
    				END_IF
    			300: (* Beginn: KEY erkannt -> Name auswerten *)
    				IF c < 32 THEN (* Steuerzeichen - fehlerhafte KEY-Zeile -> weitersuchen *)
    					pk := ADR(KEY);
    					pk := 0; (* KEY = '' *)
    					step := 0;
    				ELSIF c = 61 THEN (* prüfe auf '=' *)
    					step := 330;
    				ELSE
    					k_add := c; (* Zeichen ablegen *)
    				END_IF
    			330: (* KeyValue beginn suchen *)
    				IF c < 32 THEN (* Steuerzeichen  *)
    					state := 2; (* KEY ohne VALUE gefunden *)
    				ELSIF eof THEN
    					state := 2; (* KEY ohne VALUE gefunden *)
    					v_add := c; (* Zeichen ablegen *)
    				ELSE
    					v_add := c; (* Zeichen ablegen *)
    					step := 350;
    				END_IF
    			350: (* KeyValue Ende suchen *)
    				IF c < 32 THEN (* Steuerzeichen *)
    					state := 2; (* KEY gefunden *)
    				ELSIF eof THEN
    					v_add := c; (* Zeichen ablegen *)
    					state := 2; (* KEY gefunden *)
    				ELSE
    					v_add := c; (* Zeichen ablegen *)
    				END_IF
    			END_CASE

    			IF v_add > 0  AND pv < pve THEN (* Zeichen zu VALUE-String hinzufügen *)
    				pv := v_add; (* Zeichen eintragen *)
    				pv := pv + 1;
    				pv := 0; (* String-Terminierung eintragen *)
    			END_IF

    			IF k_add > 0 AND pk < pke THEN (* Zeichen zu KEY-String hinzufügen *)
    				pk := k_add; (* Zeichen eintragen *)
    				pk := pk + 1;
    				pk := 0; (* String-Terminierung eintragen *)
    			END_IF

    			i := i + 1; (* Datenzeiger erhöhen *)

    		END_IF
    	END_WHILE

    	CASE state OF
    	01:	(* Section gefunden *)
    		IF RUN = 1 OR RUN = 3 THEN (* Section vorgewählt oder alles rückmelden *)
    			IF KEY = STR OR LEN(STR) = 0 THEN (* mit gesuchter Section vergleichen oder keine Section vorgegeben *)
    				RESULT := 1; (* Section gefunden *)
    				OFFSET := i; (* OFFSET uebernehmen *)
    				RUN := 0;
    				state := 0;
    			END_IF
    		ELSE
    			pk := ADR(KEY);
    			pk := 0; (* KEY = '' *)
    			RESULT := 11; (* KEY nicht gefunden , Section-Ende - OFFSET nicht verändern *)
    			RUN := 0;
    			state := 0;
    		END_IF
    	02:	(* KEY gefunden *)
    		IF RUN = 2 OR RUN = 3 THEN (* KEY vorgewählt oder alles rückmelden *)
    			IF KEY = STR OR LEN(STR) = 0 THEN (* mit gesuchten KEY vergleichen *)
    				RESULT := 2; (* KEY gefunden *)
    				OFFSET := i; (* OFFSET uebernehmen *)
    				RUN := 0;
    				state := 0;
    			END_IF
    		END_IF
    	03:	(* Kommenar gefunden *)
    		OFFSET := i; (* OFFSET uebernehmen *)
    		state := 0;

    	05:	RESULT := 5; (* in Arbeit *)

    	10:	(* Indexüberschreitung - Bufferende *)
    		RESULT := 10; (* nichts gefunden - Datenende erreicht *)
    		OFFSET := i; (* OFFSET uebernehmen *)
    		RUN := 0;
    		state := 0;
    	END_CASE

    	(*####################  DEBUG-MESSAGE  ###################################*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'IPF: intern RESULT ~1 , state ~2, step ~3 , OFFSET ~4, RUN ~5';
    		LOG_CL.PRINTF[1] := BYTE_TO_STRING(RESULT);
    		LOG_CL.PRINTF[2] := BYTE_TO_STRING(state);
    		LOG_CL.PRINTF[3] := INT_TO_STRING(step);
    		LOG_CL.PRINTF[4] := UDINT_TO_STRING(OFFSET);
    		LOG_CL.PRINTF[5] := BYTE_TO_STRING(RUN);
    		LOG_MSG();
    	END_IF*)
    	(*########################################################################*)

    END_IF

    (*####################  DEBUG-MESSAGE  ###################################*)
    (*IF _debug_enable THEN
    	IF step_last <> step THEN
    		LOG_CL.NEW_MSG := 'IPB: step: ~1';
    		LOG_CL.PRINTF[1]  := INT_TO_STRING(step);
    		LOG_MSG();
    	END_IF
    	step_last := step;
    END_IF*)
    (*########################################################################*)

    (* revision history
    ks	23. sep. 2010	rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
