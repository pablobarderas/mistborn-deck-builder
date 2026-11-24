# Verificación E2 — primera partida local

Estado: completada **en alcance de ensayo local**, 2026-11-24. No admite el catálogo final ni la distribución. E1 continúa abierta por cotejo humano; su contenido se promueve solo en memoria del fixture. Publicación de este paquete autorizada expresamente el 2026-11-24 y recogida en el commit que incorpora esta nota.

## Resultado por aceptación

| Puerta | Evidencia |
| --- | --- |
| E2-01 preparación | `GameSetup` con 2/3/4 plazas, cuatro mazos vinculados, mercado 82/6 y ocho misiones en manifiesto; semilla elige M5/M6/M7 por la ruta aleatoria y el perfil rechaza una selección no admitida. Identidad atada a contenido, manifiesto y programa. |
| E2-02 turnos | Funding, 16 primarias, cuatro firmas, niveles I/II/III, Atium, combustible, fulguración, refresco, compra/reposición, Boxings 2→1 persistentes y limpieza. Mercado de cuatro Acciones sencillas de ensayo, 82 copias. |
| E2-03 finales | Partidas completas desde preparación por tres misiones y por último superviviente con 2 plazas; Target y eliminación con 3/4. Premios M5/M6/M7 normal/primero y prioridad de la tercera cima. |
| E2-04 autoridad | Rechazo atómico, estado/RNG conservados, vistas de mano privadas, replay/restauración desde checkpoint, reenvío idempotente. Ensayo focal REG-068: reciclaje de mercado desde eliminadas, barajado determinista, reposición y rechazo atómico sin ambos suministros. |
| E2-05 pantalla | Inicio → mesa local, preparación, mano/mercado/misiones/combate/limpieza, pase que oculta mano y victoria. `preview-local` terminó una partida desde la pantalla mediante intenciones; probó error legible, Target de 3, desplazamiento compacto y diez capturas reales. Revisión visual favorable. |
| E2-06 verificación | `test-local-competitive`: **4078 comprobaciones**, código 0, sin `SCRIPT ERROR`/`ERROR` (`tmp/e2-profile-market-final.log`). `preview-local`: **53 comprobaciones**, diez capturas, código 0, sin errores (`tmp/e2-ui-final.log`, `tmp/screenshots/e2-*.png`). Importación y carga de escena correctas (`tmp/e2-import-final.log`, `tmp/e2-scene-final.log`). |

Regresiones tras el perfil/Boxings, antes del último cambio limitado al test REG-068: E1 370, motor 102, limpieza 561, entrenamiento 295, preparación 175 y avance de misiones 878; todas código 0 y sin errores de script. Logs `tmp/e2-regression-*.log`. El cambio posterior no tocó autoridad, UI ni dependencias compartidas.

Cierre documental: 460 destinos de enlaces locales de los documentos E2/globales afectados comprobados, ninguno ausente; `git diff --check` sin errores. Las advertencias de finales de línea no indican fallo de contenido.

## Revisión y límites

`sdd_rules` Sol/high contrastó SRC-001/002, REG y DEC-031/032/034 antes de implementar; E1 y el servicio de misiones no podían encadenarse sin invalidar sus guardas, por lo que E2 tiene perfil propio. `sdd_reviewer` Sol/high emitió dictamen favorable sobre reglas, estado, RNG, replay, privacidad y pantalla. Tras su hallazgo, revisó el delta de la prueba REG-068 y lo consideró resuelto a nivel de ensayo focal; no es una partida completa hasta agotamiento ni restauración pública de esa rama. `sdd_visual` Terra/medium emitió dictamen favorable sobre las diez capturas finales tras corregir ancho, premios, nombres, errores, pase y victoria. El revisor visual no ejecutó Godot; el ejecutor sí lo hizo.

Metodología R3: aceptación y plan registrados antes del código; propiedad de archivos separada, un ejecutor Godot a la vez, contraste previo, pruebas adversas/recorridos reales y revisión independiente. Dispensa humana: la instrucción «vamos con lo siguiente» permitió iniciar E2 en el mismo chat con E1 abierta; sólo afecta AC-08 de separación de objetivos por sesión. Ninguna otra dispensa.

**Límites:** E1 sigue en borrador hasta cotejo humano. El mercado es ficticio, M5/M6/M7 se eligen entre ocho definiciones de ensayo y no se prueban las otras cinco dentro de E2. Si mercado y eliminadas se agotan a la vez, la compra se rechaza porque la FAQ no define una reposición adicional. Confrontación no está en el fixture; cuatro Atium por sí solos no dan victoria. Cooperativo, solitario, red, arte/distribución y catálogo competitivo completo siguen pendientes. E2 no cierra E3–E6 ni P10–P18.
