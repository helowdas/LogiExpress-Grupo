:- consult('carga_datos.pl').
:- consult('utilidades.pl').


/* Busca una ruta valida entre Origen y Destino para un Dia respetando dias de operacion, control de ciclos y TMC. */

buscar_ruta(Origen, Destino, Dia, Ruta) :-
    dfs_ruta(Origen, Destino, Dia, [Origen], Ruta).

buscar_ruta(Origen, Destino, Dia, MaxEscalas, Ruta) :-
    buscar_ruta(Origen, Destino, Dia, Ruta),
    length(Ruta, TotalVuelos),
    Escalas is TotalVuelos - 1,
    Escalas =< MaxEscalas.


buscar_rutas(Origen, Destino, Dia, Rutas) :-
    findall(Ruta, buscar_ruta(Origen, Destino, Dia, Ruta), Rutas).

buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas) :-
    findall(Ruta, buscar_ruta(Origen, Destino, Dia, MaxEscalas, Ruta), Rutas).


/* Validacion de escala segun Tiempo Minimo de Conexion (TMC) */
conexion_valida(LlegadaMin, SalidaMin) :-
    (   current_predicate(obtener_tmc/1)
    ->  obtener_tmc(TMC)
    ;   TMC = 45
    ),
    SalidaMin >= LlegadaMin + TMC.

/* DFS con control de ciclos y validacion de conexiones */

/* Caso Base: vuelo directo de la ciudad actual al destino */
dfs_ruta(Actual, Destino, Dia, _Visitados, [vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias)]) :-
    vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias),
    opera_dia(Dias, Dia).

/* Caso Recursivo: vuelo a una ciudad intermedia */
dfs_ruta(Actual, Destino, Dia, Visitados, [vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias) | RestoRuta]) :-
    vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias),
    Intermedia \= Destino,
    opera_dia(Dias, Dia),
    \+ member(Intermedia, Visitados),
    dfs_con_conexion(Lleg, Intermedia, Destino, Dia, [Intermedia | Visitados], RestoRuta).

/* DFS para vuelos con escala  */
dfs_con_conexion(LlegAnterior, Actual, Destino, Dia, _Visitados, [vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias)]) :-
    vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias),
    opera_dia(Dias, Dia),
    conexion_valida(LlegAnterior, Sal).

dfs_con_conexion(LlegAnterior, Actual, Destino, Dia, Visitados, [vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias) | RestoRuta]) :-
    vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias),
    Intermedia \= Destino,
    opera_dia(Dias, Dia),
    conexion_valida(LlegAnterior, Sal),
    \+ member(Intermedia, Visitados),
    dfs_con_conexion(Lleg, Intermedia, Destino, Dia, [Intermedia | Visitados], RestoRuta).
