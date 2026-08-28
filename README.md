# Taller Práctico: Puertos, Servicios y Análisis de Tráfico de Red con Wireshark

**Especialización en Seguridad de la Información — Curso: Ciberespacio**

Taller 100% práctico: cada concepto se aplica de inmediato en un laboratorio real (contenedores Docker, sin máquinas virtuales y sin direcciones IP que dependan de tu red), y cada actividad está pensada como una tarea de seguridad informática — auditar superficie de ataque, capturar credenciales para demostrar un riesgo, detectar un escaneo, reconstruir un incidente — no como un ejercicio de redes en abstracto. Las citas técnicas siguen el **estilo IEEE** (`[n]`, referencias completas al final).

| Campo | Detalle |
|---|---|
| Duración | 5-6 horas de trabajo práctico continuo |
| Formato | Un solo recorrido guiado, de principio a fin, con laboratorio Docker integrado |
| Nivel | Especialización — requiere fundamentos de redes TCP/IP |
| Laboratorio | 100% en contenedores Docker (`lab/`), sin VM y sin IPs fijas |

> ⚠️ **Marco ético y legal.** Todo el tráfico que vas a capturar, todos los intentos de conexión Telnet/SSH/FTP y todo el escaneo de puertos de este taller ocurren **dentro de tu propio laboratorio Docker aislado** (`lab/`), en una red sin salida a Internet. No repitas estas prácticas contra sistemas de terceros, redes corporativas de producción o redes públicas: el acceso abusivo a sistemas informáticos y la interceptación de datos están tipificados como delito — en Colombia, por la Ley 1273 de 2009 `[12]`. Verifica el marco equivalente en tu jurisdicción si trabajas fuera de este país.

## Objetivos del taller

- Entender qué es un puerto y cómo se clasifican los servicios de red, para poder auditar la superficie de ataque real de un sistema.
- Manejar Wireshark con soltura: instalación, filtros de captura y de visualización, seguimiento de flujos y estadísticas.
- Demostrar, con evidencia de tráfico real, por qué Telnet y FTP sin cifrar son un riesgo de seguridad y por qué SSH/SFTP no lo son.
- Reconocer el patrón de un escaneo de puertos en una captura, con fines defensivos.
- Analizar el riesgo de gestión de la información que introduce un cliente como FileZilla al generar copias locales fuera de control.
- Reconstruir, de punta a punta, un incidente simulado: capturarlo, analizarlo, mapearlo a MITRE ATT&CK y redactarlo como informe.

---

## Preparación del laboratorio

Todo el taller se apoya en un laboratorio Docker reproducible que vive en la carpeta [`lab/`](lab/): cuatro contenedores (un servidor Telnet, uno FTP, uno SSH y una estación de análisis con Wireshark/tshark, Nmap y clientes Telnet/SSH/FTP) conectados en una red interna sin salida a Internet. **No necesitas máquinas virtuales ni averiguar ninguna dirección IP**: dentro del laboratorio, cada equipo se referencia simplemente por su nombre (`telnet-server`, `ftp-server`, `ssh-server`, `analyst`).

### Instalar Docker en Kali Linux

Kali es la distribución de referencia de la especialización, así que estos son los pasos concretos para dejar Docker funcionando ahí. Kali se basa en Debian, así que el método oficial de Docker para Debian aplica directamente.

**Opción recomendada — repositorio oficial de Docker (versión más reciente, incluye el plugin Compose v2):**

```bash
# 1. Quitar paquetes antiguos si existieran (en una instalación nueva de Kali no suele haber nada que quitar)
sudo apt remove -y docker docker-engine docker.io containerd runc

# 2. Dependencias para añadir el repositorio por HTTPS
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# 3. Clave GPG oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Repositorio de Docker (Kali usa la base "bookworm" de Debian)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Instalar Docker Engine + CLI + containerd + plugin Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Habilitar el servicio y verificar
sudo systemctl enable --now docker
sudo docker run hello-world
```

