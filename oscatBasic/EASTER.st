FUNCTION EASTER
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=122*)
    b := (204 - 11 * (YEAR MOD 19)) MOD 30;
    IF b > 27 THEN b := b - 1; END_IF
    c := (YEAR + SHR(YEAR,2) + b - 13) MOD 7;
    oday := 28 + b - c;
    IF oday > 33 THEN
    	EASTER := SET_DATE(YEAR, 4, oday - 31);
    ELSE
    	EASTER := SET_DATE(YEAR, 3, oday);
    END_IF




    (* alternativer algorithmus ueber das pasah fest
    execution time roughly 200us
    Der sog. Passah-Vollmond wird berechnet, in dem das Jahr durch 19 ge-
    teilt wird und der Rest mit der folgenden Tabelle verglichen wird:
     
        0: Apr 14       5: Apr 18      10: Mrz 25      15: Mrz 30
        1: Apr 03       6: Apr 08      11: Apr 13      16: Apr 17
        2: Mrz 23       7: Mrz 28      12: Apr 02      17: Apr 07
        3: Apr 11       8: Apr 16      13: Mrz 22      18: Mrz 27
        4: Mrz 31       9: Apr 05      14: Apr 10
     
    Faellt dieses Datum auf einen Sonntag, ist Ostern der naechste Sonntag!
     
    Beispiel: 1992 MOD 19 = 16, daraus folgt 17.04., der naechste Sonntag
              ist dann der 19. April (Ostersonntag)
    *)


    (* this algorithm is 180 us
    a := YEAR MOD 19;
    b := YEAR / 100;
    c := YEAR MOD 100;
    d := b / 4;
    e := b MOD 4;
    f := (b + 8) / 25;
    g := (b - f + 1) / 3;
    h := (19 * a + b - d -g + 15) MOD 30;
    i := c / 4;
    k := c MOD 4;
    l := (32 + 2*e + 2*i - h - k) MOD 7;
    m := (a + 11 * h + 22 * l) / 451;
    x := h + l - 7 * m + 114;
    n := X / 31;
    o := x MOD 31 + 1;

    EASTER := set_Date(YEAR,n,o);
    *)
    (*
    Im Magazin "Nature" vom 20. April 1876 veröffentlichte ein anonymer Autor eine Tabelle mit Regeln zur Berechnung des (Gregorianischen) Ostersonntages des Jahres J. In Formeln ausgedrückt erhält man das Folgende:
    a	=	J mod 19
    b	=	int(J / 100)
    c	=	J mod 100
    d	=	int(b / 4)
    e	=	b mod 4
    f	=	int((b + 8) / 25)
    g	=	int((b - f + 1) / 3
    h	=	(19 · a + b - d - g + 15) mod 30
    i	=	int(c / 4)
    k	=	c mod 4
    l	=	(32 + 2 · e + 2 · i - h - k) mod 7
    m	=	int((a + 11 · h + 22 · l) / 451)
    n	=	int((h + l - 7 · m + 114) / 31)
    o	=	(h + l - 7 · m + 114) mod 31

    n ist hierbei die Nummer des Monats, o + 1 die Nummer des Tages auf welchen der Ostersonntag im Jahr J fällt. Dieser Algorithmus kommt ohne Hilfszahlen aus.

    *)

    (* revision history
    hm	27. dec 2006	rev 1.0
    	original version

    hm	15. dec 2007	rev 1.1
    	modified code for better performance

    hm	3. feb 2008		rev 1.2
    	modified code for better performance

    hm	7. apr. 2008	rev 1.3
    	improved performance
    *)
END_FUNCTION
