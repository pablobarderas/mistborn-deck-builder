# Datos de cartas

Fuente actual: [`data/cartas.json`](../data/cartas.json). Consumidor: [`scripts/Database.gd`](../scripts/Database.gd).

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
