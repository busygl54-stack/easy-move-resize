#!/bin/bash
set -e

SDK=$(xcrun --sdk macosx --show-sdk-path)
SRC="easy-move-resize"
OUT="build/Easy Move+Resize.app/Contents"
MACOS="$OUT/MacOS"
RES="$OUT/Resources"
BUNDLE_ID="org.dmarcotte.Easy-Move-Resize"
EXECUTABLE="Easy Move+Resize"
MIN_OS="11.0"

rm -rf build
mkdir -p "$MACOS" "$RES/en.lproj"

echo "==> Compiling Objective-C sources..."
clang \
  -fobjc-arc \
  -fmodules \
  -isysroot "$SDK" \
  -mmacosx-version-min="$MIN_OS" \
  -arch arm64 -arch x86_64 \
  -framework Cocoa \
  -framework Carbon \
  -framework QuartzCore \
  -include "$SRC/easy-move-resize-Prefix.pch" \
  "$SRC/main.m" \
  "$SRC/EMRAppDelegate.m" \
  "$SRC/EMRMoveResize.m" \
  "$SRC/EMRPreferences.m" \
  -o "$MACOS/$EXECUTABLE"

echo "==> Copying NIB and assets from installed app (unchanged)..."
INSTALLED="$HOME/Applications/Easy Move+Resize.app/Contents/Resources"
cp -r "$INSTALLED/en.lproj" "$RES/"
cp "$INSTALLED/Assets.car" "$RES/" 2>/dev/null || true
cp "$INSTALLED/AppIcon.icns" "$RES/" 2>/dev/null || true

echo "==> Writing Info.plist..."
cat > "$OUT/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>Easy Move+Resize</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>Easy Move+Resize</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.8.1</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key><string>$MIN_OS</string>
  <key>LSUIElement</key><true/>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2013 Daniel Marcotte. All rights reserved.</string>
  <key>NSMainNibFile</key><string>MainMenu</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
EOF

echo "==> Copying localisation strings..."
cp "$SRC/en.lproj/InfoPlist.strings" "$RES/en.lproj/"

echo "==> Writing PkgInfo..."
echo -n "APPL????" > "$OUT/PkgInfo"

echo "==> Ad-hoc signing..."
codesign --force --deep --sign - "build/Easy Move+Resize.app"

echo ""
echo "Done: build/Easy Move+Resize.app"
