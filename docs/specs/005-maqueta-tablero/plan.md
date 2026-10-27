# Plan de SPEC-005

## Diseño

Base azul/grafito, superficies apenas separadas, texto marfil y secundario gris azulado. Plata para líneas/foco; cobre/oro para acción principal; ocho acentos de metales acompañados por nombres. Serif contenida para identidad y títulos, Segoe UI para interfaz.

Barra superior con modo de muestra y salida; columna lateral con participantes y misiones; mesa central con mercado, zona jugada y metales; mano y recursos en el borde inferior. Filas de cartas se desplazan horizontalmente. Detalle de carta en panel modal con fondo atenuado.

Escena propia, controles Godot y componentes separados: vista de carta reutilizable, datos de muestra locales, paleta/estilos y composición del tablero. La maqueta no llama a Database ni al transporte. Se conserva la pantalla inicial y se añade acceso a Ver tablero.

Ilustraciones raster provisionales generadas mediante herramienta integrada en un atlas de cuatro motivos; guardado en assets/images/board/ y referenciado por ruta. Marcos, símbolos de interfaz y disposición se construyen en Godot. El prompt y procedencia quedan documentados.

## Verificación

Render real en tres resoluciones, mano saturada y modal. Comprobar botones, foco, Escape, movimiento visual/reinicio y navegación sin atribuir cobertura de reglas. Revisar capturas antes de entregar al usuario; conservar AC-06 pendiente de aceptación visual cuando corresponda.
