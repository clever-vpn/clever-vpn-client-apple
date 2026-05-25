#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 --developer-config <path> --key-id <id> --issuer-id <id> --api-key-base64 <base64>"
}

developer_config="Config/Developer.xcconfig"
key_id=""
issuer_id=""
api_key_base64=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --developer-config)
      if [ "$#" -lt 2 ]; then
        echo "error: --developer-config requires a value" >&2
        exit 1
      fi
      developer_config="$2"
      shift 2
      ;;
    --key-id)
      if [ "$#" -lt 2 ]; then
        echo "error: --key-id requires a value" >&2
        exit 1
      fi
      key_id="$2"
      shift 2
      ;;
    --issuer-id)
      if [ "$#" -lt 2 ]; then
        echo "error: --issuer-id requires a value" >&2
        exit 1
      fi
      issuer_id="$2"
      shift 2
      ;;
    --api-key-base64)
      if [ "$#" -lt 2 ]; then
        echo "error: --api-key-base64 requires a value" >&2
        exit 1
      fi
      api_key_base64="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$key_id" ] || [ -z "$issuer_id" ] || [ -z "$api_key_base64" ]; then
  echo "error: --key-id, --issuer-id, and --api-key-base64 are required" >&2
  usage >&2
  exit 1
fi

if [ ! -f "$developer_config" ]; then
  echo "error: developer config not found: $developer_config" >&2
  exit 1
fi

app_bundle_id="$(sed -n 's/^APP_ID[[:space:]]*=[[:space:]]*//p' "$developer_config" | head -1 | tr -d '[:space:]')"
if [ -z "$app_bundle_id" ]; then
  echo "error: failed to read APP_ID from $developer_config" >&2
  exit 1
fi

key_path="$(mktemp "${TMPDIR:-/tmp}/asc-key.XXXXXX.p8")"
trap 'rm -f "$key_path"' EXIT INT TERM

printf '%s' "$api_key_base64" | base64 --decode > "$key_path"
chmod 600 "$key_path"

export KEY_PATH="$key_path"
export ASC_KEY_ID="$key_id"
export ASC_ISSUER_ID="$issuer_id"

jwt_token="$(ruby <<'RUBY'
require 'base64'
require 'json'
require 'openssl'

def base64url(value)
  Base64.urlsafe_encode64(value, padding: false)
end

key = OpenSSL::PKey.read(File.read(ENV.fetch('KEY_PATH')))
now = Time.now.to_i
header = {
  alg: 'ES256',
  kid: ENV.fetch('ASC_KEY_ID'),
  typ: 'JWT',
}
payload = {
  iss: ENV.fetch('ASC_ISSUER_ID'),
  exp: now + 1200,
  aud: 'appstoreconnect-v1',
}

encoded_header = base64url(JSON.generate(header))
encoded_payload = base64url(JSON.generate(payload))
signing_input = "#{encoded_header}.#{encoded_payload}"
der_signature = key.dsa_sign_asn1(OpenSSL::Digest::SHA256.digest(signing_input))
sequence = OpenSSL::ASN1.decode(der_signature)
raw_signature = sequence.value.map { |integer| integer.value.to_s(2).rjust(32, "\x00") }.join

print "#{signing_input}.#{base64url(raw_signature)}"
RUBY
)"

app_response="$(curl --silent --show-error --fail --get \
  'https://api.appstoreconnect.apple.com/v1/apps' \
  -H "Authorization: Bearer ${jwt_token}" \
  -H 'Accept: application/json' \
  --data-urlencode "filter[bundleId]=${app_bundle_id}" \
  --data-urlencode 'limit=1')"

app_store_app_id="$(printf '%s' "$app_response" | jq -r '.data[0].id // empty')"
if [ -z "$app_store_app_id" ]; then
  echo "error: failed to find App Store Connect app for bundle identifier ${app_bundle_id}" >&2
  printf '%s\n' "$app_response" >&2
  exit 1
fi

next_url="https://api.appstoreconnect.apple.com/v1/builds?filter[app]=${app_store_app_id}&limit=200"
max_build_number=0

while [ -n "$next_url" ]; do
  response="$(curl --globoff --silent --show-error --fail "$next_url" \
    -H "Authorization: Bearer ${jwt_token}" \
    -H 'Accept: application/json')"

  page_max="$(printf '%s' "$response" | jq -r '[.data[].attributes.version | select(test("^[0-9]+$")) | tonumber] | max // 0')"
  if [ "$page_max" -gt "$max_build_number" ]; then
    max_build_number="$page_max"
  fi

  next_url="$(printf '%s' "$response" | jq -r '.links.next // empty')"
done

printf '%s\n' "$((max_build_number + 1))"