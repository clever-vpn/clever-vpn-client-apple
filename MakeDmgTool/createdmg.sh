#!/bin/bash
set -euo pipefail

# 删除输出目录
rm -rf output
# 创建输出目录
mkdir -p output

# 获取输入参数作为app包路径
APP_PATH="$1"
APP_NAME=$(basename "$APP_PATH")
APP_BASENAME="${APP_NAME%.*}"
DMG_NAME="${APP_BASENAME}.dmg"
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
