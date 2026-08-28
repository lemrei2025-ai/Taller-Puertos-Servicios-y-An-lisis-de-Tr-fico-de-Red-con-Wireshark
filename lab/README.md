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

### Instalar Docker en Kali Linux

Kali se basa en Debian, así que el método oficial de Docker para Debian funciona directamente.

**Opción recomendada — repositorio oficial de Docker (versión más reciente, incluye el plugin Compose v2):**

```bash
# 1. Quitar paquetes antiguos si existieran
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

**Opción rápida — paquetes propios de los repositorios de Kali** (más simple, versión algo más antigua):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo docker run hello-world
```

**Usar Docker sin `sudo`:**

```bash
sudo usermod -aG docker $USER
newgrp docker            # o cierra sesión y vuelve a entrar
docker run hello-world   # debe funcionar ya sin sudo
```

> Con el usuario `root` por defecto de una imagen Live/VM de Kali, el paso de `usermod`/`newgrp` no es necesario.

Verifica al final:

```bash
docker --version
docker compose version
```

### Instalar Docker en Windows y macOS

Instala **Docker Desktop** desde [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) y ábrelo al menos una vez para que el motor arranque. Docker Desktop ya incluye el plugin Compose v2, así que `docker compose version` debería funcionar directamente desde una terminal (PowerShell, cmd o la terminal de macOS) una vez instalado. En Windows se recomienda el backend WSL2 (la opción por defecto del instalador).

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
