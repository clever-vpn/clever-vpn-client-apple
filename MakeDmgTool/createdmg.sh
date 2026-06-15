#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 获取输入参数作为app包路径
APP_PATH="$1"
APP_NAME=$(basename "$APP_PATH")

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: app bundle not found at $APP_PATH" >&2
  exit 1
fi

# 删除并重建输出目录
rm -rf output
mkdir -p output

# 创建 clever-vpn-www-download 的 apple 目录
DOWNLOAD_PATH="../../../../Clever-VPN-Platform/clever-vpn-www-download/dist/apple/"
mkdir -p "$DOWNLOAD_PATH"

# 生成 DMG 背景图 (如果不存在)
BG_PNG="dmg-background.png"
if [[ ! -f "$BG_PNG" ]]; then
  echo "Generating DMG background image..."
  python3 "$SCRIPT_DIR/generate_background.py" "$BG_PNG"
fi

DMG_NAME="clever-vpn.dmg"
OUTPUT_DMG="output/${DMG_NAME}"

echo "Creating DMG: $OUTPUT_DMG from $APP_PATH"
echo "App basename: $APP_NAME"

create-dmg \
  --volname "Clever VPN" \
  --background "$BG_PNG" \
  --window-pos 400 300 \
  --window-size 600 400 \
  --icon-size 100 \
  --text-size 14 \
  --icon "$APP_NAME" 160 190 \
  --app-drop-link 410 190 \
  --format UDBZ \
  "$OUTPUT_DMG" \
  "$APP_PATH"

echo "DMG created: $OUTPUT_DMG"

cp -f "$OUTPUT_DMG" "$DOWNLOAD_PATH"
echo "Copied to: $DOWNLOAD_PATH$DMG_NAME"
