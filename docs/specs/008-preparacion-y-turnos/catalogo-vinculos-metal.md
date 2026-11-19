# Catálogo v4: vínculo de metal de una acción

T08.1b27 amplía el descriptor de condición sin ejecutar texto como código. Conserva v1–v3; v4 hereda la reserva de puntos de misión de v3, las misiones de v2 y la validación de fuentes físicas y huellas. [Contrato de activación](activacion-perseguir.md) y [base v3](catalogo-puntos-mision.md).

Una habilidad de `tipo: accion`, `momento: al_jugar`, puede declarar `{"op":"metal_asignado","metales":["bronce"]}`. Significa que el resolutor debe vincular a **esa activación** un metal efectivo de la lista. No basta con que el mismo metal figure entre los quemados del turno. La ficha ordinaria, el Atium sustituto y una carta usada como metal tienen consumo distinto según el contrato de activación.

Una habilidad de `tipo: accion`, `momento: metal_quemado`, puede declarar `{"op":"esta_carta_como_metal","metales":["cobre","bronce"]}`. Significa que el disparador es el uso de **esa misma instancia** como uno de sus metales impresos. El validador exige que cada metal figure en `carta.metales`; quemar otra fuente o descartar para refrescar no satisface la condición. La omisión y el cierre único son operaciones de autoridad, no se infieren de `siempre`.

Las dos formas exigen lista no vacía y sin duplicados de metales conocidos, carecen de claves adicionales y están disponibles sólo en v4 y en el momento correspondiente. También se validan dentro de condiciones compuestas. v1–v3 las rechazan. El validador sólo admite la forma; un perfil debe reconocer explícitamente la carta, efectos, fuentes y oportunidades antes de ejecutarla. La definición independiente [Perseguir](../../../data/perseguir.json) usa v4 y no se incorpora al catálogo de arranque.

La verificación estructural de Perseguir depende de preparar localmente el original mediante `tools/prepare-perseguir-source.ps1` y de su SHA-256. El original está fuera de Git. La política para distribuirlo a otros clones sigue pendiente; esta gramática no concede admisión de producto, Sense, Seek, copia de nivel II ni modos con rival.
