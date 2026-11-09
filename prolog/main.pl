:- consult('carga_datos.pl').
:- consult('utilidades.pl').
:- consult('rutas.pl').
:- consult('optimizacion.pl').

% Predicados de inicio
iniciar :- menu.

menu :-
    nl,
    writeln(' LogiExpress - Sistema de Gestion Aerea '),
    bucle_menu.

bucle_menu :-
    nl,
    writeln('Menu'),
    writeln('1. Cargar archivo de vuelos'),
    writeln('2. Consultar vuelos que salen de una ciudad'),
    writeln('3. Consultar vuelos que llegan a una ciudad'),
    writeln('4. Configuracion TMC (Tiempo Minimo de Conexion)'),
    writeln('5. Buscar rutas validas entre dos ciudades'),
    writeln('6. Ruta de costo economico minimo'),
    writeln('7. Ruta de menor tiempo total'),
    writeln('8. Reporte ordenado de itinerarios (costo/tiempo y filtros)'),
    writeln('9. Salir'),
    write('Seleccione una opcion: '),
    read_line_to_string(user_input, Opcion),
    ejecutar_opcion(Opcion).

% ===============================================================
% Ejecucion de opciones del Menu
% ===============================================================

% Opcion 1: Cargar archivo de vuelos
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


% Opcion 2: Consultar vuelos que salen de una ciudad
ejecutar_opcion("2") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_ciudad('Ingrese la ciudad de origen: ', Ciudad)
        ->  vuelos_desde(Ciudad, Vuelos),
            (   Vuelos = []
            ->  format('~nNo se encontraron vuelos saliendo de "~w".~n', [Ciudad])
            ;   format('~nVuelos saliendo de ~w:~n', [Ciudad]),
                imprimir_separador,
                imprimir_lista_vuelos(Vuelos)
            )
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).


% Opcion 3: Consultar vuelos que llegan a una ciudad
ejecutar_opcion("3") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_ciudad('Ingrese la ciudad de destino: ', Ciudad)
        ->  vuelos_hacia(Ciudad, Vuelos),
            (   Vuelos = []
            ->  format('~nNo se encontraron vuelos llegando a "~w".~n', [Ciudad])
            ;   format('~nVuelos llegando a ~w:~n', [Ciudad]),
                imprimir_separador,
                imprimir_lista_vuelos(Vuelos)
            )
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).

% Opcion 4: Configuracion TMC
ejecutar_opcion("4") :-
    nl,
    obtener_tmc(TmcActual),
    format('Tiempo Minimo de Conexion (TMC) actual: ~w minutos.~n', [TmcActual]),
    write('Ingrese el nuevo valor en minutos (o Enter para mantener): '),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  writeln('No se modifico el TMC.')
    ;   (   number_string(NuevoTmc, Entrada),
            integer(NuevoTmc),
            NuevoTmc >= 0
        ->  establecer_tmc(NuevoTmc),
            format('TMC actualizado exitosamente a ~w minutos.~n', [NuevoTmc])
        ;   writeln('Error: Debe ingresar un numero entero mayor o igual a 0.')
        )
    ),
    bucle_menu.

% Opcion 5: Buscar rutas validas entre dos ciudades
ejecutar_opcion("5") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_origen_destino(Origen, Destino),
            pedir_dia(Dia)
        ->  leer_entero_opcional('Maximo de escalas [Enter = sin limite]: ', MaxEscalas),
            mostrar_rutas(Origen, Destino, Dia, MaxEscalas)
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).

% Opcion 6: Ruta de costo economico minimo
ejecutar_opcion("6") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_origen_destino(Origen, Destino),
            pedir_dia(Dia)
        ->  leer_entero_opcional('Maximo de escalas [Enter = sin limite]: ', MaxEscalas),
            mostrar_optimizacion_criterio(costo, Origen, Destino, Dia, MaxEscalas)
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).

% Opcion 7: Ruta de menor tiempo total
ejecutar_opcion("7") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_origen_destino(Origen, Destino),
            pedir_dia(Dia)
        ->  leer_entero_opcional('Maximo de escalas [Enter = sin limite]: ', MaxEscalas),
            mostrar_optimizacion_criterio(tiempo, Origen, Destino, Dia, MaxEscalas)
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).

