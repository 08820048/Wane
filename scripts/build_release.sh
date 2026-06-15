#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.0001}"
APP_NAME="Wane"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
DMG_ROOT="$ROOT_DIR/dist/dmg-root"
DMG_PATH="$ROOT_DIR/dist/$APP_NAME-$VERSION.dmg"
DMG_LATEST_PATH="$ROOT_DIR/dist/$APP_NAME.dmg"
INFO_PLIST="$APP_BUNDLE/Contents/Info.plist"
PRODUCTS_DIR="$ROOT_DIR/.build/out/Products/Release"
SIGN_IDENTITY="${CODESIGN_IDENTITY:-}"

if [[ -d /Applications/Xcode.app ]]; then
  export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
elif [[ -d /Applications/Xcode-beta.app ]]; then
  export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"
fi

cd "$ROOT_DIR"

rm -rf "$ROOT_DIR/dist"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources" "$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$DMG_ROOT"

swift build -c release

if [[ -z "$SIGN_IDENTITY" ]]; then
  SIGN_IDENTITY="$(security find-identity -v -p codesigning | awk '/Developer ID Application/ { print $2; exit }')"
fi

if [[ -z "$SIGN_IDENTITY" ]]; then
  SIGN_IDENTITY="-"
  SIGN_OPTIONS=(--force --deep --sign "$SIGN_IDENTITY")
else
  SIGN_OPTIONS=(--force --deep --options runtime --timestamp --sign "$SIGN_IDENTITY")
fi

cp "$PRODUCTS_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Config/Wane-Info.plist" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$INFO_PLIST"

cp "$ROOT_DIR/Sources/WaneCore/Resources/WaneIcon.icns" "$APP_BUNDLE/Contents/Resources/WaneIcon.icns"
cp -R "$PRODUCTS_DIR/Sparkle.framework" "$APP_BUNDLE/Contents/Frameworks/Sparkle.framework"

if ! otool -l "$APP_BUNDLE/Contents/MacOS/$APP_NAME" | grep -q "@executable_path/../Frameworks"; then
  install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
fi

if [[ -d "$PRODUCTS_DIR/Wane_WaneCore.bundle" ]]; then
  cp -R "$PRODUCTS_DIR/Wane_WaneCore.bundle" "$APP_BUNDLE/Contents/Resources/Wane_WaneCore.bundle"
fi

codesign "${SIGN_OPTIONS[@]}" "$APP_BUNDLE"

rm -f "$DMG_PATH" "$DMG_LATEST_PATH"
cp -R "$APP_BUNDLE" "$DMG_ROOT/$APP_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

cp "$DMG_PATH" "$DMG_LATEST_PATH"

echo "Built:"
echo "  $APP_BUNDLE"
echo "  $DMG_PATH"
echo "  $DMG_LATEST_PATH"
