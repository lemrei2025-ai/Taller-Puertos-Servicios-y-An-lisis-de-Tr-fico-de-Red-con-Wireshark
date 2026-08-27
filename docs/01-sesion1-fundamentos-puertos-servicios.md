[Índice general](../README.md) · [⬅ Introducción](./00-introduccion.md) · [Sesión 2 — Instalación de Wireshark ➡](./02-sesion2-instalacion-wireshark.md)

---

## Sesión 1 — Fundamentos de puertos y servicios en redes

### 1.1 Objetivos de la sesión

- Explicar el concepto de puerto lógico y su relación con el direccionamiento de servicios (socket = IP + puerto).
- Clasificar los puertos según el registro oficial de IANA.
- Diferenciar TCP y UDP en términos de confiabilidad, control de flujo y casos de uso.
- Reconocer los servicios de red más comunes y su puerto asociado.

### 1.2 El puerto como identificador de servicio

En el modelo TCP/IP, una dirección IP identifica un host dentro de una red, pero un mismo host puede ejecutar simultáneamente decenas de servicios (un servidor web, un servidor de correo, un servicio SSH, etc.). El puerto es un número de 16 bits (rango 0-65535) que permite al sistema operativo multiplexar y entregar el tráfico entrante al proceso correcto. La combinación dirección IP + protocolo de transporte + número de puerto se conoce como **socket**, y es el identificador único de un extremo de comunicación `[2][3]`.

Estos conceptos operan sobre las capas de enlace definidas por los estándares **IEEE 802**, como IEEE 802.3 (Ethernet) e IEEE 802.11 (redes inalámbricas), que Wireshark decodifica en la trama de nivel 2 antes de exponer los encabezados IP y de transporte donde residen los puertos `[11]`.

### 1.3 Clasificación de puertos según IANA

| Rango | Nombre | Descripción |
|---|---|---|
| 0 – 1023 | Puertos bien conocidos (*well-known*) | Reservados para servicios estándar del sistema (HTTP, SSH, DNS, etc.); en sistemas Unix requieren privilegios de administrador para ser abiertos. |
| 1024 – 49151 | Puertos registrados (*registered*) | Asignados por IANA a aplicaciones específicas de proveedores (bases de datos, software empresarial); no requieren privilegios elevados. |
| 49152 – 65535 | Puertos dinámicos/privados (efímeros) | Asignados temporalmente por el sistema operativo como puerto de origen del cliente en cada conexión saliente. |

El registro oficial y actualizado de asignaciones de puertos es mantenido por la Internet Assigned Numbers Authority (IANA) `[1]`.

### 1.4 TCP vs UDP

| Característica | TCP | UDP |
|---|---|---|
| Orientación a conexión | Sí (*three-way handshake*: SYN, SYN-ACK, ACK) | No (envío directo de datagramas) |
| Confiabilidad | Garantiza entrega, orden y retransmisión | No garantiza entrega ni orden |
| Control de flujo/congestión | Sí | No |
| Tamaño mínimo de encabezado | 20 bytes | 8 bytes |
| Latencia/overhead | Mayor, por confirmaciones y control | Menor, más rápido |
| Casos de uso típicos | HTTP/HTTPS, SSH, FTP, SMTP, RDP | DNS, DHCP, SNMP, VoIP, streaming, NTP |

### 1.5 Servicios y puertos comunes

| Puerto | Protocolo | Servicio | Descripción |
|---|---|---|---|
| 20 / 21 | TCP | FTP (datos / control) | Transferencia de archivos sin cifrar |
| 22 | TCP | SSH / SFTP | Acceso remoto y transferencia de archivos cifrados |
| 23 | TCP | Telnet | Acceso remoto sin cifrar (considerado obsoleto e inseguro) |
| 25 | TCP | SMTP | Envío de correo electrónico |
| 53 | TCP/UDP | DNS | Resolución de nombres de dominio |
| 67 / 68 | UDP | DHCP | Asignación dinámica de direcciones IP |
| 80 | TCP | HTTP | Tráfico web sin cifrar |
| 110 | TCP | POP3 | Descarga de correo electrónico |
| 143 | TCP | IMAP | Sincronización de correo electrónico |
| 161 / 162 | UDP | SNMP | Monitoreo y gestión de dispositivos de red |
| 389 | TCP/UDP | LDAP | Servicios de directorio |
| 443 | TCP | HTTPS | Tráfico web cifrado (TLS) |
| 445 | TCP | SMB | Compartición de archivos en Windows |
| 587 | TCP | SMTP (submission) | Envío de correo con autenticación/cifrado |
| 989 / 990 | TCP | FTPS | FTP sobre TLS |
| 993 | TCP | IMAPS | IMAP cifrado |
| 995 | TCP | POP3S | POP3 cifrado |
| 3306 | TCP | MySQL | Acceso a motor de base de datos |
| 3389 | TCP | RDP | Escritorio remoto en Windows |
| 5432 | TCP | PostgreSQL | Acceso a motor de base de datos |

### 1.6 Actividad guiada 1.1 — Identificar servicios activos en el propio equipo

Objetivo: reconocer, mediante herramientas del sistema operativo, qué puertos están escuchando conexiones en el equipo de laboratorio, como paso previo al análisis con Wireshark.

**Pasos (Windows)**

1. Abrir la terminal como administrador (`cmd` o PowerShell).
2. Ejecutar el comando: `netstat -ano`
3. Identificar la columna "Estado" y filtrar las líneas en estado `LISTENING`.
4. Para cada puerto en escucha, anotar el PID y consultarlo en el Administrador de tareas para identificar el proceso/servicio asociado.
5. Registrar los resultados en la tabla de bitácora (puerto, protocolo, proceso, ¿es un servicio esperado?).

**Pasos (Linux)**

1. Abrir una terminal.
2. Ejecutar el comando: `sudo ss -tulnp`
3. Identificar los puertos TCP (`-t`) y UDP (`-u`) en escucha (`-l`) y el proceso asociado (`-p`).
4. Comparar los resultados con la tabla de servicios comunes de la sección 1.5.
5. Registrar en la bitácora cualquier puerto no reconocido para su posterior investigación.

```text
Ejemplo de salida esperada (Linux):
State   Recv-Q  Send-Q  Local Address:Port   Peer Address:Port  Process
LISTEN  0       128     0.0.0.0:22           0.0.0.0:*          sshd
LISTEN  0       128     127.0.0.1:3306        0.0.0.0:*          mysqld
```

### 1.7 Preguntas de reflexión — Sesión 1

- ¿Por qué los puertos bien conocidos (0-1023) requieren privilegios administrativos para ser abiertos en sistemas Unix/Linux?
- ¿Qué riesgos de seguridad implica dejar activo un servicio en un puerto que no es utilizado por la organización?
- Explique con sus propias palabras por qué DNS puede operar tanto sobre TCP como sobre UDP.

---

---

[⬅ Introducción](./00-introduccion.md) · [Índice general](../README.md) · [Sesión 2 — Instalación de Wireshark ➡](./02-sesion2-instalacion-wireshark.md)
