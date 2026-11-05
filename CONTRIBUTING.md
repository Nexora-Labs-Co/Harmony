<p align="center">
  <h1 align="center">Guía de Contribución</h1>
  <p align="center"><strong>Directrices y flujos de trabajo para colaborar en proyectos de Nexora</strong></p>
</p>

---

## Tabla de Contenidos

- [Bienvenida](#bienvenida)
- [Antes de empezar](#antes-de-empezar)
- [Flujo de trabajo](#flujo-de-trabajo)
- [Entorno de desarrollo](#entorno-de-desarrollo)
- [Estándares de código](#estándares-de-código)
- [Checklist del Pull Request](#checklist-del-pull-request)
- [Proceso de revisión](#proceso-de-revisión)
- [Acuerdo de contribución (CLA)](#acuerdo-de-contribución-cla)
- [Código de conducta](#código-de-conducta)
- [Licencia](#licencia)

---

## Bienvenida

Agradecemos tu interés en colaborar con Nexora. Este repositorio sirve como plantilla base y punto de partida para nuestros proyectos. El código fuente es abierto a la comunidad y todas las contribuciones orientadas a mejorar la calidad, estructura o rendimiento del software son bienvenidas.

## Antes de empezar

Para evitar esfuerzos duplicados o cambios que no se alineen con la visión del proyecto, te solicitamos seguir estas pautas iniciales:

- **Cambios menores (corrección de erratas, bugfixes simples):** Puedes abrir directamente un Pull Request.
- **Cambios mayores o nuevas características:** Abre primero un **Issue** para discutir la propuesta con el equipo mantenedor antes de comenzar a escribir código.

## Flujo de trabajo

Sigue estos pasos para realizar contribuciones al repositorio:

1. Realiza un **Fork** de este repositorio en tu cuenta personal de GitHub.
2. Crea una rama descriptiva siguiendo las convenciones de nomenclatura:
   - `feat/nombre-funcionalidad` para nuevas características.
   - `fix/descripcion-error` para correcciones de errores.
   - `docs/nombre-documento` para mejoras en la documentación.
   - `refactor/zona-afectada` para reestructuración de código sin cambio de comportamiento.
3. Realiza tus cambios utilizando **Conventional Commits** (ejemplo: `feat(core): agregar soporte para variables de entorno`).
4. Sube la rama a tu fork y abre un **Pull Request** hacia la rama principal del proyecto original.

## Entorno de desarrollo

Para configurar el entorno de trabajo localmente, ejecuta los siguientes comandos:

```bash
# Instalar dependencias
{{TODO: comando de instalación, ej. npm install}}

# Iniciar servidor de desarrollo
{{TODO: comando de desarrollo, ej. npm run dev}}

# Ejecutar la suite de pruebas
{{TODO: comando de pruebas, ej. npm test}}
```
