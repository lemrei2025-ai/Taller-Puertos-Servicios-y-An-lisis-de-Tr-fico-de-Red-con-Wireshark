# Bitácora de laboratorio — Taller de Puertos, Servicios y Wireshark

**Estudiante:** ____________________________________________
**Fecha de inicio:** ____________________ **Fecha de entrega:** ____________________

> Copia este archivo a `capturas/mi-bitacora.md` y complétalo a medida que avanzas por el taller. Guarda tus archivos `.pcapng` y capturas de pantalla dentro de `capturas/`, referenciándolos desde aquí.

---

## 1. Puertos y servicios — auditoría de superficie de exposición

| Puerto | Protocolo | Proceso | ¿Servicio esperado? |
|---|---|---|---|
|  |  |  |  |

Respuesta al punto de control:

---

## 2. Wireshark — primera captura

- Archivo de captura: `capturas/captura1.pcapng`
- Observaciones sobre el tráfico HTTP capturado:

Respuesta al punto de control:

---

## 3. Análisis de tráfico

- Archivo de captura: `capturas/navegacion.pcapng`
- Hallazgos en el Follow TCP Stream:
- Resultado de Estadísticas → Conversaciones (host más activo, puertos observados):

Respuesta al punto de control:

---

## 4. Telnet vs SSH

- Archivo de captura Telnet: `capturas/telnet.pcapng`
- Evidencia de credenciales en texto claro (captura de pantalla): `capturas/telnet-stream.png`
- Archivo de captura SSH: `capturas/ssh.pcapng`

| Aspecto | Telnet | SSH |
|---|---|---|
| Núm. de paquetes |  |  |
| Tamaño promedio |  |  |
| Contenido legible |  |  |

Técnicas MITRE ATT&CK identificadas:

Respuesta al punto de control:

---

## 5. Escaneo de puertos

- Comando Nmap ejecutado:
- Archivo de captura: `capturas/escaneo.pcapng`
- Patrón observado en el Gráfico de E/S:
- Comparación puertos reportados por Nmap vs. servicios reales activos (sección 1):

Respuesta al punto de control:

---

## 6. FileZilla y gestión centralizada de la información

- Evidencia de credenciales FTP en texto claro (captura de pantalla): `capturas/ftp-stream.png`
- Resultado de la prueba en modo SFTP:
- Diagnóstico de riesgo (resumen propio, separando confidencialidad en tránsito de gestión de activos de información):
- Mitigaciones propuestas (mínimo 3, priorizadas):

Respuesta al punto de control:

---

## 7. Laboratorio final — Informe de incidente simulado

- Archivo de captura: `capturas/incidente.pcapng`

**Resumen ejecutivo:**

**Línea de tiempo:**

| Hora | Evento | Paquete(s) |
|---|---|---|
|  |  |  |

**Indicadores de compromiso (IOC):**

**Técnicas MITRE ATT&CK identificadas:**

| Técnica | ID | Evidencia |
|---|---|---|
| Reconocimiento (escaneo de puertos) | T1046 |  |
| Fuerza bruta | T1110 |  |
| Uso de credenciales válidas | T1078 |  |

**Recomendaciones de contención y mitigación:**

---

## Checklist de hardening aplicado

Marca lo que verificaste o corregiste durante el taller:

- [ ] Inventario de puertos en escucha justificado
- [ ] Telnet deshabilitado / migración a SSH
- [ ] FTP sin cifrar deshabilitado / migración a SFTP
- [ ] Autenticación reforzada en SSH (llaves y/o MFA)
- [ ] Puertos de base de datos sin exposición innecesaria
- [ ] Alertas de escaneo configuradas
- [ ] Monitoreo de puertos críticos en el SIEM

---

## Autoevaluación final

| Criterio | Autoevaluación (0-máx.) | Máximo |
|---|---|---|
| Evidencia de laboratorio |  | 25 |
| Dominio teórico |  | 15 |
| Análisis de tráfico |  | 15 |
| Caso Telnet vs SSH |  | 10 |
| Caso FileZilla / gestión centralizada |  | 10 |
| Laboratorio final de incidente |  | 20 |
| Ética y buenas prácticas |  | 5 |
| **Total** |  | **100** |

Ver la rúbrica completa en el [`README.md`](../README.md#entregable-y-evaluación) del taller.
