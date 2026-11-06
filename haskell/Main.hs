module Main where

import CargaDatos
import Rutas
import Optimizacion
import System.Directory (doesFileExist)
import System.IO (hFlush, stdout)
import Text.Printf (printf)

-- ===============================================================
-- Menu principal interactivo (CLI) de LogiExpress en Haskell
-- ===============================================================

main :: IO ()
main = do
    putStrLn "   Logi Express - Sistema de Gestion Aerea  "
    bucleMenu [] tmcPorDefecto

bucleMenu :: [Vuelo] -> Int -> IO ()
bucleMenu vuelos tmc = do
    putStrLn "\n Menu  "
    putStrLn "1. Cargar archivo de vuelos"
    putStrLn "2. Consultar vuelos que salen de una ciudad"
    putStrLn "3. Consultar vuelos que llegan a una ciudad"
    putStrLn "4. Configuracion TMC (Tiempo Minimo de Conexion)"
    putStrLn "5. Buscar rutas validas entre dos ciudades"
    putStrLn "6. Ruta de costo economico minimo"
    putStrLn "7. Ruta de menor tiempo total"
    putStrLn "8. Reporte ordenado de itinerarios (costo/tiempo y filtros)"
    putStrLn "9. Salir"
    putStr "Seleccione una opcion: "
    hFlush stdout
    opcion <- getLine
    ejecutarOpcion opcion vuelos tmc

ejecutarOpcion :: String -> [Vuelo] -> Int -> IO ()

-- Opcion 1: Cargar archivo de vuelos
ejecutarOpcion "1" vuelos tmc = cargarArchivo vuelos tmc

-- Opcion 2: Consultar vuelos que salen de una ciudad
ejecutarOpcion "2" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudad <- pedir "Ingrese la ciudad de origen: "
        let encontrados = vuelosDesde ciudad vuelos
        if null encontrados
            then putStrLn ("\nNo se encontraron vuelos saliendo de \"" ++ ciudad ++ "\".")
            else do
                putStrLn ("\nVuelos saliendo de " ++ ciudad ++ ":")
                putStrLn separador
                mapM_ imprimirVuelo encontrados
        bucleMenu vuelos tmc

-- Opcion 3: Consultar vuelos que llegan a una ciudad
ejecutarOpcion "3" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudad <- pedir "Ingrese la ciudad de destino: "
        let encontrados = vuelosHacia ciudad vuelos
        if null encontrados
            then putStrLn ("\nNo se encontraron vuelos llegando a \"" ++ ciudad ++ "\".")
            else do
                putStrLn ("\nVuelos llegando a " ++ ciudad ++ ":")
                putStrLn separador
                mapM_ imprimirVuelo encontrados
        bucleMenu vuelos tmc

-- Opcion 4: Configuracion del TMC
ejecutarOpcion "4" vuelos tmc = do
    putStrLn ("\nTiempo Minimo de Conexion (TMC) actual: " ++ show tmc ++ " minutos.")
    entrada <- pedir "Ingrese el nuevo valor en minutos (o Enter para mantener): "
    if null entrada
        then do
            putStrLn "No se modifico el TMC."
            bucleMenu vuelos tmc
        else case leerEntero entrada of
            Just nuevoTmc
                | nuevoTmc >= 0 -> do
                    putStrLn ("TMC actualizado exitosamente a " ++ show nuevoTmc ++ " minutos.")
                    bucleMenu vuelos nuevoTmc
            _ -> do
                putStrLn "Error: debe ingresar un numero entero mayor o igual a 0."
                bucleMenu vuelos tmc

-- Opcion 5: Buscar rutas validas entre dos ciudades
ejecutarOpcion "5" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudadOrigen <- pedir "Ciudad de origen: "
        ciudadDestino <- pedir "Ciudad de destino: "
        diaConsulta <- pedir "Dia del viaje (ej. L, martes, Diario): "
        textoEscalas <- pedir "Maximo de escalas [Enter = sin limite]: "
        let filtros = sinFiltros { maxEscalas = leerEnteroOpcional textoEscalas }
            rutas = buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta
                    (maxEscalas filtros)
            ordenadas = ordenarRutas "escalas" rutas
        mostrarReporte ciudadOrigen ciudadDestino diaConsulta "escalas" ordenadas
        bucleMenu vuelos tmc

