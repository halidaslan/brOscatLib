FUNCTION_BLOCK MD5_STREAM
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=80*)
    CASE MODE OF

    1:	(* Initialisierung der hash-Werte *)
    	hash[0] := DWORD#16#67452301;
    	hash[1] := DWORD#16#EFCDAB89;
    	hash[2] := DWORD#16#98BADCFE;
    	hash[3] := DWORD#16#10325476;

    	block := SHR(SIZE,6) + BOOL_TO_UDINT((UDINT_TO_BYTE(SIZE) AND 16#3F) > 55);
    	pad_1 := FALSE;
    	POS := 0;
    	end := SIZE;
    	SIZE := MIN(64,end);
    	MODE := 2;

    2:	(* Fuell-Bytes anhängen *)
    	FOR n := UDINT_TO_INT(SIZE) TO 63 DO
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
    		x[n1] := DWORD_OF_BYTE(BUF[n+3],BUF[n+2],BUF[n+1],BUF[n]); (* Little Endian Format *)
    		n := n + 4;
    	END_FOR

    	IF block = 0 THEN (* am Ende des letzten Blocks die Datenlänge eintragen *)
    		x[14] := SHL(UDINT_TO_DWORD(end),3); (* Anzahl Datenbits im Little-Endian Format eintragen *)
    		MODE := 3;
    	ELSE
    		block := block - 1;
    	END_IF

    	a := hash[0];
    	b := hash[1];
    	c := hash[2];
    	d := hash[3];

    	a := MD5_AUX(1, a, b, c, d, x[00], 07, 16#D76AA478); (* 01 *)
    	d := MD5_AUX(1, d, a, b, c, x[01], 12, 16#E8C7B756); (* 02 *)
    	c := MD5_AUX(1, c, d, a, b, x[02], 17, 16#242070DB); (* 03 *)
    	b := MD5_AUX(1, b, c, d, a, x[03], 22, 16#C1BDCEEE); (* 04 *)
    	a := MD5_AUX(1, a, b, c, d, x[04], 07, 16#F57C0FAF); (* 05 *)
    	d := MD5_AUX(1, d, a, b, c, x[05], 12, 16#4787C62A); (* 06 *)
    	c := MD5_AUX(1, c, d, a, b, x[06], 17, 16#A8304613); (* 07 *)
    	b := MD5_AUX(1, b, c, d, a, x[07], 22, 16#FD469501); (* 08 *)
    	a := MD5_AUX(1, a, b, c, d, x[08], 07, 16#698098D8); (* 09 *)
    	d := MD5_AUX(1, d, a, b, c, x[09], 12, 16#8B44F7AF); (* 10 *)
    	c := MD5_AUX(1, c, d, a, b, x[10], 17, 16#FFFF5BB1); (* 11 *)
    	b := MD5_AUX(1, b, c, d, a, x[11], 22, 16#895CD7BE); (* 12 *)
    	a := MD5_AUX(1, a, b, c, d, x[12], 07, 16#6B901122); (* 13 *)
    	d := MD5_AUX(1, d, a, b, c, x[13], 12, 16#FD987193); (* 14 *)
    	c := MD5_AUX(1, c, d, a, b, x[14], 17, 16#A679438E); (* 15 *)
    	b := MD5_AUX(1, b, c, d, a, x[15], 22, 16#49B40821); (* 16 *)

    	a := MD5_AUX(2, a, b, c, d, x[01], 05, 16#F61E2562); (* 17 *)
    	d := MD5_AUX(2, d, a, b, c, x[06], 09, 16#C040B340); (* 18 *)
    	c := MD5_AUX(2, c, d, a, b, x[11], 14, 16#265E5A51); (* 19 *)
    	b := MD5_AUX(2, b, c, d, a, x[00], 20, 16#E9B6C7AA); (* 20 *)
    	a := MD5_AUX(2, a, b, c, d, x[05], 05, 16#D62F105D); (* 21 *)
    	d := MD5_AUX(2, d, a, b, c, x[10], 09, 16#02441453); (* 22 *)
    	c := MD5_AUX(2, c, d, a, b, x[15], 14, 16#D8A1E681); (* 23 *)
    	b := MD5_AUX(2, b, c, d, a, x[04], 20, 16#E7D3FBC8); (* 24 *)
    	a := MD5_AUX(2, a, b, c, d, x[09], 05, 16#21E1CDE6); (* 25 *)
    	d := MD5_AUX(2, d, a, b, c, x[14], 09, 16#C33707D6); (* 26 *)
    	c := MD5_AUX(2, c, d, a, b, x[03], 14, 16#F4D50D87); (* 27 *)
    	b := MD5_AUX(2, b, c, d, a, x[08], 20, 16#455A14ED); (* 28 *)
    	a := MD5_AUX(2, a, b, c, d, x[13], 05, 16#A9E3E905); (* 29 *)
    	d := MD5_AUX(2, d, a, b, c, x[02], 09, 16#FCEFA3F8); (* 30 *)
    	c := MD5_AUX(2, c, d, a, b, x[07], 14, 16#676F02D9); (* 31 *)
    	b := MD5_AUX(2, b, c, d, a, x[12], 20, 16#8D2A4C8A); (* 32 *)

    	a := MD5_AUX(3, a, b, c, d, x[05], 04, 16#FFFA3942); (* 33 *)
    	d := MD5_AUX(3, d, a, b, c, x[08], 11, 16#8771F681); (* 34 *)
    	c := MD5_AUX(3, c, d, a, b, x[11], 16, 16#6D9D6122); (* 35 *)
    	b := MD5_AUX(3, b, c, d, a, x[14], 23, 16#FDE5380C); (* 36 *)
    	a := MD5_AUX(3, a, b, c, d, x[01], 04, 16#A4BEEA44); (* 37 *)
    	d := MD5_AUX(3, d, a, b, c, x[04], 11, 16#4BDECFA9); (* 38 *)
    	c := MD5_AUX(3, c, d, a, b, x[07], 16, 16#F6BB4B60); (* 39 *)
    	b := MD5_AUX(3, b, c, d, a, x[10], 23, 16#BEBFBC70); (* 40 *)
    	a := MD5_AUX(3, a, b, c, d, x[13], 04, 16#289B7EC6); (* 41 *)
    	d := MD5_AUX(3, d, a, b, c, x[00], 11, 16#EAA127FA); (* 42 *)
    	c := MD5_AUX(3, c, d, a, b, x[03], 16, 16#D4EF3085); (* 43 *)
    	b := MD5_AUX(3, b, c, d, a, x[06], 23, 16#04881D05); (* 44 *)
    	a := MD5_AUX(3, a, b, c, d, x[09], 04, 16#D9D4D039); (* 45 *)
    	d := MD5_AUX(3, d, a, b, c, x[12], 11, 16#E6DB99E5); (* 46 *)
    	c := MD5_AUX(3, c, d, a, b, x[15], 16, 16#1FA27CF8); (* 47 *)
    	b := MD5_AUX(3, b, c, d, a, x[02], 23, 16#C4AC5665); (* 48 *)

    	a := MD5_AUX(4, a, b, c, d, x[00], 06, 16#F4292244); (* 49 *)
    	d := MD5_AUX(4, d, a, b, c, x[07], 10, 16#432AFF97); (* 50 *)
    	c := MD5_AUX(4, c, d, a, b, x[14], 15, 16#AB9423A7); (* 51 *)
    	b := MD5_AUX(4, b, c, d, a, x[05], 21, 16#FC93A039); (* 52 *)
    	a := MD5_AUX(4, a, b, c, d, x[12], 06, 16#655B59C3); (* 53 *)
    	d := MD5_AUX(4, d, a, b, c, x[03], 10, 16#8F0CCC92); (* 54 *)
    	c := MD5_AUX(4, c, d, a, b, x[10], 15, 16#FFEFF47D); (* 55 *)
    	b := MD5_AUX(4, b, c, d, a, x[01], 21, 16#85845DD1); (* 56 *)
    	a := MD5_AUX(4, a, b, c, d, x[08], 06, 16#6FA87E4F); (* 57 *)
    	d := MD5_AUX(4, d, a, b, c, x[15], 10, 16#FE2CE6E0); (* 58 *)
    	c := MD5_AUX(4, c, d, a, b, x[06], 15, 16#A3014314); (* 59 *)
    	b := MD5_AUX(4, b, c, d, a, x[13], 21, 16#4E0811A1); (* 60 *)
    	a := MD5_AUX(4, a, b, c, d, x[04], 06, 16#F7537E82); (* 61 *)
    	d := MD5_AUX(4, d, a, b, c, x[11], 10, 16#BD3AF235); (* 62 *)
    	c := MD5_AUX(4, c, d, a, b, x[02], 15, 16#2AD7D2BB); (* 63 *)
    	b := MD5_AUX(4, b, c, d, a, x[09], 21, 16#EB86D391); (* 64 *)

    	hash[0] := hash[0] + a;
    	hash[1] := hash[1] + b;
    	hash[2] := hash[2] + c;
    	hash[3] := hash[3] + d;

    END_CASE

    IF MODE = 3 THEN
    	z := 0;
    	FOR n := 0 TO 3 DO (* von Little-Endian auf Big-Endian format konvertieren und DWORD auf BYTE-Array *)
    		FOR n1 := 0 TO 3 DO
    			MD5[z] := DWORD_TO_BYTE(hash[n]);
    			hash[n] := ROR(hash[n],8);
    			z := z + 1;
    		END_FOR
    	END_FOR
    END_IF

    (* revision history

    ks	6. dec. 2009 rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
