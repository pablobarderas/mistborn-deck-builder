# Integración competitiva de misiones M1–M8

Contrato T08.1b21; implementación prevista T08.1b22. Estado: contrato revisado favorablemente; sin código combinado todavía. Los perfiles aislados publicados siguen vigentes con snapshot 7.

## Alcance y fuentes

Crear un único servicio interno de autoridad para tres misiones distintas cualesquiera entre las ocho definiciones verificadas del catálogo v2. Son 56 subconjuntos posibles, en competitivo de dos, tres o cuatro plazas. No es un manifiesto de producto ni permite jugar cartas, comprar, quemar, combatir, entrar públicamente a limpieza, persistir en disco o reconectar. Cooperativo/solitario y rival obligatorio conservan su trabajo propio; P04 externa/P08 siguen abiertas.

Reutilizar [avance](avance-misiones.md), [permanentes](permanentes-misiones.md), [M1](elecciones-m1.md), [M2](elecciones-m2.md), [M8](elecciones-m8.md) y [catálogo](catalogo-misiones.md), con los textos contrastados de [SRC-005](../../referencias/misiones-competitivas.md). SRC-001 pp. 6–7, 11, 14, 17 y SRC-002 se consultan a través de la trazabilidad de esos contratos. Prevalecen correcciones expresas del editor y DEC-031/032/034/037/039. No se cambia opcionalidad, propiedad de objetivos, orden normal/extra ni victoria inmediata. Una duda nueva que cambie resultado bloqueará esa parte antes de implementarla.

Los ocho diseños reales se congelan completos junto con pista de entrenamiento y descriptores inertes de autoridad. Los componentes restantes son fixtures explícitos sin habilidades/Defender/Cloud ni obligaciones. Rechazar contenido activo o desconocido incluso fuera de juego. Mantener IDs, cantidades, textos y procedencia; no transcribir cartas nuevas ni promover muestras.

## Admisión y compatibilidad

Servicio propuesto `scripts/game/integrated_missions_play.gd`, construido desde catálogo/descriptores/pista como los pilotos anteriores. Fuente tipada `SnapshotSource.latest(match_id, profile_id)` para motor vacío; entrada pública de snapshots siempre rechazada. La selección de tres proviene del estado confirmado por autoridad, no de un payload de cliente ni de un setter. No añadir una interfaz de preparación o sorteo en este paso: se comprueba admisión de cualquier subconjunto; el sorteo/preparación general existente y el producto no se integran por inferencia.

Exigir exactamente tres instancias de misión con definiciones distintas de M1–M8, en cualquier orden de diccionario/ID válido, igual para todos los jugadores. Rechazar dos/cuatro, duplicadas, ID desconocido, texto de misión alterado o catálogo/pista/registro no coincidente. Identidad estable de perfil cubre catálogo, pista y versión de composición/registro. La combinación se valida en el snapshot y no se acepta un cambio externo durante una resolución. Mismos límites de estado, autoridad e hilos de P07.

Implementación prevista: snapshot **8**, motor `p08-integrated-missions-1/godot-4.7.2`, sin migración implícita desde 7. Actualizar versión y fixtures compartidos explícitamente; los adaptadores anteriores conservan sus conjuntos exactos y no admiten combinaciones por activar globalmente capacidades. No cambiar catálogo v2 ni intención v1. Fases admitidas del nuevo perfil: inicio/libre/limpieza internos y finalizada coherente; no resolución en inicio/limpieza. La admisión de limpieza sirve exclusivamente al servicio interno ya definido, nunca a `libre -> limpieza`.

## Composición de candidatos y programas

El núcleo compartido debe distinguir capacidades del perfil de la definición de la misión actual. Evitar prioridades booleanas que elijan sólo M2 o sólo M1 y oculten las demás. Los perfiles legados conservan su selección exacta. En el nuevo, cada misión despacha sus efectos, grupos pendientes y ledger según su propia definición.

Intención pública exacta `avanzar_mision` con `{mission_id}`; `responder` conserva el payload P07. Un punto neto por paso, turno activo, vida, fase, fondos, primera llegada y premios decididos por autoridad. No aceptar recursos/grupos/programas/opciones/callbacks arbitrarios del cliente. Tercera cima: llegada, orden y victoria antes de premios/grupos/marca/ledger de esa cima; primera/segunda conservan premios.

Registro cerrado combinado: reutilizar los cinco programas `m1_normal_v1`, `m1_first_v1`, `m2_first_v1`, `m8_normal_v1`, `m8_first_v1`, sus operaciones y bindings. Sin colisión ni sustitución mutable de callbacks. Las ocurrencias mantienen el prefijo por definición y la tupla partida/plaza/misión/posición ya publicada. Coexistencia de cierres de las tres familias; validación de grupos/cursor/ocurrencia por misión, sin permitir que una pausa excuse deuda de otra.

