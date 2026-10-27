# Contrato del catálogo, versión 1

Implementado en [catalog_validator.gd](../scripts/catalog/catalog_validator.gd). Versión de desarrollo; nuevas familias podrán ampliarlo mediante especificación y pruebas. No afirma cobertura de todas las cartas aún no recibidas.

## Sobre del documento

Raíz objeto con campos obligatorios: version_esquema (entero 1), id_catalogo (ID estable), idioma (es), fuentes (array no vacío) y cartas (array no vacío). No se ignoran claves desconocidas. El array plano anterior se rechaza con diagnóstico; la migración de los dos ejemplos es explícita.

Cada fuente declara id, tipo (muestra/reglamento/errata/carta_fisica/editorial), descripcion, ruta y url. Ruta y URL pueden ser null en muestras; las fuentes reales necesitan archivo o URL https. Una carta física requiere foto/escaneo local existente. Las rutas locales permanecen dentro de res://. Una URL se registra sin descargarla ni acreditar su contenido.

## Definiciones de carta

| Campo | Contrato |
| --- | --- |
| id | Único, estable; minúsculas ASCII, cifras y guion bajo; empieza por letra. |
| nombre | Texto de presentación no vacío. |
| tipo | muestra, sin_clasificar, funding, entrenamiento, accion, aliado, personaje, mision, edicto, adversario, rival, dominacion, pista_entrenamiento. Son identificadores internos; no validan terminología editorial española. |
| cantidad | Copias físicas por diseño; entero positivo o null mientras no se conozca. Una carta verificada exige cantidad confirmada. |
| coste_compra | Entero no negativo o null. Null en borrador puede significar pendiente (anotar duda); en tipos no comprables significa no aplicable. Acciones/aliados verificados exigen coste. |
| texto_original | Transcripción humana/OCR conservada, contrastada con imagen antes de verificar. No es código. |
| resumen | Objeto con recurso y ataque, enteros no negativos o null si desconocidos; solo presentación, nunca fuente del motor. |
| metales | Lista sin duplicados de IDs ordinarios: peltre, estano, bronce, cobre, zinc, laton, hierro, acero. No inferir pareja ni activación por el nombre. |
| ruta_imagen | Null o ruta res://assets/images/ con extensión png/jpg/jpeg/webp/svg. Ausencia avisa y usa sustituto. |
| fuentes | Referencias no vacías con id de fuente declarada y localizador (página, cara, posición, archivo dentro del lote o sección). |
| revision | estado, idioma_verificado (booleano), dudas (array de textos). |
| vinculos | IDs de otras definiciones; deben existir y no apuntar a sí misma. Una verificada solo puede depender de otras verificadas. |
| rasgos | Objeto; opcionales salud, escudos, posiciones_limpieza y recorridos. No añadir campos por intuición. |
| habilidades | Secuencia de bloques de habilidad; vacía si el componente se expresa mediante recorridos. |

IDs, cantidades, coste, texto y valores heredados de moneda_de_cobre/kelsier se conservan. Las antiguas rutas inexistentes se sustituyen por null y recurso/ataque se trasladan a resumen. Tipo y revisión son muestra: no se convierte Kelsier en una ficha oficial por compartir nombre.

## Revisión y disponibilidad

- muestra: contenido ficticio/de desarrollo; nunca catálogo verificado.
- borrador: transcripción/estructura en trabajo; puede tener dudas y op pendiente. No se interpreta como carta válida de partida.
- verificada: revisión declarada con fuente real, idioma revisado, cero dudas, tipo clasificado, cantidad confirmada, sin momentos/condiciones/efectos pendientes. Se comprueban también sus requisitos de tipo.

El validador comprueba las declaraciones, no certifica que una foto corresponda al texto ni que la transcripción sea fiel. Esa revisión debe registrarse al incorporar cada lote. Ninguna carta actual está verificada.

Database.cartas devuelve una copia profunda para la presentación. get_definition(id) devuelve otra copia. get_verified_definitions() devuelve solo las declaradas verificadas y estructuralmente válidas; no significa que sus efectos estén implementados o probados. El futuro motor no debe consumir directamente muestras/borradores.

La definición describe un diseño y su cantidad física, no una carta concreta de la partida. En P07 una instancia tendrá identidad propia, definition_id, propietario/zona/estado; nunca se añadirá estado mutable de partida al JSON.

