[Índice general](../README.md) · [⬅ Índice general](../README.md) · [Sesión 1 — Fundamentos de puertos y servicios ➡](./01-sesion1-fundamentos-puertos-servicios.md)

---

## Introducción y guía de uso del taller

Este taller guiado ha sido diseñado para el módulo de Ciberespacio de la Especialización en Seguridad de la Información. Su propósito es que el estudiante comprenda, de forma teórico-práctica, cómo operan los puertos y servicios de red bajo el modelo TCP/IP, y desarrolle competencias de análisis de tráfico con Wireshark, herramienta de referencia en el análisis forense y la respuesta a incidentes `[7]`.

El documento está organizado en seis (6) sesiones progresivas, cada una con objetivos específicos, marco teórico, tablas de referencia y al menos una actividad guiada paso a paso con criterios de verificación. Al final de cada sesión se incluyen preguntas de reflexión que pueden usarse como insumo de autoevaluación o como espacio de discusión dirigida por el docente.

### Objetivo general

Analizar el funcionamiento de los puertos y servicios de red, y aplicar Wireshark como herramienta de captura y análisis de tráfico, para identificar riesgos de seguridad asociados al uso de protocolos inseguros y al manejo inadecuado de la información en procesos de transferencia de archivos.

### Objetivos específicos

- Diferenciar los rangos y la clasificación de puertos según el estándar de IANA, así como las diferencias operativas entre TCP y UDP `[1][2][3]`.
- Instalar, configurar y operar Wireshark para la captura de tráfico en un entorno de laboratorio controlado.
- Aplicar filtros de captura y de visualización para identificar protocolos, sesiones y anomalías en el tráfico de red.
- Comparar técnicamente los protocolos Telnet y SSH, evidenciando mediante captura de tráfico los riesgos del texto claro frente al cifrado.
- Reconocer patrones de escaneo de puertos y tráfico sospechoso en capturas de Wireshark, con fines defensivos.
- Analizar los riesgos de gestión de la información asociados a herramientas de transferencia de archivos como FileZilla, y proponer estrategias de mitigación alineadas con buenas prácticas de gestión centralizada de la información.

### Metodología

El taller sigue una metodología de aprender-haciendo (*learning by doing*): cada bloque teórico breve es seguido de una actividad guiada con instrucciones numeradas, de modo que el estudiante ejecute los procedimientos en su propio entorno de laboratorio mientras construye una bitácora con evidencias (capturas de pantalla, archivos `.pcapng` y análisis escrito).

### Público objetivo y prerrequisitos

Estudiantes de posgrado en seguridad de la información con conocimientos previos de: modelo OSI y TCP/IP, direccionamiento IP básico, y manejo elemental de la línea de comandos en Windows y/o Linux.

### Requisitos técnicos y materiales

- Equipo con mínimo 8 GB de RAM y virtualización habilitada (VT-x/AMD-V).
- Software de virtualización (VirtualBox o VMware) con al menos dos máquinas virtuales en red interna/host-only: una "atacante/analista" y una "servidor de laboratorio".
- Wireshark 4.x instalado en la máquina de análisis.
- Servidor Telnet y servidor SSH instalados en la VM de laboratorio (por ejemplo, sobre una distribución Linux ligera).
- Nmap instalado en la VM de analista.
- Cliente FileZilla y un servicio FTP/SFTP de prueba en la VM de laboratorio.
- Editor de texto para documentar la bitácora de laboratorio.

> **⚠️ Marco ético y legal — lectura obligatoria antes de iniciar**
>
> Todas las actividades de captura, escaneo y análisis de tráfico de este taller deben ejecutarse **exclusivamente** dentro de un laboratorio aislado (redes host-only o NAT interno) y sobre equipos propiedad del estudiante o expresamente autorizados por la institución.
>
> Está prohibido capturar tráfico, escanear puertos o interceptar credenciales en redes de terceros, redes corporativas de producción o redes públicas sin autorización explícita y por escrito.
>
> En Colombia, la interceptación de datos y el acceso abusivo a sistemas informáticos están tipificados como delito por la Ley 1273 de 2009 `[12]`. El estudiante debe verificar y respetar la normativa vigente en su jurisdicción.
>
> El objetivo pedagógico de las prácticas con Telnet, escaneo de puertos y FileZilla es exclusivamente **defensivo**: comprender el riesgo para poder mitigarlo, nunca explotarlo contra terceros.

---

---

[⬅ Índice general](../README.md) · [Índice general](../README.md) · [Sesión 1 — Fundamentos de puertos y servicios ➡](./01-sesion1-fundamentos-puertos-servicios.md)
