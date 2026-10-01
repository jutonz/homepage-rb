set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
kit_dir="$repo_root/.sbx"

TEMPLATE_TAG="${TEMPLATE_TAG:-homepage-rb:latest}"
SBX_KIT_DIR="${SBX_KIT_DIR:-$HOME/.config/skillshare/skills/_sbx-kit}"

if [ ! -f "$SBX_KIT_DIR/host-lib.sh" ]; then
  echo "[sbx] cannot find the shared sandbox kit at $SBX_KIT_DIR;" \
    "set SBX_KIT_DIR to its directory" >&2
  exit 1
fi

. "$SBX_KIT_DIR/host-lib.sh"

# Sandboxes need the development and test credential keys, and must never see
# the production key.
repo_sandbox_argv() {
  DEVELOPMENT_KEY="$(cat "$repo_root/config/credentials/development.key")"
  TEST_KEY="$(cat "$repo_root/config/credentials/test.key")"
  export DEVELOPMENT_KEY TEST_KEY

  sandbox_argv+=(--env DEVELOPMENT_KEY --env TEST_KEY)
}
