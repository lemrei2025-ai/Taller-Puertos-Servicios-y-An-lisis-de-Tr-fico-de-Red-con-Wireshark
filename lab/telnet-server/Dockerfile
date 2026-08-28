# Servidor Telnet de laboratorio (protocolo inseguro, solo para fines didácticos)
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        xinetd telnetd \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash labuser \
    && echo "labuser:Laboratorio123" | chpasswd

RUN printf 'service telnet\n{\n  disable = no\n  flags = REUSE\n  socket_type = stream\n  wait = no\n  user = root\n  server = /usr/sbin/in.telnetd\n  log_on_failure += USERID\n}\n' > /etc/xinetd.d/telnet

EXPOSE 23
CMD ["xinetd", "-dontfork"]
