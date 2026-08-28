# Servidor FTP de laboratorio (protocolo inseguro, solo para fines didácticos)
FROM alpine:3.20

RUN apk add --no-cache vsftpd \
    && adduser -D -s /bin/sh ftpuser \
    && echo "ftpuser:Laboratorio123" | chpasswd \
    && mkdir -p /var/lib/vsftpd/empty \
    && mkdir -p /home/ftpuser/subida && chown -R ftpuser:ftpuser /home/ftpuser

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 21 21100-21110
CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
