module Rutas
    ( buscar_rutas
    , buscar_rutas_con_escalas
    , normalizar_dia
    , opera_dia
    , conexion_valida
    ) where

import CargaDatos
import Utilidades (operaDia, conexionValida, normalizarDia)


-- Reexportacion de funciones de Utilidades
normalizar_dia :: String -> Maybe String
normalizar_dia = normalizarDia

opera_dia :: String -> String -> Bool
opera_dia = operaDia

conexion_valida :: Int -> Int -> Int -> Bool
conexion_valida = conexionValida

-- Busca todas las rutas validas de ciudadOrigen a ciudadDestino para un dia 
buscar_rutas :: [Vuelo] -> Int -> String -> String -> String -> [[Vuelo]]
buscar_rutas vuelos tmc ciudadOrigen ciudadDestino diaConsulta =
    buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta Nothing

-- Busca todas las rutas validas con poda opcional por limite de escalas K 
buscar_rutas_con_escalas :: [Vuelo] -> Int -> String -> String -> String -> Maybe Int -> [[Vuelo]]
buscar_rutas_con_escalas vuelos tmc ciudadOrigen ciudadDestino diaConsulta maxEscalas =
    dfs ciudadOrigen Nothing [ciudadOrigen] 0
  where
    dfs actual llegadaAnterior visitados escalasActuales
        | limiteAlcanzado escalasActuales = []
        | otherwise = concatMap (seguir llegadaAnterior visitados escalasActuales) (vuelosDesde actual vuelos)

    -- Criterio de corte si se supera el máximo de escalas permitido
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

    -- El primer vuelo no requiere conexion previa y los siguientes deben respetar el TMC
    conexion_ok Nothing _ = True
    conexion_ok (Just llegadaAnterior) salidaSiguiente =
        conexion_valida tmc llegadaAnterior salidaSiguiente
