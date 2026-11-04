module CargaDatos where

import Data.List (nub)

data Vuelo = Vuelo{
    origen :: String,
    destino :: String,
    salida :: Int,
    llegada :: Int,
    precio :: Double,
    codigo :: String,
    dias :: String
} deriving (Show, Eq)

-- Configuración del Tiempo Mínimo de Conexión (TMC) por defecto: 45 min
tmcPorDefecto :: Int
tmcPorDefecto = 45


type Grafo = [(String, [Vuelo])]


construirGrafo :: [Vuelo] -> Grafo

construirGrafo listaVuelos =
    let ciudadesOrigen = nub (map origen listaVuelos)
    in [(c, vuelosDesde c listaVuelos) | c <- ciudadesOrigen]



cargar_vuelos :: FilePath -> IO [Vuelo]


cargar_vuelos ruta = do 
    contenido <- readFile ruta
    let lista_lineas = lines contenido
    let lineas_validas = filter (\l -> l /= "") lista_lineas
    let vuelos = map parsear_linea lineas_validas
    return vuelos

dividir_por :: Char -> String -> [String]
dividir_por _ "" = []
dividir_por sep str = 
    let (primero,resto) = break (== sep) str
    in primero : case resto of 
                    [] -> [] 
                    (_:mas) -> dividir_por sep mas

-- Función auxiliar para convertir "HH:MM" a minutos desde las 00:00
hora_a_minutos :: String -> Int
hora_a_minutos hora = 
    case dividir_por ':' hora of 
        [h,m] -> (read h :: Int) * 60 + (read m :: Int) 
        _ -> error ("Formato Invalido: " ++ hora)

-- Convierte minutos desde las 00:00 a formato "HH:MM"
minutos_a_hora :: Int -> String
minutos_a_hora minutos =
    let h = minutos `div` 60
        m = minutos `mod` 60
    in dos_digitos h ++ ":" ++ dos_digitos m

dos_digitos :: Int -> String
dos_digitos n
    | n < 10 = '0' : show n
    | otherwise = show n

parsear_linea :: String -> Vuelo
parsear_linea linea = case dividir_por '|' linea of 
    [org,dest,sal,lleg,prec,cod,d] ->
        Vuelo{
            origen = org,
            destino = dest,
            salida = hora_a_minutos sal,
            llegada = hora_a_minutos lleg,
            precio = read prec,
            codigo = cod,
            dias = d
        }
    _ -> error ("formato de linea invalido: " ++ linea)

-- ===============================================================
-- Consultas Básicas de Partidas y Llegadas por Ciudad
-- ===============================================================

-- Dada una ciudad C, genera la lista de todos los vuelos que salen de ella
vuelosDesde :: String -> [Vuelo] -> [Vuelo]
vuelosDesde ciudad listaVuelos = filter (\v -> origen v == ciudad) listaVuelos

-- Dada una ciudad C, genera la lista de todos los vuelos que llegan a ella
vuelosHacia :: String -> [Vuelo] -> [Vuelo]
vuelosHacia ciudad listaVuelos = filter (\v -> destino v == ciudad) listaVuelos