**Opción rápida — paquetes propios de los repositorios de Kali** (más simple, puede traer una versión algo más antigua):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo docker run hello-world
```

**Usar Docker sin `sudo`** (recomendado para no tener que anteponer `sudo` en cada comando del taller):

```bash
sudo usermod -aG docker $USER
newgrp docker            # o cierra sesión y vuelve a entrar
docker run hello-world   # debe funcionar ya sin sudo
```

> Si trabajas con el usuario `root` por defecto de una imagen Live/VM de Kali, el paso de `usermod`/`newgrp` no es necesario: `root` ya puede usar Docker directamente.

Verifica al final que ambos comandos respondan correctamente:

```bash
docker --version
docker compose version
```

### Levantar el laboratorio

Sigue estos cuatro comandos **en este orden**, siempre desde dentro de la carpeta `lab/` del repositorio:

```bash
cd lab                  # 1. entra a la carpeta del laboratorio
docker compose build    # 2. construye las cuatro imágenes (tarda unos minutos la primera vez)
docker compose up -d    # 3. levanta los cuatro contenedores en segundo plano
docker compose ps       # 4. verifica que los cuatro estén "Up"
```

En el paso 4 deberías ver algo así — los cuatro en estado `Up`:

```text
NAME                  IMAGE               STATUS
lab-analyst           lab-analyst         Up
lab-ftp-server        lab-ftp-server      Up
lab-ssh-server        lab-ssh-server      Up
lab-telnet-server     lab-telnet-server   Up
```

**Cómo entrar al contenedor `analyst`** — aquí es donde ejecutas todo lo que sigue en el taller:

```bash
docker compose exec analyst bash
```

Tu *prompt* va a cambiar a algo como `root@<id-del-contenedor>:/work#` — eso confirma que ya estás dentro. Para salir, escribe `exit` (los contenedores siguen corriendo en segundo plano; no hay que reconstruirlos cada vez que entras y sales).

**Problemas comunes al levantar el laboratorio:**

| Síntoma | Causa más probable | Qué hacer |
|---|---|---|
| `no configuration file provided: not found` | No estás parado dentro de la carpeta `lab/`, o el repositorio no se descomprimió completo | Ejecuta `pwd` (debe terminar en `.../lab`) y `ls docker-compose.yml` para confirmar que el archivo está ahí |
| `permission denied` al ejecutar `docker` | Tu usuario no pertenece al grupo `docker` | `sudo usermod -aG docker $USER && newgrp docker` (ver instalación arriba) |
| `docker compose ps` no muestra los cuatro contenedores | `docker compose up -d` no llegó a levantarlos, o `build` falló antes | Repite `docker compose build` y revisa que no aparezca ningún error en rojo antes de seguir |
| Al conectar (`telnet telnet-server`, `ssh labuser@ssh-server`, `ftp ftp-server`) sale `Connection refused` | Ese contenedor no terminó de iniciar, o construiste la imagen antes de una actualización de este repositorio | `docker compose logs telnet-server` (o el nombre del servicio) para ver el error; si la imagen es de una versión anterior del repo, reconstrúyela con `docker compose build --no-cache telnet-server && docker compose up -d` |

Guía completa (incluye credenciales de cada servicio y la opción de usar clientes gráficos reales como FileZilla o PuTTY contra `localhost`) en [`lab/README.md`](lab/README.md) — ahí también está la instalación de Docker en Windows y macOS, y más ejemplos de solución de problemas.

---

## 1. Puertos y servicios: el mapa de la superficie de ataque

Una dirección IP identifica un equipo, pero un mismo equipo ejecuta simultáneamente muchos servicios (web, correo, SSH…). El **puerto** —un número de 16 bits, 0-65535— es lo que permite entregar el tráfico entrante al proceso correcto. La combinación IP + protocolo de transporte + puerto se llama **socket** `[2][3]`. Estos conceptos corren sobre las capas de enlace definidas por los estándares **IEEE 802** (802.3 Ethernet, 802.11 Wi-Fi), que Wireshark decodifica antes de mostrarte los encabezados IP/transporte donde viven los puertos `[11]`.

**IANA clasifica los puertos en tres rangos** `[1]`:

