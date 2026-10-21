Asignatura: Tópicos Especiales de Programación

Profesor: Jannelly Bello / Noraimar Mora

## Planteamiento del Problema

La empresa de transporte aéreo LogiExpress requiere el desarrollo del motor analítico para su

sistema de gestión de vuelos e itinerarios interurbanos. El objetivo principal es determinar rutas

válidas entre distintas ciudades, evaluando restricciones temporales, días de operación, ventanas de conexión y optimizaciones de costos tanto financieros como de tiempo de viaje. El sistema debe implementarse obligatoriamente bajo dos paradigmas distintos: Paradigma

Lógico (Prolog) y Paradigma Funcional (Haskell),

procesamiento de listas y algoritmos sobre grafos ponderados dirigidos.

El sistema debe leer de forma dinámica un archivo de texto plano (vuelos.txt) que contiene la

base de conocimiento con la información de los vuelos.

haciendo un uso exhaustivo del

## 1. Entrada de Datos y Formato de Archivo

## Estructura del Archivo

El archivo utiliza el carácter (|) como delimitador de campos:

Pto Ordaz|Maiquetia|07:00|08:00|5600|Vlo#1|Diario

Maiquetia|Porlamar|09:00|10:00|4800|Vlo#2|L-M-Mi-J-V

Maiquetia|Pto Ordaz|15:00|16:00|5300|Vlo#3|L-M-V

Pto Ordaz|Maracaibo|13:00|15:00|9000|Vlo#4|Diario

Maracaibo|Maiquetia|17:00|18:00|5500|Vlo#5|Diario

Pto Ordaz|Valencia|11:00|12:30|6700|Vlo#6|Diario

Maracaibo|Valencia|08:00|08:45|4700|Vlo#7|Diario

Porlamar|Maracaibo|02:00|03:30|5900|Vlo#8|Diario

Valencia|Porlamar|17:00|18:00|4300|Vlo#9|L-S-D

Maiquetia|Barquisimeto|06:30|07:30|4200|Vlo#10|Diario

Barquisimeto|Maracaibo|08:30|09:30|3900|Vlo#11|L-M-Mi-J-V

Barquisimeto|Maiquetia|18:00|19:00|4500|Vlo#12|L-Mi-V

Valencia|Barquisimeto|10:00|11:00|3200|Vlo#13|Diario

Maiquetia|Barcelona|11:00|11:50|4100|Vlo#14|Diario

Barcelona|Porlamar|13:00|13:40|3500|Vlo#15|Diario

Barcelona|Pto Ordaz|14:30|15:30|4600|Vlo#16|M-J-S

Maiquetia|San Antonio|07:00|08:30|8500|Vlo#17|L-Mi-V

San Antonio|Maracaibo|09:45|10:45|6100|Vlo#18|L-Mi-V

Maracaibo|San Antonio|12:00|13:00|6300|Vlo#19|M-J-S

San Antonio|Maiquetia|15:00|16:30|8800|Vlo#20|Diario


Nota: La hora se trabaja en formato militar (HH:MM) de 24 horas.

## 2. Interface y Salida del Sistema

- Ambas soluciones (Haskell y Prolog) deben implementar un Menú Interactivo en Consola ejecutable desde la línea de comandos (en Haskell mediante el módulo Main / ghci y en Prolog mediante un predicado principal menu o iniciar).

## 2. Requerimientos del Sistema

- Lectura y parseo del archivo plano de datos. En Prolog, los datos se deben cargar dinámicamente en la base de conocimientos; en Haskell, se deben estructurar mediante tipos de datos algebraicos (data Vuelo, type Grafo).

- Configuración global del Tiempo Mínimo de Conexión (TMC) entre vuelos expresado en minutos (ej. TMC = 45 min).

- Consultas simples de partidas y llegadas por ciudad:

- Dada una ciudad , generar la lista de todos los vuelos que salen de ella. 𝐶

- Dada una ciudad , generar la lista de todos los vuelos que llegan a ella. 𝐶

- Generación de Rutas Válidas: Dadas dos ciudades (Origen y Destino) y un día de la semana específico (ej. Lunes), determinar todas las rutas válidas (directas o con escalas) que satisfagan de forma simultánea:

- 1. Compatibilidad de Frecuencia: Cada vuelo de la secuencia debe estar disponible en el día consultado.

- 2. Validación de Escala: Para dos vuelos consecutivos 𝑉 1 y , la hora de salida de 𝑉2 𝑉 2 debe ser mayor o igual a la hora de llegada de 𝑉 1 más el TMC configurado.

- 3. Control de Ciclos: Evitar visitar la misma ciudad más de una vez en un mismo itinerario.

- 4. Límite de Escalas: Permitir definir opcionalmente un número máximo de escalas . 𝐾

- Optimización por Doble Criterio: Dadas dos ciudades (Origen y Destino) y un día de la semana:

- 1. Encontrar la ruta de Costo Económico Mínimo (sumatoria del precio de los boletos).

- 2. Encontrar la ruta de Menor Tiempo Total de Viaje (diferencia entre la hora de llegada al destino final y la hora de salida de la primera ciudad, incluyendo los tiempos de espera en las escalas).

- Agrupamiento e Itinerarios: Generar un reporte ordenado de las rutas por costo o por tiempo de viaje utilizando algoritmos de ordenamiento implementados sobre listas.

## Módulo 1: Carga Dinámica y Consultas Básicas

## Módulo 2: Búsqueda Avanzada de Rutas

## Módulo 3: Optimización y Filtrado de Listas


## 3. Especificaciones y Retos Técnicos por Paradigma

