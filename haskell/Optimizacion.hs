module Optimizacion where

import CargaDatos
import Data.List (intercalate)
import Text.Printf (printf)

-- ===============================================================
-- Modulo 3: Optimizacion y filtrado de listas
-- ---------------------------------------------------------------
-- - Costo economico de una ruta (sumatoria de precios)
-- - Tiempo total de viaje (llegada final - salida inicial)
-- - Ordenamiento propio sobre listas: mergesort y quicksort
-- - Ruta de costo minimo y ruta de menor tiempo
-- - Filtros finales: maximo de escalas, costo y tiempo
-- - Agrupamiento de itinerarios por numero de escalas
-- - Reporte ordenado por costo o por tiempo
-- ===============================================================

-- ===============================================================
-- 1. Metricas de una ruta
-- ===============================================================

-- Costo total: suma de los precios de todos los vuelos de la ruta
costoRuta :: [Vuelo] -> Double
costoRuta = foldr (\vueloActual acumulado -> precio vueloActual + acumulado) 0

-- Tiempo total: llegada al destino final menos salida inicial.
-- Incluye de forma implicita las esperas entre escalas.
tiempoRuta :: [Vuelo] -> Int
tiempoRuta [] = 0
tiempoRuta (primerVuelo : resto) =
    llegada (ultimoVuelo (primerVuelo : resto)) - salida primerVuelo

-- Ultimo vuelo de una ruta (recursivo, sin usar last)
ultimoVuelo :: [Vuelo] -> Vuelo
ultimoVuelo [vueloActual] = vueloActual
ultimoVuelo (_ : resto) = ultimoVuelo resto
ultimoVuelo [] = error "ultimoVuelo: ruta vacia"

-- Cantidad de escalas = cantidad de vuelos - 1
escalasRuta :: [Vuelo] -> Int
escalasRuta ruta = max 0 (length ruta - 1)

-- Ciudades visitadas en orden: origen y luego cada destino
ciudadesRuta :: [Vuelo] -> [String]
ciudadesRuta [] = []
ciudadesRuta (primerVuelo : resto) =
    origen primerVuelo : map destino (primerVuelo : resto)

-- Codigos de vuelo de la ruta
codigosRuta :: [Vuelo] -> [String]
codigosRuta = map codigo

-- ===============================================================
-- 2. Ordenamiento implementado sobre listas
-- ===============================================================

-- Comparadores segun el criterio elegido
porCosto :: [Vuelo] -> [Vuelo] -> Bool
porCosto ruta1 ruta2 = costoRuta ruta1 <= costoRuta ruta2

porTiempo :: [Vuelo] -> [Vuelo] -> Bool
porTiempo ruta1 ruta2 = tiempoRuta ruta1 <= tiempoRuta ruta2

porEscalas :: [Vuelo] -> [Vuelo] -> Bool
porEscalas ruta1 ruta2 = escalasRuta ruta1 <= escalasRuta ruta2

comparador :: String -> [Vuelo] -> [Vuelo] -> Bool
comparador "tiempo" = porTiempo
comparador "escalas" = porEscalas
comparador _ = porCosto

-- mergesort propio (estable): divide, ordena cada mitad y mezcla
mergesort :: (a -> a -> Bool) -> [a] -> [a]
mergesort _ [] = []
mergesort _ [elemento] = [elemento]
mergesort menor elementos =
    mezclar menor (mergesort menor izquierda) (mergesort menor derecha)
  where
    (izquierda, derecha) = dividirLista elementos

dividirLista :: [a] -> ([a], [a])
dividirLista elementos = splitAt (length elementos `div` 2) elementos

mezclar :: (a -> a -> Bool) -> [a] -> [a] -> [a]
mezclar _ [] derecha = derecha
mezclar _ izquierda [] = izquierda
mezclar menor (elemento1 : resto1) (elemento2 : resto2)
    | menor elemento1 elemento2 = elemento1 : mezclar menor resto1 (elemento2 : resto2)
    | otherwise = elemento2 : mezclar menor (elemento1 : resto1) resto2

-- quicksort propio: pivote, menores/iguales y mayores
quicksort :: (a -> a -> Bool) -> [a] -> [a]
quicksort _ [] = []
quicksort menor (pivote : resto) =
    quicksort menor (filter (\elemento -> menor elemento pivote) resto)
    ++ [pivote]
    ++ quicksort menor (filter (\elemento -> not (menor elemento pivote)) resto)

-- Ordena una lista de rutas segun "costo", "tiempo" o "escalas"
ordenarRutas :: String -> [[Vuelo]] -> [[Vuelo]]
ordenarRutas criterio = mergesort (comparador criterio)

-- ===============================================================
-- 3. Optimizacion por doble criterio
-- ===============================================================

-- Devuelve la primera ruta segun el criterio (Nothing si no hay rutas)
minimoPor :: (a -> a -> Bool) -> [a] -> Maybe a
minimoPor _ [] = Nothing
minimoPor menor (primero : resto) = Just (foldl elegir primero resto)
  where
    elegir actual candidato
        | menor candidato actual = candidato
        | otherwise = actual

