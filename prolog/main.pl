:- consult('carga_datos.pl').
:- consult('utilidades.pl').
:- consult('rutas.pl').
:- consult('optimizacion.pl').

% Predicados de inicio
iniciar :- menu.

menu :-
    nl,
    writeln(' LogiExpress - Sistema de Gestión Aérea '),
    bucle_menu.

bucle_menu :-
    nl,
    writeln('Menu'),
    writeln('1. Cargar archivo de vuelos'),
    writeln('2. Consultar vuelos que salen de una ciudad'),
    writeln('3. Consultar vuelos que llegan a una ciudad'),
    writeln('4. Configuración TMC (Tiempo Mínimo de Conexión)'),
    writeln('5. Buscar rutas válidas entre dos ciudades'),
    writeln('6. Ruta de costo mínimo y ruta de menor tiempo'),
    writeln('7. Reporte ordenado de itinerarios (costo/tiempo y filtros)'),
    writeln('8. Salir'),
    write('Seleccione una opción: '),
    read_line_to_string(user_input, Opcion),
    ejecutar_opcion(Opcion).



% Opción 1: Cargar archivo de vuelos
ejecutar_opcion("1") :-
    nl,
    write('Ingrese la ruta del archivo [por defecto: ../vuelos.txt]: '),
    read_line_to_string(user_input, EntradaRuta),
    determinar_ruta(EntradaRuta, RutaFinal),
    (   exists_file(RutaFinal)
    ->  cargar_datos(RutaFinal),
        aggregate_all(count, vuelo(_, _, _, _, _, _, _), Total),
        format('~nSe han cargado ~w vuelos exitosamente desde "~w".~n', [Total, RutaFinal])
    ;   format('~nError: El archivo "~w" no existe.~n', [RutaFinal])
    ),
    bucle_menu.


% Opción 2: Consultar vuelos que salen de una ciudad
ejecutar_opcion("2") :-
    nl,
    write('Ingrese la ciudad de origen: '),
    read_line_to_string(user_input, Ciudad),
    vuelos_desde(Ciudad, Vuelos),
    (   Vuelos = []
    ->  format('~nNo se encontraron vuelos saliendo de "~w".~n', [Ciudad])
    ;   format('~nVuelos saliendo de ~w:~n', [Ciudad]),
        imprimir_separador,
        imprimir_lista_vuelos(Vuelos)
    ),
    bucle_menu.


% Opción 3: Consultar vuelos que llegan a una ciudad
ejecutar_opcion("3") :-
    nl,
    write('Ingrese la ciudad de destino: '),
    read_line_to_string(user_input, Ciudad),
    vuelos_hacia(Ciudad, Vuelos),
    (   Vuelos = []
    ->  format('~nNo se encontraron vuelos llegando a "~w".~n', [Ciudad])
    ;   format('~nVuelos llegando a ~w:~n', [Ciudad]),
        imprimir_separador,
        imprimir_lista_vuelos(Vuelos)
    ),
    bucle_menu.

% Opción 4: Configuración TMC
ejecutar_opcion("4") :-
    nl,
    obtener_tmc(TmcActual),
    format('Tiempo Mínimo de Conexión (TMC) actual: ~w minutos.~n', [TmcActual]),
    write('Ingrese el nuevo valor en minutos (o Enter para mantener): '),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  writeln('No se modificó el TMC.')
    ;   (   number_string(NuevoTmc, Entrada),
            integer(NuevoTmc),
            NuevoTmc >= 0
        ->  establecer_tmc(NuevoTmc),
            format('TMC actualizado exitosamente a ~w minutos.~n', [NuevoTmc])
        ;   writeln('Error: Debe ingresar un número entero mayor o igual a 0.')
        )
    ),
    bucle_menu.

% Opción 5: Buscar rutas válidas entre dos ciudades
ejecutar_opcion("5") :-
    nl,
    write('Ciudad de origen: '),
    read_line_to_string(user_input, Origen),
    write('Ciudad de destino: '),
    read_line_to_string(user_input, Destino),
    write('Día del viaje (ej. L, martes, Diario): '),
    read_line_to_string(user_input, Dia),
    leer_entero_opcional('Máximo de escalas [Enter = sin límite]: ', MaxEscalas),
    mostrar_rutas(Origen, Destino, Dia, MaxEscalas),
    bucle_menu.

% Opción 6: Ruta de costo mínimo y ruta de menor tiempo
ejecutar_opcion("6") :-
    nl,
    write('Ciudad de origen: '),
    read_line_to_string(user_input, Origen),
    write('Ciudad de destino: '),
    read_line_to_string(user_input, Destino),
    write('Día del viaje (ej. L, martes, Diario): '),
    read_line_to_string(user_input, Dia),
    leer_entero_opcional('Máximo de escalas [Enter = sin límite]: ', MaxEscalas),
    mostrar_optimizacion(Origen, Destino, Dia, MaxEscalas),
    bucle_menu.

