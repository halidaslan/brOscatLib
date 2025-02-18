FUNCTION_BLOCK LOG_VIEWPORT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=111*)
    (* Scroll Button verarbeiten *)
    IF LV.MOVE_TO_X <> 0 THEN
    	CASE LV.MOVE_TO_X OF
    	30000: pos := 1 ; (* älteste Meldung anzeigen *)
    	30001: pos := LC.SIZE; (* neueste Meldung anzeigen *)
    	30002: pos := pos + LV.count; (* eine Seite nach unten blättern -> Richtung neuere Nachrichten *)
    	30003: pos := pos - LV.count; (* eine Seite nach oben blättern -> Richtung ältere Nachrichten *)
    	ELSE
    		pos := pos + LV.MOVE_TO_X;
    	END_CASE
    	update_pos := TRUE;
    	LV.MOVE_TO_X := 0;
    END_IF

    IF (LV.UPDATE_COUNT <> LC.UPDATE_COUNT) OR update_pos THEN (* Aktualisierung überwachen *)
    	LV.UPDATE := TRUE;
    	LV.UPDATE_COUNT := LC.UPDATE_COUNT;
    	update_pos := FALSE;

    	(* pos prüfen und übernehmen *)
    	IF LC.RING_MODE THEN
    		pos := LIMIT(1,pos,LC.SIZE - LV.count + 1);
    	ELSE
    		IF LC.idx > LV.count THEN
    			pos := LIMIT(1,pos,LC.idx - LV.count + 1);
    		ELSE
    			pos := 1;
    		END_IF
    	END_IF

    	(* idxBasis berechnen *)
    	base := LC.idx - pos - LV.count + 1;
    	IF LC.RING_MODE THEN 
    		(* Anzeige im Ringpuffermodus *)
    		FOR count:= 1 TO LV.count DO
    			idx := base + count;
    			IF idx < 1 THEN
    				idx := idx + LC.SIZE;
    			END_IF
    			LV.LINE_ARRAY[count] := idx;
    		END_FOR
    	ELSE
    		(* Anzeige im Normalmodus *)
    		FOR count:= 1 TO LV.count DO
    			idx := base + count;
    			IF idx < 1 THEN
    				(* Leere Zeile ausgeben *)
    				LV.LINE_ARRAY[count] := 0;
    			ELSE
    				LV.LINE_ARRAY[count] := idx;
    			END_IF
    		END_FOR
    	END_IF
    END_IF

    (* revision history
    ks	01. mai 2010	rev 1.0
    	original version

    ks	05. mai 2012	rev 1.1
    	Fehler im Ringmodus

    *)
END_FUNCTION_BLOCK
