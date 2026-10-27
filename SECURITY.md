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

| Versión | Soportada |
| ------- | --------- |
| `0.1.x` | [x] Sí    |

## Alcance

### Entra dentro del alcance:

- Vulnerabilidades directas en el código fuente de Nexora (Flutter/Dart o Rust)
- Vulnerabilidades explotables en las dependencias del proyecto (`cpal`, `rodio`, `symphonia`, `flutter_rust_bridge`, etc.)
- Exposición accidental de credenciales, tokens o información sensible
- Problemas de seguridad en el motor de audio o sistema de archivos

### Queda fuera del alcance:

- Vulnerabilidades en dependencias upstream sin impacto directo
- Ataques de ingeniería social
- Pruebas de denegación de servicio (DoS/DDoS)
- Vulnerabilidades en Flutter SDK o Rust toolchain

## Cómo reportar una vulnerabilidad

La seguridad de Nexora es una prioridad. **No publiques vulnerabilidades en Issues públicos**.

Utiliza el canal privado de GitHub:

1. Dirígete a la pestaña **Security** del repositorio [Nexora](https://github.com/Nexora-Company/Nexora)
2. Haz clic en **"Report a vulnerability"**
3. Completa el formulario con todos los detalles

## Qué incluir en el reporte

- **Descripción:** Explicación clara de la vulnerabilidad
- **Pasos para reproducir:** Guía paso a paso o PoC
- **Impacto potencial:** Qué podría lograr un atacante
- **Versión afectada:** Commit hash, tag o versión
- **Entorno:** Sistema operativo, arquitectura, versiones de Flutter/Rust
- **Evidencias:** Logs, capturas o código relevante

## Tiempos objetivo de respuesta

| Etapa | Plazo objetivo |
|-------|----------------|
| Acuse de recibo | Máximo 72 horas |
| Evaluación inicial | Máximo 7 días |
| Corrección y parche | Según gravedad (Crítica: prioritario, Alta: < 30 días) |

## Divulgación coordinada

Solicitamos no divulgar públicamente la vulnerabilidad hasta que exista un parche oficial. Nos comprometemos a mantenerte informado durante todo el proceso y a coordinar la divulgación contigo.

## Reconocimiento

Agradecemos a los investigadores de seguridad por sus reportes responsables. Los hallazgos válidos serán reconocidos en el CHANGELOG y release notes, siempre con autorización del investigador.
