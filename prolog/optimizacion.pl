:- consult('rutas.pl').

/* =============================================================
   MODULO 3: Optimizacion y filtrado de listas
   -------------------------------------------------------------
   - Costo economico de una ruta (sumatoria de precios)
   - Tiempo total de viaje (llegada final - salida inicial, con esperas)
   - Ordenamiento propio sobre listas: mergesort y quicksort
   - Ruta de costo minimo y ruta de menor tiempo
   - Filtros finales: maximo de escalas, costo y tiempo
   - Agrupamiento de itinerarios por numero de escalas
   - Reporte ordenado por costo o por tiempo
   ============================================================= */

% =============================================================
% 1. Metricas de una ruta
% =============================================================

/* Costo total: suma de los precios de todos los vuelos de la ruta */
costo_ruta(Ruta, Costo) :-
    suma_precios(Ruta, 0, Costo).

suma_precios([], Acumulado, Acumulado).
suma_precios([vuelo(_, _, _, _, Precio, _, _) | Resto], Acumulado, Total) :-
    NuevoAcumulado is Acumulado + Precio,
    suma_precios(Resto, NuevoAcumulado, Total).

/* Tiempo total: llegada al destino final menos salida de la primera ciudad.
   Incluye de forma implicita las esperas en las escalas. */
tiempo_ruta([], 0).
tiempo_ruta(Ruta, Tiempo) :-
    Ruta = [vuelo(_, _, SalidaInicial, _, _, _, _) | _],
    ultimo(Ruta, vuelo(_, _, _, LlegadaFinal, _, _, _)),
    Tiempo is LlegadaFinal - SalidaInicial.

/* Ultimo elemento de una lista (recursivo, sin usar last/2 de libreria) */
ultimo([Elemento], Elemento).
ultimo([_ | Resto], Ultimo) :-
    ultimo(Resto, Ultimo).

/* Cantidad de escalas = vuelos de la ruta - 1 */
escalas_ruta([], 0).
escalas_ruta(Ruta, Escalas) :-
    Ruta = [_ | _],
    length(Ruta, TotalVuelos),
    Escalas is TotalVuelos - 1.

/* Ciudades visitadas, en orden: origen y luego cada destino */
ciudades_ruta(Ruta, Ciudades) :-
    Ruta = [vuelo(Origen, _, _, _, _, _, _) | _],
    destinos_ruta(Ruta, Destinos),
    Ciudades = [Origen | Destinos].

destinos_ruta([], []).
destinos_ruta([vuelo(_, Destino, _, _, _, _, _) | Resto], [Destino | Destinos]) :-
    destinos_ruta(Resto, Destinos).

/* Codigos de vuelo de la ruta, para mostrarlos como Vlo#1+Vlo#2 */
codigos_ruta([], []).
codigos_ruta([vuelo(_, _, _, _, _, Codigo, _) | Resto], [Codigo | Codigos]) :-
    codigos_ruta(Resto, Codigos).

% =============================================================
% 2. Ordenamiento implementado sobre listas
% =============================================================

/* Criterios de orden: costo, tiempo o escalas.
   valor_orden/3 obtiene la clave numerica de comparacion. */
valor_orden(costo, Ruta, Valor) :- costo_ruta(Ruta, Valor).
valor_orden(tiempo, Ruta, Valor) :- tiempo_ruta(Ruta, Valor).
valor_orden(escalas, Ruta, Valor) :- escalas_ruta(Ruta, Valor).

antes_o_igual(Criterio, Ruta1, Ruta2) :-
    valor_orden(Criterio, Ruta1, Valor1),
    valor_orden(Criterio, Ruta2, Valor2),
    Valor1 =< Valor2.

/* mergesort propio (estable): divide, ordena y mezcla */
ordenar_rutas(Criterio, Rutas, Ordenadas) :-
    mergesort_rutas(Criterio, Rutas, Ordenadas).

mergesort_rutas(_, [], []).
mergesort_rutas(_, [Ruta], [Ruta]).
mergesort_rutas(Criterio, Rutas, Ordenadas) :-
    Rutas = [_, _ | _],
    dividir_lista(Rutas, Izquierda, Derecha),
    mergesort_rutas(Criterio, Izquierda, OrdenadasIzquierda),
    mergesort_rutas(Criterio, Derecha, OrdenadasDerecha),
    mezclar_rutas(Criterio, OrdenadasIzquierda, OrdenadasDerecha, Ordenadas).

dividir_lista(Lista, Izquierda, Derecha) :-
    length(Lista, Total),
    Mitad is Total // 2,
    length(Izquierda, Mitad),
    append(Izquierda, Derecha, Lista).

