# Plan de SPEC-009

1. Auditar estado/código y dependencias actuales; contrastar esquema de agentes y modelos en OpenAI Docs.
2. Elegir coordinador existente y especialistas bajo demanda, concurrencia máxima de dos subagentes y un escritor por archivo. No crear infraestructura de orquestación propia.
3. Configurar `.codex/config.toml` y siete perfiles `.codex/agents/`. El coordinador conserva el modelo de la sesión. En clientes sin selección de rol, leer el perfil y trasladar instrucciones/modelo a la herramienta disponible.
4. Documentar en `docs/gestion/agentes-sdd.md` análisis, enrutado, pasos, puertas, transferencia y medición. Integrar referencias desde AGENTS y flujo SDD.
5. Añadir un validador local de TOML y contrato de configuración con Python 3.11+ estándar, ajeno a la ejecución Godot. Verificar configuraciones válidas y negativas en copias temporales.
6. Ensayar delegación acotada y revisión independiente; corregir hallazgos. Mantener reconocimiento nativo y delegación manual como evidencias distintas.
7. Actualizar memoria y evidencia. No ejecutar suites del juego sin cambios de juego; sí revisar diff y enlaces.

Alternativas descartadas: agente por microfase (traspasos repetidos), todos los agentes en Astra (coste innecesario), todos en Luna (riesgo/retrabajo), framework/API/automatización externa (dependencias y coste operativo), especialistas siempre activos (sin trabajo independiente). Riesgos: cliente sin recarga dinámica, modelos no disponibles en otro equipo, métricas incompletas y ediciones compartidas. Mitigación en la guía operativa.

## Ampliación AC-07 — Cumplimiento obligatorio

Encargo humano explícito del 2026-10-29. Riesgo R2 por modificar controles del proceso; objetivo, aceptación, plan y responsables registrados en spec.md antes de editar. Coordinador mantiene instrucciones/perfiles/documentación; Sol high revisa de forma independiente las vías de excepción y el cierre. Conservar cambios previos sin commit y limitar esta ampliación al método: no cambiar modelos ni permisos, código del juego, fuentes o fases.

Secuencia: regla obligatoria y dispensas trazables en AGENTS/política; reflejo en siete perfiles, plantillas y continuidad; comprobación TOML, enlaces/anclas locales y diff; revisión/corrección y cierre con evidencia. R0 conserva proporcionalidad, nunca sirve para evadir revisión de un cambio crítico. Sin dispensa humana aplicable.