- Investigación esperada sobre Listas: Uso de estructuras [Cabeza|Cola], acumuladores para control de ciclos (lista de visitados) e implementación de predicados de ordenamiento (ej. quicksort o mergesort sobre listas).

- Meta-predicados y Búsqueda: Manejo de backtracking para explorar el espacio de soluciones y recopilación mediante findall/3, bagof/3 o setof/3.

- Procesamiento de Tiempo: Conversión de cadenas HH:MM a minutos desde el inicio del día para realizar operaciones aritméticas puras de tiempo.

- Investigación esperada sobre Listas: Uso intensivo de list comprehensions, funciones de alto orden (map, filter, foldl/foldr) y módulos de manipulación de listas (Data.List).

- Algoritmos sobre Grafos Inmutables: Búsqueda en profundidad (DFS) recursiva evaluando restricciones de ruta mediante composición de funciones.

- Parseo y Tipo de Datos: Definición de registros/tipos para representar vuelos y rutas. Lectura del archivo utilizando I/O puro/impuro y funciones como lines y words.

## Solución en Prolog (Paradigma Lógico)

## Solución en Haskell (Paradigma Funcional)

## 4. Esquema de Evaluación Continua

La evaluación del desarrollo se llevará a cabo mediante un Seguimiento Continuo y Auditoría de

Repositorio desde el primer día de trabajo hasta la fecha de entrega final del proyecto.

- 1. Creación Inmediata del Repositorio: Durante los primeros tres (3) días de la asignación, cada equipo creará un repositorio Privado en GitHub y otorgará permisos de Colaborador a las cuentas de las profesoras de la cátedra:

- Prof. Jannelly Bello: jbelloch@gmail.com

- Prof. Noraimar Mora: Noraimar.mora@gmail.com

- 2. Revisiones Periódicas Sin Previo Aviso: El equipo docente ingresará en cualquier momento durante las 3 semanas de desarrollo para inspeccionar el avance del código, comprobar qué integrantes están trabajando y validar la calidad del historial de versiones.

## 4.1. Reglas del Repositorio y Auditoría de Contribuciones

Dado que la nota del proyecto dependerá del avance visible en el repositorio, se aplican de

forma estricta las siguientes normas de trabajo:

- Inexistencia de Entregas Masivas ("Commits de Última Hora"): No se aceptará que el código fuente lo suban en un único commit o en los últimos días previos al cierre del


- proyecto. El historial de Git debe reflejar un desarrollo progresivo y constante a lo largo de las 3 semanas.

- Trazabilidad de Integrantes: Cada uno de los 3 miembros del equipo debe realizar commits significativos desde su propia cuenta de Git. Si la auditoría del repositorio refleja que uno o dos integrantes no registran actividad ni aportes de código en el historial, dichos integrantes sufrirán una penalización directa en su nota individual o la reprobación del proyecto.

- Mensajes de Confirmación Formales: Los mensajes asociados a cada commit deben ser descriptivos del cambio realizado (ej. feat: implementado parseo del archivo vuelos.txt en Haskell o fix: corregido control de ciclos en el backtracking de Prolog). Los mensajes genéricos o informales afectarán la nota de calidad de código.

## 4.2. Estructura Obligatoria del Proyecto en Git

El repositorio debe organizarse en todo momento bajo la siguiente estructura limpia:

├── README.md # Instrucciones de compilación, ejecución y estado del proyecto

├── vuelos.txt

├── .gitignore

├── /haskell

├── /prolog

└── /docs

## LogiExpress-GrupoXX/

\# Base de datos de prueba

\# Archivos compilados e intermedios (.o, .hi, binarios, etc.)

\# Solución en Paradigma Funcional (Módulo Main + CLI)

\# Solución en Paradigma Lógico (Módulo Main + CLI)

\# Informe Técnico Comparativo en PDF (Cargado al finalizar)

## 4.3. Entrega Final Única

- Fecha Límite: 08/11/2026

- Mecanismo de Cierre: El equipo congelará la rama principal (main/master) y creará la etiqueta (tag) v1.0-final. El Informe Técnico Comparativo deberá estar cargado obligatoriamente dentro de la carpeta /docs del repositorio en ese momento.

## 5. Especificación del Informe

Formato de Entrega: Documento en PDF, máximo 8 a 10 páginas, redactado con rigor formal

de ingeniería.

0. Portada.

- 1. Introducción.

- 2. Explicación del Modelado de Datos (Lógico y Funcional)

- 3. Funciones y Predicados Investigados (Lógico y Funcional)

Esta sección documenta el proceso de investigación y aprendizaje autónomo del

## Estructura Detallada del Documento


equipo de desarrollo.

- 4. Resumen de actividades y responsables

Desglose detallado de qué módulos, predicados o funciones implementó cada uno de

los integrantes, coincidiendo con los commits del repositorio.

- 5. Evidencias de Ejecución por Consola

## 6. Conclusiones

- 1. Cumplimiento Funcional en Ambos Paradigmas (40%): Correcta resolución de todos los requerimientos tanto en Haskell como en Prolog.

- 2. Dominio de Listas e Investigación (25%): Eficiencia en el manejo de listas, uso adecuado de funciones de alto orden en Haskell y recursión/predicados de lista en Prolog.

- 3. Manejo Riguroso del Tiempo y Restricciones (15%): Correcto cálculo de las ventanas de tiempo entre escalas (TMC) y compatibilidad de días de vuelo.

- 4. Informe Comparativo (20%): Documento analítico que compare la resolución del mismo problema mediante evaluación perezosa/inmutabilidad (Haskell) frente a backtracking/unificación (Prolog).

Demostración mediante capturas de pantalla de la interfaz CLI en ambos lenguajes.

## 6. Criterios de Evaluación
