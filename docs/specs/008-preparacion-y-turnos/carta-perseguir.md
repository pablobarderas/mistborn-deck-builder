# T08.1b23 — Primera carta real que genera puntos de misión

Contrato documental para un futuro perfil competitivo aislado. No admite aún cartas de mercado en el motor ni declara verificada una definición de catálogo.

## Fuente y lectura

**Perseguir**, SRC-005, `cartas_mercado/mercado.3.png`, fila 1 derecha, código impreso 17/82; SHA-256 del PNG original `747A01D7EBBF69E8272C052C81A40BEAA5EF67FFF853C1C4E1E8C69B49A105CB`. La [auditoría](../../referencias/auditoria-escaneos-2026-11-09.md) registra un diseño naranja y una copia física declarada. El escaneo local es externo al repositorio: el contrato v1 exige una fuente física dentro de `res://` antes de marcar la carta verificada.

Lectura visual contrastada: coste 3, pareja de metales cobre/bronce; la capacidad primaria marcada **BRONCE** muestra un cuadrado con 2 y una moneda con 2, ambos efectos sin barra de alternativa. El cuadrado corresponde a puntos de misión según [REG-032](../../referencias/matriz-reglas.md) y la leyenda de SRC-001, p. 14. El icono cuadrado con 1 junto a la pareja de metales es la capacidad Savant, separada de la primaria (SRC-001, p. 10; REG-023). No hay texto secundario ni habilidad fuera de turno visibles. No se halló una errata específica de Perseguir en SRC-002; la comprobación de fidelidad final se repetirá al incorporar el catálogo.

Fuentes de reglas: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp. 7–10, 14 y 17; [SRC-002](../../referencias/README.md#src-002--faq-y-erratas-del-editor), secciones de cartas de acción, metales y misiones; REG-014/021/023/032/045. Las correcciones expresas de SRC-002 prevalecen sobre el PDF.

## Frontera de integración

- La activación de la capacidad primaria requiere asignar bronce a la acción según REG-021. Quemar la carta como metal, descartarla para refrescar o quemar bronce en otra acción no ejecutan su capacidad. Savant +1 punto de misión se activa únicamente al usar **Perseguir** como metal (REG-023), no al jugar su primaria ni al descartarla para refrescar. La primera implementación deberá cubrir ambas rutas antes de admitir la definición completa.
- La capacidad primaria aporta **dos puntos de misión brutos** y **dos monedas de turno** en el orden impreso; Savant aporta un punto bruto por su ruta distinta. La capacidad primaria puede omitirse como una unidad: no se obtiene sólo uno de sus dos efectos ni se reserva el otro para más tarde. Los puntos no avanzan automáticamente una misión: la autoridad debe conservar el neto en `turn_resources.mision` y cada gasto posterior elige una misión mediante el servicio [M1–M8](integracion-misiones.md). La moneda de turno no es Boxing ni reserva permanente.
- El servicio combinado actual sólo consume puntos ya presentes y sus descriptores admiten contenido inerte. No tiene una intención pública de jugar esta acción ni un resolutor de metales/cartas. Por ello este contrato no habilita Perseguir mediante el constructor existente. El [catálogo v1](../../contrato-catalogo-v1.md) tampoco admite `ganar` con recurso `mision`; representar la primaria como `avanzar` sería incorrecto porque salta la elección de recorrido.
- Una futura ampliación debe admitir un descriptor cerrado para esta carta con ID estable, fuente física versionada, cantidad/coste/texto/iconos revisados, esquema de efecto de reserva y perfil explícito. No se ejecutará `texto_original` como código ni se aceptarán descriptores o resultados suministrados por el cliente. Al incorporarla se probarán partida/carga, proyecciones, límites, rechazos y rollback junto con regresiones de los tres recorridos y premios.
- La reducción por Sense de REG-045 se aplica a los puntos obtenidos durante todo el turno antes de permitir gastar su saldo neto; una deuda pendiente puede consumir ganancias posteriores. Los puntos negativos reducen la reserva sin retroceder marcadores confirmados. El primer perfil puede excluir Sense mediante admisión cerrada; incorporarlo exige modelar la deuda y probar varias ganancias sucesivas. Cooperativo y solitario precisan sus propios finales y paso rival: este contrato no les aplica la victoria competitiva por tres misiones.

## Aceptación documental y escenarios para la implementación posterior

| ID | Criterio y escenario futuro |
| --- | --- |
| CAR-DOC-01 | Original, posición, huella, iconos, coste, pareja, cantidad y estado de revisión trazados; dudas visibles, sin dato oficial inventado. |
| CAR-DOC-02 | Contrato de reserva distinguido de avance: al activar la primaria con bronce se obtienen dos puntos brutos, sujetos a Sense, y dos monedas de turno; dos gastos posteriores pueden escoger misiones distintas. Savant, por uso como metal, aporta un punto bruto sin disparar la primaria. |
| CAR-DOC-03 | Impedir activación sin bronce asignado, segunda activación de la misma primaria, uso como metal que dispare la primaria o descarte que dispare Savant; rechazo íntegro sin alterar carta, metal, recursos, RNG ni recibo. La omisión voluntaria consume la primaria entera sin recursos ni activación posterior. |
| CAR-DOC-04 | Con Sense, puntos netos y monedas se resuelven según fuente; al gastar el último punto que alcanza una cima se aplican premio/final del servicio combinado sin repetir la acción original. Reenvío idéntico devuelve el recibo anterior; restauración no duplica reserva. |
| CAR-DOC-05 | Contrato y límites de catálogo/autoridad identificados; una revisión independiente de reglas y diff comprueba que no se habilite producto, turno completo ni carta no verificada. |

Primer paso de implementación posterior: versionar un derivado legible del escaneo y una definición de prueba trazada, ampliar la gramática/validador del catálogo con el recurso de misión y pruebas negativas; después especificar el ciclo de juego/metal de acciones y su integración transaccional. La ficha física externa, aunque legible aquí, no viaja con un clon del repositorio.
