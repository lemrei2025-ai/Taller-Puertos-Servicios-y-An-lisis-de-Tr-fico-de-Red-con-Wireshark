[Índice general](../README.md) · [⬅ Sesión 3 — Análisis de tráfico](./03-sesion3-analisis-trafico.md) · [Sesión 5 — Escaneo de puertos ➡](./05-sesion5-escaneo-puertos.md)

---

## Sesión 4 — Seguridad en el acceso remoto: Telnet vs SSH

### 4.1 Objetivos de la sesión

- Explicar el funcionamiento de Telnet y SSH como protocolos de acceso remoto.
- Evidenciar mediante captura de tráfico por qué Telnet se considera un protocolo inseguro.
- Comparar técnicamente ambos protocolos y formular recomendaciones de mitigación.

### 4.2 Telnet (puerto 23)

Telnet es un protocolo de terminal remota definido en RFC 854 `[4]`, diseñado en una época en que la confidencialidad del tráfico no era un requisito de diseño. Toda la sesión —incluidas las credenciales de acceso y los comandos ejecutados— viaja en **texto claro**, lo que la hace trivialmente interceptable por cualquiera con acceso al segmento de red o capacidad de *sniffing*.

### 4.3 SSH (puerto 22)

Secure Shell (SSH) es el sucesor seguro de Telnet, definido en RFC 4251 `[5]`. Establece un canal cifrado mediante intercambio de llaves (Diffie-Hellman u otros algoritmos), autentica al servidor mediante su llave pública (*host key*) y ofrece autenticación del cliente por contraseña cifrada o por par de llaves pública/privada, además de verificación de integridad de cada mensaje mediante códigos de autenticación (HMAC).

### 4.4 Actividad guiada 4.1 — Captura y análisis de una sesión Telnet (laboratorio aislado)

> **Recordatorio ético:** esta práctica se ejecuta únicamente entre dos máquinas virtuales propias, dentro de una red host-only/NAT interna sin salida a redes de producción o de terceros.

1. En la VM "servidor de laboratorio", instalar y habilitar un servicio Telnet (por ejemplo, el paquete `telnetd` en una distribución Linux de pruebas).
2. En la VM "analista", iniciar Wireshark y comenzar a capturar sobre la interfaz conectada a la red interna del laboratorio.
3. Desde la misma VM, conectarse al servidor: `telnet 192.168.56.10`
4. Autenticarse con un usuario y contraseña de prueba (nunca credenciales reales) y ejecutar un par de comandos (ej.: `whoami`, `ls`).
5. En Wireshark, aplicar el filtro: `telnet`
6. Clic derecho sobre uno de los paquetes > Follow > TCP Stream y localizar, en texto legible, el usuario y la contraseña ingresados.
7. Documentar en la bitácora, con una captura de pantalla del stream, la evidencia de exposición de credenciales en claro.
8. Detener la conexión y la captura; guardar como `sesion4_telnet.pcapng`.

### 4.5 Actividad guiada 4.2 — Captura y análisis de una sesión SSH

1. Verificar que el servicio SSH esté activo en la VM "servidor de laboratorio" (puerto 22).
2. En la VM "analista", iniciar una nueva captura en Wireshark.
3. Conectarse por SSH: `ssh usuario@192.168.56.10` y autenticarse.
4. Ejecutar los mismos comandos de prueba utilizados en la actividad 4.1.
5. En Wireshark, aplicar el filtro: `tcp.port==22` (el filtro `ssh` también aplica una vez identificado el protocolo).
6. Intentar Follow > TCP Stream sobre el tráfico SSH y describir en la bitácora por qué el contenido es ilegible.
7. Comparar en una tabla propia el número de paquetes, el tamaño promedio y la legibilidad del contenido frente a la captura Telnet.
8. Guardar la captura como `sesion4_ssh.pcapng`.

### 4.6 Comparativo técnico Telnet vs SSH

| Característica | Telnet | SSH |
|---|---|---|
| Puerto | 23 | 22 |
| Cifrado del canal | No (texto claro) | Sí (cifrado simétrico negociado) |
| Autenticación | Usuario/contraseña en texto claro | Contraseña cifrada o llaves públicas/privadas, con soporte de MFA |
| Verificación de integridad | No | Sí (HMAC en cada paquete) |
| Verificación del servidor | No | Sí, mediante *host key* |
| Exposición ante sniffing | Alta — credenciales y comandos visibles | Baja — contenido cifrado extremo a extremo |
| Estado recomendado | Deshabilitar / migrar | Estándar de uso obligatorio |

### 4.7 Recomendaciones de mitigación

- Deshabilitar el servicio Telnet en servidores, routers y switches; utilizar exclusivamente SSHv2.
- Restringir el acceso remoto administrativo mediante listas de control de acceso, VPN o *bastion hosts*, en línea con el control de acceso remoto AC-17 de NIST SP 800-53 `[9]`.
- Implementar autenticación multifactor (MFA) para accesos SSH críticos.
- Rotar y proteger las llaves privadas SSH; deshabilitar el acceso por contraseña cuando sea viable.
- Registrar y monitorear los intentos de conexión a los puertos 22 y 23 mediante el SIEM/IDS de la organización.

### 4.8 Preguntas de reflexión — Sesión 4

- ¿Qué evidencia concreta encontró en el Follow TCP Stream de la captura Telnet que no pudo observar en la captura SSH?
- ¿Por qué SSH exige verificar la huella (*fingerprint*) del host la primera vez que se conecta a un servidor?
- Además de deshabilitar Telnet, ¿qué otros protocolos de la Sesión 1 transmiten credenciales o datos en texto claro y deberían revisarse?

---

---

[⬅ Sesión 3 — Análisis de tráfico](./03-sesion3-analisis-trafico.md) · [Índice general](../README.md) · [Sesión 5 — Escaneo de puertos ➡](./05-sesion5-escaneo-puertos.md)
