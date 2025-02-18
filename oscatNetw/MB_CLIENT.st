FUNCTION_BLOCK MB_CLIENT
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=112*)
    CASE state OF

    00: (* Warten auf DELAY-Time *)
    	ton_1(IN:=ENABLE,PT:=DELAY);

    	IF ton_1.Q OR DELAY = T#0s THEN
    		ton_1(IN:=FALSE);
    		state := 20;
    		ip_state := BYTE#1; (* Anmelden *)
    	END_IF

    20: (* Bei IP_Control anmelden *)
    	IF ip_state = BYTE#3 THEN
    		(* IP Datenverkehr einrichten *)
    		IP_C.C_PORT := WORD#0; (* Port von IP_CONTROL verwenden *)
    		IP_C.C_IP := DWORD#0; (* IP von IP_CONTROL verwenden *)
    		IP_C.C_MODE := BOOL_TO_BYTE(UDP); (* Mode: 0=TCP+ACTIVE+IP , 1=UDP+ACTIVE+IP *)
    		IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    		IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    		IP_C.R_OBSERVE := TRUE; (* Empfangsueberwachung *)
    		ERROR := DWORD#00; (* letzten Fehler rücksetzen *)

    		CASE FC OF
    		(******************************************************************)
    		1..2: (* 0x01 Read Coil Status , 0x02 Read Input Status *)
    			IF R_POINTS <= 2000 THEN
    				w_tmp := INT_TO_WORD(R_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(R_POINTS);
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				S_BUF.SIZE := UINT#12;
    				response :=	WORD_TO_INT(SHR(INT_TO_WORD(R_POINTS + 7),3));
    				comp := 7;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		3..4: (* 0x03 Read Holding Registers , 0x04 Read Input Registers *)
    			IF R_POINTS <= 125 THEN
    				w_tmp := INT_TO_WORD(R_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(R_POINTS);
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				S_BUF.SIZE := UINT#12;
    				response :=	WORD_TO_INT(SHL(w_tmp,1));
    				comp := 7;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		5:	(* 0x05 Force Single Coil *)
    			IF W_DATA_ADR <= DATA_SIZE THEN
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				S_BUF.BUFFER[10] := SEL((DATA[W_DATA_ADR] AND SHL(WORD#1,W_DATA_BITPOS))>WORD#00,BYTE#16#00,BYTE#16#FF);
    				S_BUF.BUFFER[11] := BYTE#00;
    				S_BUF.SIZE := UINT#12;
    				response := 3;
    				comp := 11;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		6:	(* 0x06 Preset Single Register *)
    			IF W_DATA_ADR <= DATA_SIZE THEN
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := DATA[W_DATA_ADR];
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				S_BUF.SIZE := UINT#12;
    				response := 3;
    				comp := 11;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		15:	(* 0x0F Force Multiple Coils *)
    			IF (WORD_TO_INT(SHR(INT_TO_WORD(WORD_TO_INT(SHL(INT_TO_WORD(W_DATA_ADR),4)) + W_POINTS + W_DATA_BITPOS + 15),4)) <= DATA_SIZE) AND W_POINTS <= 1968 THEN
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(W_POINTS);
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				S_BUF.BUFFER[12] := WORD_TO_BYTE(SHR(INT_TO_WORD(W_POINTS + 7),3));

    				w_mask := SHL(WORD#1,W_DATA_BITPOS);
    				bit_pos := 0;
    				w_tmp := WORD#00;
    				idx1 := 12;
    				idx2 := W_DATA_ADR;
    				FOR i := 1 TO W_POINTS DO
    					w_tmp :=BIT_LOAD_W(w_tmp,(DATA[idx2] AND w_mask) > WORD#0,bit_pos);
    					bit_pos := bit_pos + 1;
    					IF bit_pos > 7 OR i=W_POINTS THEN
    						bit_pos := 0;
    						idx1 := idx1 + 1;
    						S_BUF.BUFFER[idx1] := WORD_TO_BYTE(w_tmp);
    						w_tmp := WORD#0;
    					END_IF
    					w_mask := ROL(w_mask,1);
    					IF w_mask = WORD#1 THEN
    						idx2 := idx2 +1;
    					END_IF
    				END_FOR
    				S_BUF.SIZE := INT_TO_UINT(idx1 + 1);
    				response := 3;
    				comp := 11;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		16:	(* 0x10 Write Multiple Registers *)
    			IF W_DATA_ADR + W_POINTS <= DATA_SIZE AND W_POINTS <= 123 THEN
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(W_POINTS);
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				S_BUF.BUFFER[12] := SHL(S_BUF.BUFFER[11],1);
    			
    				idx1 := 11;
    				count := W_DATA_ADR + W_POINTS - 1;
    				FOR i := W_DATA_ADR TO count DO
    					idx1 := idx1 + 2;
    					idx2 := idx1 + 1; (* zweiter index für pcworx notwendig ! *)
    					w_tmp := DATA[i];
    					S_BUF.BUFFER[idx1] := WORD_TO_BYTE(SHR(w_tmp,8));
    					S_BUF.BUFFER[idx2] := WORD_TO_BYTE(w_tmp);
    				END_FOR

    				S_BUF.SIZE := INT_TO_UINT(idx2 + 1);
    				response := 3;
    				comp := 11;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		22:	(* 0x16 mask Write Register *)
    			IF W_DATA_ADR + 2 <= DATA_SIZE THEN
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				idx1 := W_DATA_ADR;
    				w_tmp := DATA[idx1];
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);
    				idx1 := idx1 +1;
    				w_tmp := DATA[idx1];
    				S_BUF.BUFFER[12] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[13] := WORD_TO_BYTE(w_tmp);

    				S_BUF.SIZE := UINT#14;
    				response := 5;
    				comp := 13;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)
    		23:	(* 0x17 Read/Write Multible Registers *)
    			IF W_DATA_ADR + W_POINTS <= DATA_SIZE AND W_POINTS <= 121 AND R_POINTS <= 125 THEN
    				idx1 := 15;
    				count := W_DATA_ADR + W_POINTS - 1;
    				FOR i := W_DATA_ADR TO count DO
    					idx1 := idx1 + 2;
    					idx2 := idx1 + 1; (* zweiter index für pcworx notwendig ! *)
    					w_tmp := DATA[i];
    					S_BUF.BUFFER[idx1] := WORD_TO_BYTE(SHR(w_tmp,8));
    					S_BUF.BUFFER[idx2] := WORD_TO_BYTE(w_tmp);
    				END_FOR

    				(* WRITE *)
    				w_tmp := INT_TO_WORD(W_ADDR);
    				S_BUF.BUFFER[12] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[13] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(W_POINTS);
    				S_BUF.BUFFER[14] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[15] := WORD_TO_BYTE(w_tmp);
    				S_BUF.BUFFER[16] := SHL(S_BUF.BUFFER[15],1);

    				(* READ *)
    				w_tmp := INT_TO_WORD(R_ADDR);
    				S_BUF.BUFFER[08] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[09] := WORD_TO_BYTE(w_tmp);
    				w_tmp := INT_TO_WORD(R_POINTS);
    				S_BUF.BUFFER[10] := WORD_TO_BYTE(SHR(w_tmp,8));
    				S_BUF.BUFFER[11] := WORD_TO_BYTE(w_tmp);

    				S_BUF.SIZE := INT_TO_UINT(idx2 + 1);
    				response := WORD_TO_INT(SHL(w_tmp,1));
    				comp := 7;
    			ELSE
    				ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    			END_IF
    		(******************************************************************)

    		ELSE
    			ERROR := DWORD#00000001; (* ILLEGAL FUNCTION *)
    		END_CASE

    		(* Daten senden *)
    		IF ERROR = DWORD#00 THEN
    			transaction_id := transaction_id + 1;
    			w_tmp := UINT_TO_WORD(S_BUF.SIZE - UINT#6);
    			(* ---- H E A D E R --------------------------------------------------------------- *)
    			S_BUF.BUFFER[0] := ip_id; (* TRANSACTION-ID HI-Byte *)
    			S_BUF.BUFFER[1] := INT_TO_BYTE(transaction_id); (* TRANSACTION-ID LO-Byte *)
    			S_BUF.BUFFER[2] := BYTE#00; (* PROTOKOLL-ID HI-Byte *)
    			S_BUF.BUFFER[3] := BYTE#00; (* PROTOKOLL-ID LO-Byte *)
    			S_BUF.BUFFER[4] := WORD_TO_BYTE(SHR(w_tmp,8)); (* Laenge HI-Byte *)
    			S_BUF.BUFFER[5] := WORD_TO_BYTE(w_tmp); (* Laenge LO-Byte *)
    			S_BUF.BUFFER[6] := UNIT_ID; (* UNIT *)
    			S_BUF.BUFFER[7] := INT_TO_BYTE(FC); (* FUNCTION-CODE *)
    			(*----- END OF HEADER --------------------------------------------------------------*)
    			R_BUF.SIZE := UINT#0; (* Empfangsbuffer löschen *)
    			state := 30; (* wait for response *)
    		ELSE
    			ip_state := BYTE#4; (* Abmelden *)
    			state := 00;
    		END_IF
    	END_IF

    30: (* response *)
    	IF IP_C.ERROR <> DWORD#00 THEN
    		ERROR := IP_C.ERROR;
    		ip_state := BYTE#4; (* Abmelden *)
    		state := 00;
    	ELSIF S_BUF.SIZE = UINT#0 AND R_BUF.SIZE > UINT#0 THEN
    		(* erwartete länge in sendebuffer nachträglich eintragen um vergleich zu ermöglichen *)
    		w_tmp := INT_TO_WORD(response + 3);
    		S_BUF.BUFFER[4] := WORD_TO_BYTE(SHR(w_tmp,8));
    		S_BUF.BUFFER[5] := WORD_TO_BYTE(w_tmp);

    		FOR i := 0 TO comp DO
    			IF S_BUF.BUFFER[i] <> R_BUF.BUFFER[i] THEN EXIT; END_IF
    		END_FOR

    		IF R_BUF.SIZE >= UINT#9 AND R_BUF.BUFFER[7] > BYTE#128 THEN  (* Bit 7 = ERROR Message *)
    			ERROR := BYTE_TO_DWORD(R_BUF.BUFFER[8]);
    			ip_state := BYTE#4; (* Abmelden *)
    			state := 00;
    		ELSIF R_BUF.SIZE = INT_TO_UINT(response + 9) AND i > comp THEN
    			mask := SHL(DWORD#1,FC);
    			(* READ_COILS, READ_INPUT_DISCRETES *)
    			IF (mask AND DWORD#2#00000000_00000000_00000000_00000110) > DWORD#0 THEN (* FC 1,2 *)
    				IF WORD_TO_INT(SHR(INT_TO_WORD(WORD_TO_INT(SHL(INT_TO_WORD(R_DATA_ADR),4)) + R_POINTS + R_DATA_BITPOS + 15),4)) <= DATA_SIZE THEN
    					b_mask := BYTE#1;
    					idx1 := 09;
    					idx2 := R_DATA_ADR;
    					bit_pos := R_DATA_BITPOS;
    					FOR i := 1 TO R_POINTS DO
    						DATA[idx2]:=BIT_LOAD_W(DATA[idx2],(R_BUF.BUFFER[idx1] AND b_mask) > BYTE#0,bit_pos);
    						bit_pos := bit_pos + 1;
    						IF bit_pos > 15 THEN
    							idx2 := idx2 + 1;
    							bit_pos := 0;
    						END_IF
    						b_mask := ROL(b_mask,1);
    						IF b_mask = BYTE#1 THEN
    							idx1 := idx1 + 1;
    						END_IF
    					END_FOR
    				ELSE
    					ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    				END_IF

    			(* READ_MULTIPLE_REGISTERS, READ_INPUT_REGISTERS, READ_WRITE_REGISTERS *)
    			ELSIF (mask AND DWORD#2#00000000_10000000_00000000_00011000) > DWORD#0 THEN (* FC 3,4,23 *)
    				IF R_DATA_ADR + R_POINTS <= DATA_SIZE THEN
    					stop := R_DATA_ADR + R_POINTS -1 ;
    					idx1 := 07;
    					FOR i := R_DATA_ADR TO stop DO
    						idx1 := idx1 + 2;
    						idx2 := idx1 + 1;
    						DATA[i] := WORD_OF_BYTE(R_BUF.BUFFER[idx1],R_BUF.BUFFER[idx2]);
    					END_FOR
    				ELSE
    					ERROR := DWORD#2; (* ILLEGAL DATA ADDRESS *)
    				END_IF
    			ELSIF (mask AND DWORD#2#11111111_00111110_01111111_10000001) > DWORD#0 THEN (* ILLEGAL FUNCTION CODE ? *)
    				ERROR := DWORD#1; (* ILLEGAL FUNCTION *)
    			END_IF
    		ELSE
    			ERROR := DWORD#3; (* ILLEGAL DATA VALUE *)
    		END_IF

    		ip_state := BYTE#4; (* Abmelden *)
    		state := 00;
    		R_BUF.SIZE := UINT#0;

    	END_IF

    END_CASE

    (* ip_fifo *)
    ip_fifo(FIFO:=IP_C.FIFO,state:=ip_state,ID:=ip_id);
    BUSY := ip_state = BYTE#3;

    (* revision history
    ks	05. jan. 2009	rev 1.0
    	original version

    ks	28. jan. 2009	rev 1.1
    	network_buffer_short verwendet  

    ks	20. oct. 2009	rev 1.2
    Networkbuffer und Buffer-funktionen auf Basis 0

    *)
END_FUNCTION_BLOCK
