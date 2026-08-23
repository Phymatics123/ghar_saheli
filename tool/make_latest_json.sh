#!/usr/bin/env bash
# Builds release/latest.json from an actual built APK.
#
# This exists because of one trap that fails silently. `flutter build apk
# --split-per-abi` does NOT use the build number from pubspec.yaml as the
# versionCode — it adds a per-ABI offset (armeabi-v7a +1000, arm64-v8a +2000,
# x86_64 +4000). So pubspec `1.0.0+1` ships as versionCode 1001, and that is
# what an installed copy reports back through PackageManager.
#
# Write "1" into latest.json by hand and the updater compares 1 against 1001,
# concludes the phone is already newer, and offers nothing. No error, no
# crash — updates just quietly never appear. Reading the number back out of
# the APK removes the chance of getting it wrong.
#
# Usage: tool/make_latest_json.sh <path-to-apk> <download-url> [notes-roman]
set -euo pipefail

APK="${1:?usage: make_latest_json.sh <apk> <url> [notes]}"
URL="${2:?usage: make_latest_json.sh <apk> <url> [notes]}"
NOTES="${3:-Choti kharabiyan theek ki gayin}"

AAPT="$(ls /e/Android/sdk/build-tools/*/aapt2.exe 2>/dev/null | tail -1)"
[ -x "$AAPT" ] || { echo "aapt2 not found under /e/Android/sdk/build-tools" >&2; exit 1; }

BADGING="$("$AAPT" dump badging "$APK" | head -1)"
CODE="$(echo "$BADGING" | grep -oE "versionCode='[0-9]+'" | grep -oE '[0-9]+')"
NAME="$(echo "$BADGING" | grep -oE "versionName='[^']+'" | sed "s/versionName='//;s/'//")"
SHA="$(sha256sum "$APK" | cut -d' ' -f1)"
SIZE="$(stat -c%s "$APK")"

cat > release/latest.json <<JSON
{
  "versionCode": $CODE,
  "versionName": "$NAME",
  "apkUrl": "$URL",
  "sha256": "$SHA",
  "sizeBytes": $SIZE,
  "mandatory": false,
  "notes": {
    "ur": "نیا ورژن",
    "roman": "$NOTES",
    "en": "$NOTES"
  }
}
JSON

echo "release/latest.json written:  versionCode=$CODE  versionName=$NAME  size=$SIZE"