% Opcion 8: Reporte ordenado de itinerarios con filtros
ejecutar_opcion("8") :-
    (   verificar_vuelos_cargados
    ->  nl,
        (   pedir_origen_destino(Origen, Destino),
            pedir_dia(Dia)
        ->  writeln('Criterio de orden: 1 = costo, 2 = tiempo'),
            write('Seleccione criterio [1]: '),
            read_line_to_string(user_input, EntradaCriterio),
            elegir_criterio(EntradaCriterio, Criterio),
            leer_entero_opcional('Maximo de escalas [Enter = sin limite]: ', MaxEscalas),
            leer_numero_positivo_opcional('Costo maximo en $ [Enter = sin limite]: ', MaxCosto),
            leer_entero_positivo_opcional('Tiempo maximo en minutos [Enter = sin limite]: ', MaxTiempo),
            construir_filtros([max_escalas-MaxEscalas, max_costo-MaxCosto, max_tiempo-MaxTiempo], Filtros),
            reporte_itinerarios(Origen, Destino, Dia, Criterio, Filtros)
        ;   true
        ),
        bucle_menu
    ;   bucle_menu
    ).

% Opcion 9: Salir
ejecutar_opcion("9") :-
    nl,
    writeln('Gracias por utilizar LogiExpress! Hasta luego.'), !.

% Opcion invalida
ejecutar_opcion(_) :-
    writeln('\nOpcion invalida. Intente de nuevo.'),
    bucle_menu.

% ===============================================================
% Predicados auxiliares (formateo y utilidades de consola)
% ===============================================================

determinar_ruta(Entrada, RutaFinal) :-
    (   Entrada == ""
    ->  ruta_defecto_vuelos(RutaFinal)
    ;   RutaFinal = Entrada
    ).

% Busca la ubicacion real de vuelos.txt:
% 1. En la carpeta actual (si se ejecuta desde la raiz: vuelos.txt)
% 2. En la carpeta superior (si se ejecuta desde prolog/: ../vuelos.txt)
% 3. Relativo al archivo fuente main.pl (si se abrio desde cualquier otro directorio)
ruta_defecto_vuelos(RutaFinal) :-
    (   exists_file('vuelos.txt')
    ->  RutaFinal = 'vuelos.txt'
    ;   exists_file('../vuelos.txt')
    ->  RutaFinal = '../vuelos.txt'
    ;   source_file(iniciar, ArchivoMain),
        file_directory_name(ArchivoMain, DirProlog),
        atomic_list_concat([DirProlog, '/../vuelos.txt'], RutaRelativa),
        absolute_file_name(RutaRelativa, RutaAbsoluta),
        exists_file(RutaAbsoluta)
    ->  RutaFinal = RutaAbsoluta
    ;   RutaFinal = 'vuelos.txt'
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
    format('  [~w] ~w -> ~w | Salida: ~w | Llegada: ~w | Precio: $~2f | Dias: ~w~n',
           [Codigo, Origen, Destino, SalidaStr, LlegadaStr, Precio, Dias]).

% ===============================================================
% Predicados auxiliares del Modulo 3
% ===============================================================

/* Lee un entero opcional: Enter produce ninguno.
   Si el valor no es un entero >= 0, muestra error y solicita reingreso. */
leer_entero_opcional(Prompt, Resultado) :-
    write(Prompt),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  Resultado = ninguno
    ;   (   number_string(Valor, Entrada),
            integer(Valor),
            Valor >= 0
        ->  Resultado = Valor
        ;   format('~nError: "~w" no es valido. Debe ingresar un numero entero mayor o igual a 0.~n', [Entrada]),
            leer_entero_opcional(Prompt, Resultado)
        )
    ).

/* Lee un numero (entero o decimal) opcional positivo (> 0): Enter produce ninguno.
   Si el valor no es un numero > 0, muestra error y solicita reingreso. */
leer_numero_positivo_opcional(Prompt, Resultado) :-
    write(Prompt),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  Resultado = ninguno
    ;   (   number_string(Valor, Entrada),
            number(Valor),
            Valor > 0
        ->  Resultado = Valor
        ;   format('~nError: "~w" no es valido. Debe ingresar un numero mayor a 0.~n', [Entrada]),
            leer_numero_positivo_opcional(Prompt, Resultado)
        )
    ).

