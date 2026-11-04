# Solución en Paradigma Funcional (Haskell)

Implementación del motor analítico de vuelos usando el **Paradigma Funcional**
(GHC >= 9.4, sin librerías externas más allá de `base`).

## Módulos

| Archivo | Contenido |
|---------|-----------|
| `CargaDatos.hs` | Modelo `Vuelo`, parseo de `vuelos.txt`, conversión de horas y consultas básicas |
| `Rutas.hs` | Módulo 2: DFS de rutas con control de ciclos, días de operación, TMC y escalas |
| `Optimizacion.hs` | Módulo 3: métricas, mergesort/quicksort propios, mínimos, filtros y reportes |
| `Main.hs` | Menú interactivo (CLI) con las 8 opciones |

## Ejecución

Desde la **raíz del repositorio**:

```bash
runghc -ihaskell haskell/Main.hs
```

O en modo interactivo:

```bash
ghci -ihaskell haskell/Main.hs
ghci> main
```

El archivo de vuelos por defecto es `vuelos.txt` en la raíz del repositorio. Si se
ejecuta desde esta carpeta, el menú busca automáticamente `../vuelos.txt`.

## Opciones del menú

1. Cargar archivo de vuelos
2. Consultar vuelos que salen de una ciudad
3. Consultar vuelos que llegan a una ciudad
4. Configuración del TMC
5. Buscar rutas válidas entre dos ciudades
6. Ruta de costo mínimo y ruta de menor tiempo
7. Reporte ordenado de itinerarios (costo/tiempo y filtros)
8. Salir