% Opción 7: Reporte ordenado de itinerarios con filtros
ejecutar_opcion("7") :-
    nl,
    write('Ciudad de origen: '),
    read_line_to_string(user_input, Origen),
    write('Ciudad de destino: '),
    read_line_to_string(user_input, Destino),
    write('Día del viaje (ej. L, martes, Diario): '),
    read_line_to_string(user_input, Dia),
    writeln('Criterio de orden: 1 = costo, 2 = tiempo'),
    write('Seleccione criterio [1]: '),
    read_line_to_string(user_input, EntradaCriterio),
    elegir_criterio(EntradaCriterio, Criterio),
    leer_entero_opcional('Máximo de escalas [Enter = sin límite]: ', MaxEscalas),
    leer_entero_opcional('Costo máximo en $ [Enter = sin límite]: ', MaxCosto),
    leer_entero_opcional('Tiempo máximo en minutos [Enter = sin límite]: ', MaxTiempo),
    construir_filtros([max_escalas-MaxEscalas, max_costo-MaxCosto, max_tiempo-MaxTiempo], Filtros),
    reporte_itinerarios(Origen, Destino, Dia, Criterio, Filtros),
    bucle_menu.

% Opción 8: Salir
ejecutar_opcion("8") :-
    nl,
    writeln('¡Gracias por utilizar LogiExpress! Hasta luego.'), !.

% Opción inválida
ejecutar_opcion(_) :-
    writeln('\nOpción inválida. Intente de nuevo.'),
    bucle_menu.

% ===============================================================
% Predicados auxiliares (formateo y utilidades de consola)
% ===============================================================

determinar_ruta(Entrada, RutaFinal) :-
    (   Entrada == ""
    ->  (   exists_file('../vuelos.txt')
        ->  RutaFinal = '../vuelos.txt'
        ;   RutaFinal = 'vuelos.txt'
        )
    ;   RutaFinal = Entrada
    ).

imprimir_separador :-
    writeln('--------------------------------------------------------------------------------').

imprimir_lista_vuelos([]).
imprimir_lista_vuelos([Vuelo | Resto]) :-
    imprimir_vuelo(Vuelo),
    imprimir_lista_vuelos(Resto).

imprimir_vuelo(vuelo(Origen, Destino, SalidaMin, LlegadaMin, Precio, Codigo, Dias)) :-
    minutos_a_hora(SalidaMin, SalidaStr),
    minutos_a_hora(LlegadaMin, LlegadaStr),
    format('  [~w] ~w -> ~w | Salida: ~w | Llegada: ~w | Precio: $~2f | Días: ~w~n',
           [Codigo, Origen, Destino, SalidaStr, LlegadaStr, Precio, Dias]).

% ===============================================================
% Predicados auxiliares del Módulo 3
% ===============================================================

/* Lee un entero opcional: Enter produce ninguno; un valor inválido
   también se ignora con un aviso. */
leer_entero_opcional(Prompt, Resultado) :-
    write(Prompt),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  Resultado = ninguno
    ;   (   number_string(Valor, Entrada),
            integer(Valor),
            Valor >= 0
        ->  Resultado = Valor
        ;   writeln('Valor inválido: se ignorará este filtro.'),
            Resultado = ninguno
        )
    ).

construir_filtro_escalas(ninguno, []).
construir_filtro_escalas(MaxEscalas, [max_escalas(MaxEscalas)]).

/* Arma la lista de filtros omitiendo los que quedaron en ninguno */
construir_filtros([], []).
construir_filtros([Nombre-Valor | Resto], Filtros) :-
    construir_filtros(Resto, FiltrosResto),
    (   Valor == ninguno
    ->  Filtros = FiltrosResto
    ;   Filtro =.. [Nombre, Valor],
        Filtros = [Filtro | FiltrosResto]
    ).

elegir_criterio("2", tiempo) :- !.
elegir_criterio(_, costo).

/* Muestra en paralelo la ruta más económica y la más rápida */
mostrar_optimizacion(Origen, Destino, Dia, MaxEscalas) :-
    construir_filtro_escalas(MaxEscalas, Filtros),
    buscar_rutas(Origen, Destino, Dia, Rutas),
    filtrar_rutas(Rutas, Filtros, Candidatas),
    (   Candidatas == []
    ->  format('~nNo hay itinerarios de ~w a ~w para el día ~w.~n', [Origen, Destino, Dia])
    ;   ordenar_rutas(costo, Candidatas, PorCosto),
        ordenar_rutas(tiempo, Candidatas, PorTiempo),
        PorCosto = [RutaCosto | _],
        PorTiempo = [RutaTiempo | _],
        nl,
        writeln('=== Ruta de costo económico mínimo ==='),
        imprimir_detalle_ruta(RutaCosto, 1),
        writeln('=== Ruta de menor tiempo total ==='),
        imprimir_detalle_ruta(RutaTiempo, 1)
    ).