## Habilidades, condiciones y efectos

Cada habilidad contiene id único dentro de carta, momento, condicion, limite_por_turno y efectos. Límite: entero positivo o null (no declarado). No inferir una regla de frecuencia desde null. Momentos: pendiente, al_jugar, al_comprar, metal_quemado, al_entrenar, al_progresar, reaccion, continuo, resolver_rival.

Condiciones admitidas:

- {"op":"siempre"}.
- {"op":"metales_quemados","metales":["cobre","bronce"]}: todos los metales enumerados; no valida por sí misma el evento o la frecuencia.
- {"op":"todas","condiciones":[...]} y {"op":"alguna","condiciones":[...]}.
- {"op":"pendiente","nota":"Motivo que falta contrastar"}.

Los efectos son arrays en orden de resolución. No se analiza texto_original ni se deserializan objetos/scripts. Gramática inicial:

| op | Campos adicionales obligatorios |
| --- | --- |
| sin_efecto | Ninguno; casilla que expresa explícitamente ausencia de efecto. |
| pendiente | nota no vacía; bloquea verificación. |
| ganar | cantidad positiva, objetivo, recurso (recursos/ataque/atium/boxings). |
| robar / curar / danar | cantidad positiva, objetivo. |
| avanzar | cantidad positiva, objetivo, pista (entrenamiento/mision/dominacion). |
| mover_carta | cantidad positiva, objetivo, origen y destino (mano/mazo/descarte/juego/mercado/eliminadas). |
| refrescar_metal | cantidad positiva, objetivo, metal ordinario. |
| elegir | min no negativo, max positivo, opciones (array de secuencias de efectos); min ≤ max ≤ número de opciones. |

Objetivos: propio, jugador, oponente, oponentes, rival, adversario, aliado. Son clases de selector para el motor futuro, no autorización de una acción concreta; legalidad, selección exacta, costes, multiplicadores y resolución se implementarán en P07–P09.

Ejemplo exclusivamente estructural, sin atribuirlo a ninguna carta:

```json
{
  "id": "principal",
  "momento": "al_jugar",
  "condicion": {"op": "siempre"},
  "limite_por_turno": null,
  "efectos": [{"op": "ganar", "recurso": "recursos", "cantidad": 1, "objetivo": "propio"}]
}
```

Flaring, Savant, habilidades especiales, multiplicadores de Dominación y cartas no recibidas no se inventan con estas primitivas. Si una combinación no expresa fielmente la fuente, declarar pendiente, registrar la duda y ampliar el contrato con pruebas cuando haya evidencia.

## Rasgos y recorridos

salud y escudos son enteros no negativos si se declaran. Adversario verificado requiere escudos; rival verificado requiere salud. posiciones_limpieza enumera posiciones únicas 1–6 del mercado.

recorridos es una lista de objetos id/casillas. Cada casilla tiene id único en su recorrido y efectos ordenados. Misiones/pistas verificadas requieren recorrido; Dominación verificada requiere dos recorridos (caras). No se deducen sus casillas: se transcriben desde la pieza física. Las recompensas especiales pueden permanecer pendientes en borradores.

## Fallos, avisos y límites técnicos

Un error de estructura, versión, tipo, referencia o revisión contradictoria rechaza todo el catálogo. Se vacían definiciones, selección verificada, conteos y avisos antiguos; una recarga válida recupera el estado. El diagnóstico incluye archivo y ubicación/campo, normalmente también ID de carta. Un arte nulo/ausente es aviso, no error estructural; la vista conserva sustituto.

Una fuente local ausente es error porque rompe trazabilidad. La vista carga únicamente una Texture2D válida o mantiene sustituto. No se acredita decodificación de todas las imágenes ni calidad de OCR por la presencia de un archivo.

Límites de implementación, no reglas del juego: archivo JSON 4 MiB; 512 diseños; 256 fuentes; 32 habilidades por carta; 64 efectos por secuencia; 16 opciones/condiciones agrupadas; profundidad 8; números hasta 1 000 000. Los textos y listas también tienen límites explícitos en el validador. Ampliarlos exige necesidad y pruebas, no una regla casera.

Comprobar con -Action test-catalog; evidencia en [SPEC-006](specs/006-contrato-catalogo/verification.md). Las fotos completas, terminología española, cantidades y efectos reales siguen pendientes de incorporación.
