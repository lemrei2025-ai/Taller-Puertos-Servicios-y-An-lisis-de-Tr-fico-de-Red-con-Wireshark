[Índice general](../README.md) · [⬅ Cierre y evaluación](./07-cierre-y-evaluacion.md) · [Referencias (IEEE) ➡](./09-referencias.md)

---

## Anexos

### Anexo A — Glosario de términos

| Término | Definición |
|---|---|
| Socket | Combinación de dirección IP, protocolo de transporte y puerto que identifica un extremo de comunicación. |
| BPF | Berkeley Packet Filter; sintaxis utilizada por los filtros de captura de Wireshark/tcpdump. |
| Sniffing | Captura pasiva de tráfico de red con fines de análisis (legítimo) o interceptación (malicioso). |
| Three-way handshake | Intercambio de tres paquetes (SYN, SYN-ACK, ACK) que establece una conexión TCP. |
| Pcap / pcapng | Formatos de archivo estándar para almacenar tráfico de red capturado. |
| DLP | Data Loss Prevention; conjunto de controles orientados a prevenir la fuga de información. |
| SGSI | Sistema de Gestión de Seguridad de la Información, marco de gestión definido en la familia ISO/IEC 27000. |
| C2 | Command and Control; infraestructura utilizada por software malicioso para comunicarse con su operador. |

### Anexo B — Cheatsheet de filtros de Wireshark

| Objetivo | Filtro |
|---|---|
| Tráfico de/hacia una IP | `ip.addr == x.x.x.x` |
| Tráfico en un puerto específico | `tcp.port == 443` |
| Solo paquetes SYN (inicio de conexión) | `tcp.flags.syn==1 and tcp.flags.ack==0` |
| Conexiones rechazadas/cerradas abruptamente | `tcp.flags.reset==1` |
| Tráfico HTTP | `http` |
| Tráfico DNS | `dns` |
| Tráfico ARP | `arp` |
| Tráfico Telnet | `telnet` |
| Tráfico FTP (control) | `ftp` |
| Retransmisiones TCP | `tcp.analysis.retransmission` |
| Buscar texto en cualquier capa | `frame contains "texto"` |
| Excluir un tipo de tráfico | `!(arp or dns)` |

### Anexo C — Marco ético y legal de referencia

Estas prácticas deben desarrollarse siempre en entornos autorizados. En Colombia, la Ley 1273 de 2009 tipifica como delito el acceso abusivo a sistemas informáticos, la interceptación de datos informáticos y la violación de datos personales, entre otras conductas `[12]`. Los estudiantes de otras jurisdicciones deben identificar y respetar el marco normativo equivalente de su país antes de replicar cualquiera de las actividades de este taller fuera del entorno de laboratorio.

---

---

[⬅ Cierre y evaluación](./07-cierre-y-evaluacion.md) · [Índice general](../README.md) · [Referencias (IEEE) ➡](./09-referencias.md)
