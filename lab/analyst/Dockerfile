# Estación de análisis del laboratorio: Wireshark en línea de comandos (tshark),
# Nmap y clientes Telnet/SSH/FTP para ejecutar todas las prácticas del taller.
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        tshark tcpdump nmap telnet openssh-client ftp curl \
        iproute2 iputils-ping dnsutils ca-certificates less vim-tiny \
        expect netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["sleep", "infinity"]
