FUNCTION_BLOCK SNTP_SERVER
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=128*)
    (* Domain Name System (query) *)
    tx := T_PLC_MS(); (* read system time *)

    CASE state OF

    00: (* Warten auf Freigabe *)
    	IF ENABLE THEN
    		state := 10;
    		ip_state := BYTE#1; (* Anmelden *)
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
          			LOG_CL.NEW_MSG := 'SNTP_SERVER: S00 START';
          			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)
    	END_IF

    10: (* Bei IP_Control anmelden und auf freigabe warten *)
    	IF ip_state = BYTE#3 THEN
    		(* IP Datenverkehr einrichten *)
    		IP_C.C_PORT := WORD#123; (* Portnummer eintragen *)
    		IP_C.C_IP := DWORD#00; (* IP eintragen *)
    		IP_C.C_MODE := BYTE#5; (* Mode: UDP+PASSIV+PORT *)
    		IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    		IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    		IP_C.R_OBSERVE := FALSE; (* Datenempfang ueberwachen *)
    		S_BUF.SIZE := UINT#0; (* Sendelänge eintragen *)
    		R_BUF.SIZE := UINT#0; (* Empfangslänge rücksetzen *)
    		state := 20;
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
          			LOG_CL.NEW_MSG := 'SNTP_SERVER: S10 INIT';
          			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)
    	END_IF
    20:
    	IF R_BUF.SIZE > UINT#0 THEN
    		state := 20;
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
          			LOG_CL.NEW_MSG := 'SNTP_SERVER: S20 REQUEST - Size: ~1';
          			LOG_CL.PRINTF[1] := UINT_TO_STRING(R_BUF.SIZE);
          			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)
    		(* empfangenes Telegramm mit 00 auffüllen , wenn zu kurz ! und Sendebuffer mit 00 vorbelegen *)
    		FOR i := 0 TO 47 DO
    			IF INT_TO_UINT(i) > R_BUF.SIZE - 1 THEN
    				R_BUF.BUFFER[i] := BYTE#00;
    			END_IF
    			S_BUF.BUFFER[i] := BYTE#00;
    		END_FOR

    		R_BUF.SIZE := UINT#0;

    		(* Sendedaten aufbereiten *)
    		S_BUF.BUFFER[0] := BYTE#2#11100; (* Flags: NO WARNING, NTP VERSION 3 , SERVER *)
    		S_BUF.BUFFER[1] := STRATUM; (* Peer Clock STRATUM: *)
    		S_BUF.BUFFER[2] := BYTE#10; (* Peer Polling Intervall 2 hoch 10 = 1024 sek. *)
    		S_BUF.BUFFER[3] := BYTE#16#FB; (* Peer Clock Precision: -5 = -31,25ms *)

    		(* Umrechnung SNTP Timestamp Base 1900-01-01 = Unix 1970-01-01 + 2208988800 sekunden *)
    		timestamp_int := DT_TO_DWORD(UDT) + DWORD#2208988800;

    		(* Sekundenanteile sind als 32 Bit Fractal dargestellt *)
    		(* nur mit veringerte Auflösung berechnen 1/65535 -> Highword verwenden *)
    		(* Berechnung des Sekundenanteils: XMS * 65535 / 1000 *)
    		timestamp_sek := DINT_TO_DWORD(DWORD_TO_DINT(SHL(INT_TO_DWORD(XMS),16))/DINT#1000);

    		ts_b := BYTE_OF_DWORD(timestamp_int,3); (* Timestamp Byte 3 *)
    		S_BUF.BUFFER[16] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[32] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[40] := ts_b; (* Transmit  Timestamp *)

    		ts_b := BYTE_OF_DWORD(timestamp_int,2); (* Timestamp Byte 2 *)
    		S_BUF.BUFFER[17] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[33] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[41] := ts_b; (* Transmit  Timestamp *)

    		ts_b := BYTE_OF_DWORD(timestamp_int,1); (* Timestamp Byte 1 *)
    		S_BUF.BUFFER[18] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[34] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[42] := ts_b; (* Transmit  Timestamp *)

    		ts_b := BYTE_OF_DWORD(timestamp_int,0); (* Timestamp Byte 0 *)
    		S_BUF.BUFFER[19] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[35] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[43] := ts_b; (* Transmit  Timestamp *)

    		ts_b := BYTE_OF_DWORD(timestamp_sek,1); (* Timestamp Byte 1 *)
    		S_BUF.BUFFER[20] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[36] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[44] := ts_b; (* Transmit  Timestamp *)

    		ts_b := BYTE_OF_DWORD(timestamp_sek,0);	(* Timestamp Byte 0 *)
    		S_BUF.BUFFER[21] := ts_b; (* Reference Timestamp *)
    		S_BUF.BUFFER[37] := ts_b; (* Receive   Timestamp *)
    		S_BUF.BUFFER[45] := ts_b; (* Transmit  Timestamp *)

    		(* Byte 1-8 von Transmit-Time auf Originate-Time umkopieren *)
    		i2 := 40;
    		FOR i := 24 TO 31 DO
    			S_BUF.BUFFER[i] := R_BUF.BUFFER[i2];
    			i2 := i2 +1;
    		END_FOR

    		S_BUF.SIZE := UINT#48; (* Daten senden *)

    	ELSIF NOT ENABLE AND S_BUF.SIZE = UINT#0 THEN
    		ip_state := BYTE#4; (* Abmelden *)
    		state := 0;
    	END_IF

    END_CASE

    t(IN:= IP_C.ERROR > DWORD#0, PT:=t#5s);
    IF t.Q THEN
      IP_C.TIME_RESET := TRUE; (* Error Reset *)
    END_IF

    (* IP_FIFO *)
    IP_FIFO(FIFO:=IP_C.FIFO,state:=ip_state,ID:=ip_id);

    (* revision history
    ks	18. oct. 2008	rev 1.0
    	original version

    ks	20. oct. 2009	rev 1.1
    	Networkbuffer und Buffer-funktionen auf Basis 0

    ks	17. may. 2011	rev 1.2
    	automatischer re-connect
    *)


    (*               SNTP(NTP) Datenstruktur
                                      1                   2                   3
                  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 01-04  |LI | VN  |Mode |    STRATUM    |     Poll      |   Precision   |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 05-08  |                          Root  Delay (32 Bit)                 |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 09-12  |                       Root  Dispersion (32 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 13-16  |                     Reference Identifier (32 Bit)             |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 17-24  |                    Reference Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 25-32  |                    Originate Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 33-40  |                     Receive Timestamp (64 Bit)                |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 41-48  |                     Transmit Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 49-52  |                 Key Identifier (optional) (32 Bit)            |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 53-68  |                 Message Digest (optional) (128 Bit)           |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    *)
END_FUNCTION_BLOCK
