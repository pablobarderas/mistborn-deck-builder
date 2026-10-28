# Plantilla de una especificación

Copiar cada bloque al archivo indicado de una nueva carpeta NNN-descripcion. Eliminar instrucciones y completar campos; no marcar como lista una especificación con campos necesarios pendientes.

## spec.md

- ID / título:
- Estado y fecha:
- Fases e IDs de issues:
- Objetivo y problema:
- Fuentes SRC/REG y objetivos PROD:
- Dentro / fuera del alcance:
- Actores y escenarios:
- AC-01: Dado … cuando … entonces …; evidencia requerida.
- AC-02: Acción inválida o caso límite y resultado esperado.
- Preguntas que afectan al comportamiento:
- Dependencias y compatibilidad:

## plan.md

- Especificación relacionada:
- Diseño elegido y alternativas descartadas:
- Archivos/capas afectados:
- Contratos de datos, acciones y versiones:
- Información pública/privada y autoridad, si aplica:
- Migración y compatibilidad:
- Secuencia y riesgos:
- Nivel R0–R3, perfiles/modelos/esfuerzo previstos y motivo de delegación; archivos por propietario:
- Verificación por criterio:
- Cumplimiento obligatorio de SDD; dispensas humanas explícitas aplicables o ninguna (referencia, requisito, alcance y vigencia):

## tasks.md

| ID estable | Resultado comprobable | Depende de | Criterio AC | Issue/estado |
| --- | --- | --- | --- | --- |
| Txx.n | Completar | Completar | AC-01 | Sin publicar / pendiente |

## verification.md

| Criterio | Entorno/datos | Comando o pasos | Resultado observado | Estado | Evidencia/issue |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Pendiente | Pendiente | No ejecutado | No ejecutado | Pendiente |

Registrar cambios de alcance y discrepancias. No confundir una casilla de tarea terminada con una prueba superada.

Control de cierre obligatorio: AC/plan/riesgo y responsables registrados antes de editar; controles aplicables y evidencia; revisión independiente exigida y hallazgos resueltos; memoria/siguiente paso actualizados; dispensas humanas o «ninguna». Una omisión sin dispensa válida deja la tarea abierta. Lo dispensado/no ejecutado se identifica como tal, nunca como prueba aprobada. Para una puerta no aplicable, justificar por qué el cambio no la afecta.

Registro de ejecución según [agentes SDD](../gestion/agentes-sdd.md): roles/modelos/esfuerzo efectivos, número de delegaciones, escalados y motivo, revisión independiente/hallazgos/correcciones, pruebas no ejecutadas y siguiente paso. Añadir tiempo y tokens/caché/razonamiento solo si se han medido; en otro caso indicar «no disponible». Una tarea R0/R1 breve puede conservar este registro en su issue o documento de tarea sin crear cuatro archivos.