- M1 casillas 5/9: normal selectivo obligatorio y luego extra selectivo del primero. Cero candidatos liquida; una candidata exige selección. Cima directa: capacidad +1 derivada del permanente y refresco total del primero; no secuencia ficticia.
- M2 4/7/10: normal automático +1/+2/+3 ataque y, sólo primero, elección obligatoria de aliado propio/rival inerte. Sin objetivos liquida y cierra. Al derrotar, juego al descarte del propietario, sin coste de combate. Cima directa: +2 ataque/permanente y +1 primero.
- M3/M4/M5/M6/M7: candidatos automáticos ya definidos; M3 +2 monedas al adquirir y por inicio propio, M4 mano nueva +1, M6 avanza entrenamiento, M5 recursos/ataque/curación/Atium y M7 curación según catálogo. M6 no altera ni borra el bonus de capacidad M1 al recalcular entrenamiento.
- M8 5/9/12: eliminación opcional normal/extra desde zonas propias admitidas; misma oferta y máximo (cuatro normal de cima, uno extra). Tercera cima directa terminal sin eliminación.

M4+M8 conserva el robo corto sin deuda si faltan cartas tras eliminar; M2+M8 distingue derrota al descarte del propietario de eliminación a la pila común. Cada ventana reconstruye su oferta desde el estado confirmado actual, sin reutilizar candidatos anteriores de otra familia.

Ventanas completas, privadas, opacas y una a la vez. Restaurar ventanas M1/M2/M8 en el mismo motor combinado sin repetir llegada/normal/segmentos ya aceptados. Rechazo atómico por segmento; no revertir segmentos ya confirmados.

## Permanentes, inicio y cierre internos

Capacidad M1 se deriva de entrenamiento más su permanente liquidado. M6 y el entrenamiento de inicio conservan ese bonus, sin incrementar dos veces ni aceptar capacidad inventada. M4 determina mano nueva 5/6 del propietario, no roba al adquirir el permanente (el extra de cima sí roba dos al primero). No añadir marcas por turno a M1/M4.

`authority.mission_permanents` puede contener simultáneamente M2 y M3, con adquisición/última aplicación por plaza; validar cada marca contra definición, progreso, premio y turno. Inicio interno único: entrenamiento, +2 ataque de M2 y +2 monedas de M3 cuando correspondan, marcas y apertura de libre juntos. Mismo ID estable de autoridad; reenvío/ID nuevo sobre ocurrencia consumida no duplican. No mezclar los recursos por despachar todo permanente como M2 o M3.

`finish_cleanup` interno reutiliza el contrato de permanentes y TurnCleanup: desde limpieza acreditada por fuente de autoridad, reinicia temporales propios, Atium según contrato, descarta/roba mano 5/6, mantiene capacidad M1 y marcas, entrega inicio al siguiente vivo. Fallos de robo/entrenamiento/límites/marca revierten el segmento y RNG. Nunca exponer por submit los namespaces internos, tampoco tras registrar un recibo interno. No se implementa la entrada pública a limpieza ni un turno completo; los fixtures de inicio/limpieza no prueban una partida.

## RNG, presupuestos y privacidad

M4 y el cierre interno de limpieza pueden robar/reciclar: el motor combinado ya no puede exigir RNG inalterado en todas las acciones. Comparar delta y RNG con la ejecución fiable del candidato/segmento concreto; M1/M2/M8 siguen sin azar. No aceptar RNG alterado por callbacks ni saltarse comparación por admitir un efecto aleatorio en otro programa. Reconstrucción debe partir del mismo RNG confirmado y aceptar exactamente su resultado. Recibos P07 sellados después del delta como antes.

Antes de gastar y al restaurar una pausa, probar capacidad de oferta completa, vistas actuales, revisiones/recibos, pasos restantes, destinos y cierre/ledger para toda respuesta legal, incluidos M8 subconjuntos y la segunda ventana M1. Conservar límites globales 50.000 nodos/profundidad 20/10.000 opciones, límites por programa y no truncar objetivos. Reutilizar cotas demostradas de cada familia cuando su hipótesis de contenido inerte siga siendo válida; sumar estado/ledger/otras marcas no autoriza ignorar su tamaño. Simular candidatos sobre copias sin consumir RNG vivo. Fallo de presupuesto rechaza antes de la primera llegada o carga; una respuesta ilegal conserva ventana/estado/RNG.

