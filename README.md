# LogiExpress - Motor Analítico de Vuelos e Itinerarios

Proyecto de la asignatura **Tópicos Especiales de Programación** (Paradigmas Declarativos).
El mismo problema de optimización sobre un grafo ponderado dirigido de vuelos interurbanos
resuelto **dos veces**: con el **Paradigma Funcional (Haskell)** y con el **Paradigma Lógico (Prolog)**.

## Estructura del repositorio

```
LogiExpress-Grupo/
├── README.md        # Este archivo: compilación, ejecución y estado del proyecto
├── vuelos.txt       # Base de datos de prueba (20 vuelos, formato pipe |)
├── .gitignore
├── /haskell         # Solución en Paradigma Funcional (CargaDatos, Rutas, Optimizacion, Main)
├── /prolog          # Solución en Paradigma Lógico (carga_datos, utilidades, rutas, optimizacion, main)
└── /docs            # Plan de ejecución e informe técnico comparativo (PDF)
```

## Requisitos

- **Haskell:** [GHC](https://www.haskell.org/ghcup/) >= 9.4 (incluye `ghci` y `runghc`)
- **Prolog:** [SWI-Prolog](https://www.swi-prolog.org/) >= 9.0

## Compilación y ejecución

### Solución Funcional (Haskell)

Ejecutar **desde la raíz del repositorio** (para que encuentre `vuelos.txt`):

```bash
runghc -ihaskell haskell/Main.hs
```

O en modo interactivo:

```bash
ghci -ihaskell haskell/Main.hs
> main
```

### Solución Lógica (Prolog)

Los `consult` usan rutas relativas, por lo que se debe ejecutar desde la carpeta `prolog`:

```bash
cd prolog
swipl -s main.pl
```

Luego en la consola de SWI-Prolog:

```prolog
?- iniciar.
```

## Formato del archivo `vuelos.txt`

Cada línea es un vuelo con campos delimitados por `|`:

```
Origen|Destino|Salida|Llegada|Precio|Codigo|Dias
Pto Ordaz|Maiquetia|07:00|08:00|5600|Vlo#1|Diario
Maiquetia|Porlamar|09:00|10:00|4800|Vlo#2|L-M-Mi-J-V
```

- Horas en formato militar (HH:MM), convertidas internamente a minutos desde 00:00.
- Días: `L, M, Mi, J, V, S, D`; la palabra `Diario` equivale a los 7 días.
- Tiempo Mínimo de Conexión (TMC) global: **45 minutos** (configurable).

## Estado del proyecto

| Módulo | Haskell | Prolog |
|--------|---------|--------|
| Módulo 1: Carga dinámica y consultas básicas | Completado | Completado |
| Módulo 2: Búsqueda avanzada de rutas (DFS, TMC, escalas) | Completado | Completado |
| Módulo 3: Optimización doble criterio y ordenamiento | Completado | Completado |
| Informe técnico comparativo (PDF en /docs) | Pendiente | |

> Módulos 1 a 3 implementados y verificados en ambos lenguajes
> (GHC 9.10.3 y SWI-Prolog 10.0.2). Pendiente: informe comparativo y tag `v1.0-final`.

## Plan de ejecución

Ver [docs/plan-ejecucion.md](docs/plan-ejecucion.md) para el cronograma y checklists detallados.
