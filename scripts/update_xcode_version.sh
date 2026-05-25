#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$REPO_ROOT/Config/Version.xcconfig"

usage() {
  echo "Usage: $0 --version <semver> --build <integer>"
}

version=""
build=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      if [ "$#" -lt 2 ]; then
        echo "error: --version requires a value" >&2
        exit 1
      fi
      version="$2"
      shift 2
      ;;
    --build)
      if [ "$#" -lt 2 ]; then
        echo "error: --build requires a value" >&2
        exit 1
      fi
      build="$2"
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

if ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$'; then
  echo "error: version must look like 1.2.3 or 1.2.3-rc.1" >&2
  exit 1
fi

if ! printf '%s' "$build" | grep -Eq '^[0-9]+$'; then
  echo "error: build must be a positive integer" >&2
  exit 1
fi

VERSION_VALUE="$version" BUILD_VALUE="$build" perl -0pi -e '
  my $version = $ENV{VERSION_VALUE};
  my $build = $ENV{BUILD_VALUE};
  my $version_count = s/^VERSION_NAME = .*$/VERSION_NAME = $version/mg;
  my $build_count = s/^VERSION_ID = .*$/VERSION_ID = $build/mg;
  die "expected to update VERSION_NAME and VERSION_ID exactly once\n" if $version_count != 1 || $build_count != 1;
' "$VERSION_FILE"

echo "Updated $VERSION_FILE to VERSION_NAME=$version VERSION_ID=$build"