/* Lee un entero opcional positivo (> 0): Enter produce ninguno.
   Si el valor no es un entero > 0, muestra error y solicita reingreso. */
leer_entero_positivo_opcional(Prompt, Resultado) :-
    write(Prompt),
    read_line_to_string(user_input, Entrada),
    (   Entrada == ""
    ->  Resultado = ninguno
    ;   (   number_string(Valor, Entrada),
            integer(Valor),
            Valor > 0
        ->  Resultado = Valor
        ;   format('~nError: "~w" no es valido. Debe ingresar un numero entero mayor a 0.~n', [Entrada]),
            leer_entero_positivo_opcional(Prompt, Resultado)
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

/* Muestra la ruta optima segun el criterio seleccionado */
mostrar_optimizacion_criterio(Criterio, Origen, Destino, Dia, MaxEscalas) :-
    construir_filtro_escalas(MaxEscalas, Filtros),
    buscar_rutas(Origen, Destino, Dia, Rutas),
    filtrar_rutas(Rutas, Filtros, Candidatas),
    (   Candidatas == []
    ->  format('~nNo hay itinerarios de ~w a ~w para el dia ~w.~n', [Origen, Destino, Dia])
    ;   ordenar_rutas(Criterio, Candidatas, [RutaOptima | _]),
        nl,
        (   Criterio == costo
        ->  writeln('=== Ruta de costo economico minimo ===')
        ;   writeln('=== Ruta de menor tiempo total ===')
        ),
        imprimir_detalle_ruta(RutaOptima, 1)
    ).


% ===============================================================
% Verificacion y lectura validada de ciudades
% ===============================================================

/* Solicita una ciudad por consola, recortando espacios y verificando
   sin distinguir mayusculas ni minusculas si existe en los vuelos cargados.
   Si existe, retorna el nombre oficial. De lo contrario, muestra un mensaje
   de error con la lista de ciudades disponibles y falla. */
pedir_ciudad(Prompt, CiudadOficial) :-
    write(Prompt),
    read_line_to_string(user_input, Entrada),
    (   normalizar_ciudad(Entrada, CiudadOficial)
    ->  true
    ;   normalize_space(string(EntradaLimpia), Entrada),
        format('~nError: La ciudad "~w" no existe en el registro de vuelos.~n', [EntradaLimpia]),
        mostrar_ciudades_disponibles,
        fail
    ).

/* Solicita origen y destino de forma secuencial. Si el origen falla,
   no solicita el destino. */
pedir_origen_destino(Origen, Destino) :-
    pedir_ciudad('Ciudad de origen: ', Origen),
    pedir_ciudad('Ciudad de destino: ', DestinoTemp),
    (   Origen == DestinoTemp
    ->  format('~nError: La ciudad de origen y destino no pueden ser iguales ("~w").~n', [Origen]),
        fail
    ;   Destino = DestinoTemp
    ).

/* Muestra las ciudades disponibles registradas en la base de datos */
mostrar_ciudades_disponibles :-
    ciudades_disponibles(Ciudades),
    atomic_list_concat(Ciudades, ', ', StrCiudades),
    format('Ciudades disponibles: ~w~n', [StrCiudades]).

/* Solicita el dia del viaje y valida que sea un dia reconocido.
   Si no es valido, muestra el mensaje de error con los valores aceptados y falla. */
pedir_dia(DiaOficial) :-
    write('Dia del viaje (ej. L, martes): '),
    read_line_to_string(user_input, Entrada),
    (   normalizar_dia(Entrada, DiaOficial)
    ->  true
    ;   normalize_space(string(EntradaLimpia), Entrada),
        format('~nError: "~w" no es un dia valido.~n', [EntradaLimpia]),
        writeln('Valores aceptados: L, M, Mi, J, V, S, D (o nombres completos: Lunes, Martes...).'),
        fail
    ).

% ===============================================================
% Verificacion de vuelos cargados
% ===============================================================

verificar_vuelos_cargados :-
    (   vuelo(_, _, _, _, _, _, _)
    ->  true
    ;   nl,
        writeln('Primero debe cargar un archivo de vuelos (opcion 1).'),
        fail
    ).
