
/*esto le dice a prolog que habra una instancia vuelo con 7 argumentos para consumir el archivo vuelos.txt*/

:- dynamic vuelo/7.




cargar_datos(Ruta):-
    open(Ruta,read,Stream),

    leer_lineas(Stream), close(Stream).

/*caso base*/
leer_lineas(Stream):-
    read_line_to_string(Stream,end_of_file),!.

/*String completo: linea que se acaba de leer Separadadores: caracteres para cortar en este caso el | CaracteresBorrar: sobrantes como \r\n listaresultados: la lista donde pondra las variables resultantes*/
leer_lineas(Stream):-
    read_line_to_string(Stream,Linea),
    split_string(Linea,"|","\r\n",[Origen,Destino,Salida,Llegada,Precio,Codigo,Dias]),
    assertz(vuelo(Origen,Destino,Salida,Llegada,Precio,Codigo,Dias)),
    leer_lineas(Stream).


 