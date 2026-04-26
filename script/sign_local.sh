#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/RightClick.app" >&2
  exit 64
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$1"
EXTENSION_BUNDLE="$APP_BUNDLE/Contents/PlugIns/RightClickFinderExtension.appex"

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "App bundle not found: $APP_BUNDLE" >&2
  exit 66
fi

if [[ ! -d "$EXTENSION_BUNDLE" ]]; then
  echo "Finder extension not found: $EXTENSION_BUNDLE" >&2
  exit 66
fi

codesign \
  --force \
  --sign - \
  --options runtime \
  --entitlements "$ROOT_DIR/RightClickFinderExtension/RightClickFinderExtension.entitlements" \
  --requirements '=designated => identifier "com.dominicduan.RightClick.FinderExtension"' \
  "$EXTENSION_BUNDLE"

codesign \
  --force \
  --sign - \
  --options runtime \
  --entitlements "$ROOT_DIR/RightClick/RightClick.entitlements" \
  --requirements '=designated => identifier "com.dominicduan.RightClick"' \
  "$APP_BUNDLE"

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
