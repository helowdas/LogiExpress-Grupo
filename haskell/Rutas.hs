module Rutas
    ( buscar_rutas
    , buscar_rutas_con_escalas
    , mostrar_rutas
    , mostrar_rutas_con_escalas
    , normalizar_dia
    , opera_dia
    , conexion_valida
    ) where

import CargaDatos
import Utilidades (operaDia, conexionValida, normalizarDia, minutosAHora)



-- Reexportacion de funciones de Utilidades para mantener compatibilidad
normalizar_dia :: String -> Maybe String
normalizar_dia = normalizarDia

opera_dia :: String -> String -> Bool
opera_dia = operaDia

conexion_valida :: Int -> Int -> Int -> Bool
conexion_valida = conexionValida

-- Busca todas las rutas validas de ciudadOrigen a ciudadDestino para un dia (sin limite de escalas)
buscar_rutas :: [Vuelo] -> Int -> String -> String -> String -> [[Vuelo]]
buscar_rutas vuelos tmc ciudadOrigen ciudadDestino diaConsulta =
    buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta Nothing

-- Busca todas las rutas validas con poda opcional por limite de escalas K (K escalas intermedias)
buscar_rutas_con_escalas :: [Vuelo] -> Int -> String -> String -> String -> Maybe Int -> [[Vuelo]]
buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta maxEscalas =
    dfs ciudadOrigen Nothing [ciudadOrigen] 0
  where
    dfs actual llegadaAnterior visitados escalasActuales
        | limiteAlcanzado escalasActuales = []
        | otherwise = concatMap (seguir llegadaAnterior visitados escalasActuales) (vuelosDesde actual vuelos)

    -- Poda del DFS si se supera el maximo de escalas permitido
    limiteAlcanzado esc = case maxEscalas of
        Just k  -> esc > k
        Nothing -> False

    seguir llegadaAnterior visitados escalasActuales vueloActual
        | not (opera_dia (dias vueloActual) diaConsulta) = []
        | not (conexion_ok llegadaAnterior (salida vueloActual)) = []
        | destino vueloActual == ciudadDestino = [[vueloActual]]
        | destino vueloActual `elem` visitados = []
        | otherwise =
            map (vueloActual :)
                (dfs (destino vueloActual)
                     (Just (llegada vueloActual))
                     (destino vueloActual : visitados)
                     (escalasActuales + 1))

    -- El primer vuelo no requiere conexion previa; los siguientes deben respetar el TMC
    conexion_ok Nothing _ = True
    conexion_ok (Just llegadaAnterior) salidaSiguiente =
        conexion_valida tmc llegadaAnterior salidaSiguiente

-- Visualizacion de rutas en consola para pruebas del Modulo 2

-- | Muestra en consola las rutas encontradas (sin limite de escalas)
mostrar_rutas :: [Vuelo] -> Int -> String -> String -> String -> IO ()
mostrar_rutas vuelos tmc ciudadOrigen ciudadDestino diaConsulta =
    mostrar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta Nothing

--  Muestra en consola las rutas encontradas con limite opcional de escalas
mostrar_rutas_con_escalas :: [Vuelo] -> Int -> String -> String -> String -> Maybe Int -> IO ()
mostrar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta maxEscalas = do
    let rutas = buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta maxEscalas
    putStrLn "\n======================================================"
    putStrLn ("  Rutas de " ++ ciudadOrigen ++ " a " ++ ciudadDestino ++ " (" ++ diaConsulta ++ ")")
    case maxEscalas of
        Just k  -> putStrLn ("  Limite de escalas: " ++ show k)
        Nothing -> return ()
    putStrLn ("  Total encontradas: " ++ show (length rutas))
    putStrLn "======================================================"
    if null rutas
        then putStrLn "  No se encontraron rutas disponibles."
        else mapM_ imprimirRuta (zip [1..] rutas)
    putStrLn ""
  where
    imprimirRuta (idx, ruta) = do
        let escalas = max 0 (length ruta - 1)
        putStrLn ("\n[Ruta #" ++ show (idx :: Int) ++ "] (" ++ show escalas ++ " escala(s)):")
        mapM_ (\v -> putStrLn ("   -> " ++ codigo v ++ ": " ++ origen v ++ " -> " ++ destino v
                            ++ " | " ++ minutosAHora (salida v) ++ " - " ++ minutosAHora (llegada v)
                            ++ " | $" ++ show (precio v))) ruta
