#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# 删除输出目录
rm -rf output

# 创建输出local目录
mkdir -p output

# 创建clever-vpn-www-download 的apple目录
DOWNLOAD_PATH="../../../../Clever-VPN-Platform/clever-vpn-www-download/dist/apple/"
mkdir -p "$DOWNLOAD_PATH"

# 获取输入参数作为app包路径
APP_PATH="$1"
# APP_NAME=$(basename "$APP_PATH")
# APP_BASENAME="${APP_NAME%.*}"
DMG_NAME="clever-vpn.dmg"
OUTPUT_DMG="output/${DMG_NAME}"
# echo "Creating DMG: $OUTPUT_DMG from $APP_PATH"
# echo "App Name: $APP_NAME"
# echo "App Base Name: $APP_BASENAME"
create-dmg \
  --volname "Application Installer" \
  --window-pos 400 300 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "$APP_PATH" 150 100 \
  --hide-extension "Applications" \
  --app-drop-link 400 100 \
  "$OUTPUT_DMG" \
  "$APP_PATH"

cp -f "$OUTPUT_DMG" "$DOWNLOAD_PATH"
