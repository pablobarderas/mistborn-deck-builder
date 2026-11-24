# Plan E2

1. Contratar el fixture cerrado y las rutas de autoridad sobre [spec.md](spec.md), con contraste de SRC-001/002 y especialista de reglas. Mantener el documento E1 de autoría sin promover.
2. Implementar un perfil E2 independiente con fachada estable para preparar, iniciar, enviar intención, limpiar, exportar/restaurar y consultar vistas. El perfil posee el RNG y los resultados; las escenas solo envían intenciones. Probar primero las transiciones y finales.
3. Conectar una pantalla local de plazas privadas y controles para acciones legales. Ejecutar partidas reales en Godot, corregir defectos observados y comprobar capturas.
4. Revisar independientemente código, reglas y vista; registrar evidencia una vez en `verification.md`. Actualizar estado, plan, backlog y registro con alcance real. El plan previo no autorizaba commit/push; el usuario lo autorizó posteriormente el 2026-11-24 junto con la regla permanente DEC-049.

Responsabilidades: coordinador, contrato, integración y pantalla; `sdd_developer` Sol/high, perfil de autoridad y pruebas en archivos propios; `sdd_rules` Sol/high, contraste previo; `sdd_reviewer` Sol/high, revisión final; `sdd_visual` Terra/medium, vista real. Riesgo R3 por estado, RNG, privacidad y final. Godot lo ejecuta un responsable a la vez.