mezclar_rutas(_, [], Derecha, Derecha).
mezclar_rutas(_, Izquierda, [], Izquierda).
mezclar_rutas(Criterio, [Ruta1 | Resto1], [Ruta2 | Resto2], [Ruta1 | Mezcla]) :-
    antes_o_igual(Criterio, Ruta1, Ruta2), !,
    mezclar_rutas(Criterio, Resto1, [Ruta2 | Resto2], Mezcla).
mezclar_rutas(Criterio, [Ruta1 | Resto1], [Ruta2 | Resto2], [Ruta2 | Mezcla]) :-
    mezclar_rutas(Criterio, [Ruta1 | Resto1], Resto2, Mezcla).

/* quicksort propio: pivote, menores/iguales y mayores */
quicksort_rutas(_, [], []).
quicksort_rutas(Criterio, [Pivote | Resto], Ordenadas) :-
    particionar_rutas(Criterio, Pivote, Resto, Menores, Mayores),
    quicksort_rutas(Criterio, Menores, OrdenadasMenores),
    quicksort_rutas(Criterio, Mayores, OrdenadasMayores),
    append(OrdenadasMenores, [Pivote | OrdenadasMayores], Ordenadas).

particionar_rutas(_, _, [], [], []).
particionar_rutas(Criterio, Pivote, [Ruta | Resto], Menores, Mayores) :-
    particionar_rutas(Criterio, Pivote, Resto, MenoresResto, MayoresResto),
    (   antes_o_igual(Criterio, Ruta, Pivote)
    ->  Menores = [Ruta | MenoresResto],
        Mayores = MayoresResto
    ;   Menores = MenoresResto,
        Mayores = [Ruta | MayoresResto]
    ).

% =============================================================
% 3. Optimizacion por doble criterio
% =============================================================

/* Ruta de costo economico minimo (sin limite de escalas) */
ruta_min_costo(Origen, Destino, Dia, Ruta) :-
    buscar_rutas(Origen, Destino, Dia, Rutas),
    seleccionar_primera(costo, Rutas, Ruta).

/* Ruta de menor tiempo total (sin limite de escalas) */
ruta_min_tiempo(Origen, Destino, Dia, Ruta) :-
    buscar_rutas(Origen, Destino, Dia, Rutas),
    seleccionar_primera(tiempo, Rutas, Ruta).

/* Variantes con limite maximo de escalas K */
ruta_min_costo(Origen, Destino, Dia, MaxEscalas, Ruta) :-
    buscar_rutas(Origen, Destino, Dia, Rutas),
    filtrar_max_escalas(Rutas, MaxEscalas, Filtradas),
    seleccionar_primera(costo, Filtradas, Ruta).

ruta_min_tiempo(Origen, Destino, Dia, MaxEscalas, Ruta) :-
    buscar_rutas(Origen, Destino, Dia, Rutas),
    filtrar_max_escalas(Rutas, MaxEscalas, Filtradas),
    seleccionar_primera(tiempo, Filtradas, Ruta).

/* Ordena y toma la primera ruta; falla si no hay rutas validas */
seleccionar_primera(Criterio, Rutas, Ruta) :-
    Rutas \= [],
    ordenar_rutas(Criterio, Rutas, [Ruta | _]).

% =============================================================
% 4. Filtros finales
% =============================================================

/* Filtros soportados:
   max_escalas(K), max_costo(C), max_tiempo(T) */

filtro_valido(max_escalas(K)) :- integer(K), K >= 0.
filtro_valido(max_costo(C)) :- number(C), C >= 0.
filtro_valido(max_tiempo(T)) :- integer(T), T >= 0.

filtros_validos(Filtros) :-
    forall(member(Filtro, Filtros), filtro_valido(Filtro)).

cumple_filtros([], _Ruta).
cumple_filtros([Filtro | Resto], Ruta) :-
    cumple_filtro(Filtro, Ruta),
    cumple_filtros(Resto, Ruta).

cumple_filtro(max_escalas(Maximo), Ruta) :-
    escalas_ruta(Ruta, Escalas),
    Escalas =< Maximo.
cumple_filtro(max_costo(Maximo), Ruta) :-
    costo_ruta(Ruta, Costo),
    Costo =< Maximo.
cumple_filtro(max_tiempo(Maximo), Ruta) :-
    tiempo_ruta(Ruta, Tiempo),
    Tiempo =< Maximo.

/* Filtrado recursivo sobre la lista de rutas */
filtrar_rutas([], _, []).
filtrar_rutas([Ruta | Resto], Filtros, Filtradas) :-
    (   cumple_filtros(Filtros, Ruta)
    ->  Filtradas = [Ruta | RestoFiltrado]
    ;   Filtradas = RestoFiltrado
    ),
    filtrar_rutas(Resto, Filtros, RestoFiltrado).

filtrar_max_escalas(Rutas, Maximo, Filtradas) :-
    filtrar_rutas(Rutas, [max_escalas(Maximo)], Filtradas).

% =============================================================
% 5. Agrupamiento por numero de escalas
% =============================================================

