# Taller : Puertos, Servicios y Análisis de Tráfico de Red con Wireshark

**Especialización en Seguridad de la Información — Curso: Ciberespacio**

Taller práctico de 6 sesiones sobre puertos y servicios de red, uso de Wireshark para análisis de tráfico, comparación Telnet vs SSH, detección de escaneo de puertos y gestión segura de transferencia de archivos (caso FileZilla). Las citas técnicas del documento siguen el **estilo IEEE**.

| Campo | Detalle |
|---|---|
| Duración total | 5 horas (6 sesiones guiadas de 40-55 minutos) |
| Modalidad | Presencial / virtual sincrónica, con laboratorio práctico |
| Nivel | Especialización — requiere fundamentos de redes TCP/IP |
| Herramientas | Wireshark, terminal (netstat/ss), cliente Telnet, cliente SSH, Nmap, FileZilla |
| Entorno | Laboratorio aislado / máquinas virtuales propias del estudiante |

> ⚠️ **Antes de empezar:** todas las prácticas de este taller (captura de tráfico, Telnet, escaneo de puertos, FTP) deben ejecutarse exclusivamente en un laboratorio aislado (red host-only/NAT interna) sobre equipos propios. Ver el marco ético y legal en [`docs/00-introduccion.md`](docs/00-introduccion.md).

## Contenido del taller

| # | Sesión | Archivo |
|---|---|---|
| 0 | Introducción, objetivos y marco ético/legal | [docs/00-introduccion.md](docs/00-introduccion.md) |
| 1 | Fundamentos de puertos y servicios en redes | [docs/01-sesion1-fundamentos-puertos-servicios.md](docs/01-sesion1-fundamentos-puertos-servicios.md) |
| 2 | Instalación y configuración de Wireshark | [docs/02-sesion2-instalacion-wireshark.md](docs/02-sesion2-instalacion-wireshark.md) |
| 3 | Análisis de tráfico de red con Wireshark | [docs/03-sesion3-analisis-trafico.md](docs/03-sesion3-analisis-trafico.md) |
| 4 | Seguridad en el acceso remoto: Telnet vs SSH | [docs/04-sesion4-telnet-vs-ssh.md](docs/04-sesion4-telnet-vs-ssh.md) |
| 5 | Detección de escaneo de puertos y tráfico sospechoso | [docs/05-sesion5-escaneo-puertos.md](docs/05-sesion5-escaneo-puertos.md) |
| 6 | Transferencia de archivos y gestión centralizada: caso FileZilla | [docs/06-sesion6-filezilla-gestion-informacion.md](docs/06-sesion6-filezilla-gestion-informacion.md) |
| — | Cierre, entregable y rúbrica de evaluación | [docs/07-cierre-y-evaluacion.md](docs/07-cierre-y-evaluacion.md) |
| — | Anexos (glosario, cheatsheet de filtros, marco legal) | [docs/08-anexos.md](docs/08-anexos.md) |
| — | Referencias (formato IEEE) | [docs/09-referencias.md](docs/09-referencias.md) |

## Estructura del repositorio

```text
.
├── README.md                      → este archivo (índice general)
├── LICENSE                        → licencia del material (CC BY 4.0)
├── docs/                          → contenido del taller, una sesión por archivo
├── plantillas/
│   └── bitacora-laboratorio.md    → plantilla para el entregable del estudiante
├── material/
│   └── Taller_Puertos_Servicios_Wireshark.docx  → versión Word (formato de entrega oficial)
└── capturas/                      → carpeta sugerida para guardar los .pcapng generados
                                      en las prácticas (ignorada por git, ver .gitignore)
```

## Cómo usar este repositorio

1. Clonar o hacer *fork* del repositorio.
2. Copiar `plantillas/bitacora-laboratorio.md` a `capturas/mi-bitacora.md` y usarla para documentar cada sesión.
3. Seguir las sesiones en orden (`docs/00-...` a `docs/06-...`), guardando cada captura `.pcapng` dentro de `capturas/`.
4. Completar el entregable final descrito en [docs/07-cierre-y-evaluacion.md](docs/07-cierre-y-evaluacion.md).

## Publicar este repositorio en GitHub

Este directorio ya está inicializado como repositorio Git local con un primer commit. Para subirlo a tu cuenta:

```bash
# 1. Crear un repositorio vacío en GitHub (sin README, sin licencia) y copiar su URL, por ejemplo:
#    https://github.com/tu-usuario/taller-puertos-servicios-wireshark.git

# 2. Enlazarlo y subir el contenido
git remote add origin https://github.com/tu-usuario/taller-puertos-servicios-wireshark.git
git branch -M main
git push -u origin main
```

Si prefieres usar la CLI de GitHub:

```bash
gh repo create taller-puertos-servicios-wireshark --public --source=. --remote=origin --push
```

## Licencia

Este material educativo se distribuye bajo licencia [Creative Commons Attribution 4.0 (CC BY 4.0)](LICENSE). Puedes reutilizarlo y adaptarlo libremente citando la fuente.
