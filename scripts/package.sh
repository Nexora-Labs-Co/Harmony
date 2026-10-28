#!/usr/bin/env bash
set -euo pipefail

# Harmony - Multi-platform packaging script
# Usage: ./scripts/package.sh [linux|android|windows|all]

APP_NAME="harmony"
BASE_VERSION="26.10.27"
# Incremento automatico: base + numero de commit git (o timestamp si no hay git)
if git -C "$(dirname "$0")/.." rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BUILD_NUM=$(git -C "$(dirname "$0")/.." rev-list --count HEAD)
else
  BUILD_NUM=$(date +%Y%m%d%H%M)
fi
VERSION="${BASE_VERSION}+${BUILD_NUM}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PROJECT_DIR"

build_linux() {
  echo "==> Building Linux (.deb)..."
  cd "$APP_DIR"
  flutter build linux --release

  BUNDLE="$APP_DIR/build/linux/x64/release/bundle"
  DEB_ROOT="/tmp/opencode/${APP_NAME}_${VERSION}_amd64"
  rm -rf "$DEB_ROOT"
  mkdir -p "$DEB_ROOT/DEBIAN" "$DEB_ROOT/usr/bin" "$DEB_ROOT/usr/share/applications" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps" "$DEB_ROOT/usr/share/icons/hicolor/scalable/apps" "$DEB_ROOT/opt/$APP_NAME"

  cp -r "$BUNDLE"/* "$DEB_ROOT/opt/$APP_NAME/"
  ln -sf "/opt/$APP_NAME/$APP_NAME" "$DEB_ROOT/usr/bin/$APP_NAME"
  # Icono (PNG + SVG si existe)
  cp "$PROJECT_DIR/linux/packaging/icons/harmony.png" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/harmony.png"
  if [ -f "$PROJECT_DIR/assets/icons/Logo-Harmony.svg" ]; then
    cp "$PROJECT_DIR/assets/icons/Logo-Harmony.svg" "$DEB_ROOT/usr/share/icons/hicolor/scalable/apps/harmony.svg"
  fi

  cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: sound
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libgstreamer1.0-0, libmpv2
Replaces: $APP_NAME
Breaks: $APP_NAME (<< $VERSION)
Maintainer: Nexora Labs <dev@nexora.local>
Description: Harmony Music Player
 Cross-platform music player built with Flutter and Rust.
EOF

  cat > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=Harmony
Exec=/opt/$APP_NAME/$APP_NAME
Icon=$APP_NAME
Terminal=false
Type=Application
Categories=Audio;Music;Player;
StartupNotify=true
StartupWMClass=com.nexoralabs.harmony
EOF

  dpkg-deb --build "$DEB_ROOT" "$PROJECT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
  echo "==> .deb created: $PROJECT_DIR/${APP_NAME}_${VERSION}_amd64.deb"
}

build_android() {
  echo "==> Building Android (APK)..."
  cd "$APP_DIR"
  flutter build apk --release
  cp "$APP_DIR/build/app/outputs/flutter-apk/app-release.apk" \
     "$PROJECT_DIR/${APP_NAME}_${VERSION}.apk"
  echo "==> APK created: $PROJECT_DIR/${APP_NAME}_${VERSION}.apk"
}

build_windows() {
  echo "==> Building Rust core (release)..."
  cd "$APP_DIR/rust"
  cargo build -p nexora_core --release
  cd "$APP_DIR"

  echo "==> Building Windows (.exe)..."
  flutter build windows --release

  echo "==> Copying native libraries..."
  cp "$APP_DIR/rust/target/release/nexora_core.dll" \
     "$APP_DIR/build/windows/x64/runner/Release/nexora_core.dll"

  RELEASE_DIR="$APP_DIR/build/windows/x64/runner/Release"
  ZIP_PATH="$PROJECT_DIR/${APP_NAME}_${VERSION}_windows.zip"
  echo "==> Creating Windows package: $ZIP_PATH"
  if command -v cygpath >/dev/null 2>&1; then
    WIN_RELEASE_DIR="$(cygpath -w "$RELEASE_DIR")"
    WIN_ZIP_PATH="$(cygpath -w "$ZIP_PATH")"
  else
    WIN_RELEASE_DIR="$RELEASE_DIR"
    WIN_ZIP_PATH="$ZIP_PATH"
  fi
  powershell -NoProfile -Command "Compress-Archive -Path '$WIN_RELEASE_DIR' -DestinationPath '$WIN_ZIP_PATH' -Force"
  echo "==> Windows package created: $ZIP_PATH"
}

case "${1:-all}" in
  linux)   build_linux ;;
  android) build_android ;;
  windows) build_windows ;;
  all)
    build_linux
    build_android
    build_windows
    ;;
  *)
    echo "Usage: $0 [linux|android|windows|all]"
    exit 1
    ;;
esac