Vistas por lista permitida: `option_allies` sólo en M2 al destinatario; correspondencias M1 y M8 sólo en su programa propio. Terceros sólo bloqueo y zonas autorizadas, nunca opciones privadas, mano/descarte ajenos, programa/contexto/cursor/ledger/recibos/RNG. No inferir la forma de proyección de otra familia por estar registrado el mismo servicio.

## Aceptación documental T08.1b21

| AC | Evidencia |
| --- | --- |
| INT-DOC-01 | Fuentes/decisiones/contratos reutilizados contrastados, combinaciones y límites explícitos; ninguna regla nueva atribuida al humano. |
| INT-DOC-02 | Contrato de admisión, programas, grupos, RNG, permanentes, inicio/cierre/carga y privacidad cotejado con APIs actuales. |
| INT-DOC-03 | Escenarios y plan comprobables para b22, versión/compatibilidad y exclusiones expresas. |
| INT-DOC-04 | Revisión independiente/contraste, enlaces/anclas/diff y memoria/traspaso; commit/push verificado antes de implementación por encargo humano. |

## Aceptación de implementación T08.1b22

| AC | Escenarios exigidos |
| --- | --- |
| INT-01 | Admitir los 56 subconjuntos en 2/3/4 plazas desde fuente tipada; rechazar duplicadas/desconocidas/cantidad incorrecta/catálogo activo/perfil ajeno/versión anterior; perfiles legados siguen exactos. |
| INT-02 | Recorrer las doce casillas de cada misión en combinaciones, normal/primero/posterior, comprobando efectos contra catálogo y decisiones; cierre terminal por cualquiera de las ocho, sin premios de última cima. |
| INT-03 | M1/M2/M8 juntos: pausas/auto_empty/omisión según familia, respuestas inválidas y reenvíos, ledger simultáneo, restauración de cada cursor admitido; deuda/programa/fuente/grupo de otra misión no se acepta. |
| INT-04 | M1+M6+M4: capacidad derivada sobre entrenamiento/inicio, mano 5/6/agotamiento y robo con reciclado/RNG reproducible; M2+M3 juntos: ambos recursos y marcas una vez en inicio. |
| INT-05 | Inicio y cierre internos atómicos con reenvíos/ocurrencia consumida; rechazo público de namespaces antes de recibos. Carga de marcas ausentes/huérfanas/futuras/reaplicadas y capacidad/ledger falsos rechazada sin estado parcial. |
| INT-06 | Presupuestos de familias combinadas y vistas actuales/cierre: frontera suficiente/insuficiente, más de 16 candidatos sin truncado, destinos propios/rivales, recibos/revisión, auto_empty; falla conserva snapshot/RNG. |
| INT-07 | Proyección de las tres familias por destinatario/tercero, sin correspondencias cruzadas ni secretos; callbacks adversos con delta/RNG inválidos se rechazan tanto con azar legítimo como sin él. |
| INT-08 | Suite nueva y regresiones pertinentes con versión exacta Godot, marcas/códigos/logs; revisión independiente del diff final, documentación/traspaso y limitaciones. No acredita producto, red ni modos con rival. |

## Plan y propiedad

1. Publicar este contrato tras contraste/revisión documental favorable y comprobación de enlaces/diff. Verificar HEAD remoto y árbol limpio antes de empezar b22.
2. Registrar b22 R2 antes de editar código. Un implementador posee scripts/game, tests y tools/godot.ps1; coordinador documentación e integración. Registro combinado y candidato por definición sin ampliar pilotos previos. Snapshot 8/versión y fixtures explícitos.
3. Servicio combinado, inicio/cierre internos, proyección/carga, cálculo de capacidad con M6 y validación de RNG por acción. Mantener invariantes/guardas de cada familia y presupuesto previo a gasto/carga.
4. `tests/integrated_missions_test.gd` y fixtures; acción `test-integrated-missions`. Ejecutar INT-01–07 y las diecisiete suites vigentes (`test-m2`, `test-m1`, `test-m8`, `test-sequence`, `test-mission-advance`, `test-permanents`, `test-state`, `test-engine`, `test-setup`, `test-cycle`, `test-cleanup`, `test-funding`, `test-training`, `test-start`, `test-catalog`, `test-missions`, `test`) en serie con SRC-005 preparado. Artefactos ignorados tmp, evidencia durable en verification.md.
5. Revisor independiente Sol/high examina fuentes/diff/casos adversos/evidencia; corregir y revalidar deltas afectados. Sin UI/transporte: visual/red no aplican. Cerrar memoria una vez; b22 queda local porque el encargo sólo exige commit/push entre pasos. No declarar cerrada P08.
