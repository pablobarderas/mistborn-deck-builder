# T08.1b28 — Fuentes físicas fuera de la distribución

Política técnica para SRC-005 y futuras fotos de componentes. Separa el cotejo local de un catálogo que pueda instalarse en otro equipo. Es un contrato documental: no cambia el validador v4, no promueve [Perseguir](../../../data/perseguir.json) y no publica un paquete jugable.

## Decisión y alcance

Los PNG originales de las cartas y misiones permanecen fuera de Git, de los paquetes de Godot y de cualquier descarga para los amigos. Se conservan en la carpeta del propietario y, para verificar una definición, en `evidencia_local/` ignorada. La huella SHA-256, el localizador y el resultado de la revisión sí pueden viajar como metadatos. La interfaz usará recursos visuales creados para el proyecto o sustitutos permitidos; `ruta_imagen: null` no se interpreta como permiso para distribuir la imagen de la fuente. Antes de distribuir texto, ilustraciones o iconos derivados del juego se revisará su procedencia por separado. Esta política no concede licencia ni afirma que un uso concreto esté autorizado.

La elección evita incluir en el repositorio o en un ejecutable copias de obras cuyos derechos no se han acreditado para esta adaptación. La [Ley de Propiedad Intelectual, art. 17–18](https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930) reserva reproducción y otras modalidades de explotación al titular con sus límites legales; el [reglamento editorial](https://www.brotherwisegames.com/s/MistbornRulebook_V1.pdf) identifica la titularidad de Brotherwise y el uso autorizado de la saga. Es un criterio de publicación prudente, no una conclusión jurídica sobre la partida privada.

| Alternativa | Resultado para este proyecto |
| --- | --- |
| Incluir el PNG en Git, Git LFS o el ejecutable | No se adopta sin autorización específica del titular; un repositorio privado tampoco establece por sí solo ese permiso. |
| Exigir que cada amigo aporte el escaneo al instalar | Conserva la comprobación actual, pero impide una instalación sencilla y requiere copias de la caja en cada equipo. No se adopta como flujo del producto. |
| Cotejar localmente y distribuir un catálogo de ejecución sin PNG | Opción elegida. Requiere separar validación de autoría y admisión del paquete antes de promover Perseguir. |

## Dos fronteras de validación

**Autoría local.** El validador actual exige una ruta segura `res://` y un archivo presente para `carta_fisica`, compara SHA y valida la definición completa, incluida revisión. `res://evidencia_local/...` es la convención de los preparadores, no un prefijo impuesto por el validador. El preparador rechaza una copia distinta y no sobrescribe el original. Una persona revisa carta/escaneo, cantidad, iconos y reglas; el SHA sólo prueba identidad de bytes, no fidelidad de la transcripción. El resultado de la revisión queda en tarea, fuente y pruebas. `data/perseguir.json` sigue `borrador` hasta que el procedimiento de admisión de T08.1b29 exista y pase sus puertas.

**Paquete de ejecución.** Una herramienta de construcción, ejecutada en entorno de autoría con fuentes presentes, emitirá un artefacto separado y versionado. Sólo aceptará una lista cerrada de definiciones revisadas y perfiles con resolutor probado. Registrará ID/revisión del catálogo, huellas de fuentes y digest canónico de definiciones/efectos, sin rutas locales absolutas, bytes PNG, transcripciones OCR auxiliares ni claves de revisión editables por el jugador. El artefacto podrá guardarse en Git y distribuirse cuando su contenido concreto haya sido revisado. No se obtiene cambiando `revision.estado` en el JSON de trabajo ni permitiendo `ruta: null` en el validador actual.

La autoridad sólo admitirá un artefacto cuyo digest y versión figuren en un manifiesto de lanzamiento fijado por código o configuración fiable de esa autoridad. Recalcular un digest sobre un archivo que suministra el cliente no acredita procedencia; el cliente tampoco puede proponer revisión, fuente, resultado de efecto o estado inicial. La identidad del catálogo forma parte del perfil y del snapshot; un cambio de definiciones, fuente, formato o resolutor exige nueva identidad y, si cambia el estado, migración explícita. Las vistas privadas de cartas y las proyecciones siguen bajo P07/P14. El manifiesto no acredita la integridad del ejecutable anfitrión: si un participante hospeda con código modificado, puede saltarse esta comprobación. La elección y confianza del alojamiento siguen pendientes en P13–P14.

El validador de autoría y el cargador de ejecución serán interfaces tipadas distintas. No se añadirá un interruptor público `omitir_fuentes` ni una ruta de carga que acepte un JSON v4 verificado sin PNG por mera declaración. Si falta el manifiesto fijado, el digest no coincide, una definición no está admitida, una fuente fue alterada durante la construcción o el paquete incluye rutas/bytes prohibidos, la construcción o carga rechaza íntegramente y conserva el estado anterior.

## Implementación y aceptación futura

T08.1b29 debe concretar el esquema del artefacto y sus límites, generarlo de forma determinista a partir de `misiones.1.png`, `misiones.2.png` y `mercado.3.png` de SRC-005 y los descriptores admitidos, verificarlo con un cargador separado y comprobar un clon limpio sin `evidencia_local/`. En ese clon, el perfil cerrado deberá restaurar/ejecutar el mismo contenido sin abrir perfiles anteriores ni aceptar un paquete alterado. La prueba de exportación inspeccionará el paquete de Godot por rutas, nombres y huellas de los PNG; no basta con `.gitignore` o `.gdignore`. Un test negativo debe probar que el JSON de autoría continúa fallando sin las fuentes. Se registrarán digest, versión, comandos, revisión independiente y mecanismo de actualización. No distribuir todavía el artefacto ni el ejecutable por crear esta especificación.

| ID | Criterio documental de T08.1b28 |
| --- | --- |
| FUE-DOC-01 | Originales, arte de UI, metadatos y paquete quedan separados con una política de distribución explícita. |
| FUE-DOC-02 | Autoría con SHA y revisión humana; ejecución con artefacto fijado por autoridad, sin confiar en declaración del cliente ni relajar el validador v4. |
| FUE-DOC-03 | Plan T08.1b29 cubre versión, identidad, rechazo, clon limpio, exportación y límites con producto/red. |
| FUE-DOC-04 | Fuentes, alternativas, documentación, revisión independiente, enlaces/diff y traspaso comprobados sin afirmar pruebas Godot nuevas. |

La adopción del catálogo de ejecución no habilita automáticamente la carta en el producto: siguen pendientes la integración de interfaz/turno, el resto del contenido competitivo y los modos con rival. La distribución del texto y arte final debe revisarse para la entrega, y cualquier licencia o autorización obtenida posteriormente podrá cambiar esta política mediante una decisión nueva.
