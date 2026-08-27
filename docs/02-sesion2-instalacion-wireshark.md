[Índice general](../README.md) · [⬅ Sesión 1 — Fundamentos de puertos y servicios](./01-sesion1-fundamentos-puertos-servicios.md) · [Sesión 3 — Análisis de tráfico ➡](./03-sesion3-analisis-trafico.md)

---

## Sesión 2 — Instalación y configuración de Wireshark

### 2.1 Objetivos de la sesión

- Instalar Wireshark y sus componentes de captura (Npcap/libpcap) en el sistema operativo del laboratorio.
- Reconocer los elementos de la interfaz de usuario de Wireshark.
- Diferenciar filtros de captura y filtros de visualización.
- Realizar una primera captura de tráfico y guardarla en formato `.pcapng`.

### 2.2 ¿Qué es Wireshark?

Wireshark es un analizador de protocolos de red de código abierto que permite capturar y examinar, en tiempo real o desde un archivo, el tráfico que circula por una interfaz de red. Internamente utiliza la librería libpcap (Linux/macOS) o Npcap (Windows) para capturar tramas a nivel de enlace, y las decodifica capa por capa hasta el protocolo de aplicación `[7]`. Es una herramienta estándar en análisis forense, respuesta a incidentes, depuración de aplicaciones y auditoría de seguridad.

### 2.3 Instalación

**Windows**

1. Descargar el instalador oficial desde el sitio de Wireshark (wireshark.org) correspondiente a la arquitectura del equipo.
2. Ejecutar el instalador y aceptar la instalación del componente Npcap cuando se solicite (obligatorio para capturar tráfico en vivo).
3. Durante la instalación de Npcap, marcar la opción "Support raw 802.11 traffic" solo si se requiere capturar tráfico inalámbrico en modo monitor.
4. Finalizar la instalación y reiniciar el equipo si el instalador lo solicita.
5. Abrir Wireshark y verificar que aparezca el listado de interfaces de red disponibles.

**Linux (Debian/Ubuntu)**

1. Actualizar los repositorios: `sudo apt update`
2. Instalar el paquete: `sudo apt install wireshark`
3. Durante la instalación, responder "Sí" a la pregunta sobre permitir captura a usuarios no root.
4. Agregar el usuario actual al grupo de captura: `sudo usermod -aG wireshark $USER`
5. Cerrar sesión y volver a iniciarla para aplicar el cambio de grupo.
6. Verificar la instalación ejecutando: `wireshark --version`

### 2.4 Recorrido por la interfaz

| Elemento | Función |
|---|---|
| Lista de interfaces | Pantalla inicial; muestra las interfaces disponibles y un mini-gráfico de actividad para elegir dónde capturar. |
| Barra de filtro de visualización | Campo superior donde se escriben expresiones de filtro (*display filters*) para mostrar solo el tráfico de interés. |
| Panel de lista de paquetes | Tabla con cada paquete capturado: número, tiempo, origen, destino, protocolo, longitud e información resumida. |
| Panel de detalles del paquete | Árbol jerárquico que desglosa el paquete seleccionado por capas (Frame, Ethernet, IP, TCP/UDP, protocolo de aplicación). |
| Panel de bytes | Representación hexadecimal y ASCII del contenido crudo del paquete seleccionado. |
| Barra de estado | Muestra el perfil activo, cantidad de paquetes capturados/mostrados y el estado de la captura. |

### 2.5 Filtros de captura vs. filtros de visualización

Es fundamental no confundir ambos tipos de filtro: el **filtro de captura** (sintaxis BPF) se define antes de iniciar la captura y descarta tráfico a nivel del driver, por lo que ese tráfico nunca llega a almacenarse; el **filtro de visualización** (sintaxis propia de Wireshark) se aplica después, sobre los paquetes ya capturados, y solo oculta temporalmente lo que no coincide, sin borrar datos.

| Aspecto | Filtro de captura | Filtro de visualización |
|---|---|---|
| Momento de aplicación | Antes de iniciar la captura | Sobre paquetes ya capturados |
| Sintaxis | BPF (ej.: `host`, `port`, `net`) | Propia de Wireshark (ej.: `ip.addr`, `tcp.port`) |
| Ejemplo | `tcp port 80` | `http` |
| Efecto | Descarta tráfico no capturado | Oculta paquetes sin eliminarlos |

### 2.6 Actividad guiada 2.1 — Primera captura de tráfico

1. Abrir Wireshark y seleccionar la interfaz de red activa (por ejemplo, "Ethernet" o "Wi-Fi").
2. Hacer doble clic sobre la interfaz o pulsar el botón de tiburón azul para iniciar la captura.
3. Abrir un navegador web y visitar un sitio HTTP simple del entorno de laboratorio (o generar tráfico con: `curl http://example.com` desde la VM).
4. Regresar a Wireshark y escribir en la barra de filtro de visualización: `http`
5. Pulsar Enter y observar los paquetes de solicitud (GET) y respuesta (HTTP/1.1 200 OK).
6. Detener la captura con el botón cuadrado rojo.
7. Guardar la captura: Archivo > Guardar como… > formato `.pcapng`, con un nombre descriptivo (ej.: `sesion2_captura1.pcapng`).

### 2.7 Preguntas de reflexión — Sesión 2

- ¿Por qué Wireshark requiere permisos elevados o pertenecer a un grupo especial para capturar tráfico en Linux?
- ¿En qué escenario conviene usar un filtro de captura en lugar de esperar a filtrar en la vista?
- ¿Qué diferencia existe entre guardar una captura en formato `.pcap` y en `.pcapng`?

---

---

[⬅ Sesión 1 — Fundamentos de puertos y servicios](./01-sesion1-fundamentos-puertos-servicios.md) · [Índice general](../README.md) · [Sesión 3 — Análisis de tráfico ➡](./03-sesion3-analisis-trafico.md)
