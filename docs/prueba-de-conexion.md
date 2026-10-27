# Probar la conexión de P04

El prototipo comparte lista de participantes y contador. No contiene partidas ni recupera plazas al reconectar. El anfitrión es la autoridad: solo él aplica las señales válidas. Hay un máximo de cuatro personas incluyendo anfitrión.

## Probar ahora con un PC

Abrir dos terminales PowerShell en la raíz del proyecto y ejecutar en cada una:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action network
```

También se llega desde la pantalla inicial mediante **Probar conexión**. En la primera ventana, escribir un nombre y pulsar **Crear prueba como anfitrión**. Dejar el puerto 24567 y copiar la clave que aparece a la derecha.

En la segunda, usar otro nombre, dirección `127.0.0.1`, el mismo puerto y la clave copiada; pulsar **Unirse a la prueba**. Ambas ventanas deben mostrar dos participantes. **Enviar una señal (+1)** debe aumentar el contador en ambas, pulse quien pulse. Se pueden abrir otras dos ventanas; la quinta persona no entra.

**Desconectar** permite crear o entrar de nuevo; la nueva conexión no recupera una plaza anterior. **Volver** cierra la sesión de esa ventana y regresa al inicio. Si sale el anfitrión termina el ensayo. La nueva prueba genera otra clave; su contador empieza en cero.

## Comprobación automática

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-network
```

Ejecuta un anfitrión y clientes en procesos Godot independientes usando sockets UDP reales en localhost. Comprueba admisión, autoridad, convergencia, cuatro personas, rechazo del quinto, errores de clave/protocolo, solicitudes sin admisión, duplicadas, desconocidas o mal formadas y estado forjado; cierre, reintento y botones. Termina con `P04_NETWORK_OK` y código 0. El fallo de crear un segundo servidor en un puerto ocupado es un error esperado de la prueba.

Logs locales: `tmp/godot/test-network.log` y `tmp/godot/p04-*.log`. La clave de los ensayos automáticos es una constante de prueba, no una credencial real. El proceso coordinador cierra sus procesos hijo al terminar normalmente. Ejecutar una sola prueba automática de red cada vez.

La acción `preview-network` genera tres capturas reales en `tmp/screenshots/`: `connection-screen.png`, `connection-host.png` y `connection-host-1024.png`. Comprueba navegación, botones y liberación del puerto al volver. La regresión del catálogo sigue disponible con `-Action test`.

## Prueba futura con dos equipos

El 2026-10-27 el usuario confirma que ahora solo dispone de un PC. La prueba externa queda pendiente; no se necesita instalar nada adicional para la prueba local anterior.

Cuando haya dos equipos, preparar la misma revisión y Godot fijado en ambos. En una LAN, el invitado usa la IP local del anfitrión. En redes distintas, hace falta una ruta UDP hasta él: por ejemplo, una red privada que conecte ambos equipos o un reenvío UDP del puerto de prueba cuando la conexión lo permita. Una IP local normal y `127.0.0.1` no sirven para entrar desde otra red. El motor usa UDP; una comprobación de puerto TCP no demuestra conectividad ENet.

Este prototipo no añade cifrado. Orientar el ensayo a enlaces de confianza; revisar transporte/alojamiento antes de convertirlo en acceso público. No se cambia el cortafuegos, el router o la instalación de red automáticamente. Si Windows solicita acceso para el anfitrión en la red de prueba, debe permitirse ese tráfico para que el otro equipo llegue. Si el acceso directo exige demasiada configuración o no es posible, registrar el resultado para evaluar un servidor accesible; no dar por resuelto el problema con un código de sala.

1. Anfitrión crea prueba y comparte de forma privada dirección alcanzable, puerto y clave.
2. Invitado entra desde la otra red; ambos comprueban nombres y total de participantes.
3. Cada uno envía cinco señales; ambos deben ver diez.
4. Invitado desconecta, verifica retirada del listado y vuelve a entrar con la misma clave; continúa el contador mientras viva el anfitrión, sin promesa de plaza persistente.
5. Se prueba una clave incorrecta y el cierre del anfitrión; guardar resultados y diagnóstico, sin publicar clave ni IP personal.

## Registro para cerrar T04.2

Copiar resultados a [verificación de SPEC-004](specs/004-conexion-temprana/verification.md): fecha, commit, Godot/Windows de ambos, si eran realmente redes distintas, vía usada (directa/red privada/servidor), configuración necesaria, lista y contador observados, desconexión/reintento, errores, y facilidad de acceso para el grupo. Omitir credenciales e IP públicas personales.

Con esa evidencia se decide transporte y alojamiento del producto. Sin ella P04 permanece abierta. La [comparación técnica](specs/004-conexion-temprana/plan.md) explica las opciones y qué costes siguen sin determinar.
