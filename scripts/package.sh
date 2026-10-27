#!/usr/bin/env bash
set -euo pipefail

# Harmony - Multi-platform packaging script
# Usage: ./scripts/package.sh [linux|android|windows|all]

APP_NAME="harmony"
VERSION="26.10.27"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PROJECT_DIR/nexora_app"

build_linux() {
  echo "==> Building Linux (.deb)..."
  cd "$APP_DIR"
  flutter build linux --release

  BUNDLE="$APP_DIR/build/linux/x64/release/bundle"
  DEB_ROOT="/tmp/opencode/${APP_NAME}_${VERSION}_amd64"
  rm -rf "$DEB_ROOT"
  mkdir -p "$DEB_ROOT/DEBIAN" "$DEB_ROOT/usr/bin" "$DEB_ROOT/usr/share/applications" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps" "$DEB_ROOT/opt/$APP_NAME"

  cp -r "$BUNDLE"/* "$DEB_ROOT/opt/$APP_NAME/"
  ln -sf "/opt/$APP_NAME/$APP_NAME" "$DEB_ROOT/usr/bin/$APP_NAME"

  cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: $APP_NAME
Version: $VERSION
Section: sound
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libgstreamer1.0-0, libmpv2
Maintainer: Nexora Labs <dev@nexora.local>
Description: Harmony Music Player
 Cross-platform music player built with Flutter and Rust.
EOF

  cat > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=Harmony
Exec=/opt/$APP_NAME/$APP_NAME
Icon=$APP_NAME
Type=Application
Categories=Audio;Music;Player;
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
  echo "==> Building Windows (.exe)..."
  cd "$APP_DIR"
  flutter build windows --release
  echo "==> Windows build ready in: $APP_DIR/build/windows/x64/runner/Release/"
  echo "    Zip the Release folder to distribute as .exe package."
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
```

Also rename the binary? The binary is named `nexora_app` (from CMake BINARY_NAME). Let me update CMakeLists.txt BINARY_NAME to `harmony` for consistency. Actually the user renamed app to Harmony. Let me update the Linux binary name.<|end|><|start|>start of thinking<|message|>Update CMake binary name to harmony.<|end|><|start|><|start|>assistant to=edit<|channel|>analysis <|constrain|>xml<|message|><rfl:parameter name="path">
/home/saaarmyx/Desktop/Nexora-Labs-Co/Harmony/nexora_app/linux/CMakeLists.txt