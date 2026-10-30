
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