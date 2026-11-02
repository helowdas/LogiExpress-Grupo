
/*esto le dice a prolog que habra una instancia vuelo con 7 argumentos para consumir el archivo vuelos.txt*/
:- consult('utilidades.pl').
:- dynamic vuelo/7.

/* ===============================================================
   Configuración Global del TMC (Tiempo Mínimo de Conexión)
   Valor por defecto: 45 minutos (configurable dinámicamente) 
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
      Consultas Básicas de Vuelos por Ciudad 
   ===============================================
    */


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
    /*procesar las lineas*/
    ( Linea == "" ->
        true
    ;
        split_string(Linea, "|", "\r\n", [Origen, Destino, SalidaStr, LlegadaStr, PrecioStr, Codigo, Dias]),
        hora_a_minutos(SalidaStr, SalidaMin),
        hora_a_minutos(LlegadaStr, LlegadaMin),
        number_string(PrecioNum, PrecioStr),
        assertz(vuelo(Origen, Destino, SalidaMin, LlegadaMin, PrecioNum, Codigo, Dias))
    ),
    leer_lineas(Stream).
