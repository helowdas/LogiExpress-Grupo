# Solución en Paradigma Lógico (Prolog)

Implementación del motor analítico de vuelos usando el **Paradigma Lógico**
(SWI-Prolog >= 9.0).

## Archivos

| Archivo | Contenido |
|---------|-----------|
| `carga_datos.pl` | Hechos `vuelo/7` dinámicos, carga desde archivo y TMC global |
| `utilidades.pl` | Conversión de horas y normalización de días |
| `rutas.pl` | Módulo 2: DFS de rutas con control de ciclos, días de operación y TMC |
| `optimizacion.pl` | Módulo 3: métricas, mergesort/quicksort propios, mínimos, filtros y reportes |
| `main.pl` | Menú interactivo (`iniciar`) con las 8 opciones |

## Ejecución

Los `consult` usan rutas relativas, por lo que se debe ejecutar **desde esta carpeta**:

```bash
cd prolog
swipl -s main.pl
```

```prolog
?- iniciar.
```

## Opciones del menú

1. Cargar archivo de vuelos
2. Consultar vuelos que salen de una ciudad
3. Consultar vuelos que llegan a una ciudad
4. Configuración del TMC
5. Buscar rutas válidas entre dos ciudades
6. Ruta de costo mínimo y ruta de menor tiempo
7. Reporte ordenado de itinerarios (costo/tiempo y filtros)
8. Salir
