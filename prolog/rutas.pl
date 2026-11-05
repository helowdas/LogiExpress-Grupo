:- consult('carga_datos.pl').
:- consult('utilidades.pl').

 
/* Búsqueda de rutas válidas (DFS) */

/* Busca una ruta valida entre Origen y Destino para un Dia respetando dias de operacion, control de ciclos y TMC. */
buscar_ruta(Origen, Destino, Dia, Ruta) :-
    dfs_ruta(Origen, Destino, Dia, [Origen], Ruta).

buscar_ruta(Origen, Destino, Dia, MaxEscalas, Ruta) :-
    buscar_ruta(Origen, Destino, Dia, Ruta),
    length(Ruta, TotalVuelos),
    Escalas is TotalVuelos - 1,
    Escalas =< MaxEscalas.

/* Recopilacion de todas las rutas validas */
buscar_rutas(Origen, Destino, Dia, Rutas) :-
    findall(Ruta, buscar_ruta(Origen, Destino, Dia, Ruta), Rutas).

buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas) :-
    findall(Ruta, buscar_ruta(Origen, Destino, Dia, MaxEscalas, Ruta), Rutas).

   /*Validacion de escala segun Tiempo Minimo de Conexion (TMC)
   Acepta tanto enteros (minutos) como cadenas ("HH:MM") */
conexion_valida(Llegada, Salida) :-
    (number(Llegada) -> LlegMin = Llegada ; hora_a_minutos(Llegada, LlegMin)),
    (number(Salida)  -> SalMin = Salida   ; hora_a_minutos(Salida, SalMin)),
    (   current_predicate(obtener_tmc/1)
    ->  obtener_tmc(TMC)
    ;   TMC = 45
    ),
    SalMin >= LlegMin + TMC.

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

/* DFS para vuelos con escala */
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

/* Visualizacion y presentacion de rutas por consola */
mostrar_rutas(Origen, Destino, Dia) :-
    mostrar_rutas(Origen, Destino, Dia, ninguno).

mostrar_rutas(Origen, Destino, Dia, MaxEscalas) :-
    rutas_para_consulta(Origen, Destino, Dia, MaxEscalas, Rutas),
    length(Rutas, Total),
    format('~n======================================================~n'),
    format('  Rutas de ~w a ~w para el dia ~w~n', [Origen, Destino, Dia]),
    (   MaxEscalas \== ninguno
    ->  format('  Limite de escalas: ~w~n', [MaxEscalas])
    ;   true
    ),
    format('  Total encontradas: ~w~n', [Total]),
    format('======================================================~n'),
    (   Total =:= 0
    ->  writeln('  No se encontraron rutas disponibles.')
    ;   imprimir_rutas_detalle(Rutas, 1)
    ),
    nl.

rutas_para_consulta(Origen, Destino, Dia, ninguno, Rutas) :-
    buscar_rutas(Origen, Destino, Dia, Rutas).
rutas_para_consulta(Origen, Destino, Dia, MaxEscalas, Rutas) :-
    integer(MaxEscalas),
    MaxEscalas >= 0,
    buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas).

imprimir_rutas_detalle([], _).
imprimir_rutas_detalle([Ruta | Resto], N) :-
    length(Ruta, TotalVuelos),
    Escalas is TotalVuelos - 1,
    format('~n[Ruta #~w] (~w escala(s)):~n', [N, Escalas]),
    imprimir_segmentos(Ruta),
    N1 is N + 1,
    imprimir_rutas_detalle(Resto, N1).

imprimir_segmentos([]).
imprimir_segmentos([vuelo(Orig, Dest, Sal, Lleg, Precio, Cod, Dias) | Resto]) :-
    (number(Sal)  -> minutos_a_hora(Sal, SalStr)   ; SalStr = Sal),
    (number(Lleg) -> minutos_a_hora(Lleg, LlegStr) ; LlegStr = Lleg),
    format('   -> ~w: ~w -> ~w | ~w - ~w | $~w (~w)~n',
           [Cod, Orig, Dest, SalStr, LlegStr, Precio, Dias]),
    imprimir_segmentos(Resto).
