#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/ALLMYSCREENS/MacsyZones.xcodeproj"
SCHEME="ALLMYSCREENS"
BUILD_DIR="$ROOT/ALLMYSCREENS/build"

if ! xcodebuild -version &>/dev/null; then
  echo "ERROR: Full Xcode is required (xcodebuild not available)."
  echo "Install Xcode from the App Store, then run:"
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM= \
  CODE_SIGN_IDENTITY=-

APP="$BUILD_DIR/Build/Products/Release/ALLMYSCREENS.app"
echo ""
echo "Build succeeded: $APP"
echo ""
echo "Install:"
echo "  cp -R \"$APP\" /Applications/"
echo "  codesign --force --deep --sign - /Applications/ALLMYSCREENS.app"
echo "  open /Applications/ALLMYSCREENS.app"