agrupar_por_escalas(Rutas, Grupos) :-
    ordenar_rutas(escalas, Rutas, Ordenadas),
    agrupar(Ordenadas, Grupos).

agrupar([], []).
agrupar([Ruta | Resto], [Escalas-Grupo | Grupos]) :-
    escalas_ruta(Ruta, Escalas),
    separar_por_escalas(Escalas, Resto, GrupoResto, RestoFinal),
    Grupo = [Ruta | GrupoResto],
    agrupar(RestoFinal, Grupos).

separar_por_escalas(_, [], [], []).
separar_por_escalas(Escalas, [Ruta | Resto], Grupo, RestoFinal) :-
    escalas_ruta(Ruta, EscalasRuta),
    (   EscalasRuta =:= Escalas
    ->  Grupo = [Ruta | GrupoResto],
        RestoFinal = RestoFinalResto
    ;   Grupo = GrupoResto,
        RestoFinal = [Ruta | RestoFinalResto]
    ),
    separar_por_escalas(Escalas, Resto, GrupoResto, RestoFinalResto).

% =============================================================
% 6. Reporte ordenado de itinerarios
% =============================================================

/* Genera el reporte completo: rutas validas, filtradas y ordenadas */
reporte_itinerarios(Origen, Destino, Dia, Criterio, Filtros) :-
    buscar_rutas(Origen, Destino, Dia, Rutas),
    filtrar_rutas(Rutas, Filtros, Filtradas),
    ordenar_rutas(Criterio, Filtradas, Ordenadas),
    mostrar_reporte(Origen, Destino, Dia, Criterio, Ordenadas).

mostrar_reporte(Origen, Destino, Dia, _Criterio, []) :-
    format('~nNo hay itinerarios de ~w a ~w para el dia ~w con los filtros indicados.~n',
           [Origen, Destino, Dia]).

mostrar_reporte(Origen, Destino, Dia, Criterio, Rutas) :-
    Rutas \= [],
    length(Rutas, Total),
    format('~n=== Itinerarios de ~w a ~w (dia ~w) ===~n', [Origen, Destino, Dia]),
    format('Criterio de orden: ~w | Total de rutas: ~w~n', [Criterio, Total]),
    imprimir_resumen_grupos(Rutas),
    nl,
    imprimir_rutas_numeradas(Rutas, 1).

imprimir_resumen_grupos(Rutas) :-
    agrupar_por_escalas(Rutas, Grupos),
    format('Distribucion por escalas: '),
    imprimir_grupos(Grupos),
    nl.

imprimir_grupos([]).
imprimir_grupos([Escalas-Grupo | Resto]) :-
    length(Grupo, Cantidad),
    (   Escalas =:= 0
    ->  format('directos: ~w', [Cantidad])
    ;   format('~w escala(s): ~w', [Escalas, Cantidad])
    ),
    (   Resto = []
    ->  true
    ;   write(' | '),
        imprimir_grupos(Resto)
    ).

imprimir_encabezado :-
    writeln('--------------------------------------------------------------------------------').

imprimir_rutas_numeradas([], _).
imprimir_rutas_numeradas([Ruta | Resto], Numero) :-
    imprimir_detalle_ruta(Ruta, Numero),
    Siguiente is Numero + 1,
    imprimir_rutas_numeradas(Resto, Siguiente).

/* Imprime una ruta con sus metricas: costo, duracion, escalas y horario */
imprimir_detalle_ruta(Ruta, Numero) :-
    costo_ruta(Ruta, Costo),
    tiempo_ruta(Ruta, Tiempo),
    escalas_ruta(Ruta, Escalas),
    codigos_ruta(Ruta, Codigos),
    ciudades_ruta(Ruta, Ciudades),
    Ruta = [vuelo(_, _, SalidaInicial, _, _, _, _) | _],
    ultimo(Ruta, vuelo(_, _, _, LlegadaFinal, _, _, _)),
    minutos_a_hora(SalidaInicial, HoraSalida),
    minutos_a_hora(LlegadaFinal, HoraLlegada),
    atomic_list_concat(Codigos, '+', CodigosTexto),
    atomic_list_concat(Ciudades, ' -> ', CiudadesTexto),
    formato_duracion(Tiempo, DuracionTexto),
    format('~w. [~w] ~w~n', [Numero, CodigosTexto, CiudadesTexto]),
    format('   Costo: $~2f | Duracion: ~w (~w min) | Escalas: ~w | Horario: ~w-~w~n~n',
           [Costo, DuracionTexto, Tiempo, Escalas, HoraSalida, HoraLlegada]).

/* Duracion en formato "2h 15m" */
formato_duracion(Minutos, Texto) :-
    Horas is Minutos // 60,
    Resto is Minutos mod 60,
    format(atom(Texto), '~wh ~wm', [Horas, Resto]).
