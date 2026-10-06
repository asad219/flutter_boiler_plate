#!/usr/bin/env bash
# Generates Android and iOS launcher icons from one PNG using
# flutter_launcher_icons (config: `flutter_launcher_icons:` in pubspec.yaml).
#
# Usage:
#   ./tool/generate_app_icons.sh                      # use assets/icon/app_icon.png
#   ./tool/generate_app_icons.sh ~/Downloads/logo.png # copy it there first
#
# Run from the project root. The source must be a square PNG, ideally 1024×1024.
set -euo pipefail

ICON_PATH="assets/icon/app_icon.png"

[[ -f pubspec.yaml ]] || { echo "Run from the project root" >&2; exit 1; }

if [[ $# -gt 1 ]]; then
  sed -n '2,9p' "$0"
  exit 1
fi

if [[ $# -eq 1 ]]; then
  [[ -f "$1" ]] || { echo "File not found: $1" >&2; exit 1; }
  mkdir -p "$(dirname "$ICON_PATH")"
  cp "$1" "$ICON_PATH"
  echo "→ Copied $1 to $ICON_PATH"
fi

[[ -f "$ICON_PATH" ]] || { echo "Missing $ICON_PATH (pass a PNG path)" >&2; exit 1; }

# PNG signature, then width/height as big-endian uint32 at bytes 16–23.
signature=$(od -An -tx1 -N8 "$ICON_PATH" | tr -d ' \n')
[[ "$signature" == "89504e470d0a1a0a" ]] || { echo "$ICON_PATH is not a PNG" >&2; exit 1; }
read -r w1 w2 w3 w4 h1 h2 h3 h4 < <(od -An -tu1 -j16 -N8 "$ICON_PATH")
width=$(( (w1 << 24) | (w2 << 16) | (w3 << 8) | w4 ))
height=$(( (h1 << 24) | (h2 << 16) | (h3 << 8) | h4 ))

[[ "$width" -eq "$height" ]] || { echo "Icon must be square (got ${width}×${height})" >&2; exit 1; }
if [[ "$width" -lt 1024 ]]; then
  echo "Warning: icon is ${width}×${height}; use 1024×1024 or the App Store icon will be blurry." >&2
fi

echo "→ Generating launcher icons from $ICON_PATH (${width}×${height})"
flutter pub get
dart run flutter_launcher_icons

# flutter_launcher_icons 0.14.x also rewrites this unrelated YES/NO build
# setting to "AppIcon" in the Xcode project; put it back.
perl -pi -e 's/(ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = )AppIcon;/${1}YES;/' \
  ios/Runner.xcodeproj/project.pbxproj

echo "Done. Review with git diff, then rebuild the app (uninstall first if the old icon is cached)."
