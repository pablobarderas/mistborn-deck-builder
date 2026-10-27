# SPEC-003 — Proyecto Godot ejecutable

- Estado: completada y verificada; fecha 2026-10-27.
- Fase: P03. Tareas: T03.1 y T03.2; sin issue publicada.
- Entrada: alcance funcional confirmado y dos cartas JSON de prueba.

## Resultado

Abrir y ejecutar el proyecto en Windows con una versión fija de Godot, una pantalla inicial en español y un diagnóstico real de carga. Mantener identificados los ejemplos como contenido de prueba.

## Aceptación

- **AC-01:** Godot 4.7.2 estándar ejecuta project.godot y su escena principal con el renderizador Compatibility.
- **AC-02:** Database se carga como Autoload antes de la pantalla y permite comprobar cuántas cartas se han cargado; las dos entradas originales se conservan.
- **AC-03:** La pantalla muestra los datos de prueba con un recurso visual de sustitución, sin depender de las imágenes ausentes. Salir y comprobar de nuevo el catálogo son acciones funcionales.
- **AC-04:** Un fallo de carga produce diagnóstico de ruta/causa y estado visible de error; no deja cartas antiguas presentadas como válidas. Se puede recuperar cargando datos válidos.
- **AC-05:** Hay comandos reproducibles para importar, abrir editor, ejecutar y comprobar arranque/carga, con códigos de salida útiles.
- **AC-06:** Se verifica desde una copia de fuentes sin caché previa y se revisa la pantalla renderizada a la resolución de referencia de 1280×800.

## Límites

No se implementan reglas, salas, reconexión, exportación distribuible ni catálogo oficial. La validación mínima solo cubre lo necesario para indexar con seguridad (array, objetos, IDs únicos no vacíos); el esquema completo pertenece a P06. La dirección visual definitiva pertenece a P05.

La versión se fija con el ejecutable portátil descargado del enlace oficial de Godot; no se incorpora el motor al repositorio. No se necesita completar el catálogo ni resolver las dudas de reglas para esta fase.
