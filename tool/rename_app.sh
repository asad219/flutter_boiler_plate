#!/usr/bin/env bash
# Renames the boilerplate for a new app: Dart package, Android applicationId /
# namespace, iOS bundle identifier and display name.
#
# Usage:
#   ./tool/rename_app.sh \
#     --package my_app \
#     --android-id com.acme.myapp \
#     --ios-id com.acme.myapp \
#     --name "My App"
#
# Run from the project root on a clean git tree so you can review the diff.
set -euo pipefail

OLD_PACKAGE="app_boilerplate"
OLD_ANDROID_ID="com.starter.boilerplate.app_boilerplate"
OLD_IOS_ID="com.starter.boilerplate.appBoilerplate"
OLD_NAME="App Boilerplate"

NEW_PACKAGE=""
NEW_ANDROID_ID=""
NEW_IOS_ID=""
NEW_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package) NEW_PACKAGE="$2"; shift 2 ;;
    --android-id) NEW_ANDROID_ID="$2"; shift 2 ;;
    --ios-id) NEW_IOS_ID="$2"; shift 2 ;;
    --name) NEW_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$NEW_PACKAGE" || -z "$NEW_ANDROID_ID" || -z "$NEW_IOS_ID" || -z "$NEW_NAME" ]]; then
  sed -n '2,12p' "$0"
  exit 1
fi

[[ "$NEW_PACKAGE" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "--package must be snake_case" >&2; exit 1; }
[[ "$NEW_ANDROID_ID" =~ ^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$ ]] || { echo "Invalid --android-id" >&2; exit 1; }
[[ "$NEW_IOS_ID" =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]] || { echo "Invalid --ios-id" >&2; exit 1; }
[[ -f pubspec.yaml ]] || { echo "Run from the project root" >&2; exit 1; }

# Literal (non-regex) in-place replace across files.
replace() {
  local from="$1" to="$2"; shift 2
  FROM="$from" TO="$to" perl -pi -e 's/\Q$ENV{FROM}\E/$ENV{TO}/g' "$@"
}

echo "→ Dart package: $OLD_PACKAGE → $NEW_PACKAGE"
replace "name: $OLD_PACKAGE" "name: $NEW_PACKAGE" pubspec.yaml
find lib test -name '*.dart' -print0 | while IFS= read -r -d '' file; do
  replace "package:$OLD_PACKAGE/" "package:$NEW_PACKAGE/" "$file"
done

echo "→ Android id: $OLD_ANDROID_ID → $NEW_ANDROID_ID"
replace "$OLD_ANDROID_ID" "$NEW_ANDROID_ID" android/app/build.gradle.kts
OLD_KOTLIN_DIR="android/app/src/main/kotlin/${OLD_ANDROID_ID//.//}"
NEW_KOTLIN_DIR="android/app/src/main/kotlin/${NEW_ANDROID_ID//.//}"
if [[ -d "$OLD_KOTLIN_DIR" && "$OLD_KOTLIN_DIR" != "$NEW_KOTLIN_DIR" ]]; then
  mkdir -p "$NEW_KOTLIN_DIR"
  mv "$OLD_KOTLIN_DIR"/* "$NEW_KOTLIN_DIR"/
  find android/app/src/main/kotlin -type d -empty -delete
fi
replace "package $OLD_ANDROID_ID" "package $NEW_ANDROID_ID" "$NEW_KOTLIN_DIR/MainActivity.kt"
replace "android:label=\"$OLD_NAME\"" "android:label=\"$NEW_NAME\"" android/app/src/main/AndroidManifest.xml

echo "→ iOS bundle id: $OLD_IOS_ID → $NEW_IOS_ID"
replace "$OLD_IOS_ID" "$NEW_IOS_ID" ios/Runner.xcodeproj/project.pbxproj
replace "<string>$OLD_NAME</string>" "<string>$NEW_NAME</string>" ios/Runner/Info.plist
replace "<string>$OLD_PACKAGE</string>" "<string>$NEW_PACKAGE</string>" ios/Runner/Info.plist

echo "→ App name: $OLD_NAME → $NEW_NAME"
replace "appName = '$OLD_NAME'" "appName = '$NEW_NAME'" lib/core/constants/app_constants.dart

echo "→ Refreshing dependencies"
flutter clean >/dev/null
flutter pub get >/dev/null

echo "✓ Done. Next: add Firebase config for the new ids (see README › Firebase setup)."