| Rango | Nombre | Implicación de seguridad |
|---|---|---|
| 0 – 1023 | Bien conocidos (*well-known*) | Requieren privilegios de administrador en Unix; suelen ser el primer objetivo de un escaneo. |
| 1024 – 49151 | Registrados | Servicios de aplicaciones específicas; su presencia inesperada suele delatar software no autorizado. |
| 49152 – 65535 | Dinámicos/efímeros | Puertos de origen del cliente; en el destino no deberían aparecer como puertos "en escucha". |

**TCP vs UDP**, en una tabla:

| Característica | TCP | UDP |
|---|---|---|
| Conexión | *Three-way handshake* (SYN, SYN-ACK, ACK) | Sin conexión |
| Confiabilidad | Garantiza entrega y orden | No garantiza nada |
| Casos de uso | HTTP/HTTPS, SSH, FTP, SMTP, RDP | DNS, DHCP, SNMP, VoIP, streaming |

**Servicios y puertos que todo analista debe reconocer de memoria:**

| Puerto | Servicio | Riesgo si está expuesto sin control |
|---|---|---|
| 21 / 20 | FTP | Credenciales y datos en texto claro |
| 22 | SSH / SFTP | Objetivo habitual de fuerza bruta si la autenticación es débil |
| 23 | Telnet | Texto claro; debería estar deshabilitado en cualquier auditoría |
| 25 / 587 | SMTP | Relay abierto, suplantación de remitente |
| 53 | DNS | Túneles DNS, exfiltración, envenenamiento de caché |
| 80 / 443 | HTTP / HTTPS | Superficie de ataque de aplicaciones web |
| 445 | SMB | Vector clásico de ransomware y movimiento lateral |
| 3389 | RDP | Objetivo habitual de fuerza bruta y ransomware |
| 3306 / 5432 | MySQL / PostgreSQL | Nunca deberían estar expuestos fuera de la red interna |

### Práctica — Auditar tu propia superficie de exposición

Antes de tocar Wireshark, audita qué está realmente escuchando en un sistema — el mismo primer paso que un analista ejecuta en una revisión de hardening. **Este ejercicio se hace en tu propio equipo (tu Kali u otro sistema donde trabajas normalmente), no dentro del laboratorio Docker** — todavía no necesitas tenerlo levantado para este paso.

```bash
# Linux (tu propio equipo)
sudo ss -tulnp

# Windows (tu propio equipo)
netstat -ano
```

Por cada puerto en estado `LISTEN`/`LISTENING`, identifica el proceso y compáralo contra la tabla anterior. Cualquier puerto que no reconozcas es candidato a investigación — así es como se detecta software no autorizado o *backdoors* en una auditoría real.

> Si más adelante quieres comparar contra lo que expone el propio contenedor `analyst` (normalmente casi nada, porque solo corre herramientas bajo demanda), entra con `docker compose exec analyst bash` y ejecuta el mismo comando `ss -tulnp` ahí dentro — verás una superficie mucho más reducida que en tu equipo real.

> **Punto de control:** ¿por qué dejar un servicio escuchando en un puerto que nadie usa cuenta como aumento de superficie de ataque, incluso si el servicio "no tiene vulnerabilidades conocidas"?

---

## 2. Wireshark: instalación y manejo esencial

Wireshark captura tráfico usando Npcap (Windows) o libpcap (Linux/macOS) y lo decodifica capa por capa hasta el protocolo de aplicación `[7]`. Es la herramienta estándar de análisis forense, respuesta a incidentes y auditoría de tráfico.

> ✅ **Si usas Kali Linux, no necesitas instalar nada.** Wireshark (interfaz gráfica) y `tshark` (línea de comandos) ya vienen preinstalados en la instalación por defecto de Kali. Verifica que estén ahí y pasa directo a la práctica:
>
> ```bash
> wireshark --version
> tshark --version
> ```
>
> Si alguno de los dos comandos no existe (por ejemplo, en una instalación mínima de Kali sin el metapaquete por defecto), instálalos con el mismo comando de Debian/Ubuntu de abajo.

**Instalación — Windows:** descarga el instalador desde wireshark.org, acepta instalar Npcap cuando se solicite, reinicia si lo pide el instalador.

**Instalación — Linux que no sea Kali (Debian/Ubuntu) o Kali sin Wireshark preinstalado:**

