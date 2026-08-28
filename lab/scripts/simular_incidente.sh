#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# simular_incidente.sh
#
# Genera, dentro del laboratorio aislado (red "lab-net", sin salida a
# Internet), una secuencia de tráfico que imita un incidente típico de
# reconocimiento + acceso inicial:
#   1) Escaneo de puertos contra los tres servicios del laboratorio.
#   2) Varios intentos de autenticación fallidos por Telnet (fuerza bruta).
#   3) Un inicio de sesión Telnet exitoso (acceso inicial logrado).
#
# Uso previsto: ejecutarlo DESPUÉS de iniciar una captura con tshark dentro
# del contenedor "analyst", para luego analizar el .pcapng resultante como
# si fuera la evidencia de un incidente real.
#
# Este script solo se conecta a los contenedores del propio laboratorio
# (telnet-server, ftp-server, ssh-server) por su nombre de servicio Docker;
# no requiere ni contiene direcciones IP.
# ---------------------------------------------------------------------------
set -uo pipefail

echo "[$(date '+%H:%M:%S')] === Fase 1: Reconocimiento (escaneo de puertos) ==="
nmap -sS -Pn -p 20-25,53,80,443,3306 telnet-server ftp-server ssh-server

echo
echo "[$(date '+%H:%M:%S')] === Fase 2: Intentos de acceso por Telnet (fuerza bruta simulada) ==="
for pass in "admin123" "root123" "qwerty" "Laboratorio000"; do
  echo "--- Intento con contraseña incorrecta: $pass ---"
  expect -c "
    set timeout 5
    spawn telnet telnet-server
    expect \"login:\"
    send \"labuser\r\"
    expect \"Password:\"
    send \"$pass\r\"
    expect {
      \"incorrect\" { puts \"LOGIN FALLIDO\" }
      timeout      { puts \"SIN RESPUESTA\" }
    }
    send \"\x1d\r\"
    send \"quit\r\"
  " >/dev/null 2>&1
  sleep 1
done

echo
echo "[$(date '+%H:%M:%S')] === Fase 3: Acceso inicial logrado (credencial correcta) ==="
expect -c "
  set timeout 5
  spawn telnet telnet-server
  expect \"login:\"
  send \"labuser\r\"
  expect \"Password:\"
  send \"Laboratorio123\r\"
  expect \"$ \"
  send \"whoami\r\"
  expect \"$ \"
  send \"id\r\"
  expect \"$ \"
  send \"exit\r\"
"

echo
echo "[$(date '+%H:%M:%S')] === Incidente simulado finalizado ==="
echo "Detén la captura de tshark y analiza el archivo .pcapng generado."
