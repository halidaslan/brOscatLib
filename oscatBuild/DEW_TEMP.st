FUNCTION DEW_TEMP
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=436*)
    IF RH > 0.0 THEN
    (*	old code was rewritten for better performance
    	SDD := 6.1078*EXPT(10,(a*T)/(b+T));
    	DD := RH/100 * SDD;
    	V := LOG(DD/6.1078);
    	DEW_TEMP := b*V/(a-V);
    *)
    	V := LOG(RH * 0.01 * EXP10((a*T) / (b+T)));
    	DEW_TEMP := b*V / (a-V);
    ELSE
    	DEW_TEMP:= cT0;
    END_IF

    (* revision history

    hm		2.10.2006	rev 1.0
    	original version created

    hm		29.4.2007	rev 1.1
    	checked for RH not to be 0 because log(0) is not defined

    hm		13.9.2007	rev 1.2
    	code rewritten for better performance

    hm	2. dec 2007	rev 1.3
    	changed code for better performance

    hm	8. jan 2008	rev 1.4
    	further improvement in performance

    hm	18. oct. 2008	rev 1.5
    	using phys constants	

    hm	13. mar. 2009	rev 1.6
    	real constants updated to new systax using dot
    	function will now return -273.15 °C for RH = 0
    *)

    (*
    Bezeichnungen:
    r = relative Luftfeuchte
    T = Temperatur in °C
    TK = Temperatur in Kelvin (TK = T + 273.15)
    TD = Taupunkttemperatur in °C
    DD = Dampfdruck in hPa
    SDD = Sättigungsdampfdruck in hPa

    Parameter:
    a = 7.5, b = 237.3 für T >= 0
    a = 7.6, b = 240.7 für T < 0 über Wasser (Taupunkt)
    a = 9.5, b = 265.5 für T < 0 über Eis (Frostpunkt)

    R* = 8314.3 J/(kmol*K) (universelle Gaskonstante)
    mw = 18.016 kg (Molekulargewicht des Wasserdampfes)
    AF = absolute Feuchte in g Wasserdampf pro m3 Luft

    Formeln:

       1. SDD(T) = 6.1078 * 10((a*T)/(b+T))
       2. DD(r,T) = r/100 * SDD(T)
       3. r(T,TD) = 100 * SDD(TD) / SDD(T)
       4. TD(r,T) = b*V/(a-V) mit V(r,T) = log10(DD(r,T)/6.1078)
       5. AF(r,TK) = 105 * mw/R* * DD(r,T)/TK; AF(TD,TK) = 105 * mw/R* * SDD(TD)/TK 

    *)
END_FUNCTION
