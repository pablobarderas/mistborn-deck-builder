# Plan inicial de SPEC-002

Propuesta técnica pendiente de concretar contratos en P06/P07; no describe código existente.

1. Mantener catálogo, estado, resolución de efectos y validación comunes. Modelar modo y participantes explícitamente.
2. Separar variaciones de preparación, objetivos legales, selección de Target, finales y paso posterior al turno.
3. Añadir estado del rival: salud, mazo/descarte, Dominación/cara/casilla y adversarios con escudos y jugador asociado.
4. Resolver el turno mediante una secuencia que permita elecciones y reacciones fuera del turno activo; no reducirlo a una llamada instantánea que impida Cloud o reparto colectivo.
5. Ejecutar el rival con la misma autoridad de reglas que valida las acciones humanas; no delegar el robo o resultado de edictos a cada cliente.
6. Mantener los escudos destruidos como estado persistente. Obtener X de la Dominación al resolver el coste conforme a la fuente.
7. Probar solitario sin red y después la misma lógica en sesiones cooperativas de 2–4. Reutilizar acciones de prueba, no abrir dos motores distintos.

Datos pendientes: todos los textos de cartas rivales, selección de mercado por edicto, casillas de Dominación y entrenamiento. Nunca completar esos datos inventando efectos.

Verificación: las filas AC-01 a AC-12 de verification.md se irán vinculando a pruebas reales. Las dudas deben resolverse antes de dar por verificada su parte; un prototipo no cierra el catálogo completo.
