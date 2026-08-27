[Índice general](../README.md) · [⬅ Sesión 2 — Instalación de Wireshark](./02-sesion2-instalacion-wireshark.md) · [Sesión 4 — Telnet vs SSH ➡](./04-sesion4-telnet-vs-ssh.md)

---

## Sesión 3 — Análisis de tráfico de red con Wireshark

### 3.1 Objetivos de la sesión

- Aplicar filtros de visualización esenciales para aislar protocolos y conversaciones.
- Interpretar la anatomía de un paquete capturado, capa por capa.
- Reconstruir y analizar una conversación TCP completa (*Follow TCP Stream*).
- Utilizar las herramientas estadísticas de Wireshark para caracterizar el tráfico capturado.

### 3.2 Filtros de visualización esenciales

| Filtro | Descripción |
|---|---|
| `ip.addr == 192.168.1.10` | Tráfico hacia o desde una IP específica |
| `ip.src == 192.168.1.10` | Tráfico originado en una IP específica |
| `tcp.port == 80` | Tráfico TCP en el puerto 80 (origen o destino) |
| `tcp.flags.syn==1 and tcp.flags.ack==0` | Paquetes SYN puros (inicio de conexión) |
| `tcp.flags.reset==1` | Paquetes RST (conexión rechazada o cerrada abruptamente) |
| `http` | Solo tráfico HTTP |
| `dns` | Solo tráfico DNS |
| `arp` | Solo tráfico ARP |
| `telnet` | Solo tráfico Telnet |
| `ftp` | Solo tráfico FTP (control) |
| `tcp.analysis.retransmission` | Paquetes retransmitidos (indicio de problemas de red) |
| `frame contains "usuario"` | Búsqueda de una cadena de texto en cualquier capa del paquete |

### 3.3 Anatomía de un paquete capturado

Al seleccionar un paquete en el panel de lista, el panel de detalles despliega su estructura en capas, de menor a mayor nivel de abstracción:

- **Frame**: metadatos de captura (número, marca de tiempo, longitud).
- **Ethernet II**: direcciones MAC de origen y destino (capa de enlace, IEEE 802.3).
- **Internet Protocol**: direcciones IP de origen y destino, TTL, protocolo transportado.
- **TCP/UDP**: puertos de origen y destino, banderas de control (en TCP), número de secuencia y acuse de recibo.
- **Protocolo de aplicación** (HTTP, DNS, SSH, etc.): datos propios del servicio.

### 3.4 Seguimiento de flujo (Follow TCP Stream)

Esta función reconstruye toda una conversación TCP en orden, mostrando en un solo panel lo enviado por el cliente y lo recibido del servidor, coloreados por dirección. Se activa haciendo clic derecho sobre un paquete y seleccionando **Follow > TCP Stream**. Es la herramienta clave para evidenciar si un protocolo transmite información en texto claro o cifrada, como se explorará en la Sesión 4.

### 3.5 El saludo de tres vías (three-way handshake)

Toda conexión TCP inicia con un intercambio de tres paquetes: **SYN** (el cliente solicita abrir la conexión), **SYN-ACK** (el servidor acepta y confirma) y **ACK** (el cliente confirma). El cierre ordenado utiliza banderas **FIN**, mientras que un cierre abrupto o un rechazo se identifica con la bandera **RST**. Reconocer este patrón es indispensable para distinguir tráfico legítimo de intentos de escaneo, como se verá en la Sesión 5.

### 3.6 Actividad guiada 3.1 — Captura y análisis de una sesión de navegación

1. Iniciar una nueva captura en Wireshark sobre la interfaz activa.
2. Desde el navegador o con `curl`, generar una solicitud a un sitio de prueba del laboratorio.
3. Aplicar el filtro: `dns` y observar el par de consulta/respuesta que resuelve el nombre de dominio a una IP.
4. Aplicar el filtro: `tcp.flags.syn==1 and tcp.flags.ack==0` y ubicar el paquete SYN inicial hacia el servidor.
5. Aplicar el filtro: `http` y seleccionar el paquete GET; expandir la capa "Hypertext Transfer Protocol" en el panel de detalles.
6. Clic derecho sobre el paquete HTTP > Follow > TCP Stream, y describir en la bitácora qué información viaja en texto claro (cabeceras, cookies si las hay).
7. Detener y guardar la captura como `sesion3_navegacion.pcapng`.

### 3.7 Actividad guiada 3.2 — Estadísticas del tráfico capturado

1. Con una captura abierta, ir al menú Estadísticas > Jerarquía de protocolos y registrar qué porcentaje del tráfico corresponde a cada protocolo.
2. Ir a Estadísticas > Conversaciones y ordenar por número de paquetes para identificar los pares IP:puerto más activos.
3. Ir a Estadísticas > Extremos (*Endpoints*) para listar todas las IP involucradas en la captura.
4. Registrar en la bitácora si se observan patrones inesperados (por ejemplo, un mismo origen hablando con demasiados destinos o puertos distintos).

### 3.8 Preguntas de reflexión — Sesión 3

- ¿Qué diferencia hay entre filtrar por `tcp.port==22` y filtrar por `ssh`?
- ¿Por qué es más confiable analizar un flujo completo con Follow TCP Stream que revisar paquetes sueltos?
- ¿Qué utilidad tiene la vista de Conversaciones para un analista de seguridad frente a un incidente?

---

---

[⬅ Sesión 2 — Instalación de Wireshark](./02-sesion2-instalacion-wireshark.md) · [Índice general](../README.md) · [Sesión 4 — Telnet vs SSH ➡](./04-sesion4-telnet-vs-ssh.md)
