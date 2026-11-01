-- Menú principal interactivo CLI
main :: IO ()
main = do
    
    putStrLn "   Logi Express - Sistema de Gestion Area  "
    
    bucleMenu

bucleMenu :: IO ()
bucleMenu = do
    putStrLn "\n Menu  "
    putStrLn "1. Cargar archivo de vuelos"
    putStrLn "2. Consultar vuelos que salen de una ciudad"
    putStrLn "3. Consultar vuelos que llegan a una ciudad"
    putStrLn "4. Configuración TMC (Tiempo Mínimo de Conexión)"
    putStrLn "5. Salir"
    putStrLn "Seleccione una opción: "

    opcion <- getLine
    ejecutarOpcion opcion

ejecutarOpcion :: String -> IO ()

ejecutarOpcion "1" = do
    putStrLn ""
    bucleMenu


ejecutarOpcion "2" = do
    putStrLn "\n"
    bucleMenu

ejecutarOpcion "3" = do

    putStrLn "\n"
    bucleMenu

ejecutarOpcion "4" = do
    putStrLn "\n"
    bucleMenu

ejecutarOpcion "5" = do
    
    putStrLn "\n¡Gracias por utilizar LogiExpress! Hasta luego."


ejecutarOpcion _ = do
    putStrLn "\nOpción inválida. Intente de nuevo."
    bucleMenu

