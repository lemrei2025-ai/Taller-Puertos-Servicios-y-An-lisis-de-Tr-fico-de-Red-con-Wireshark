# Servidor SSH de laboratorio (protocolo seguro, para contrastar con Telnet)
FROM alpine:3.20

RUN apk add --no-cache openssh \
    && adduser -D -s /bin/sh labuser \
    && echo "labuser:Laboratorio123" | chpasswd \
    && ssh-keygen -A \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
