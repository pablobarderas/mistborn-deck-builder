# Reglas del Proyecto: Mistborn Deckbuilder

## Entorno
- Motor: Godot 4.x
- Lenguaje: GDScript (NUNCA usar C#).
- Estructura de carpetas: 
  - `data/` (Bases de datos JSON)
  - `assets/images/` (Recursos visuales)
  - `scenes/` (Archivos .tscn)
  - `scripts/` (Archivos .gd)

## Reglas de Programación
- Tipado estricto: Usa tipado estático en GDScript siempre que sea posible (ej: `var salud: int = 100`).
- Nomenclatura: Variables y funciones en `snake_case`, clases y nodos en `PascalCase`.
- Separación de responsabilidades: Nunca incrustar imágenes en código; cargar siempre rutas desde los datos (`cartas.json`).
- Validaciones: Incluir siempre `push_error()` o `push_warning()` cuando se abran archivos o se instancien nodos para facilitar el debug.