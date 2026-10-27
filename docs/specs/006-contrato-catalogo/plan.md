# Plan de SPEC-006

Sobre versionado con fuentes y cartas. Definiciones inmutables por convención y acceso mediante copias profundas; instancias futuras usarán instance_id/definition_id y estado separado en P07. No duplicar datos de muestras de P05 dentro del catálogo.

Validador GDScript separado de Database: tipos estrictos (JSON representa enteros como float), claves conocidas, enum/IDs, ramas de condición/efecto y referencias en segunda pasada. Límites técnicos de profundidad/tamaño, sin convertirlos en límites del juego. Ningún texto se evalúa.

Retener el rechazo atómico de P03. Una revisión pendiente es contenido válido de trabajo con avisos, nunca definición verificada. Arte ausente admite sustituto con aviso; una ruta fuera de assets/images/ no. Fuente física debe apuntar a un archivo existente. La UI inicial mantiene los ejemplos pero expone estado y avisos.

La gramática inicial no pretende cubrir todos los efectos de cartas aún no recibidas: op pendiente conserva el bloqueo de revisión sin inventar comportamiento. Extensiones futuras requieren contrato/pruebas y migración si rompen compatibilidad.

Pruebas mediante mutaciones de un catálogo válido de muestra y fixtures de declaraciones verificadas ficticias solo dentro de tests. Comprobar fallos de tipos, enum, límites, referencias, recursión, revisión, recursos y recuperación; fixtures no se distribuyen como catálogo oficial.
