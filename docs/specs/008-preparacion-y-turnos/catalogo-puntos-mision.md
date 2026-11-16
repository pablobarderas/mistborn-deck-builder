# Catálogo v3: reserva de puntos de misión

T08.1b24 amplía sólo la gramática estructural del catálogo para representar puntos de misión ganados por una habilidad de acción. El descriptor no ejecuta efectos, no selecciona una misión y no admite Perseguir al motor. [Contrato de la carta](carta-perseguir.md); [base v1](../../contrato-catalogo-v1.md) y [ampliación v2 de misiones](catalogo-misiones.md).

## Sobre y forma

`version_esquema: 3` conserva las formas de v2, incluidas la huella SHA-256 obligatoria de cada fuente `carta_fisica` y las casillas de misión. Una acción declarada verificada en v3 requiere referencia física local, además de la revisión general; las muestras pueden probar la gramática sin esa declaración. v1 y v2 mantienen exactamente su gramática anterior. Sólo en v3 se admite esta forma nueva dentro de `habilidades[].efectos` de una carta `tipo: accion` cuyo `momento` sea `al_jugar` o `metal_quemado`:

```json
{"op":"ganar","recurso":"mision","cantidad":2,"objetivo":"propio"}
```

`cantidad` es entero positivo dentro del límite general; no hay campos adicionales. Las opciones anidadas conservan el tipo y momento de la habilidad propietaria. Otros tipos, momentos, objetivos y versiones rechazan `ganar mision`, también dentro de opciones. `avanzar` con pista `mision` sigue siendo una operación distinta: el nuevo descriptor aumenta una reserva de turno; la elección de recorrido y el gasto posterior pertenecen a la autoridad. No expresa Sense, la asignación de metal, la omisión de una capacidad, la oportunidad Savant ni la victoria. Esas reglas requieren el contrato de activación y transacción posterior.

La fuente española original de Perseguir está ahora localizada en `C:/Users/pbard/Pictures/Digitalizaciones/cartas_mercado/mercado.3.png`; su SHA-256 coincide con [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado) y [T08.1b23](carta-perseguir.md). El escaneo permanece fuera de Git y del proyecto. Esta entrega usa sólo fixtures ficticios de catálogo; no declara cantidad, texto completo o definición de Perseguir verificados en un lote ejecutable. Preparar fuente local reproducible, resolver la política de distribución de originales y contrastar la definición completa sigue pendiente.

## Aceptación

| ID | Comprobación |
| --- | --- |
| CAT-PM-01 | v3 acepta reserva propia en `al_jugar` y `metal_quemado`, en orden con otros efectos; conserva v1/v2 y las misiones v2. |
| CAT-PM-02 | v1/v2, otro tipo/momento/objetivo, cantidad inválida y campo adicional rechazan todo el documento, sin selección verificada parcial; opciones anidadas no escapan al contexto. |
| CAT-PM-03 | Suite de catálogo y regresión de misiones ejecutadas con Godot 4.7.2; el validador no ejecuta el descriptor ni lo equipara a `avanzar`. |
| CAT-PM-04 | Contraste de reglas, revisión independiente, documentación y traspaso distinguen fuente física, catálogo verificado, activación y producto. |

## Siguiente integración

Preparar la fuente física dentro de `res://` mediante procedimiento reproducible y revisar cantidad, texto, metales y habilidades completos antes de declarar verificada una definición de Perseguir. Después especificar y probar la activación directa de la primaria, su omisión y la ruta Savant con autoridad y rollback; excluir expresamente Sense, Seek y copia de nivel II si el perfil inicial no las resuelve. Cooperativo/solitario requieren sus finales y rival propios.
