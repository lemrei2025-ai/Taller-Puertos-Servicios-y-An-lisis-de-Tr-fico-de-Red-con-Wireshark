[Índice general](../README.md) · [⬅ Sesión 5 — Escaneo de puertos](./05-sesion5-escaneo-puertos.md) · [Cierre y evaluación ➡](./07-cierre-y-evaluacion.md)

---

## Sesión 6 — Transferencia de archivos y gestión centralizada de la información: el caso FileZilla

### 6.1 Objetivos de la sesión

- Comparar FTP, FTPS y SFTP en términos de puerto, cifrado y exposición de credenciales.
- Evidenciar mediante Wireshark los riesgos de una transferencia FTP sin cifrar realizada con FileZilla.
- Analizar el riesgo de gestión de la información que introducen los clientes de transferencia de archivos al generar copias locales del original.
- Proponer, en grupo, una política de mitigación alineada con la gestión centralizada de la información.

### 6.2 FTP, FTPS y SFTP

File Transfer Protocol (FTP) es uno de los protocolos más antiguos de Internet, definido en RFC 959 `[6]`. Utiliza dos canales (control en el puerto 21 y datos en el puerto 20) y, en su forma estándar, transmite usuario, contraseña y contenido de archivos en texto claro. FileZilla es uno de los clientes FTP/SFTP más utilizados en entornos corporativos y educativos, y soporta los tres modos siguientes:

| Característica | FTP | FTPS | SFTP |
|---|---|---|---|
| Puerto | 20 / 21 | 990 (implícito) o 21 + TLS (explícito) | 22 |
| Protocolo base | RFC 959 (propio) | FTP + TLS/SSL | Subsistema de SSH |
| Cifrado | No | Sí | Sí |
| Compatibilidad con firewalls | Compleja (rango de puertos dinámico) | Compleja | Sencilla (un solo puerto) |
| Recomendación | Evitar en producción | Aceptable si SFTP no es viable | Preferido |

### 6.3 Actividad guiada 6.1 — Captura de una sesión FTP con FileZilla

> **Recordatorio ético:** utilizar exclusivamente un servidor FTP de prueba propio, con un usuario y contraseña ficticios, dentro de la red de laboratorio.

1. En la VM "servidor de laboratorio", habilitar un servicio FTP de pruebas (por ejemplo, `vsftpd`) con un usuario ficticio.
2. En la VM "analista", iniciar Wireshark y comenzar la captura.
3. Abrir FileZilla y conectarse al servidor: Host `192.168.56.10`, usuario y contraseña de prueba, puerto 21.
4. Descargar (arrastrar) un archivo de prueba desde el servidor hacia el equipo local.
5. En Wireshark, aplicar el filtro: `ftp` y luego Follow > TCP Stream sobre el canal de control.
6. Localizar en texto claro los comandos `USER` y `PASS` con las credenciales utilizadas.
7. Documentar en la bitácora la evidencia y repetir el ejercicio configurando FileZilla en modo SFTP (puerto 22) para contrastar el resultado.

### 6.4 El problema de fondo: copias locales y gestión centralizada de la información

Más allá del cifrado en tránsito, existe un riesgo estructural en el uso de clientes como FileZilla: **cada descarga crea una copia local del archivo original en el equipo del usuario**, fuera del control del repositorio o sistema de gestión documental centralizado. Esto contradice el principio de "fuente única de verdad" (*single source of truth*) y genera varios riesgos de gestión de la información, alineados con los controles de gestión de activos de información de ISO/IEC 27001:2022 `[10]`:

- **Descontrol de versiones**: coexisten múltiples copias del mismo documento, potencialmente desactualizadas, sin trazabilidad de cuál es la vigente.
- **Fuga de información (Data Loss Prevention)**: las copias locales no heredan los controles de acceso ni el cifrado en reposo del repositorio central, y pueden terminar en dispositivos personales, correo o almacenamiento en la nube no corporativo.
- **"Shadow IT" de facto**: el usuario administra su propia copia de la información sensible, al margen de las políticas de clasificación y retención de la organización.
- **Información residual**: al desvincular un equipo o un empleado, las copias locales descargadas vía FTP/FileZilla suelen no ser identificadas ni eliminadas de forma sistemática.
- **Incumplimiento normativo**: para datos personales o información clasificada, la existencia de copias no controladas puede violar políticas internas o marcos regulatorios de protección de datos.

### 6.5 Estrategias de mitigación

- Migrar de FTP a SFTP o a plataformas de gestión documental con control de versiones (repositorios centralizados, DMS/ECM) que eviten la necesidad de descargar copias completas.
- Definir políticas de "descarga controlada": acceso de solo lectura/edición en línea, o descargas con expiración y marca de agua cuando la descarga sea inevitable.
- Implementar cifrado en reposo en los repositorios centrales y en tránsito en toda transferencia (SFTP/FTPS/HTTPS).
- Desplegar herramientas de Data Loss Prevention (DLP) que detecten y controlen transferencias de archivos sensibles hacia el exterior, correlacionando eventos con los puertos 21/22/990 en el SIEM.
- Establecer políticas de clasificación de la información y capacitar periódicamente a los usuarios (concientización), reforzando que el uso de clientes como FileZilla debe restringirse a flujos autorizados y auditados.
- Aplicar controles de expiración y borrado remoto en dispositivos gestionados (MDM) para reducir la persistencia de copias locales.

### 6.6 Actividad guiada 6.2 — Taller grupal: propuesta de política de mitigación

En grupos de 3 a 4 personas, a partir de la evidencia recolectada en la actividad 6.3, elaborar un documento breve (máximo 2 páginas) que incluya:

- Diagnóstico del riesgo observado (con referencia a la captura de Wireshark como evidencia técnica).
- Al menos tres controles de mitigación concretos, priorizados por facilidad de implementación e impacto.
- Un indicador de seguimiento para verificar que la política se está cumpliendo (por ejemplo, número de conexiones FTP sin cifrar detectadas por mes).
- Una recomendación sobre qué protocolo/herramienta debería reemplazar a FTP/FileZilla sin cifrar en la organización simulada del ejercicio.

### 6.7 Preguntas de reflexión — Sesión 6

- ¿Por qué cifrar el canal (SFTP) no resuelve por sí solo el problema de las copias locales descontroladas?
- ¿Qué diferencia existe entre un riesgo de confidencialidad en tránsito y un riesgo de gestión de activos de información?
- ¿Cómo se relaciona la evidencia obtenida con Wireshark en las Sesiones 4 y 6 con el ciclo de mejora continua de un Sistema de Gestión de Seguridad de la Información (SGSI)?

---

---

[⬅ Sesión 5 — Escaneo de puertos](./05-sesion5-escaneo-puertos.md) · [Índice general](../README.md) · [Cierre y evaluación ➡](./07-cierre-y-evaluacion.md)