-- Opcion 6: Ruta de costo economico minimo
ejecutarOpcion "6" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudadOrigen <- pedir "Ciudad de origen: "
        ciudadDestino <- pedir "Ciudad de destino: "
        diaConsulta <- pedir "Dia del viaje (ej. L, martes, Diario): "
        textoEscalas <- pedir "Maximo de escalas [Enter = sin limite]: "
        let filtros = sinFiltros { maxEscalas = leerEnteroOpcional textoEscalas }
            candidatas =
                buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta
                    (maxEscalas filtros)
        case rutaMinCosto candidatas of
            Just rutaEconomica -> do
                putStrLn "\n=== Ruta de costo economico minimo ==="
                putStrLn (descripcionRuta rutaEconomica)
            Nothing -> putStrLn ("\nNo hay itinerarios de " ++ ciudadOrigen ++ " a "
                                 ++ ciudadDestino ++ " para el dia " ++ diaConsulta ++ ".")
        bucleMenu vuelos tmc

-- Opcion 7: Ruta de menor tiempo total
ejecutarOpcion "7" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudadOrigen <- pedir "Ciudad de origen: "
        ciudadDestino <- pedir "Ciudad de destino: "
        diaConsulta <- pedir "Dia del viaje (ej. L, martes, Diario): "
        textoEscalas <- pedir "Maximo de escalas [Enter = sin limite]: "
        let filtros = sinFiltros { maxEscalas = leerEnteroOpcional textoEscalas }
            candidatas =
                buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta
                    (maxEscalas filtros)
        case rutaMinTiempo candidatas of
            Just rutaRapida -> do
                putStrLn "\n=== Ruta de menor tiempo total ==="
                putStrLn (descripcionRuta rutaRapida)
            Nothing -> putStrLn ("\nNo hay itinerarios de " ++ ciudadOrigen ++ " a "
                                 ++ ciudadDestino ++ " para el dia " ++ diaConsulta ++ ".")
        bucleMenu vuelos tmc

-- Opcion 8: Reporte ordenado de itinerarios con filtros
ejecutarOpcion "8" vuelos tmc
    | null vuelos = pedirCarga tmc
    | otherwise = do
        putStrLn ""
        ciudadOrigen <- pedir "Ciudad de origen: "
        ciudadDestino <- pedir "Ciudad de destino: "
        diaConsulta <- pedir "Dia del viaje (ej. L, martes, Diario): "
        putStrLn "Criterio de orden: 1 = costo, 2 = tiempo"
        textoCriterio <- pedir "Seleccione criterio [1]: "
        let criterio = if textoCriterio == "2" then "tiempo" else "costo"
        textoEscalas <- pedir "Maximo de escalas [Enter = sin limite]: "
        textoCosto <- pedir "Costo maximo en $ [Enter = sin limite]: "
        textoTiempo <- pedir "Tiempo maximo en minutos [Enter = sin limite]: "
        let filtros = Filtros
                { maxEscalas = leerEnteroOpcional textoEscalas
                , maxCosto = leerDoubleOpcional textoCosto
                , maxTiempo = leerEnteroOpcional textoTiempo
                }
        let rutas = buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta
                (maxEscalas filtros)
        let ordenadas = ordenarRutas criterio (filtrarRutas filtros rutas)
        mostrarReporte ciudadOrigen ciudadDestino diaConsulta criterio ordenadas
        bucleMenu vuelos tmc

-- Opcion 9: Salir
ejecutarOpcion "9" _ _ =
    putStrLn "\n¡Gracias por utilizar LogiExpress! Hasta luego."

