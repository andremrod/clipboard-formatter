#!/usr/bin/env bash
# Gera dist/ClipboardFormatter.app e dist/ClipboardFormatter-<versão>.dmg a partir do código.
# A versão vem de Sources/ClipboardFormatter/AppVersion.swift.
set -euo pipefail
cd "$(dirname "$0")/.."

APP=ClipboardFormatter
VERSION=$(sed -n 's/.*marketing = "\(.*\)".*/\1/p' Sources/$APP/AppVersion.swift)
BUILD=$(sed -n 's/.*build = "\(.*\)".*/\1/p' Sources/$APP/AppVersion.swift)

swift build -c release
BIN="$(swift build -c release --show-bin-path)/$APP"

rm -rf dist && mkdir -p "dist/$APP.app/Contents/MacOS"
cp "$BIN" "dist/$APP.app/Contents/MacOS/$APP"
sed -e "/CFBundleShortVersionString/{n;s/<string>.*</<string>$VERSION</;}" \
    -e "/CFBundleVersion/{n;s/<string>.*</<string>$BUILD</;}" \
    Support/Info.plist > "dist/$APP.app/Contents/Info.plist"
codesign --force --sign - "dist/$APP.app"   # assinatura ad-hoc (sem Developer ID)

STAGE=$(mktemp -d)
cp -R "dist/$APP.app" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "$APP $VERSION" -srcfolder "$STAGE" -ov -format UDZO "dist/$APP-$VERSION.dmg" >/dev/null
rm -rf "$STAGE"
echo "dist/$APP.app e dist/$APP-$VERSION.dmg ($VERSION, build $BUILD)"
