module Rutas where

import CargaDatos
import Data.Char (toLower)

-- ===============================================================
-- Modulo 2: Busqueda avanzada de rutas
-- ---------------------------------------------------------------
-- DFS recursivo sobre el grafo de vuelos con control de ciclos,
-- validacion de dias de operacion y Tiempo Minimo de Conexion.
-- Una ruta se representa como una lista de vuelos conectados [Vuelo].
-- ===============================================================

-- Normaliza el dia ingresado por el usuario al codigo usado en los datos
normalizar_dia :: String -> Maybe String
normalizar_dia entrada =
    case map toLower entrada of
        "l"         -> Just "L"
        "lunes"     -> Just "L"
        "m"         -> Just "M"
        "martes"    -> Just "M"
        "mi"        -> Just "Mi"
        "miercoles" -> Just "Mi"
        "miércoles" -> Just "Mi"
        "j"         -> Just "J"
        "jueves"    -> Just "J"
        "v"         -> Just "V"
        "viernes"   -> Just "V"
        "s"         -> Just "S"
        "sabado"    -> Just "S"
        "sábado"    -> Just "S"
        "d"         -> Just "D"
        "domingo"   -> Just "D"
        _           -> Nothing

-- Verifica si un vuelo opera el dia consultado
opera_dia :: String -> String -> Bool
opera_dia diasVuelo diaConsulta =
    case normalizar_dia diaConsulta of
        Nothing -> False
        Just diaNorm ->
            let diasNormalizados = map toLower diasVuelo
            in diasNormalizados == "diario"
               || diaNorm `elem` dividir_por '-' diasVuelo

-- Validacion de una escala segun el Tiempo Minimo de Conexion (TMC):
-- la salida del siguiente vuelo debe ser posterior a la llegada + TMC
conexion_valida :: Int -> Int -> Int -> Bool
conexion_valida tmc llegadaAnterior salidaSiguiente =
    salidaSiguiente >= llegadaAnterior + tmc

-- Busca todas las rutas validas de ciudadOrigen a ciudadDestino para un dia
buscar_rutas :: [Vuelo] -> Int -> String -> String -> String -> [[Vuelo]]
buscar_rutas vuelos tmc ciudadOrigen ciudadDestino diaConsulta =
    dfs ciudadOrigen Nothing [ciudadOrigen]
  where
    -- Estado del DFS: ciudad actual, llegada del vuelo anterior y
    -- lista de ciudades visitadas (control de ciclos).
    dfs actual llegadaAnterior visitados =
        concatMap (seguir llegadaAnterior visitados) (vuelosDesde actual vuelos)

    seguir llegadaAnterior visitados vueloActual
        | not (opera_dia (dias vueloActual) diaConsulta) = []
        | not (conexion_ok llegadaAnterior (salida vueloActual)) = []
        | destino vueloActual == ciudadDestino = [[vueloActual]]
        | destino vueloActual `elem` visitados = []
        | otherwise =
            map (vueloActual :)
                (dfs (destino vueloActual)
                     (Just (llegada vueloActual))
                     (destino vueloActual : visitados))

    -- El primer vuelo no requiere conexion; los demas si
    conexion_ok Nothing _ = True
    conexion_ok (Just llegadaAnterior) salidaSiguiente =
        conexion_valida tmc llegadaAnterior salidaSiguiente
