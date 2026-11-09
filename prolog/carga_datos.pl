
/*esto le dice a prolog que habra una instancia vuelo con 7 argumentos para consumir el archivo vuelos.txt*/
:- consult('utilidades.pl').
:- dynamic vuelo/7.

/* ===============================================================
   Configuracion Global del TMC (Tiempo Minimo de Conexion)
   Valor por defecto: 45 minutos (configurable dinamicamente) 
   ===============================================================
   */
:- dynamic tmc/1.
tmc(45).


obtener_tmc(Minutos) :-
    tmc(Minutos), !.

/* Actualiza el TMC global */
establecer_tmc(NuevoMin) :-
    integer(NuevoMin),
    NuevoMin >= 0,
    retractall(tmc(_)),
    assertz(tmc(NuevoMin)).

/* ===============================================
      Consultas Basicas de Vuelos por Ciudad 
   ===============================================
    */

/* Obtiene la lista ordenada y sin duplicados de todas las ciudades con vuelos */
ciudades_disponibles(Ciudades) :-
    findall(Orig, vuelo(Orig, _, _, _, _, _, _), Origenes),
    findall(Dest, vuelo(_, Dest, _, _, _, _, _), Destinos),
    append(Origenes, Destinos, Todas),
    sort(Todas, Ciudades).

/* Normaliza el nombre de una ciudad ingresado por el usuario:
   recorta espacios en blanco y compara sin distinguir mayusculas ni minusculas
   con respecto a las ciudades registradas en la base de datos de vuelos. */
normalizar_ciudad(Entrada, CiudadOficial) :-
    normalize_space(string(EntradaLimpia), Entrada),
    string_lower(EntradaLimpia, EntradaLower),
    (   vuelo(CiudadOficial, _, _, _, _, _, _)
    ;   vuelo(_, CiudadOficial, _, _, _, _, _)
    ),
    string_lower(CiudadOficial, CiudadLower),
    EntradaLower == CiudadLower, !.

vuelos_desde(Ciudad, Vuelos) :-
    findall(vuelo(Ciudad, Dest, Sal, Lleg, Prec, Cod, Dias),
            vuelo(Ciudad, Dest, Sal, Lleg, Prec, Cod, Dias),
            Vuelos).


vuelos_hacia(Ciudad, Vuelos) :-
    findall(vuelo(Org, Ciudad, Sal, Lleg, Prec, Cod, Dias),
            vuelo(Org, Ciudad, Sal, Lleg, Prec, Cod, Dias),
            Vuelos).


cargar_datos(Ruta):-
    open(Ruta,read,Stream),
    /*se agrega para ir borrando los duplicados */
    retractall(vuelo(_, _, _, _, _, _, _)),
    leer_lineas(Stream), close(Stream).

/*===============
    caso base
  ===============
*/
leer_lineas(Stream):-
    at_end_of_stream(Stream), !.


/*String completo: linea que se acaba de leer Separadadores: caracteres para cortar en este caso el | CaracteresBorrar: sobrantes como \r\n listaresultados: la lista donde pondra las variables resultantes*/
/*=============
 caso recursivo
==============*/
leer_lineas(Stream):-
    read_line_to_string(Stream,Linea),
    /*procesar las lineas; una linea invalida se informa y se ignora*/
    ( Linea == "" ->
        true
    ;
        (   catch(procesar_linea(Linea), _, fail)
        ->  true
        ;   format(user_error, 'Aviso: linea ignorada (formato invalido): ~w~n', [Linea])
        )
    ),
    leer_lineas(Stream).

/* Parsea y valida una linea antes de registrarla como vuelo */
procesar_linea(Linea) :-
    split_string(Linea, "|", "\r\n ", Campos),
    Campos = [Origen, Destino, SalidaStr, LlegadaStr, PrecioStr, Codigo, Dias],
    hora_a_minutos(SalidaStr, SalidaMin),
    hora_a_minutos(LlegadaStr, LlegadaMin),
    number_string(PrecioNum, PrecioStr),
    PrecioNum >= 0,
    Origen \= "", Destino \= "", Codigo \= "",
    assertz(vuelo(Origen, Destino, SalidaMin, LlegadaMin, PrecioNum, Codigo, Dias)).
