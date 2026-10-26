



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
dividir_por _ "" = []
dividir_por sep str = let (primero,resto) = break (== sep) str
                      in primero : case resto of [] -> [] (_:mas) -> 
dividir_por sep mas

--funcion auxiliar 
hora_a_minutos :: String->Int
hora_a_minutos hora = 
    case dividir_por ':' hora of [h,m] -> (read h :: Int) * 60 + (read m :: Int) -> _ 


parsear_linea :: String -> Vuelo
parsear_linea linea = case dividir_por '|' linea of [org,dest,lleg,prec,cod,d] ->
    vuelo{
        origen = org,
        destion = dest,
        salida = hora_a_minutos sal,
        llegada = hora_a_minutos lleg,
        precio = read prec,
        codigo = cod,
        dias = d
    }
    _ -> error ("formato de linea invalido: " ++ linea)













