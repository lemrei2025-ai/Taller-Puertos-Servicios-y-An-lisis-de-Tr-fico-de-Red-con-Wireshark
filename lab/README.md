# Laboratorio Docker del taller

Entorno de laboratorio aislado y reproducible para todo el taller: no requiere máquinas virtuales, no usa direcciones IP fijas (los equipos se referencian por su nombre de servicio) y **no tiene salida a Internet**, por lo que todas las prácticas de captura, autenticación y escaneo quedan contenidas dentro de la red del laboratorio.

## Componentes

| Servicio | Nombre en la red del laboratorio | Rol |
|---|---|---|
| `telnet-server` | `telnet-server` | Servidor Telnet inseguro (puerto 23) — usuario `labuser` / contraseña `Laboratorio123` |
| `ftp-server` | `ftp-server` | Servidor FTP inseguro (puerto 21) — usuario `ftpuser` / contraseña `Laboratorio123` |
| `ssh-server` | `ssh-server` | Servidor SSH seguro (puerto 22) — usuario `labuser` / contraseña `Laboratorio123` |
| `analyst` | `analyst` | Estación de análisis: incluye `tshark`, `nmap`, `telnet`, `ssh`, `ftp`, `expect` |

Todos los servicios viven en la misma red Docker interna `lab-net`. Desde `analyst` puedes conectarte a cualquiera de ellos usando directamente su nombre (por ejemplo `telnet telnet-server`), sin necesidad de averiguar ni escribir ninguna IP.

## Requisitos

- Docker y el plugin Docker Compose instalados (`docker compose version`).
- Ningún otro requisito: no se necesita VirtualBox, VMware ni licencias adicionales.

## Puesta en marcha

```bash
cd lab
docker compose build
docker compose up -d
```

Verifica que los cuatro contenedores estén corriendo:

```bash
docker compose ps
```

## Cómo trabajar durante el taller

Todas las prácticas se ejecutan **dentro** del contenedor `analyst`:

```bash
docker compose exec analyst bash
```

Dentro de ese contenedor ya tienes disponibles `tshark`, `nmap`, `telnet`, `ssh`, `ftp`. La carpeta `/work/capturas` está enlazada con `../capturas` en tu equipo, así que cualquier archivo que guardes allí lo verás también fuera del contenedor (y es el lugar sugerido por la plantilla de bitácora).

### Capturar tráfico con tshark

```bash
# Inicia la captura en segundo plano, escribiendo a un archivo
tshark -i eth0 -w /work/capturas/captura.pcapng &

# ... ejecuta aquí la actividad correspondiente (telnet, ssh, ftp, nmap) ...

# Detén la captura
kill %1
```

También puedes copiar el `.pcapng` resultante a tu equipo y abrirlo con la interfaz gráfica de Wireshark si la tienes instalada — `docker compose cp analyst:/work/capturas/captura.pcapng .` desde la carpeta `lab/`, o simplemente ábrelo desde `../capturas/captura.pcapng`, ya que esa carpeta está compartida.

### Ejemplos de comandos usados en el taller (sin IPs, por nombre de servicio)

```bash
# Conectarse por Telnet
telnet telnet-server

# Conectarse por SSH
ssh labuser@ssh-server

# Conectarse por FTP
ftp ftp-server

# Escanear los puertos de los tres servidores del laboratorio
nmap -sS -p 1-1000 telnet-server ftp-server ssh-server
```

### Usar clientes gráficos reales desde tu equipo (opcional): FileZilla, PuTTY, etc.

Si quieres usar la aplicación real de FileZilla (o cualquier otro cliente gráfico) desde tu propio equipo en lugar del cliente de línea de comandos dentro de `analyst`, el `docker-compose.yml` publica los tres servicios en `localhost` — **nunca necesitas averiguar ni escribir una IP de tu red**, porque `localhost` es siempre la misma dirección sin importar en qué red LAN estés conectado:

| Servicio | Host | Puerto | Usuario | Contraseña |
|---|---|---|---|---|
| FTP (para FileZilla) | `localhost` | `2121` | `ftpuser` | `Laboratorio123` |
| Telnet | `localhost` | `2323` | `labuser` | `Laboratorio123` |
| SSH | `localhost` | `2222` | `labuser` | `Laboratorio123` |

En este caso, para capturar el tráfico con Wireshark (interfaz gráfica) en tu propio equipo, selecciona la interfaz de *loopback* (`Loopback: lo0` en macOS, `Adapter for loopback traffic capture` en Windows, `lo` en Linux), ya que el tráfico hacia `localhost` viaja por esa interfaz.

### Laboratorio de incidente simulado

El script `scripts/simular_incidente.sh` (montado dentro del contenedor en `/work/scripts/`) genera automáticamente una secuencia de reconocimiento + fuerza bruta + acceso logrado contra `telnet-server`, pensada para ser capturada con `tshark` y analizada como si fuera evidencia de un incidente real. Instrucciones completas en la guía principal del taller.

## Apagar y limpiar el laboratorio

```bash
docker compose down
```

Para reconstruir desde cero (por ejemplo, si modificaste algún Dockerfile):

```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## Notas

- Las contraseñas de este laboratorio (`Laboratorio123`, etc.) son deliberadamente simples y **ficticias**: el objetivo es que sean fáciles de escribir durante la práctica, nunca deben usarse en sistemas reales.
- La red `lab-net` se crea con `internal: true`, lo que impide cualquier conexión saliente hacia redes externas o Internet desde los contenedores del laboratorio — un control adicional, no un sustituto de seguir el marco ético y legal del taller.
- Si tu organización restringe el acceso a Docker Hub, puedes adaptar los `Dockerfile` de este directorio para usar un registro interno equivalente; todos están basados en paquetes estándar de Debian/Alpine (`telnetd`, `openssh`, `vsftpd`, `tshark`, `nmap`).
