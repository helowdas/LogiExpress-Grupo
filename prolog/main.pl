

:- consult('carga_datos.pl').
:- consult('utilidades.pl').

% Predicados de inicio
iniciar :- menu.

menu :-
    nl,
    writeln(' ░▒▓█►─═  𝗟𝗼𝗴𝗶𝗘𝘅𝗽𝗿𝗲𝘀𝘀 - 𝗦𝗶𝘀𝘁𝗲𝗺𝗮 𝗱𝗲 𝗚𝗲𝘀𝘁𝗶ó𝗻 𝗔é𝗿𝗲𝗮 ═─◄█▓▒░ '),
    bucle_menu.

bucle_menu :-
    nl,
    writeln('꧁༒༺ Menu ༻༒꧂'),
    writeln('1. Cargar archivo de vuelos'),
    writeln('2. Consultar vuelos que salen de una ciudad'),
    writeln('3. Consultar vuelos que llegan a una ciudad'),
    writeln('4. Configuración TMC (Tiempo Mínimo de Conexión)'),
    writeln('5. Salir'),
    write('Seleccione una opción: '),
    read_line_to_string(user_input, Opcion),
    ejecutar_opcion(Opcion).

ejecutar_opcion("1") :-
    writeln('\n'),
    bucle_menu.

ejecutar_opcion("2") :-
    writeln('\n'),
    bucle_menu.

ejecutar_opcion("3") :-
    writeln('\n'),
    bucle_menu.

ejecutar_opcion("4") :-
    writeln('\n'),
    bucle_menu.

ejecutar_opcion("5") :-
    writeln('\n'), !.

ejecutar_opcion(_) :-
    writeln('\nOpción inválida. Intente de nuevo.'),
    bucle_menu.

