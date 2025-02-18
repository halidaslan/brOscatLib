FUNCTION_BLOCK TN_SEND_ROWS
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=183*)
    (* Verbindung vorhanden und kein Datensenden aktiv *)
    IF (IP_C.C_STATE < BYTE#127 OR S_BUF.SIZE > UINT#0) THEN
    	RETURN; (* nein -> Baustein beenden *)
    END_IF

    (* aktuellen Schreibindex laden *)
    in_Write_Index := UINT_TO_INT(S_BUF.SIZE) - 1;

    (* aktuellen Schreibindex zwischenspeichern *)
    in_Write_Index_Backup := in_Write_Index;

    (* positive Flanke Connect on *)
    IF (IP_C.C_STATE = BYTE#254) OR (XUS_TN_SCREEN.bo_Clear_Screen) THEN

    	(* Clear-Screen Meldung rücksetzen *)
    	XUS_TN_SCREEN.bo_Clear_Screen := FALSE;

    	(* alle Zeilen für Update markieren *)
    	FOR in_Line_Count := INT#00 TO INT#23 DO
    		XUS_TN_SCREEN.bya_Line_Update[in_Line_Count] := TRUE;
    	END_FOR

    	(* ESC [0;30,40m  Reset Attributes + Black,Black *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#30; (* 0 *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#33; (* 3 *)

    	(* Einerstelle Farbe Foreground ausgeben *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := (SHR(XUS_TN_SCREEN.by_Clear_Screen_Attr,4) OR BYTE#16#30);

    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#34; (* 4 *)

    	(* Einerstelle Farbe Background ausgeben *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := ((XUS_TN_SCREEN.by_Clear_Screen_Attr AND BYTE#16#07) OR BYTE#16#30);

    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#6D; (* m *)

    	(* ESC[2J Clear screen and home cursor *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#32; (* 2 *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#4A; (* J *)

    	(* ESC [?7l Off *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#3F; (* ? *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#37; (* 7 *)
    	in_Write_Index := in_Write_Index + INT#1;
    	S_BUF.BUFFER[in_Write_Index] := BYTE#16#6C; (* l *)

    END_IF

    in_Last_Row_Index := INT#0;
    bo_Break_Loop := FALSE;
    in_Write_Stop := S_BUF_SIZE - 20;

    (* alle Zeilen durchlaufen *)
    FOR in_Line_Count := 0 TO 23 DO

    	in_Offset := in_Row_Count * INT#80;

    	(* prüfen ob Update einer Zeile notwendig ist bzw. nach Reconnect *)
    	IF (XUS_TN_SCREEN.bya_Line_Update[in_Row_Count] = TRUE) THEN

    		(* Schreib-Cursor positionieren *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)

    		(* Zehnerstelle Zeilennummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] :=
    		SHR(INT_TO_BCDC(in_Row_Count + INT#1),INT#4) OR BYTE#16#30;

    		(* Einerstelle Zeilennummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] :=
    		(INT_TO_BCDC(in_Row_Count + INT#1) AND BYTE#16#0F) OR BYTE#16#30;

    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#31; (* 1 *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#48; (* H *)

    		(* alle Spalten einer Zeile durchlaufen *)
    		FOR in_Col_Count := 0 TO 79 DO

    			(* aktuelle Farbe bestimmen *)
    			by_Cur_Color := XUS_TN_SCREEN.bya_COLOR[in_Offset];
    			IF (by_Cur_Color <> by_last_Color) OR (in_Col_Count = INT#00) THEN

    				(* Farbeinstellung: ANSI-Sequenz ESC[X;Y;Zm ausgeben *)
    				in_Write_Index := in_Write_Index + INT#1;
    				S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)

    				in_Write_Index := in_Write_Index + INT#1;
    				S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)

    				(* Farbeinstellung: dunkel oder Hell und blinken bestimmen *)

    					IF (((by_Cur_Color AND BYTE#2#10001000) XOR (by_last_Color AND BYTE#2#10001000)) <> BYTE#00) OR (in_Col_Count = 0) THEN

    						in_Write_Index := in_Write_Index + INT#1;
    						S_BUF.BUFFER[in_Write_Index] := BYTE#16#30; (* 0 *)
    						in_Write_Index := in_Write_Index + INT#1;
    						S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)

    						(* keine dunklen Farben gewünscht -> dann Bold & Bright *)
    						IF (by_Cur_Color AND BYTE#2#00001000) = BYTE#2#00000000 THEN

    							(* auf Bold & Btight Farben umstellen *)
    							in_Write_Index := in_Write_Index + INT#1;
    							S_BUF.BUFFER[in_Write_Index] := BYTE#16#31; (* 1 *) 
    							in_Write_Index := in_Write_Index + INT#1;
    							S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)

    						END_IF

    						(* blinkenden Farben gewünscht *)
    						IF (by_Cur_Color AND BYTE#2#10000000) = BYTE#2#10000000 THEN 

    							(* auf Bold & Bright Farben umstellen *)
    							in_Write_Index := in_Write_Index + INT#1;
    							S_BUF.BUFFER[in_Write_Index] := BYTE#16#35; (* 5 *) 
    							in_Write_Index := in_Write_Index + INT#1;
    							S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)

    						END_IF

    					END_IF

    					(* Zehnerstelle Farbe Foreground ausgeben *)
    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := BYTE#16#33; (* 3 *)

    					(* Einerstelle Farbe Foreground ausgeben *)
    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := ((SHR(by_Cur_Color,4) AND BYTE#2#00000111) OR BYTE#16#30);

    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)

    					(* Zehnerstelle Farbe Background ausgeben *)
    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := BYTE#16#34; (* 4 *)

    					(* Einerstelle Farbe Background ausgeben *)
    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := ((by_Cur_Color AND BYTE#2#00000111) OR BYTE#16#30); 

    					in_Write_Index := in_Write_Index + INT#1;
    					S_BUF.BUFFER[in_Write_Index] := BYTE#16#6D; (* m *)

    					(* neue Farbe als letzt verwendete speichern *)
    					by_last_Color := by_Cur_Color;

    				END_IF

    				(* Buffer Ende vorzeitig erreicht -> Ende *)
    				IF (in_Write_Index > in_Write_Stop) THEN

    					bo_Break_Loop := TRUE;
    					EXIT;

    				END_IF

    				(* ein TEXT-Zeichen von Screenbuffer in den Sendebuffer übertragen *)
    				in_Write_Index := in_Write_Index + INT#1;
    				S_BUF.BUFFER[in_Write_Index] := XUS_TN_SCREEN.bya_CHAR[in_Offset];

    				(* nächste Spalte anwählen *)
    				in_Offset := in_Offset + INT#01;
    			END_FOR

    			IF (bo_Break_Loop = TRUE) THEN;

    				(* Buffer Ende vorzeitig erreicht -> nur bis zur letzten kompletten Zeile uebertragen *)
    				in_Write_Index := in_Last_Row_Index;

    				EXIT;
    			END_IF

    			(* Buffer ist noch nicht voll -> neue Zeile ubernehmen *)
    			in_Last_Row_Index := in_Write_Index;
    			XUS_TN_SCREEN.bya_Line_Update[in_Row_Count] := FALSE;

    		END_IF

    		(* naechste Zeile adressieren *)
    		in_Row_Count := in_Row_Count + INT#01;

    		(* ab letzter Zeile wieder von vorne beginnen *)
    		IF (in_Row_Count > INT#23) THEN
    			in_Row_Count := INT#00;
    		END_IF
    		(*-----------------------------------------------*)


    	END_FOR

    	(* wenn in einen Update-Zyklus alle Zeilen auf einmal geschafft wurden *)
    	(* wird der Row_Count auf ersten Zeile gestellt *)
    	(* soll das hässliche Grafikflackern verhindern *)
    	(* ansonsten wird bei der letzen Zeile weitergemacht *)
    	IF (bo_Break_Loop = FALSE) THEN
    		in_Row_Count := INT#00;
    	END_IF

    	(* Edit-Cursor positionieren *)
    	IF (in_Write_Index <> in_Write_Index_Backup) THEN

    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#1B; (* ESC *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#5B; (* [ *)

    		(* Zehnerstelle Zeilennummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := SHR(INT_TO_BCDC(XUS_TN_SCREEN.in_Cursor_Y + 1),INT#4) OR BYTE#16#30;

    		(* Einerstelle Zeilennummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := (INT_TO_BCDC(XUS_TN_SCREEN.in_Cursor_Y + 1) AND BYTE#16#0F) OR BYTE#16#30;

    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#3B; (* ; *)

    		(* Zehnerstelle Spaltenummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := SHR(INT_TO_BCDC(XUS_TN_SCREEN.in_Cursor_X + 1),INT#4) OR BYTE#16#30;

    		(* Einerstelle Spaltennummer ausgeben *)
    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := (INT_TO_BCDC(XUS_TN_SCREEN.in_Cursor_X + 1) AND BYTE#16#0F) OR BYTE#16#30;

    		in_Write_Index := in_Write_Index + INT#1;
    		S_BUF.BUFFER[in_Write_Index] := BYTE#16#48; (* H *)

    END_IF

    (* aktuellen Schreibindex speichern -> Senden anstossen *)
    S_BUF.SIZE := INT_TO_UINT(in_Write_Index + 1);

    (* revision history
    ks	10. mai. 2010	rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
