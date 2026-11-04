# Plan de Ejecución - LogiExpress

Proyecto: Motor Analítico de Vuelos e Itinerarios (Haskell + Prolog)
Asignatura: Tópicos Especiales de Programación
Fecha límite de entrega: **08/11/2026**

## Reglas de trabajo (auditoría del repositorio)

- Commits pequeños, progresivos y frecuentes. Nada de commits masivos al final.
- Cada integrante debe registrar commits significativos con su propia cuenta.
- Mensajes formales con convención: `feat:`, `fix:`, `docs:`, `test:`, `chore:` (en inglés o español sin tilde, evitando mensajes genéricos).
- Estructura obligatoria siempre limpia:

```
LogiExpress-Grupo/
├── README.md        # Instrucciones de compilación, ejecución y estado
├── vuelos.txt       # Base de datos de prueba
├── .gitignore
├── /haskell         # Solución Paradigma Funcional (Main + CLI)
├── /prolog          # Solución Paradigma Lógico (menu/iniciar + CLI)
└── /docs            # Informe técnico comparativo (PDF al final) + plan
```

## Cronograma

### Fase 0 - Inicialización (20 al 22 de octubre)

- [x] Crear estructura de carpetas y archivos base (.gitignore, README, vuelos.txt)
- [x] Mover el enunciado del proyecto a /docs
- [x] Escribir este plan de ejecución
- [ ] Instalar herramientas: GHC (GHCup) y SWI-Prolog
- [ ] Verificar que cada integrante pueda hacer push y que los commits queden con su cuenta
- [ ] Confirmar acceso de las profesoras como colaboradoras (jbelloch@gmail.com, Noraimar.mora@gmail.com)

### Fase 1 - Módulo 1: Carga dinámica y consultas básicas (23 al 29 de octubre)

Haskell:
- [x] Modelo de datos: `data Vuelo`, `type Grafo`
- [x] Parseo de `vuelos.txt` (split por `|`, conversión HH:MM a minutos)
- [x] Conversión de días (`Diario`, `L-M-Mi-J-V`) a lista de días
- [x] Consultas: vuelos desde una ciudad / hacia una ciudad
- [x] Menú interactivo en consola (módulo Main)

Prolog:
- [x] Predicado `vuelo/7` dinámico y carga desde archivo (`assertz`)
- [x] Conversión de tiempo HH:MM <-> minutos
- [x] Consultas: `vuelos_desde/2`, `vuelos_hacia/2` con `findall/3`
- [x] Menú interactivo (`iniciar` / `menu`)

### Fase 2 - Módulo 2: Búsqueda avanzada de rutas (30 de octubre al 3 de noviembre)

- [x] Configuración global del TMC (Tiempo Mínimo de Conexión, ej. 45 min)
- [x] DFS recursivo sobre el grafo con lista de visitados (control de ciclos)
- [x] Validación de escala: salida(V2) >= llegada(V1) + TMC
- [x] Compatibilidad de frecuencia: el vuelo debe operar el día consultado
- [x] Límite opcional de escalas K
- [x] Reporte de todas las rutas válidas origen -> destino en un día dado

### Fase 3 - Módulo 3: Optimización y filtrado de listas (4 al 6 de noviembre)

- [x] Ruta de costo económico mínimo (sumatoria de precios)
- [x] Ruta de menor tiempo total (llegada final - salida inicial, incluye esperas)
- [x] Algoritmo de ordenamiento implementado sobre listas (quicksort o mergesort propio, no usar `sort` de librería para el reporte)
- [x] Reporte ordenado de itinerarios por costo o por tiempo
- [x] Menú con todas las opciones funcionando en ambos lenguajes

### Fase 4 - Informe y cierre (7 y 8 de noviembre)

- [ ] Capturas de evidencias de ejecución en consola (ambos paradigmas)
- [ ] Redactar informe técnico comparativo (8-10 páginas PDF):
  - [ ] Portada
  - [ ] Introducción
  - [ ] Modelado de datos (lógico y funcional)
  - [ ] Funciones y predicados investigados
  - [ ] Resumen de actividades y responsables (coincidiendo con los commits)
  - [ ] Evidencias de ejecución por consola
  - [ ] Conclusiones
- [ ] Colocar el PDF en /docs
- [ ] Congelar rama principal y crear tag `v1.0-final` antes del 08/11/2026

## Decisiones técnicas

| Decisión | Valor |
|----------|-------|
| TMC (Tiempo Mínimo de Conexión) | 45 minutos (configurable globalmente) |
| Formato de hora | Militar HH:MM, convertido a minutos desde 00:00 para operar |
| Días de la semana | `L, M, Mi, J, V, S, D`; `Diario` expande a los 7 |
| Días válidos para una ruta | Todos los vuelos del itinerario deben operar ese día |
| Escala mínima | llegada(V1) + TMC <= salida(V2) |
| Ciclos | No repetir ciudad en un mismo itinerario |

## Criterios de evaluación (pesos)

1. Cumplimiento funcional en ambos paradigmas: 40%
2. Dominio de listas e investigación: 25%
3. Manejo riguroso del tiempo y restricciones: 15%
4. Informe comparativo: 20%
