:- consult('carga_datos.pl').
:- consult('utilidades.pl').

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
    writeln('5. Salir'),
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

% Opción 5: Salir
ejecutar_opcion("5") :-
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
