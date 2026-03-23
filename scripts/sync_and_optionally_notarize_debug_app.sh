#!/bin/sh
set -eu

is_true() {
  case "${1:-}" in
    1|yes|YES|true|TRUE|on|ON)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

sanitize_entitlements() {
  in_file="$1"
  out_file="$2"

  cp "$in_file" "$out_file"
  /usr/libexec/PlistBuddy -c "Delete :com.apple.security.get-task-allow" "$out_file" >/dev/null 2>&1 || true
}

sign_framework_if_present() {
  framework_root="$1"
  signing_identity="$2"

  if [ -f "$framework_root/Versions/A/Libbox" ]; then
    /usr/bin/codesign --force --sign "$signing_identity" --timestamp -o runtime "$framework_root/Versions/A/Libbox"
  fi

  if [ -d "$framework_root/Versions/A" ]; then
    /usr/bin/codesign --force --sign "$signing_identity" --timestamp -o runtime "$framework_root/Versions/A"
    return
  fi

  /usr/bin/codesign --force --sign "$signing_identity" --timestamp -o runtime "$framework_root"
}

sync_debug_app_bundle() {
  src_app="$1"
  dst_app="$2"
  stage_app="/Applications/.${WRAPPER_NAME}.sync"

  rm -rf "$stage_app"

  if ! /usr/bin/ditto "$src_app" "$stage_app"; then
    return 1
  fi

  if [ -d "$dst_app" ]; then
    if ! rm -rf "$dst_app"; then
      rm -rf "$stage_app"
      return 1
    fi
  fi

  if ! mv "$stage_app" "$dst_app"; then
    rm -rf "$stage_app"
    return 1
  fi

  return 0
}

resign_debug_bundle() {
  app_path="$1"
  signing_identity="$2"

  tmp_dir="$(mktemp -d)"
  cleanup() {
    rm -rf "$tmp_dir"
  }
  trap cleanup EXIT INT TERM

  app_entitlements="${TARGET_TEMP_DIR}/${WRAPPER_NAME}.xcent"
  app_entitlements_clean="$tmp_dir/app.xcent"

  if [ -f "$app_entitlements" ]; then
    sanitize_entitlements "$app_entitlements" "$app_entitlements_clean"
  else
    /usr/bin/codesign -d --entitlements :- "$app_path/Contents/MacOS/${PRODUCT_NAME}" >"$tmp_dir/app.raw.xcent" 2>/dev/null
    sanitize_entitlements "$tmp_dir/app.raw.xcent" "$app_entitlements_clean"
  fi

  if [ -d "$app_path/Contents/Frameworks" ]; then
    for framework in "$app_path"/Contents/Frameworks/*.framework; do
      [ -d "$framework" ] || continue
      sign_framework_if_present "$framework" "$signing_identity"
    done
  fi

  if [ -d "$app_path/Contents/Library/SystemExtensions" ]; then
    for sysext in "$app_path"/Contents/Library/SystemExtensions/*.systemextension; do
      [ -d "$sysext" ] || continue

      sysext_exec="$sysext/Contents/MacOS/$(basename "$sysext" .systemextension)"
      sysext_entitlements_raw="$tmp_dir/$(basename "$sysext").raw.xcent"
      sysext_entitlements_clean="$tmp_dir/$(basename "$sysext").xcent"

      if [ -d "$sysext/Contents/Frameworks" ]; then
        for framework in "$sysext"/Contents/Frameworks/*.framework; do
          [ -d "$framework" ] || continue
          sign_framework_if_present "$framework" "$signing_identity"
        done
      fi

      if [ -f "$sysext_exec" ]; then
        /usr/bin/codesign -d --entitlements :- "$sysext_exec" >"$sysext_entitlements_raw" 2>/dev/null
        sanitize_entitlements "$sysext_entitlements_raw" "$sysext_entitlements_clean"
        /usr/bin/codesign --force --sign "$signing_identity" --timestamp -o runtime --entitlements "$sysext_entitlements_clean" "$sysext"
      fi
    done
  fi

  /usr/bin/codesign --force --sign "$signing_identity" --timestamp -o runtime --entitlements "$app_entitlements_clean" "$app_path"

  /usr/bin/codesign --verify --deep --strict "$app_path"

  trap - EXIT INT TERM
  cleanup
}

if [ "${CONFIGURATION:-}" != "Debug" ] || [ "${PLATFORM_NAME:-}" != "macosx" ]; then
  exit 0
fi

SRC_APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
DST_APP="/Applications/${WRAPPER_NAME}"

if [ ! -d "${SRC_APP}" ]; then
  echo "warning: Debug app not found at ${SRC_APP}"
  exit 0
fi

if [ ! -w "/Applications" ] && [ ! -d "${DST_APP}" ]; then
  echo "warning: /Applications is not writable. Skip sync to ${DST_APP}"
  exit 0
fi

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  echo "error: EXPANDED_CODE_SIGN_IDENTITY is empty. Cannot re-sign ${WRAPPER_NAME}"
  exit 1
fi

if ! sync_debug_app_bundle "${SRC_APP}" "${DST_APP}"; then
  echo "warning: Failed to sync app to ${DST_APP}"
  echo "warning: If you see 'Operation not permitted', grant App Management permission to Xcode and Terminal."
  exit 0
fi

if ! resign_debug_bundle "${DST_APP}" "${EXPANDED_CODE_SIGN_IDENTITY}"; then
  echo "error: Re-signing synced app at ${DST_APP} failed"
  exit 1
fi

echo "Synced ${WRAPPER_NAME} to ${DST_APP} (source app kept untouched for Xcode debugging)"

if ! is_true "${NOTARIZE_DEBUG_APP:-}"; then
  echo "warning: ${WRAPPER_NAME} is Developer ID signed."
  echo "warning: For System Extension debug on SIP-enabled macOS, enable notarization in build env:"
  echo "warning:   NOTARIZE_DEBUG_APP=YES"
  echo "warning:   NOTARY_KEYCHAIN_PROFILE=<your-notary-profile>"
  exit 0
fi

if [ -z "${NOTARY_KEYCHAIN_PROFILE:-}" ]; then
  echo "error: NOTARIZE_DEBUG_APP is enabled but NOTARY_KEYCHAIN_PROFILE is empty"
  exit 1
fi

ZIP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}.notary.zip"
rm -f "${ZIP_PATH}"

if ! /usr/bin/ditto -c -k --sequesterRsrc --keepParent "${DST_APP}" "${ZIP_PATH}"; then
  echo "error: Failed to create archive for notarization"
  exit 1
fi

if ! xcrun notarytool submit "${ZIP_PATH}" --keychain-profile "${NOTARY_KEYCHAIN_PROFILE}" --wait; then
  echo "error: Notarization failed"
  exit 1
fi

if ! xcrun stapler staple "${DST_APP}"; then
  echo "error: Staple failed"
  exit 1
fi

if spctl -a -vv "${DST_APP}" >/dev/null 2>&1; then
  echo "Notarization + stapling succeeded for ${DST_APP}"
else
  echo "warning: spctl still rejects ${DST_APP}; check notarization logs"
fi
