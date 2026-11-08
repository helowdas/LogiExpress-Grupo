module Utilidades
    ( minutosAHora
    , normalizarDia
    , parsearDias
    , operaDia
    , conexionValida
    , tmcPorDefecto
    ) where

import Data.Char (toLower, isSpace)

--  TMC por defecto en minutos (configurable)
tmcPorDefecto :: Int
tmcPorDefecto = 45

--  Convierte minutos desde las 00:00 a cadena en formato militar "HH:MM"
minutosAHora :: Int -> String
minutosAHora totalMin =
    let h = totalMin `div` 60
        m = totalMin `mod` 60
        dosDigitos n = if n < 10 then "0" ++ show n else show n
    in dosDigitos h ++ ":" ++ dosDigitos m

-- Normaliza el día ingresado (código o nombre completo) al formato estandar (L, M, Mi, J, V, S, D)
normalizarDia :: String -> Maybe String
normalizarDia entrada =
    let trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace
    in case map toLower (trim entrada) of
    d | d `elem` ["l", "lunes"]                   -> Just "L"
      | d `elem` ["m", "martes"]                  -> Just "M"
      | d `elem` ["mi", "miercoles", "miércoles"] -> Just "Mi"
      | d `elem` ["j", "jueves"]                  -> Just "J"
      | d `elem` ["v", "viernes"]                 -> Just "V"
      | d `elem` ["s", "sabado", "sábado"]         -> Just "S"
      | d `elem` ["d", "domingo"]                 -> Just "D"
      | otherwise                                 -> Nothing

-- Descompone la cadena de días de un vuelo en una lista
-- Si es Diario, se expande a los 7 días de la semana
parsearDias :: String -> [String]
parsearDias diasStr
    | map toLower diasStr == "diario" = ["L", "M", "Mi", "J", "V", "S", "D"]
    | otherwise                       = dividirPor '-' diasStr

-- Verifica si un vuelo opera en un día dado
operaDia :: String -> String -> Bool
operaDia diasVuelo diaConsulta =
    case normalizarDia diaConsulta of
        Just diaNorm -> diaNorm `elem` parsearDias diasVuelo
        Nothing      -> False

-- Valida si la conexión entre dos vuelos cumple el Tiempo Mínimo de Conexión (TMC)
-- llegada y salida deben estar expresadas en minutos
conexionValida :: Int -> Int -> Int -> Bool
conexionValida tmcVal llegadaMin salidaMin =
    salidaMin >= llegadaMin + tmcVal

-- Función auxiliar para dividir una cadena por un carácter delimitador
dividirPor :: Char -> String -> [String]
dividirPor _ "" = []
dividirPor sep str =
    let (primero, resto) = break (== sep) str
    in primero : case resto of
                    []      -> []
                    (_:mas) -> dividirPor sep mas

