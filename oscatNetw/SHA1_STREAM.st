FUNCTION_BLOCK SHA1_STREAM
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=84*)
    CASE MODE OF

    1:	(* Initialisierung der hash-Werte *)
    	hash[0] := DWORD#16#67452301;
    	hash[1] := DWORD#16#EFCDAB89;
    	hash[2] := DWORD#16#98BADCFE;
    	hash[3] := DWORD#16#10325476;
    	hash[4] := DWORD#16#C3D2E1F0;

    	(* Buffer initialisieren *)
    	FOR n := 16 TO 79 DO
       		w[n] := DWORD#0;
    	END_FOR

    	block := SHR(SIZE,6) + BOOL_TO_UDINT((UDINT_TO_BYTE(SIZE) AND 16#3F) > 55);	(* benötigte Blocks errechnen *)

    	pad_1 := FALSE;
    	POS := 0;
    	end := SIZE;
    	SIZE := MIN(64,end);
    	MODE := 2;

    2:	FOR n := UDINT_TO_INT(SIZE) TO 63 DO (* Fuell-Bytes anhängen *)
    		BUF[n] := 0;
    	END_FOR

    	IF SIZE < 64 AND NOT pad_1 THEN
    		BUF[SIZE] := 2#1000_0000;
    		pad_1 := TRUE;
    	END_IF

    	POS := POS + SIZE;
    	SIZE := MIN(64,end - POS);

    	n := 0;	(* Byte-Array in DWORD-Array umkopieren *)
    	FOR n1 := 0 TO 15 DO
    		w[n1] := DWORD_OF_BYTE(BUF[n],BUF[n+1],BUF[n+2],BUF[n+3]);
    		n := n + 4;
    	END_FOR

    	IF block = 0 THEN (* am Ende des letzten Blocks die Datenlänge eintragen *)
    		w[15] := SHL(UDINT_TO_DWORD(end),3); (* Anzahl Datenbits eintragen *)
    		MODE := 3;
    	ELSE
    		block := block - 1;
    	END_IF

    	FOR n := 16 TO 79 DO (* erweitern der 16 32-bit-Worte auf 80 32-bit-Worte *)
    		w[n] := ROL(w[n-3] XOR w[n-8] XOR w[n-14] XOR w[n-16],1);
    	END_FOR

    	a := hash[0];
    	b := hash[1];
    	c := hash[2];
    	d := hash[3];
    	e := hash[4];

    	FOR n := 0 TO 79 DO
    		IF n <= 19 THEN
    			f := (b AND c) OR (NOT(b) AND d);
    			k := DWORD#16#5A827999;
    		ELSIF n <= 39 THEN
    			f := b XOR c XOR d;
    			k := DWORD#16#6ED9EBA1;
    		ELSIF n <= 59 THEN
    			f := (b AND c) OR (b AND d) OR (c AND d);
    			k := DWORD#16#8F1BBCDC;
    		ELSE
    			f := b XOR c XOR d;
    			k := DWORD#16#CA62C1D6;
    		END_IF

    		x := ROL(a,5) + f + e + k + w[n];
    		e := d;
    		d := c;
    		c := ROL(b,30);
    		b := a;
    		a := x;
    	END_FOR

    	(* aktuelle hash-Werte zum letzten Wert addieren *)
    	hash[0] := hash[0] + a;
    	hash[1] := hash[1] + b;
    	hash[2] := hash[2] + c;
    	hash[3] := hash[3] + d;
    	hash[4] := hash[4] + e;

    END_CASE

    IF MODE = 3 THEN
    	z := 0;
    	FOR n := 0 TO 4 DO (* konvertiere DWORD auf BYTE-Array *)
    		FOR n1 := 0 TO 3 DO
    			hash[n] := ROL(hash[n],8);
    			SHA1[z] := DWORD_TO_BYTE(hash[n]);
    			z := z + 1;
    		END_FOR
    	END_FOR
    END_IF

    (* revision history

    ks	6. dec. 2009 rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