```bash
sudo apt update && sudo apt install -y wireshark tshark
sudo usermod -aG wireshark $USER   # permite capturar sin sudo
# cierra sesión y vuelve a entrar para que el cambio de grupo tome efecto
```

**Instalación — macOS:** `brew install --cask wireshark`, o el instalador desde wireshark.org.

**Los cinco elementos que vas a usar todo el taller:** lista de interfaces, barra de filtro de visualización, lista de paquetes, panel de detalles (por capas: Frame → Ethernet → IP → TCP/UDP → aplicación) y panel de bytes hexadecimales.

**No confundas los dos tipos de filtro:**

| | Filtro de captura | Filtro de visualización |
|---|---|---|
| Cuándo se aplica | Antes de capturar (descarta tráfico) | Después de capturar (solo oculta) |
| Sintaxis | BPF: `tcp port 80` | Wireshark: `http` |

### Práctica — Primera captura

1. Abre Wireshark, selecciona la interfaz activa e inicia la captura.
2. Genera tráfico de prueba: `curl http://example.com` o navega a un sitio.
3. Filtra por `http`, ubica el `GET` y la respuesta `200 OK`.
4. Detén la captura y guarda como `.pcapng`.

> **Punto de control:** ¿qué diferencia práctica hay entre guardar en `.pcap` y en `.pcapng`, y por qué importa para conservar evidencia forense?

---

## 3. Leer el tráfico como un analista

**Filtros de visualización que vas a usar constantemente** (memorízalos, son tu caja de herramientas real de análisis):

| Filtro | Para qué sirve |
|---|---|
| `ip.addr == x.x.x.x` | Aislar todo el tráfico de/hacia un host |
| `tcp.port == 22` | Aislar tráfico de un puerto específico |
| `tcp.flags.syn==1 and tcp.flags.ack==0` | Solo intentos de apertura de conexión (clave para detectar escaneos) |
| `tcp.flags.reset==1` | Conexiones rechazadas o cerradas abruptamente |
| `http` / `dns` / `arp` / `telnet` / `ftp` | Aislar un protocolo completo |
| `tcp.analysis.retransmission` | Retransmisiones — síntoma de problemas de red o evasión |
| `frame contains "password"` | Buscar una cadena en cualquier capa del paquete |

**Follow TCP Stream** (clic derecho sobre un paquete → *Follow* → *TCP Stream*) reconstruye toda la conversación en orden — es la técnica que vas a usar en la sección 4 para demostrar la exposición de credenciales.

**El saludo de tres vías** (SYN → SYN-ACK → ACK) abre toda conexión TCP; un cierre limpio usa `FIN`, uno abrupto o un rechazo usa `RST`. Reconocer este patrón es la base para detectar escaneos en la sección 5.

### Práctica — Capturar y diseccionar una sesión de navegación

1. Inicia una captura, genera una petición web (`curl` o navegador).
2. Filtra `dns`, observa la consulta y su respuesta.
3. Filtra `tcp.flags.syn==1 and tcp.flags.ack==0`, ubica el SYN inicial.
4. Filtra `http`, abre *Follow TCP Stream* y anota qué viaja en texto claro (cabeceras, cookies).
5. Ve a **Estadísticas → Jerarquía de protocolos** y a **Estadísticas → Conversaciones**: identifica el par host:puerto más activo.

> **Punto de control:** ¿por qué la vista de Conversaciones es una de las primeras herramientas que abre un analista al recibir una alerta de tráfico anómalo?

---

## 4. Telnet vs SSH: el costo real de un protocolo sin cifrar

Telnet (RFC 854 `[4]`) transmite usuario, contraseña y comandos en **texto claro**: cualquiera con visibilidad del segmento de red puede leerlos. SSH (RFC 4251 `[5]`) cifra el canal completo, autentica al servidor mediante su *host key* y verifica la integridad de cada mensaje con HMAC.

### Práctica — Capturar Telnet y exponer credenciales

Dentro del contenedor `analyst` del laboratorio (`lab/`):

```bash
# 1. Inicia la captura
tshark -i eth0 -w /work/capturas/telnet.pcapng &

# 2. Conéctate por Telnet al servidor del laboratorio
telnet telnet-server
#   usuario: labuser   contraseña: Laboratorio123
whoami
exit

# 3. Detén la captura
kill %1
```

