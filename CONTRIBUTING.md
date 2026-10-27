<p align="center">
  <h1 align="center">Guía de Contribución</h1>
  <p align="center"><strong>Directrices y flujos de trabajo para colaborar en Harmony</strong></p>
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
- [Código de conducta](#código-de-conducta)
- [Licencia](#licencia)

---

## Bienvenida

Agradecemos tu interés en colaborar con **Harmony**. Todas las contribuciones orientadas a mejorar la calidad, arquitectura, rendimiento o experiencia de usuario son bienvenidas.

## Antes de empezar

- **Cambios menores** (correcciones, typos): Puedes abrir directamente un Pull Request.
- **Cambios mayores o nuevas características:** Abre primero un **Issue** para discutir la propuesta con el equipo mantenedor antes de escribir código.

## Flujo de trabajo

1. Realiza un **Fork** del repositorio en tu cuenta de GitHub.
2. Clona tu fork localmente:
   ```bash
   git clone https://github.com/tu-usuario/Harmony.git
   cd Harmony
   ```
3. Crea una rama descriptiva siguiendo las convenciones:
   - `feat/nombre-funcionalidad` - Nuevas características
   - `fix/descripcion-error` - Correcciones de bugs
   - `docs/nombre-documento` - Mejoras en documentación
   - `refactor/zona-afectada` - Refactorización sin cambio de comportamiento
   - `perf/mejora-rendimiento` - Optimizaciones
   - `chore/tarea-mantenimiento` - Tareas de mantenimiento
4. Realiza tus cambios siguiendo los estándares del proyecto.
5. Haz commit usando **[Conventional Commits](https://www.conventionalcommits.org/)**:
   ```bash
   git commit -m "feat(audio): agregar soporte para reproducción en segundo plano"
   ```
6. Sube tu rama y abre un **Pull Request** hacia `main`.

## Entorno de desarrollo

### Flutter + Dart
```bash
cd nexora_app
flutter pub get
flutter run -d linux  # o windows
```

### Rust
```bash
cd rust
cargo build
cargo test
cargo clippy
cargo fmt
```

### Generar bindings
```bash
cd nexora_app
flutter_rust_bridge_codegen generate
```

## Estándares de código

### Dart/Flutter
- Seguir las reglas de [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Usar `flutter_lints` configurado en el proyecto
- Mantener widgets pequeños y reutilizables
- Usar `Provider` para gestión de estado
- Nombrado en `snake_case` para archivos, `PascalCase` para clases

### Rust
- Formatear con `cargo fmt`
- Verificar con `cargo clippy` sin warnings
- Seguir [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Usar `thiserror`/`anyhow` para manejo de errores
- Documentar APIs públicas con comentarios `///`
- Mantener separación entre módulos (`audio`, `library`, `models`, `api`)

### General
- Mensajes de commit en inglés siguiendo Conventional Commits
- Código autoexplicativo, comentar solo lógica compleja
- Mantener arquitectura modular (UI desacoplada del core Rust)
- No incluir código comentado o debug innecesario

## Checklist del Pull Request

Antes de enviar tu Pull Request, verifica:

- [ ] El código compila correctamente (`flutter build` / `cargo build`)
- [ ] Los tests pasan (`flutter test` / `cargo test`)
- [ ] `cargo fmt` y `cargo clippy` sin errores
- [ ] `dart format` aplicado
- [ ] Documentación actualizada si es necesario
- [ ] Commits siguen Conventional Commits
- [ ] Sin archivos innecesarios (`target/`, `build/`, `.dart_tool/`)
- [ ] Cambios enfocados y atómicos

## Proceso de revisión

1. Un mantenedor revisará tu PR lo antes posible
2. Se pueden solicitar cambios o aclaraciones
3. Una vez aprobado, será mergeado a la rama principal
4. Se actualizará el CHANGELOG en releases correspondientes

## Código de conducta

Este proyecto se adhiere a un código de conducta respetuoso e inclusivo. Esperamos que todos los colaboradores mantengan un ambiente colaborativo, profesional y libre de acoso.

## Licencia

Al contribuir a este proyecto, aceptas que tus contribuciones se licencien bajo la **PolyForm Noncommercial License 1.0.0**.
