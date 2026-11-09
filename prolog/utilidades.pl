
/* Convierte una cadena en formato militar "HH:MM" a minutos */
hora_a_minutos(HoraStr, Minutos) :-
    split_string(HoraStr, ":", "", [HStr, MStr]),
    number_string(H, HStr),
    number_string(M, MStr),
    Minutos is H * 60 + M.

/* Auxiliar para agregar el cero a la izquierda si el numero es menor a 10 */
formato_dos_digitos(Num, Str) :-
    (Num < 10 -> string_concat("0", Num, Str) ; number_string(Num, Str)).

/* Convierte minutos totales de vuelta a formato "HH:MM" */
minutos_a_hora(Minutos, HoraStr) :-
    H is Minutos // 60,
    M is Minutos mod 60,
    formato_dos_digitos(H, HStr),
    formato_dos_digitos(M, MStr),
    string_concat(HStr, ":", Temp),
    string_concat(Temp, MStr, HoraStr).

    

/* Normaliza el dia ingresado por el usuario */
normalizar_dia(Entrada, "L")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["l", "lunes"]), !.
normalizar_dia(Entrada, "M")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["m", "martes"]), !.
normalizar_dia(Entrada, "Mi") :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["mi", "miercoles"]), !.
normalizar_dia(Entrada, "J")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["j", "jueves"]), !.
normalizar_dia(Entrada, "V")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["v", "viernes"]), !.
normalizar_dia(Entrada, "S")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["s", "sabado"]), !.
normalizar_dia(Entrada, "D")  :- normalize_space(string(S), Entrada), string_lower(S, D), member(D, ["d", "domingo"]), !.

/* Verifica si un vuelo opera en el dia consultado */
opera_dia(DiasVueloStr, DiaConsulta) :-
    normalizar_dia(DiaConsulta, _),
    string_lower(DiasVueloStr, "diario"), !.

opera_dia(DiasVueloStr, DiaConsulta) :-
    normalizar_dia(DiaConsulta, DiaNorm),
    split_string(DiasVueloStr, "-", "", ListaDias),
    member(DiaNorm, ListaDias).