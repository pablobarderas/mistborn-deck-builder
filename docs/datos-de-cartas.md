# Datos de cartas

## Estado actual tras P06

Formato canónico: [contrato v1](contrato-catalogo-v1.md). data/cartas.json ya es un objeto versionado con fuentes, definiciones, revisión, rasgos y efectos estructurados; los dos ejemplos conservan IDs/texto/números pero están identificados como muestras, sin equivalencia oficial.

Validador en scripts/catalog/catalog_validator.gd; Database expone copias profundas y separa definiciones verificadas. Los errores estructurales rechazan toda la carga; las imágenes pendientes generan avisos y sustitutos. La UI distingue muestra/borrador/verificada y ofrece resumen de avisos.

Comando: powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-catalog. No ejecuta efectos ni valida fidelidad por sí solo. Fotos y extracción por lotes: [guía Android](captura-de-cartas.md). Estado y evidencia en [SPEC-006](specs/006-contrato-catalogo/verification.md).

## Registro histórico anterior a P06

El inventario siguiente describe el contrato legado observado en P03, sustituido por el contrato v1 enlazado arriba. Sus referencias a trabajo pendiente conservan contexto histórico y no son las instrucciones actuales.

Fuente analizada entonces: data/cartas.json antes de la migración. Consumidor: scripts/Database.gd.

## Formato observado

La raíz es un array de objetos. Ambas entradas actuales contienen:

| Campo | Tipo observado | Uso actual |
| --- | --- | --- |
| `id` | String | Clave del diccionario del cargador. |
| `nombre` | String | Nombre mostrado en la previsualización de P03. |
| `coste_compra` | Entero | Dato de ejemplo; sin lógica de compra. |
| `generacion_recurso` | Entero | Dato de ejemplo; sin lógica de recursos. |
| `poder_ataque` | Entero | Dato de ejemplo; sin lógica de combate. |
| `efecto` | String | Descripción; sin ejecución automática. |
| `ruta_imagen` | String | Ruta `res://`; los archivos referenciados no existen. |

Este es el formato observado, no un esquema completo del juego. La estructura final dependerá del reglamento y del catálogo confirmados.

## Implicaciones de SRC-001

El reglamento recibido el 2026-10-27 distingue Funding, acciones, aliados, personajes, misiones y cartas rivales (edictos/adversarios). El contrato actual no expresa costes por metales, umbrales, Savant, reacciones, habilidades continuas, escudos, efectos según Dominación ni posiciones de limpieza del mercado.

P06 debe diseñar un contrato por tipos y familias antes de incorporar contenido oficial. No es suficiente ampliar el texto de `efecto` ni añadir un único número de ataque. Ver [componentes](referencias/componentes.md) y [SPEC-002](specs/002-modos-y-cooperativo/spec.md). Todavía faltan los textos y cantidades por diseño del catálogo español.

## Requisitos de validación del contrato

La cobertura actual es parcial y se detalla debajo; esta lista describe el contrato que deberá completarse en P06.

- Raíz de tipo array y cada entrada de tipo objeto.
- Presencia y tipo de los campos requeridos por el contrato que se adopte.
- `id` no vacío y único; conservar los IDs existentes salvo migración explícita.
- Restricciones numéricas según las reglas confirmadas, sin convertir silenciosamente textos en números.
- Política explícita para imágenes ausentes: error o recurso de sustitución.
- Diagnósticos que identifiquen entrada, campo y motivo del fallo.
- Política de carga ante errores: rechazar el catálogo o aceptar solo entradas válidas; pendiente de decisión.

P03 ya verifica apertura, parseo, raíz array, entradas objeto e IDs textuales no vacíos y únicos. Un fallo rechaza toda la carga y vacía el catálogo, emitiendo diagnóstico; una recarga válida limpia el error. La política está elegida para esta base y deberá revisarse con el contrato completo de P06.

Siguen pendientes validación del resto de campos/tipos, límites numéricos, referencias y catálogo oficial. La pantalla usa sustitutos visuales y no carga las rutas de ilustración ausentes. Godot interpreta números JSON como float; la vista muestra las cifras enteras de estos ejemplos sin decimales artificiales.

## Evolución

Mantener separados el texto que lee el jugador y los efectos estructurados que ejecutará el motor. No analizar frases de `efecto` para determinar el comportamiento. Diseñar ese formato cuando haya reglas y ejemplos confirmados, documentando cualquier migración.

Resolver la diferencia entre `assets/cartas/` (rutas actuales) y `assets/images/` (convención prevista) al incorporar los primeros recursos. No cambiar las rutas por suposición ni afirmar que existen imágenes.
