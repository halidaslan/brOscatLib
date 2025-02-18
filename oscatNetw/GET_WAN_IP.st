FUNCTION_BLOCK GET_WAN_IP
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=96*)
    CASE state OF

    00:
    	IF ACTIVATE AND NOT activate_last THEN
    		state := 20;
    		DONE := FALSE;
    		ERROR_C := DWORD#0;
    		ERROR_T := BYTE#0;
    	END_IF

    20: (* URL for DNS UND HTTP-GET *)
    	URL_DATA := STRING_TO_URL(STR:='checkip.dyndns.com',DEFAULT_PROTOCOL:='',DEFAULT_PATH:='');
    	state := 40;

    40:
    	IF DNS_CLIENT.DONE THEN
    		state := 60;
    	ELSIF (DNS_CLIENT.ERROR > DWORD#00) THEN
    		(* Fehlerbehandlung *)
    		ERROR_C := DNS_CLIENT.ERROR;
    		ERROR_T := BYTE#01;
    		state := 100;
    	END_IF

    60:
    	IF HTTP_GET.DONE THEN
    		state := 80;
    	ELSIF (HTTP_GET.ERROR > DWORD#00) THEN
    		(* Fehlerbehandlung *)
    		ERROR_C := HTTP_GET.ERROR;
    		ERROR_T := BYTE#02;
    		state := 100;
    	END_IF

    80:
    	(* Als Antwort wird folgende HTML Seite empfangen , hier muss die IP-Adresse herauskopiert werden *)
    	(* <html><head><title>Current IP Check</title></head><body>Current IP Address: 85.127.217.33</body></html> *)
    	st_ip := '';
    	p1 := 0;
    	FOR i1 := UINT_TO_INT(HTTP_GET.BODY_START) TO UINT_TO_INT(HTTP_GET.BODY_STOP) DO
    		IF R_BUF.BUFFER[i1] = BYTE#58 THEN (* suche ':' *)
    			p1 := i1 + 2;
    			EXIT;
    		END_IF
    	END_FOR

    	p3 := p1 + 15;
    	IF p1 > 0 AND p3 < UINT_TO_INT(HTTP_GET.BODY_STOP) THEN
    		FOR p2 := p1 TO p3 DO
    			IF R_BUF.BUFFER[p2] <> BYTE#60 THEN (* suche '<' *)
    				st_ip := CONCAT(st_ip,CHR_TO_STRING(C:=R_BUF.BUFFER[p2]));
    			ELSE
    				EXIT;
    			END_IF
    		END_FOR
    	END_IF

    	WAN_IP4 := IP4_DECODE(STR:=st_ip);

    	IF WAN_IP4 <> DWORD#0 THEN
    		DONE := TRUE;
    		NEW_IP4 := WAN_IP4 <> wan_ip4_last;
    		wan_ip4_last := WAN_IP4;
    	ELSE
    		ERROR_C := DWORD#01; (* keine gültige IP gefunden *)
    		ERROR_T := BYTE#03;
    	END_IF
    	state := 100;

    100:
    	(* UNLOCK HTTP DATA *)
    	IF (NOT HTTP_GET.DONE) THEN
    		state := 0;
    		DONE := ERROR_T = BYTE#0;
    	END_IF

    END_CASE

    (* ---------------- DNS --------------- *)
    DNS_CLIENT(	IP_C:=IP_C,
    			S_BUF:=S_BUF,
    			R_BUF:=R_BUF,
    			DOMAIN:=URL_DATA.DOMAIN,
    			IP4_DNS:=DWORD#00,
    			ACTIVATE:=state=40 (* DNS Start *)
    			);
    (* nicht oder nicht direkt verwendete Parameter *)
    (* DWORD :=DNS_CLIENT.IP4;
       BOOL  :=DNS_CLIENT.DONE;
       BYTE  :=DNS_CLIENT.ERROR; *)
    (* -------------------------------------*)

    (* ------------- HTTP_GET --------------- *)

    HTTP_GET(	IP_C:=IP_C,
    			S_BUF:=S_BUF,
    			R_BUF:=R_BUF,
    			IP4:=DNS_CLIENT.IP4,
    			GET:=state=60,
    			MODE:=BYTE#2, (* HTTP 1.1 mit persistenter Verbindung *)
    			UNLOCK_BUF:=state=100,
    			URL_DATA:=URL_DATA
    			);

    (* nicht oder nicht direkt verwendete Parameter *)
    (*STRING := HTTP_GET.HTTP_STATUS;
      UINT :=HTTP_GET.HEADER_START;
      UINT :=HTTP_GET.HEADER_STOP;
      UINT :=HTTP_GET.BODY_START;
      UINT :=HTTP_GET.BODY_STOP;
      BOOL :=HTTP_GET.DONE;
      BYTE :=HTTP_GET.ERROR;
    *)
    (* -------------------------------------*)

    activate_last := ACTIVATE;

    (* revision history
    ks	28. dec 2009	rev 1.1
    	original version

    *)
END_FUNCTION_BLOCK