Abre `telnet.pcapng`, filtra `telnet`, haz *Follow TCP Stream* y localiza el usuario y la contraseña en texto legible.

### Práctica — Repetir la conexión por SSH y contrastar

```bash
tshark -i eth0 -w /work/capturas/ssh.pcapng &
ssh labuser@ssh-server   # misma contraseña: Laboratorio123
kill %1
```

Intenta *Follow TCP Stream* sobre este tráfico: el contenido es ilegible. Compara ambas capturas en una tabla propia (número de paquetes, tamaño promedio, legibilidad del contenido).

| | Telnet | SSH |
|---|---|---|
| Puerto | 23 | 22 |
| Cifrado | No | Sí |
| Exposición ante *sniffing* | Alta | Baja |
| Estado recomendado | Deshabilitar | Estándar obligatorio |

**Mapeo a marcos de seguridad** — así se documenta este hallazgo en un informe profesional, no solo como "buena práctica":

| Marco | Referencia | Por qué aplica |
|---|---|---|
| MITRE ATT&CK | [T1040 – Network Sniffing](https://attack.mitre.org/techniques/T1040/) | Técnica que un atacante usaría para capturar las credenciales que acabas de ver en claro. |
| MITRE ATT&CK | [T1552 – Unsecured Credentials](https://attack.mitre.org/techniques/T1552/) | Cubre credenciales transmitidas o almacenadas sin protección, como en Telnet. |
| NIST SP 800-53 | AC-17 (Remote Access) `[9]` | Exige controles compensatorios (cifrado, MFA) para todo acceso remoto. |
| NIST CSF | PR.DS-2 (datos en tránsito protegidos) | Justifica por qué Telnet incumple el objetivo de protección de datos en tránsito. |

**Mitigación:** deshabilitar Telnet en servidores/routers/switches, exigir SSHv2, aplicar MFA en accesos críticos, rotar llaves privadas y monitorear intentos de conexión a los puertos 22/23 en el SIEM.

> **Punto de control:** más allá de "usar SSH", ¿qué otro control (de red, no solo de protocolo) reduciría el impacto si un atacante interceptara tráfico Telnet en un segmento real?

---

## 5. Detectar un escaneo de puertos antes de que sea un incidente

El escaneo de puertos es la fase de reconocimiento de un ataque — y también la primera auditoría que hace un equipo de seguridad sobre su propia red. Nmap `[8]` implementa varias técnicas:

| Técnica | Cómo actúa | Rastro en Wireshark |
|---|---|---|
| SYN scan (`-sS`) | Abre a medias (*half-open*) cada puerto | Muchos SYN sin ACK final hacia distintos puertos |
| Connect scan (`-sT`) | Completa el handshake en cada puerto | Conexiones completas, cerradas rápido |
| UDP scan (`-sU`) | Evalúa respuestas ICMP "puerto inalcanzable" | Ráfagas UDP + ICMP tipo 3 código 3 |

### Práctica — Generar y detectar un escaneo

```bash
# En analyst: inicia la captura en el servidor objetivo del laboratorio
tshark -i eth0 -w /work/capturas/escaneo.pcapng &

# Escanea los tres servicios del laboratorio por nombre, sin IP
nmap -sS -p 1-1000 telnet-server ftp-server ssh-server

kill %1
```

Filtra `tcp.flags.syn==1 and tcp.flags.ack==0` y cuenta cuántos puertos distintos contactó el mismo origen en segundos — el indicador más claro de un escaneo. Revisa también **Estadísticas → Gráfico de E/S**: un escaneo se ve como una ráfaga uniforme de paquetes pequeños.

**Mapeo a marcos de seguridad:**

| Marco | Referencia |
|---|---|
| MITRE ATT&CK | [T1046 – Network Service Discovery](https://attack.mitre.org/techniques/T1046/) |
| NIST CSF | DE.CM-1 (la red se monitorea para detectar eventos potenciales) |

**Mitigación:** IDS/IPS con reglas de umbral para barridos, segmentación de red (mínima exposición), *rate limiting* de SYN entrantes, y repetir periódicamente la auditoría de la sección 1 para reducir la superficie real.

> **Punto de control:** ¿qué diferencia esperarías ver en Wireshark entre un escaneo de reconocimiento y un ataque de fuerza bruta contra un solo servicio?

---

## 6. FileZilla y el problema de las copias sin control

FTP (RFC 959 `[6]`) transmite usuario, contraseña y archivos en texto claro por defecto. FileZilla es uno de los clientes FTP/SFTP más usados en entornos corporativos.

| | FTP | FTPS | SFTP |
|---|---|---|---|
| Cifrado | No | Sí | Sí |
| Compatibilidad con firewalls | Compleja | Compleja | Sencilla (un solo puerto) |
| Recomendación | Evitar | Aceptable si SFTP no es viable | Preferido |

### Práctica — Capturar una sesión FTP con credenciales en claro

**Opción CLI (dentro de `analyst`):**

```bash
tshark -i eth0 -w /work/capturas/ftp.pcapng &
ftp ftp-server
#   usuario: ftpuser   contraseña: Laboratorio123
ls
bye
kill %1
```

**Opción con la aplicación real de FileZilla** (desde tu equipo, sin IP de red — conecta a `localhost:2121`, ver [`lab/README.md`](lab/README.md)).

Filtra `ftp`, abre *Follow TCP Stream* del canal de control y localiza los comandos `USER` y `PASS` en texto legible. Repite la conexión apuntando a `ssh-server` en modo SFTP y compara.

### El riesgo que el cifrado por sí solo no resuelve

Cifrar el canal (SFTP) no elimina el problema de fondo: **cada descarga crea una copia local del archivo fuera del repositorio central**, rompiendo el principio de fuente única de verdad y generando riesgos alineados con la gestión de activos de información de ISO/IEC 27001:2022 `[10]`:

- Descontrol de versiones — coexisten copias potencialmente desactualizadas.
- Fuga de información — las copias locales no heredan los controles de acceso ni el cifrado en reposo del repositorio central.
- *Shadow IT* de facto y datos residuales en equipos desvinculados sin proceso de borrado.

**Mitigación:** migrar a plataformas con control de versiones (DMS/ECM) en vez de descargas completas, políticas de descarga controlada con expiración, DLP correlacionando eventos con los puertos 21/22/990 en el SIEM, y capacitación sobre el uso autorizado de clientes de transferencia.

> **Punto de control:** ¿por qué un hallazgo de "FTP sin cifrar" en un informe de auditoría debería documentarse como dos riesgos distintos — confidencialidad en tránsito y gestión de activos de información — y no como uno solo?

---

## 7. Laboratorio final — Reconstruir un incidente desde cero

Cierra el taller aplicando todo lo anterior a un caso realista: vas a generar tú mismo el tráfico de un incidente (reconocimiento + fuerza bruta + acceso logrado) dentro del laboratorio, capturarlo sin saber de antemano el resultado exacto, y analizarlo como si te lo hubiera entregado un SOC.

```bash
# 1. Inicia la captura
tshark -i eth0 -w /work/capturas/incidente.pcapng &

# 2. Dispara la simulación (reconocimiento + fuerza bruta + acceso logrado)
bash /work/scripts/simular_incidente.sh

# 3. Detén la captura
kill %1
```

**Guía de análisis** — trabaja `incidente.pcapng` en Wireshark y responde, con evidencia (número de paquete, marca de tiempo, filtro usado):

1. **Reconocimiento:** ¿qué filtro te permite aislar el escaneo inicial? ¿Qué puertos fueron sondeados?
2. **Acceso inicial:** ¿cuántos intentos de autenticación fallidos por Telnet hay antes del exitoso? Extráelos con *Follow TCP Stream*.
3. **Línea de tiempo:** construye una tabla `hora — evento — paquete(s)` desde el primer SYN del escaneo hasta el comando `whoami` ejecutado tras el acceso logrado.
4. **Indicadores de compromiso (IOC):** usuario comprometido, servicio afectado, comandos ejecutados tras el acceso.
5. **Mapeo MITRE ATT&CK:** T1046 (reconocimiento), intento de fuerza bruta ([T1110](https://attack.mitre.org/techniques/T1110/)), acceso con credenciales válidas ([T1078](https://attack.mitre.org/techniques/T1078/)).
6. **Informe de incidente:** redacta un informe breve (resumen ejecutivo, línea de tiempo, IOC, técnicas MITRE ATT&CK identificadas, recomendaciones de contención) usando la plantilla de [`plantillas/bitacora-laboratorio.md`](plantillas/bitacora-laboratorio.md).

> Este es exactamente el flujo de trabajo de un analista de nivel 1-2 en un SOC ante una alerta: capturar/recibir evidencia, reconstruir la línea de tiempo, extraer IOC, mapear a un marco de referencia y comunicar el hallazgo.

---

## Checklist de hardening de servicios de red

Resultado práctico que puedes aplicar de inmediato en cualquier sistema que audites, construido directamente sobre lo trabajado en este taller:

- [ ] Inventariar todos los puertos en estado `LISTEN`/`LISTENING` y justificar cada uno (sección 1).
- [ ] Deshabilitar Telnet; permitir únicamente SSHv2 para acceso remoto administrativo.
- [ ] Deshabilitar FTP sin cifrar; migrar a SFTP o a una plataforma de gestión documental centralizada.
- [ ] Exigir autenticación por llave y/o MFA en SSH; deshabilitar `PermitRootLogin`.
- [ ] Cerrar o filtrar por firewall cualquier puerto de base de datos (3306, 5432…) que no necesite exposición fuera de la red interna.
- [ ] Configurar alertas de IDS/IPS para patrones de escaneo (múltiples SYN sin ACK hacia un mismo destino).
- [ ] Registrar y monitorear en el SIEM los intentos de conexión a los puertos 22, 23, 21 y 3389.
- [ ] Documentar cada hallazgo con su técnica MITRE ATT&CK y su control NIST CSF/800-53 correspondiente (ver tablas de las secciones 4 y 5).

## Entregable y evaluación

**Entregable:** la bitácora de laboratorio completa ([`plantillas/bitacora-laboratorio.md`](plantillas/bitacora-laboratorio.md)) con evidencia (`.pcapng`, capturas de pantalla) y respuestas de las secciones 1 a 7, incluyendo el informe de incidente de la sección 7.

| Criterio | Descripción | Puntaje |
|---|---|---|
| Evidencia de laboratorio | Capturas `.pcapng` y capturas de pantalla de cada práctica (secciones 1-6) | 25 |
| Dominio teórico | Conceptos de puertos, TCP/UDP y servicios de red | 15 |
| Análisis de tráfico | Uso correcto de filtros y correcta interpretación de las capturas | 15 |
| Caso Telnet vs SSH | Comparación técnica y mapeo a MITRE ATT&CK/NIST | 10 |
| Caso FileZilla / gestión de la información | Diagnóstico y mitigaciones propuestas | 10 |
| Laboratorio final de incidente | Línea de tiempo, IOC, mapeo MITRE ATT&CK e informe (sección 7) | 20 |
| Ética y buenas prácticas | Cumplimiento del marco ético/legal durante todo el taller | 5 |
| **Total** | | **100** |

---

## Anexos

### Glosario

| Término | Definición |
|---|---|
| Socket | IP + protocolo de transporte + puerto: identificador único de un extremo de comunicación. |
| BPF | Sintaxis de los filtros de captura de Wireshark/tcpdump. |
| IOC | *Indicator of Compromise*: dato observable que evidencia una posible intrusión. |
| SGSI | Sistema de Gestión de Seguridad de la Información (familia ISO/IEC 27000). |
| DLP | *Data Loss Prevention*: controles para prevenir la fuga de información. |

### Cheatsheet de filtros de Wireshark

```text
ip.addr == x.x.x.x                         Tráfico de/hacia un host
tcp.port == 443                            Tráfico en un puerto específico
tcp.flags.syn==1 and tcp.flags.ack==0       Solo SYN (inicio de conexión / escaneo)
tcp.flags.reset==1                          Conexiones rechazadas/cerradas
http / dns / arp / telnet / ftp             Aislar un protocolo
tcp.analysis.retransmission                 Retransmisiones
frame contains "texto"                      Buscar texto en cualquier capa
!(arp or dns)                               Excluir un tipo de tráfico
```

### Resumen de mapeo a marcos de seguridad

| Práctica del taller | MITRE ATT&CK | NIST |
|---|---|---|
| Captura Telnet (sección 4) | T1040, T1552 | SP 800-53 AC-17, CSF PR.DS-2 |
| Escaneo de puertos (sección 5) | T1046 | CSF DE.CM-1 |
| Laboratorio de incidente (sección 7) | T1046, T1110, T1078 | CSF DE.AE (análisis de eventos) |

### Marco legal de referencia

En Colombia, la Ley 1273 de 2009 tipifica el acceso abusivo a sistemas informáticos, la interceptación de datos y la violación de datos personales `[12]`. Verifica el marco equivalente de tu jurisdicción antes de replicar cualquiera de estas prácticas fuera del laboratorio aislado de este repositorio.

---

## Referencias

Estilo IEEE, citadas en el cuerpo del documento.

`[1]` Internet Assigned Numbers Authority (IANA), "Service Name and Transport Protocol Port Number Registry," IANA, 2024. [Online]. Disponible: https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml

`[2]` W. Eddy, Ed., "Transmission Control Protocol (TCP)," RFC 9293, Internet Engineering Task Force (IETF), ago. 2022.

`[3]` J. Postel, "User Datagram Protocol," RFC 768, IETF, ago. 1980.

`[4]` J. Postel y J. Reynolds, "Telnet Protocol Specification," RFC 854, IETF, may. 1983.

`[5]` T. Ylonen y C. Lonvick, "The Secure Shell (SSH) Protocol Architecture," RFC 4251, IETF, ene. 2006.

`[6]` J. Postel, "File Transfer Protocol (FTP)," RFC 959, IETF, oct. 1985.

`[7]` Wireshark Foundation, "Wireshark User's Guide," Wireshark, 2024. [Online]. Disponible: https://www.wireshark.org/docs/wsug_html_chunked/

`[8]` G. Lyon, *Nmap Network Scanning: The Official Nmap Project Guide to Network Discovery and Security Scanning*. Sunnyvale, CA, EE. UU.: Insecure.Com LLC, 2009.

`[9]` National Institute of Standards and Technology (NIST), "Security and Privacy Controls for Information Systems and Organizations," NIST Special Publication 800-53, Rev. 5, Gaithersburg, MD, EE. UU., sep. 2020.

`[10]` International Organization for Standardization, *ISO/IEC 27001:2022 — Information Security, Cybersecurity and Privacy Protection — Information Security Management Systems — Requirements*. Ginebra, Suiza: ISO, 2022.

`[11]` IEEE, "IEEE Standard for Ethernet," IEEE Std 802.3-2022, 2022.

`[12]` Congreso de la República de Colombia, "Ley 1273 de 2009, por medio de la cual se modifica el Código Penal, se crea un nuevo bien jurídico tutelado denominado 'de la protección de la información y de los datos' y se preservan integralmente los sistemas que utilicen las tecnologías de la información y las comunicaciones," Diario Oficial, Bogotá, Colombia, ene. 2009.

`[13]` MITRE Corporation, "MITRE ATT&CK®," 2024. [Online]. Disponible: https://attack.mitre.org/

---

## Estructura del repositorio

```text
.
├── README.md              → este archivo: el taller completo
├── LICENSE                → CC BY 4.0
├── lab/                   → laboratorio Docker (servidores + estación de análisis)
│   ├── docker-compose.yml
│   ├── telnet-server/ ftp-server/ ssh-server/ analyst/
│   └── scripts/simular_incidente.sh
├── plantillas/
│   └── bitacora-laboratorio.md   → plantilla del entregable
├── material/
│   └── Taller_Puertos_Servicios_Wireshark.docx   → versión Word
└── capturas/               → aquí guardas tus .pcapng (ignorado por git salvo .gitkeep)
```

## Publicar este repositorio en GitHub

```bash
git remote add origin https://github.com/tu-usuario/taller-puertos-servicios-wireshark.git
git branch -M main
git push -u origin main
```

## Licencia

[Creative Commons Attribution 4.0 (CC BY 4.0)](LICENSE).
