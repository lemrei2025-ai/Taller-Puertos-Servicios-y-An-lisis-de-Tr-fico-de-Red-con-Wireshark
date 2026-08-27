[Índice general](../README.md) · [⬅ Sesión 4 — Telnet vs SSH](./04-sesion4-telnet-vs-ssh.md) · [Sesión 6 — Caso FileZilla ➡](./06-sesion6-filezilla-gestion-informacion.md)

---

## Sesión 5 — Detección de escaneo de puertos y tráfico sospechoso

### 5.1 Objetivos de la sesión

- Reconocer las técnicas más comunes de escaneo de puertos y su propósito, con fines exclusivamente defensivos.
- Identificar en Wireshark el patrón de tráfico característico de un escaneo de puertos.
- Utilizar estadísticas y filtros de Wireshark para detectar tráfico anómalo.

### 5.2 Técnicas comunes de escaneo de puertos

El escaneo de puertos es una técnica utilizada tanto por administradores (para auditar su propia superficie de exposición) como por atacantes (en la fase de reconocimiento). Nmap, la herramienta de referencia en este ámbito `[8]`, implementa múltiples técnicas:

| Técnica | Descripción | Rastro típico en Wireshark |
|---|---|---|
| SYN scan (`-sS`) | Envía un SYN por puerto; si recibe SYN-ACK, no completa la conexión (*half-open*). | Múltiples SYN sin ACK final hacia distintos puertos del mismo destino. |
| Connect scan (`-sT`) | Completa el three-way handshake en cada puerto. | Conexiones TCP completas y cerradas rápidamente en secuencia. |
| UDP scan (`-sU`) | Envía datagramas UDP y evalúa respuestas ICMP "puerto inalcanzable". | Ráfagas de UDP seguidas de mensajes ICMP tipo 3, código 3. |
| FIN / NULL / Xmas scan | Envía paquetes con banderas inusuales para evadir filtros simples. | Paquetes TCP con combinaciones de banderas no estándar (FIN solo, ninguna, o FIN+PSH+URG). |

### 5.3 Cómo identificar un escaneo en Wireshark

- Filtro clave: `tcp.flags.syn==1 and tcp.flags.ack==0` — aísla los intentos de apertura de conexión.
- Un mismo IP de origen dirigiéndose a muchos puertos distintos del mismo destino, en un intervalo de tiempo muy corto, es el indicador más claro de un escaneo.
- La vista Estadísticas > Conversaciones, ordenada por número de puertos de destino distintos por origen, permite visualizar el patrón rápidamente.
- El gráfico de E/S (Estadísticas > Gráfico de E/S) muestra picos de paquetes pequeños y uniformes, típicos de un barrido automatizado.

### 5.4 Actividad guiada 5.1 — Generar y analizar un escaneo en el laboratorio propio

> **Recordatorio ético y legal:** este escaneo se ejecuta exclusivamente contra la IP de la VM "servidor de laboratorio", propiedad del estudiante, dentro de la red interna aislada. Escanear sistemas de terceros sin autorización es ilegal y contrario al código de ética de la especialización `[12]`.

1. En la VM "servidor de laboratorio", iniciar una captura de Wireshark sobre su propia interfaz de red.
2. Desde la VM "analista", ejecutar: `nmap -sS -p 1-1000 192.168.56.10`
3. Esperar a que finalice el escaneo y detener la captura en la VM servidor.
4. Aplicar el filtro: `tcp.flags.syn==1 and tcp.flags.ack==0` y observar la cantidad de puertos distintos contactados por el mismo origen.
5. Abrir Estadísticas > Gráfico de E/S y describir en la bitácora el patrón observado (ráfaga corta, muchos paquetes pequeños).
6. Comparar el resultado del escaneo (puertos "open", "closed", "filtered" reportados por Nmap) contra los servicios reales activos identificados en la Actividad 1.1.
7. Guardar la captura como `sesion5_escaneo.pcapng`.

### 5.5 Otros indicadores de tráfico anómalo

- **ARP spoofing**: múltiples respuestas ARP no solicitadas asociando una misma IP a distintas MAC (filtro: `arp.duplicate-address-detected` o revisión manual de tabla ARP).
- **Tráfico DNS inusual**: consultas a dominios de longitud excesiva o alta frecuencia hacia el mismo resolutor, posible indicio de túneles DNS (filtro: `dns and frame.len > 300`).
- **Tráfico saliente por puertos no estándar** hacia servicios conocidos (por ejemplo, tráfico tipo HTTP en un puerto distinto de 80/443), posible indicio de exfiltración o C2.
- **Retransmisiones excesivas** (`tcp.analysis.retransmission`) concentradas en un solo host, que pueden indicar problemas de red o un intento de evasión de IDS.

### 5.6 Buenas prácticas de mitigación

- Implementar sistemas de detección/prevención de intrusos (IDS/IPS) con reglas de umbral para detectar barridos de puertos.
- Segmentar la red y aplicar el principio de mínima exposición: solo los puertos estrictamente necesarios deben estar accesibles.
- Configurar firewalls con reglas de limitación de tasa (*rate limiting*) para conexiones SYN entrantes.
- Revisar periódicamente los servicios expuestos (retomando la metodología de la Actividad 1.1) para reducir la superficie de ataque.

### 5.7 Preguntas de reflexión — Sesión 5

- ¿Por qué un SYN scan se considera más "sigiloso" que un Connect scan?
- ¿Qué diferencia esperaría ver en Wireshark entre un escaneo de puertos y un intento de fuerza bruta contra un único servicio?
- ¿Cómo usaría la vista de Conversaciones para diferenciar un escaneo legítimo de auditoría de uno malicioso?

---

---

[⬅ Sesión 4 — Telnet vs SSH](./04-sesion4-telnet-vs-ssh.md) · [Índice general](../README.md) · [Sesión 6 — Caso FileZilla ➡](./06-sesion6-filezilla-gestion-informacion.md)
