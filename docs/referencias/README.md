# Fuentes del juego y trazabilidad

Última revisión: 2026-10-27. Reglamento leído completo mediante extracción y revisión visual de las 20 páginas. La fuente está en inglés; el producto se quiere en español.

## SRC-001 — Reglamento aportado por el usuario

- Título: Mistborn: The Deckbuilding Game.
- Editorial: Brotherwise Games, LLC; autor: John D Clair.
- Identificación expresa en p.2: 1st Edition; 1st Printing, publicado en 2024.
- Idioma del archivo: inglés. No confirma por sí solo edición ni terminología de la caja española.
- Fuente: [PDF original conservado](fuentes/MistbornRulebook_V1.pdf).
- Ubicación relativa a la raíz Git: `docs/referencias/fuentes/MistbornRulebook_V1.pdf`.
- Copiado sin modificaciones desde la ruta aportada por el usuario; el hash se ha contrastado con el original.
- Extensión: 20 páginas; páginas físicas y numeración impresa coinciden desde la página 2.
- Tamaño: 3 366 328 bytes.
- SHA-256: `2db810336a0a62880870f693d6dbdd3a56d9bf70b46737a9abe373d7c491a054`.
- Incorporación documental: 2026-10-27, proporcionado por el usuario como reglas oficiales.
- Estado: identificado y revisado; incorporado al repositorio el 2026-10-27 por petición de trasladar todo lo necesario a otro PC.

El PDF acompaña al clon del repositorio. Mantener su hash y nombre para conservar la trazabilidad; no es una traducción española ni un catálogo de cartas.

## SRC-002 — FAQ y erratas del editor

- Fuente primaria: [Brotherwise Games — Mistborn FAQ](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq).
- Idioma: inglés. Actualización declarada por la página: enero de 2025; consulta: 2026-10-27.
- Estado: leída como complemento de SRC-001. Identificación por secciones, no por páginas; no se ha archivado una copia local completa.
- Precedencia de trabajo: las erratas y aclaraciones expresas del editor corrigen SRC-001. No completar con ellas casos que no responden explícitamente.
- Los cambios incorporados aparecen con SRC-002 en la matriz. Los casos específicos de cartas deberán revisarse otra vez al completar el catálogo.

## SRC-003 — Identificación de la edición española

- Fuentes primarias: [anuncio oficial de Devir](https://devir.com.ar/devir-publicara-los-juegos-de-rol-y-de-mesa-del-cosmere) y [ficha oficial de Nacidos de la Bruma](https://devir.co/nacidos-de-la-bruma).
- Consulta: 2026-10-27. El anuncio confirma la publicación en español por Devir; la ficha identifica el juego y a Brotherwise Games como editor original.
- Dato aportado por el usuario: en su ejemplar figura el crédito «Edición: David Pérez». Se registra literalmente como testimonio, sin atribuir a esa persona una empresa ni una tirada concreta.
- Estado: referencia de identidad editorial, no reglamento ni catálogo. No permite cerrar DUD-003 ni verificar toda la traducción de su ejemplar.
- En las páginas consultadas no se localizó un enlace accesible al reglamento español oficial; no se afirma que no exista. No se usaron traducciones de aficionados como autoridad.

## Mapa de lectura del reglamento

| Páginas | Contenido |
| --- | --- |
| 1–2 | Portada, identificación y créditos. |
| 3 | Componentes y cantidades físicas. |
| 4–5 | Preparación visual y pasos de preparación. |
| 6–8 | Zonas, ciclo del mazo, quemado, Flaring, refresco y Atium. |
| 9–11 | Palabras clave, acciones, aliados, Funding y habilidades fuera de turno. |
| 12–14 | Entrenamiento, personajes y misiones. |
| 15–17 | Combate, Target, mercado, Boxings, secuencia y victorias competitivas. |
| 18–20 | Preparación solo/cooperativa, Dominación, adversarios, edictos y finales. |

## Documentos derivados

- [Matriz inicial de reglas](matriz-reglas.md): IDs REG, páginas y casos de prueba previstos.
- [Componentes](componentes.md): cantidades confirmadas y catálogo faltante.
- [Dudas](dudas.md): ambigüedades y material que falta.
- [SPEC-001](../specs/001-alcance-y-reglamento/spec.md): inventario y acuerdos de alcance.
- [SPEC-002](../specs/002-modos-y-cooperativo/spec.md): comportamiento de modos y rival cooperativo.

Todas las reglas documentadas siguen sin implementación ni pruebas ejecutadas. El inventario inicial no sustituye el catálogo completo de cartas.

## Cómo incorporar fuentes posteriores

Asignar el siguiente ID libre (actualmente SRC-004), registrar origen, edición, idioma, páginas y fecha; comprobar diferencias con SRC-001/002. Las fotos de cartas deben identificar qué diseño y cantidad respaldan. Mantener nombre del original y nombre oficial español por separado hasta contrastarlos.

No completar contradicciones por intuición. Cerrar cada DUD con una fuente o una adaptación expresamente acordada. Conservar los IDs REG aunque se amplíe o corrija su redacción.
