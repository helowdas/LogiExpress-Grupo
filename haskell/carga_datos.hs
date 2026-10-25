



data Vuelo = Vuelo{
    origen :: String,
    destino :: String,
    salida :: Int,
    llegada :: Int,
    precio :: Double,
    codigo :: String,
    dias :: String
}deriving (Show,Eq)

cargar_vuelos :: FilePath -> IO [Vuelo]
cargar_vuelos ruta = do 
    contenido <- readFile ruta
    let lista_lineas = lines contenido
    let vuelos = map parsear_linea lista_lineas
    return vuelos


dividir_por :: Char -> String -> [String]



parsear_linea :: String -> Vuelo














