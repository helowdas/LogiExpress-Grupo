:- consult('utilidades.pl').

buscar_ruta(Origen, Destino, Dia, Ruta) :-
    dfs_ruta(Origen, Destino, Dia, [Origen], Ruta).


/* Caso Base: vuelo directo de la ciudad actual al destino */
dfs_ruta(Actual, Destino, Dia, _Visitados, [vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias)]) :-
    vuelo(Actual, Destino, Sal, Lleg, Precio, Cod, Dias),
    opera_dia(Dias, Dia).

/* Caso Recursivo: vuelo a una ciudad intermedia no visitada */
dfs_ruta(Actual, Destino, Dia, Visitados, [vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias) | RestoRuta]) :-
    vuelo(Actual, Intermedia, Sal, Lleg, Precio, Cod, Dias),
    Intermedia \= Destino,
    opera_dia(Dias, Dia),
    \+ member(Intermedia, Visitados),
    dfs_ruta(Intermedia, Destino, Dia, [Intermedia | Visitados], RestoRuta).

