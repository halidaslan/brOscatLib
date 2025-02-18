FUNCTION_BLOCK DNS_CLIENT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=89*)
    (* DOMAIN Name System (query) *)

    CASE state OF

    00:	IF ACTIVATE AND NOT activate_last THEN (* auf positive Flanke GET warten *)
    		DONE := FALSE;
    		ERROR := DWORD#0;
    		state := 5;
    	END_IF

    05:	IP4 := IP4_DECODE(str:=DOMAIN); (* prüfe ob DOMAIN schon eine IP4-Adresse ist *)
    	IF IP4 > DWORD#00 THEN
    		DONE := TRUE;
    		state := 0;
            		(*####################  DEBUG-MESSAGE  ###################################*)
            		(*IF _debug_enable THEN
                		LOG_CL.NEW_MSG := 'DNS: S05 IP4 ~1';
                		LOG_CL.PRINTF[1]  := DOMAIN;
                		LOG_MSG();
            		END_IF*)
            		(*########################################################################*)
    	ELSE
    		ip_state := BYTE#1;
    		ttl_last := DWORD#0;
    		domain_copy := DOMAIN; (* DOMAIN String sichern *)
    		state := 10;
            		(*####################  DEBUG-MESSAGE  ###################################*)
            		(*IF _debug_enable THEN
                		LOG_CL.NEW_MSG := 'DNS: S05 START';
                		LOG_MSG();
            		END_IF*)
            		(*########################################################################*)
    	END_IF

    10:	IF ip_state = BYTE#3 THEN (* Bei IP_Control anmelden *)
    		url_length := LEN(domain_copy);
    		char_count := 17 + url_length; (* sendebuffer initialisieren *)
    		FOR i := 0 TO char_count DO
    			S_BUF.BUFFER[i] := BYTE#00;
    		END_FOR
    		tid := UINT_TO_BYTE(BYTE_TO_UINT(tid) + UINT#1);
    		S_BUF.BUFFER[01] := tid; (* Transaction ID lowbyte *)
    		S_BUF.BUFFER[02] := BYTE#16#01; (* Flags: highbyte *)
    		S_BUF.BUFFER[05] := BYTE#16#01; (* Questions: lowbyte *)
    		i := url_length + 12;	(* den servernamen von hinten nach vorne bearbeiten *)
    		char_count := 0;
    		WHILE i > 12 DO
    			char := CODE(STR:=domain_copy,POS:=i - 12);
    			IF char = BYTE#46 THEN (* prüfe auf haupt/sub domänen namens-teiler "." *)
    				S_BUF.BUFFER[i] := INT_TO_BYTE(char_count); (* anstelle des teilers "." wird die länge des erkannten haupt/sub domänennames eingetragen *)
    				char_count := 0;
    			ELSE
    				S_BUF.BUFFER[i] := char; (* char in buffer eintragen *)
    				char_count := char_count + 1; (* anzahl char zählen *)
    			END_IF
    			i := i - 1;
    		END_WHILE
    		S_BUF.BUFFER[i] := INT_TO_BYTE(char_count); (* längenangabe des ganz linken (ersten) domänennamens eintragen *)
    		i := url_length + 15; (* position hinter dem servernamen *)
    		S_BUF.BUFFER[i] := BYTE#01; (* Type: A Hostaddress lowbyte *)
    		i := i + 2;
    		S_BUF.BUFFER[i] := BYTE#01; (* Class: IN lowbyte *)
    		i := i + 1;
    		(* IP Datenverkehr einrichten *)
    		IP_C.C_PORT := WORD#53; (* Portnummer eintragen *)
    		IP_C.C_IP := IP4_DNS; (* IP eintragen *)
    		IP_C.C_MODE := BYTE#1; (* Mode: UDP+AKTIV+PORT+IP *)
    		IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    		IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    		IP_C.R_OBSERVE  := TRUE; (* Datenempfang ueberwachen *)
    		S_BUF.SIZE := INT_TO_UINT(i); (* sendelänge eintragen *)
    		R_BUF.SIZE := UINT#0; (* Empfangslänge rücksetzen *)
    		state := 30;

            		(*####################  DEBUG-MESSAGE  ###################################*)
            		(*IF _debug_enable THEN
                		LOG_CL.NEW_MSG := 'DNS: S10 SEND';
                		LOG_MSG();
            		END_IF*)
            		(*########################################################################*)
    	END_IF

    30:	IF IP_C.ERROR <> DWORD#00 THEN
    		ERROR := IP_C.ERROR;
    		state := 99;
            		(*####################  DEBUG-MESSAGE  ###################################*)
            		(*IF _debug_enable THEN
                		LOG_CL.NEW_MSG := 'DNS: S30 ERROR ~1';
                		LOG_CL.PRINTF[1]  := DWORD_TO_STRING(ERROR);
                		LOG_MSG();
            		END_IF*)
            		(*########################################################################*)

    	ELSIF (S_BUF.SIZE = UINT#0) AND (tid = R_BUF.BUFFER[1]) AND (R_BUF.SIZE >= INT_TO_UINT(34 + url_length)) THEN	(* prüfe ob antwort telegramm die richtige Transaction-ID und mindestlänge hat *)
    		ERROR := BYTE_TO_DWORD(R_BUF.BUFFER[3] AND BYTE#2#0000_1111); (* prüfe Return code der Flags. 4 bits *)
    		IF ERROR = DWORD#00 THEN
    			anc := R_BUF.BUFFER[7]; (* Anzahl der Answer-RR *)
    			IP_C.R_OBSERVE := FALSE; (* Datenempfang ueberwachen *)
    			state := 40;
    		ELSE
    			state := 99;
    		END_IF
    	END_IF

    40:	IF anc > 0 THEN
    		anc := anc - 1;
    		WHILE i < R_BUF.SIZE DO
    			x := R_BUF.BUFFER[i];
    			IF rr_stop = FALSE THEN
    				IF x > BYTE#63 THEN (* zeiger auf namen *)
    					i := i + 1;
    					rr_stop := TRUE;
    				ELSIF x= BYTE#0 THEN (* namens ende *)
    					rr_stop := TRUE;
    				ELSE
    					i := i + x; (* namen *)
    				END_IF
    				i := i + 1;
    			ELSE
    				rr_stop := FALSE;
    				IF R_BUF.BUFFER[i+1] = BYTE#1 AND R_BUF.BUFFER[i+3] = BYTE#1 THEN (* Type A / Class IN *)
    					i := i + 4;
    					ttl_tmp := DWORD_OF_BYTE(R_BUF.BUFFER[i],R_BUF.BUFFER[i+1],R_BUF.BUFFER[i+2],R_BUF.BUFFER[i+3]); (* Time to live *)
    					i := i + 6;
    					IF ttl_tmp >= ttl_last THEN (* TTL ist länger *)
    						ttl_last := ttl_tmp;
    						IP4 := DWORD_OF_BYTE(R_BUF.BUFFER[i],R_BUF.BUFFER[i+1],R_BUF.BUFFER[i+2],R_BUF.BUFFER[i+3]); (* IP-Adresse *)
    					END_IF
    					i := i + 4;
    				ELSE
    					i := i + 9;
    					i := i + R_BUF.BUFFER[i] + 1; (* offset zu nächsten Block *)
    				END_IF
    				EXIT;
    			END_IF
    		END_WHILE
    	ELSE
    		IF IP4 > DWORD#0 THEN (* gültige RR mit IP gefunden *)
    			DONE := TRUE;
                		(*####################  DEBUG-MESSAGE  ###################################*)
                		(*IF _debug_enable THEN
                    			LOG_CL.NEW_MSG := 'DNS: S40 OK';
                    			LOG_MSG();
                		END_IF*)
                		(*########################################################################*)
    		ELSE
    			ERROR := DWORD#255; (* Daten fehlerhaft - keine IP-Adresse vorhanden *)
    		END_IF
    		state := 99;
    	END_IF

    99:	R_BUF.SIZE := UINT#0; (* Empfangslänge rücksetzen *)
    	ip_state := BYTE#4; (* Abmelden *)
    	state := 00;

    END_CASE

    activate_last := ACTIVATE; (* letzten Status sichern zur Flankenerkennung *)
    IP_FIFO(FIFO:=IP_C.FIFO,state:=ip_state,ID:=ip_id); (* IP_FIFO *)

    (* revision history

    ks	18. oct. 2008	rev 1.0
    	original version

    ks	20. oct. 2009	rev 1.1
    	unbenutzten code entfernt, all buffer base 0

    ks	20. dec. 2010	rev 1.2
    	parsing nach rfc1305

    ks	26. jul. 2011	rev 1.3
    	verbesserte ip-auswertung , neue fehlermeldung
    *)


    (*----------------------------------------------------------------------------------------------------------------*)
    (* Flags: 0x0100 (Standard query)                                                                                            *)
    (* 0... .... .... .... = Response: Message is a query                                                                   *)
    (* .000 0... ....  = Opcode: Standard query (0)                                                                          *)
    (* .... ..0. .... .... = Truncated: Message is not truncated                                                          *)
    (* .... ...1 .... .... = Recursion desired: Do query recursively                                                    *)
    (* .... .... .0.. .... = Z: reserved (0)                                                                                                  *)
    (* .... .... ...0 .... = Non-authenticated data OK: Non-authenticated data is unacceptable *)
    (*-----------------------------------------------------------------------------------------------------------------*)

    (*      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |                      ID                       | idx: 0/1   *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   | idx: 2/3   *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |                    QDCOUNT                    | idx: 4/5   *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |                    ANCOUNT                    | idx: 6/7   *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |                    NSCOUNT                    | idx: 8/9   *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)
    (*    |                    ARCOUNT                    | idx: 10/11 *)
    (*    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+ *)

    (*
    Errorcodes  Description	References 
    000	No ERROR. 		 	The request completed successfully.
    001	Format ERROR. 		The name server was unable to interpret the query. 
    002	Server failure.  	The name server was unable to process this query due to a problem with the name server. 
    003	Name ERROR. 	 	Meaningful only for responses from an authoritative name server, this code signifies that the DOMAIN name referenced in the query does not exist.
    004	Not Implemented. 	The name server does not support the requested kind of query.
    005	Refused. 			The name server refuses to perform the specified operation for policy reasons.
      						 For example, a name server may not wish to provide the information to the particular requester, or a name server may not wish to perform a particular operation (e.g., zone transfer) for particular data.
    006	YXDomain.			Name Exists when it should not. 
    007	YXRRSet. RR			Set Exists when it should not. 
    008	NXRRSet. RR			Set that should exist does not. 
    009	NotAuth.			Server Not Authoritative for zone. 
    010	NotZone,			Name not contained in zone. 
    255	Timeout				No Response  
       

    beispiel einer DNS Request von google.at
    ein request mit 3 Answer-Blocks


    DOMAIN Name System (response)
    [Request In: 3]
    [Time: 0.027533000 seconds]
    Transaction ID: 0x5e1a
    Flags: 0x8180 (Standard query response, No ERROR)
    1... .... .... .... = Response: Message is a response
    .000 0... .... .... = Opcode: Standard query (0)
    .... .0.. .... .... = Authoritative: Server is not an authority for DOMAIN
    .... ..0. .... .... = Truncated: Message is not truncated
    .... ...1 .... .... = Recursion desired: Do query recursively
    .... .... 1... .... = Recursion available: Server can do recursive queries
    .... .... .0.. .... = Z: reserved (0)
    .... .... ..0. .... = Answer authenticated: Answer/authority portion was not authenticated
    .... .... .... 0000 = Reply code: No ERROR (0)
    Questions: 1
    Answer RRs: 3
    Authority RRs: 0
    Additional RRs: 0

    Queries
    google.at: type A, class IN
    Name: google.at
    Type: A (Host address)
    Class: IN (0x0001)

    Answers
    google.at: type A, class IN, addr 72.14.221.104
    Name: google.at
    Type: A (Host address)
    Class: IN (0x0001)
    Time to live: 19 minutes, 9 seconds
    Data length: 4
    Addr: 72.14.221.104

    google.at: type A, class IN, addr 66.249.93.104
    Name: google.at
    Type: A (Host address)
    Class: IN (0x0001)
    Time to live: 19 minutes, 9 seconds
    Data length: 4
    Addr: 66.249.93.104

    google.at: type A, class IN, addr 216.239.59.104
    Name: google.at
    Type: A (Host address)
    Class: IN (0x0001)
    Time to live: 19 minutes, 9 seconds
    Data length: 4
    Addr: 216.239.59.104
    *)
END_FUNCTION_BLOCK