-- Opcion invalida
ejecutarOpcion _ vuelos tmc = do
    putStrLn "\nOpcion invalida. Intente de nuevo."
    bucleMenu vuelos tmc


-- Predicados auxiliares (entrada/salida y formato)

-- Solicita un dato mostrando un mensaje
pedir :: String -> IO String
pedir mensaje = do
    putStr mensaje
    hFlush stdout
    getLine

-- Avisa que primero hay que cargar el archivo de vuelos
pedirCarga :: Int -> IO ()
pedirCarga tmc = do
    putStrLn "\nPrimero debe cargar un archivo de vuelos (opcion 1)."
    bucleMenu [] tmc

-- Carga el archivo indicado por el usuario; Enter usa la ruta por defecto
cargarArchivo :: [Vuelo] -> Int -> IO ()
cargarArchivo vuelosAnteriores tmc = do
    entrada <- pedir "Ingrese la ruta del archivo [por defecto: vuelos.txt]: "
    ruta <- determinarRuta entrada
    existe <- doesFileExist ruta
    if not existe
        then do
            putStrLn ("\nError: el archivo \"" ++ ruta ++ "\" no existe.")
            bucleMenu vuelosAnteriores tmc
        else do
            vuelos <- cargar_vuelos ruta
            putStrLn ("\nSe han cargado " ++ show (length vuelos)
                      ++ " vuelos exitosamente desde \"" ++ ruta ++ "\".")
            bucleMenu vuelos tmc

-- Ruta por defecto: raiz del repositorio o carpeta haskell
determinarRuta :: String -> IO FilePath
determinarRuta entrada
    | not (null entrada) = return entrada
    | otherwise = do
        enRaiz <- doesFileExist "vuelos.txt"
        return (if enRaiz then "vuelos.txt" else "../vuelos.txt")

-- Muestra un reporte ordenado de itinerarios
mostrarReporte :: String -> String -> String -> String -> [[Vuelo]] -> IO ()
mostrarReporte ciudadOrigen ciudadDestino diaConsulta criterio rutas
    | null rutas =
        putStrLn ("\nNo hay itinerarios de " ++ ciudadOrigen ++ " a " ++ ciudadDestino
                  ++ " para el dia " ++ diaConsulta ++ " con los filtros indicados.")
    | otherwise = do
        putStrLn ("\n=== Itinerarios de " ++ ciudadOrigen ++ " a " ++ ciudadDestino
                  ++ " (dia " ++ diaConsulta ++ ") ===")
        putStrLn ("Criterio de orden: " ++ criterio
                  ++ " | Total de rutas: " ++ show (length rutas))
        putStrLn ("Distribucion por escalas: " ++ resumenGrupos rutas)
        putStrLn ""
        putStrLn (descripcionRutas rutas)

-- Parseo de enteros y decimales opcionales 
leerEntero :: String -> Maybe Int
leerEntero texto =
    case reads texto of
        [(numero, "")] -> Just numero
        _ -> Nothing

leerEnteroOpcional :: String -> Maybe Int
leerEnteroOpcional texto
    | null texto = Nothing
    | otherwise =
        case leerEntero texto of
            Just numero | numero >= 0 -> Just numero
            _ -> Nothing

leerDoubleOpcional :: String -> Maybe Double
leerDoubleOpcional texto
    | null texto = Nothing
    | otherwise =
        case reads texto of
            [(numero, "")] | numero >= 0 -> Just numero
            _ -> Nothing

-- Impresion de un vuelo individual (consultas basicas)
imprimirVuelo :: Vuelo -> IO ()
imprimirVuelo vueloActual =
    putStrLn (printf "  [%s] %s -> %s | Salida: %s | Llegada: %s | Precio: $%.2f | Dias: %s"
                     (codigo vueloActual)
                     (origen vueloActual)
                     (destino vueloActual)
                     (minutos_a_hora (salida vueloActual))
                     (minutos_a_hora (llegada vueloActual))
                     (precio vueloActual)
                     (dias vueloActual))

separador :: String
separador = replicate 80 '-'
