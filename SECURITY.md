<p align="center">
  <h1 align="center">Política de Seguridad</h1>
  <p align="center"><strong>Directrices para la notificación y gestión de vulnerabilidades en Nexora</strong></p>
</p>

---

## Tabla de Contenidos

- [Versiones soportadas](#versiones-soportadas)
- [Alcance](#alcance)
- [Cómo reportar una vulnerabilidad](#cómo-reportar-una-vulnerabilidad)
- [Qué incluir en el reporte](#qué-incluir-en-el-reporte)
- [Tiempos objetivo de respuesta](#tiempos-objetivo-de-respuesta)
- [Divulgación coordinada](#divulgación-coordinada)
- [Reconocimiento](#reconocimiento)

---

## Versiones soportadas

Las versiones del proyecto que actualmente reciben actualizaciones de seguridad se detallan en la siguiente tabla:

| Versión                 | Soportada |
| ----------------------- | --------- |
| `{{TODO: e.g., 1.x.x}}` | [x] Sí    |
| `{{TODO: e.g., 0.x.x}}` | [ ] No    |

_(Actualiza esta tabla conforme el proyecto evolucione y se emitan releases)._

## Alcance

### Entra dentro del alcance:

- Vulnerabilidades directas en el código fuente del proyecto.
- Dependencias vulnerables explotables en el contexto de la aplicación.
- Exposición accidental de credenciales, secretos o información sensible.

### Queda fuera del alcance:

- Problemas o vulnerabilidades en proyectos o dependencias upstream (de terceros).
- Ataques de ingeniería social dirigidos a colaboradores o usuarios.
- Pruebas de denegación de servicio (DoS / DDoS) que afecten la disponibilidad de infraestructura externa.

## Cómo reportar una vulnerabilidad

La seguridad de nuestros usuarios es una prioridad. Si descubres una vulnerabilidad de seguridad en este proyecto, te pedimos que **no la publiques en issues públicos**.

Utiliza exclusivamente el canal de reporte privado de GitHub:

1. Dirígete a la pestaña **Security** del repositorio.
2. Haz clic en **"Report a vulnerability"**.
3. Completa el formulario con los detalles correspondientes.

## Qué incluir en el reporte

Para agilizar la verificación y resolución del problema, por favor incluye la siguiente información en tu reporte:

- **Descripción detallada:** Explicación clara de la vulnerabilidad y sus componentes afectados.
- **Pasos para reproducir:** Una guía paso a paso o prueba de concepto (PoC) que permita verificar el fallo.
- **Impacto potencial:** Una descripción de lo que un atacante podría lograr al explotar esta vulnerabilidad.
- **Versión afectada:** Identificador de la versión, commit o entorno en el que se detectó.

## Tiempos objetivo de respuesta

Nos comprometemos a gestionar los reportes bajo los siguientes plazos estimados:

- **Acuse de recibo:** En un plazo máximo de **72 horas**.
- **Evaluación inicial:** En un plazo máximo de **7 días** para confirmar la validez del reporte.
- **Plan de corrección:** Definido según la gravedad y criticidad de la vulnerabilidad identificada.

## Divulgación coordinada

Solicitamos encarecidamente a los investigadores que **no divulguen públicamente** la vulnerabilidad hasta que se haya publicado una corrección oficial y se haya notificado a los usuarios afectados. Nos comprometemos a mantenerte informado sobre el progreso de la solución.

## Reconocimiento

Agradecemos a la comunidad de seguridad y a los desarrolladores que contribuyen de forma responsable a mantener la integridad de nuestros proyectos. Los reportes válidos y verificados recibirán el crédito correspondiente en nuestras notas de versión (CHANGELOG), previa autorización del colaborador.
