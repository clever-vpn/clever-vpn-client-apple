#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="${VERSION_FILE:-$REPO_ROOT/Config/DependencyVersions.env}"
PROJECT_FILE="$REPO_ROOT/CleverVpn.xcodeproj/project.pbxproj"
WORKSPACE_DIR="$REPO_ROOT/CleverVpn.xcodeproj/project.xcworkspace"
SCHEME="${SCHEME:-CleverVpn}"

usage() {
  echo "Usage: $0 [--version <semver>] [--no-resolve]"
  echo ""
  echo "Reads CLEVER_VPN_KIT_VERSION from Config/DependencyVersions.env by default,"
  echo "updates the clever-vpn-kit requirement in project.pbxproj, then refreshes"
  echo "Package.resolved via xcodebuild -resolvePackageDependencies."
}

resolve_packages=1
override_version=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      if [ "$#" -lt 2 ]; then
        echo "error: --version requires a value" >&2
        exit 1
      fi
      override_version="$2"
      shift 2
      ;;
    --no-resolve)
      resolve_packages=0
      shift
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

if [ ! -f "$VERSION_FILE" ]; then
  echo "error: version file not found: $VERSION_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "$VERSION_FILE"

target_version="${override_version:-${CLEVER_VPN_KIT_VERSION:-}}"

if [ -z "$target_version" ]; then
  echo "error: CLEVER_VPN_KIT_VERSION is empty" >&2
  exit 1
fi

case "$target_version" in
  *[!0-9.]*|""|*.*.*.*)
    echo "error: version must look like semantic versioning, for example 1.2.3" >&2
    exit 1
    ;;
esac

if ! printf '%s' "$target_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "error: version must look like semantic versioning, for example 1.2.3" >&2
  exit 1
fi

cd "$REPO_ROOT"

TARGET_VERSION="$target_version" perl -0pi -e '
  my $version = $ENV{TARGET_VERSION};
  my $count = ($ARGV =~ s//?/g);
' "$PROJECT_FILE" 2>/dev/null || true

TARGET_VERSION="$target_version" perl -0pi -e '
  my $version = $ENV{TARGET_VERSION};
  my $count = 0;
  s{(XCRemoteSwiftPackageReference "clever-vpn-kit" \*/ = \{\n\s+isa = XCRemoteSwiftPackageReference;\n\s+repositoryURL = "https://github.com/clever-vpn/clever-vpn-kit";\n\s+requirement = \{\n\s+kind = [^;]+;\n\s+minimumVersion = )[^;]+(;\n\s+\};\n\s+\};)}{$1$version$2}ms and $count++;
  die "expected to update exactly one clever-vpn-kit requirement, updated $count\n" if $count != 1;
' "$PROJECT_FILE"

echo "Updated clever-vpn-kit minimumVersion to $target_version in $PROJECT_FILE"

if [ "$resolve_packages" -eq 0 ]; then
  echo "Skipped dependency resolution (--no-resolve)"
  exit 0
fi

xcodebuild -resolvePackageDependencies \
  -project "$REPO_ROOT/CleverVpn.xcodeproj" \
  -scheme "$SCHEME" \
  -clonedSourcePackagesDirPath "$REPO_ROOT/.build/SourcePackages"

echo "Refreshed Package.resolved using scheme $SCHEME"