rutaMinCosto :: [[Vuelo]] -> Maybe [Vuelo]
rutaMinCosto = minimoPor porCosto

rutaMinTiempo :: [[Vuelo]] -> Maybe [Vuelo]
rutaMinTiempo = minimoPor porTiempo

-- ===============================================================
-- 4. Filtros finales
-- ===============================================================

-- Filtros opcionales: Nothing significa "sin limite"
data Filtros = Filtros
    { maxEscalas :: Maybe Int
    , maxCosto :: Maybe Double
    , maxTiempo :: Maybe Int
    } deriving (Show)

sinFiltros :: Filtros
sinFiltros = Filtros Nothing Nothing Nothing

cumpleFiltros :: Filtros -> [Vuelo] -> Bool
cumpleFiltros filtros ruta =
    cumpleMaxEscalas filtros ruta
    && cumpleMaxCosto filtros ruta
    && cumpleMaxTiempo filtros ruta

cumpleMaxEscalas :: Filtros -> [Vuelo] -> Bool
cumpleMaxEscalas (Filtros Nothing _ _) _ = True
cumpleMaxEscalas (Filtros (Just maximo) _ _) ruta = escalasRuta ruta <= maximo

cumpleMaxCosto :: Filtros -> [Vuelo] -> Bool
cumpleMaxCosto (Filtros _ Nothing _) _ = True
cumpleMaxCosto (Filtros _ (Just maximo) _) ruta = costoRuta ruta <= maximo

cumpleMaxTiempo :: Filtros -> [Vuelo] -> Bool
cumpleMaxTiempo (Filtros _ _ Nothing) _ = True
cumpleMaxTiempo (Filtros _ _ (Just maximo)) ruta = tiempoRuta ruta <= maximo

filtrarRutas :: Filtros -> [[Vuelo]] -> [[Vuelo]]
filtrarRutas filtros = filter (cumpleFiltros filtros)

-- ===============================================================
-- 5. Agrupamiento por numero de escalas
-- ===============================================================

agruparPorEscalas :: [[Vuelo]] -> [(Int, [[Vuelo]])]
agruparPorEscalas rutas = agrupar (ordenarRutas "escalas" rutas)

agrupar :: [[Vuelo]] -> [(Int, [[Vuelo]])]
agrupar [] = []
agrupar (ruta : resto) =
    let escalas = escalasRuta ruta
        (grupo, restoFinal) = separarPorEscalas escalas resto
    in (escalas, ruta : grupo) : agrupar restoFinal

separarPorEscalas :: Int -> [[Vuelo]] -> ([[Vuelo]], [[Vuelo]])
separarPorEscalas _ [] = ([], [])
separarPorEscalas escalas (ruta : resto) =
    let (grupo, restoFinal) = separarPorEscalas escalas resto
    in if escalasRuta ruta == escalas
          then (ruta : grupo, restoFinal)
          else (grupo, ruta : restoFinal)

-- ===============================================================
-- 6. Reporte ordenado de itinerarios
-- ===============================================================

-- Descripcion de una ruta con sus metricas, para la consola
descripcionRuta :: [Vuelo] -> String
descripcionRuta [] = "(ruta vacia)"
descripcionRuta ruta@(primerVuelo : _) =
    "[" ++ intercalate "+" (codigosRuta ruta) ++ "] "
    ++ intercalate " -> " (ciudadesRuta ruta) ++ "\n"
    ++ "   Costo: $" ++ printf "%.2f" (costoRuta ruta)
    ++ " | Duracion: " ++ formatoDuracion (tiempoRuta ruta)
    ++ " (" ++ show (tiempoRuta ruta) ++ " min)"
    ++ " | Escalas: " ++ show (escalasRuta ruta)
    ++ " | Horario: " ++ minutos_a_hora (salida primerVuelo)
    ++ "-" ++ minutos_a_hora (llegada (ultimoVuelo ruta))

-- Lista de rutas numeradas, una por bloque
descripcionRutas :: [[Vuelo]] -> String
descripcionRutas rutas = unlines (concatMap numerada (zip [1 ..] rutas))
  where
    numerada (numero, ruta) =
        (show numero ++ ". " ++ descripcionRuta ruta) : [""]

-- Resumen "directos: 2 | 1 escala(s): 3 | ..."
resumenGrupos :: [[Vuelo]] -> String
resumenGrupos rutas =
    intercalate " | " (map describir (agruparPorEscalas rutas))
  where
    describir (escalas, grupo)
        | escalas == 0 = "directos: " ++ show (length grupo)
        | otherwise = show escalas ++ " escala(s): " ++ show (length grupo)

-- Duracion en formato "2h 15m"
formatoDuracion :: Int -> String
formatoDuracion minutos =
    show (minutos `div` 60) ++ "h " ++ show (minutos `mod` 60) ++ "m"
