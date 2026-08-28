# Servidor Telnet de laboratorio (protocolo inseguro, solo para fines didácticos)
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        busybox-static \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash labuser \
    && echo "labuser:Laboratorio123" | chpasswd

# Se usa el telnetd de BusyBox en primer plano (-F) en vez de xinetd: xinetd
# depende de syslog y de varios archivos de estado que en un contenedor mínimo
# pueden hacer que el servicio no quede escuchando (síntoma: "Connection
# refused" al conectar). BusyBox telnetd no tiene esas dependencias y es el
# patrón estándar para exponer Telnet en un contenedor Docker.
EXPOSE 23
CMD ["busybox", "telnetd", "-F", "-p", "23", "-l", "/bin/login"]
