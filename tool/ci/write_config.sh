#!/usr/bin/env bash
# Writes the git-ignored files a CI build needs, from environment variables.
#
#   env/<env>.json                       BASE_URL (required), API_VERSION, ENABLE_FIREBASE
#   android/app/google-services.json     GOOGLE_SERVICES_JSON (base64, optional)
#   ios/Runner/GoogleService-Info.plist  GOOGLE_SERVICE_INFO_PLIST (base64, optional)
#   android/key.properties               CM_KEYSTORE_PATH, CM_KEYSTORE_PASSWORD,
#                                        CM_KEY_ALIAS, CM_KEY_PASSWORD (set by Codemagic
#                                        `android_signing`, optional)
#
# Usage: ./tool/ci/write_config.sh <dev|staging|prod>
set -euo pipefail

ENV_NAME="${1:-prod}"
[[ "$ENV_NAME" =~ ^(dev|staging|prod)$ ]] || { echo "Environment must be dev, staging or prod" >&2; exit 1; }
[[ -f pubspec.yaml ]] || { echo "Run from the project root" >&2; exit 1; }
: "${BASE_URL:?BASE_URL is not set. Add it to the Codemagic environment variable group.}"

ENABLE_FIREBASE="${ENABLE_FIREBASE:-true}"
[[ "$ENABLE_FIREBASE" =~ ^(true|false)$ ]] || { echo "ENABLE_FIREBASE must be true or false" >&2; exit 1; }

mkdir -p env
cat > "env/$ENV_NAME.json" <<EOF
{
  "ENV": "$ENV_NAME",
  "BASE_URL": "$BASE_URL",
  "API_VERSION": "${API_VERSION:-v1}",
  "ENABLE_FIREBASE": $ENABLE_FIREBASE
}
EOF
echo "✓ env/$ENV_NAME.json (BASE_URL=$BASE_URL)"

if [[ -n "${GOOGLE_SERVICES_JSON:-}" ]]; then
  echo "$GOOGLE_SERVICES_JSON" | base64 --decode > android/app/google-services.json
  echo "✓ android/app/google-services.json"
elif [[ "$ENABLE_FIREBASE" == "true" ]]; then
  echo "! GOOGLE_SERVICES_JSON not set: Android build runs without Firebase"
fi

if [[ -n "${GOOGLE_SERVICE_INFO_PLIST:-}" ]]; then
  echo "$GOOGLE_SERVICE_INFO_PLIST" | base64 --decode > ios/Runner/GoogleService-Info.plist
  echo "✓ ios/Runner/GoogleService-Info.plist"
elif [[ "$ENABLE_FIREBASE" == "true" ]]; then
  echo "! GOOGLE_SERVICE_INFO_PLIST not set: iOS build runs without Firebase"
fi

if [[ -n "${CM_KEYSTORE_PATH:-}" ]]; then
  cat > android/key.properties <<EOF
storeFile=$CM_KEYSTORE_PATH
storePassword=$CM_KEYSTORE_PASSWORD
keyAlias=$CM_KEY_ALIAS
keyPassword=$CM_KEY_PASSWORD
EOF
  echo "✓ android/key.properties (alias $CM_KEY_ALIAS)"
fi
