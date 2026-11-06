#!/bin/bash
# Builds build/DockNumberer.app (Apple Silicon, optimized, ad-hoc signed).
set -euo pipefail
cd "$(dirname "$0")/.."

APP=build/DockNumberer.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc -O -target arm64-apple-macos13.0 \
  ${CLANG_MODULE_CACHE_PATH:+-module-cache-path "$CLANG_MODULE_CACHE_PATH"} \
  Sources/DockNumberer/*.swift \
  -o "$APP/Contents/MacOS/DockNumberer"

cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built $APP"
