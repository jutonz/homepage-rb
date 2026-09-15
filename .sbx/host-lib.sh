set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
kit_dir="$repo_root/.sbx"

TEMPLATE_TAG="${TEMPLATE_TAG:-homepage-rb:latest}"
SANDBOX_CPUS="${SANDBOX_CPUS:-4}"
SANDBOX_MEMORY="${SANDBOX_MEMORY:-8g}"
READY_TIMEOUT="${READY_TIMEOUT:-1800}"
USE_TEMPLATE="${USE_TEMPLATE:-yes}"
KEEP_SANDBOXES="${KEEP_SANDBOXES:-no}"
SUITE_ATTEMPTS="${SUITE_ATTEMPTS:-3}"
FORWARD_LINEAR_KEY="${FORWARD_LINEAR_KEY:-yes}"
LINEAR_OP_ITEM="${LINEAR_OP_ITEM:-op://Private/Linear/Beads sync API key}"
LINEAR_OP_ACCOUNT="${LINEAR_OP_ACCOUNT:-my.1password.com}"

say() {
  printf '[sbx] %s\n' "$*"
}

# Sandboxes need the development and test credential keys, and must never see
# the production key.
export_credential_keys() {
  DEVELOPMENT_KEY="$(cat "$repo_root/config/credentials/development.key")"
  TEST_KEY="$(cat "$repo_root/config/credentials/test.key")"
  export DEVELOPMENT_KEY TEST_KEY
}

# An explicit export always wins. Otherwise, when the 1Password CLI is on
# the host, read the key from there instead of requiring an export.
resolve_linear_api_key() {
  if [ -n "${LINEAR_API_KEY:-}" ] || ! command -v op >/dev/null; then
    return
  fi

  if LINEAR_API_KEY="$(op read "$LINEAR_OP_ITEM" \
      --account="$LINEAR_OP_ACCOUNT" 2>/dev/null)"; then
    export LINEAR_API_KEY
  else
    say "could not read the Linear key from 1Password;" \
      "the sandbox will have no Linear access" >&2
  fi
}

template_exists() {
  local repository="${TEMPLATE_TAG%:*}"
  local tag="${TEMPLATE_TAG##*:}"

  sbx template ls 2>/dev/null | awk -v repository="$repository" -v tag="$tag" '
    $2 == tag && ($1 == repository || $1 ~ "/" repository "$") { found = 1 }
    END { exit !found }
  '
}

# Writes the flags that create a sandbox. The result is a global array
# because macOS ships bash 3.2, which has no name references.
build_sandbox_argv() {
  local name="$1"

  sandbox_argv=(
    shell
    --name "$name"
    --kit "$kit_dir"
    --clone
    --cpus "$SANDBOX_CPUS"
    --memory "$SANDBOX_MEMORY"
    --env DEVELOPMENT_KEY
    --env TEST_KEY
  )

  if [ "$USE_TEMPLATE" = yes ] && template_exists; then
    sandbox_argv+=(--template "$TEMPLATE_TAG")
  fi

  # Linear is optional and, unlike the credential keys above, forwards the
  # developer's own host value rather than one read from a repo file. A
  # Template build sets FORWARD_LINEAR_KEY=no so a cached Template never
  # acquires or carries the builder's Linear identity.
  if [ "$FORWARD_LINEAR_KEY" = yes ]; then
    resolve_linear_api_key

    if [ -n "${LINEAR_API_KEY:-}" ]; then
      sandbox_argv+=(--env LINEAR_API_KEY)
    fi
  fi
}

create_sandbox() {
  local name="$1"
  shift

  export_credential_keys
  build_sandbox_argv "$name"

  sbx create "${sandbox_argv[@]}" "$@" "$repo_root"
}

# Writes the state sbx reports for a sandbox, or nothing when no sandbox
# has the name. The ports column is empty for a stopped sandbox, so the
# fields after it shift left. Only $1 and $3 hold in both cases.
sbx_state() {
  local name="$1"

  sbx ls 2>/dev/null | awk -v name="$name" '$1 == name { print $3 }' || true
}

# sbx rejects --kit, --cpus, --memory, and --template when the sandbox
# already exists, so the attach path must not send them. sbx starts a
# stopped sandbox itself.
run_sandbox() {
  local name="$1"
  shift

  local state
  state="$(sbx_state "$name")"

  if [ -z "$state" ]; then
    export_credential_keys
    build_sandbox_argv "$name"

    sbx run "${sandbox_argv[@]}" "$@" "$repo_root"
    return
  fi

  if [ "$state" = stopped ]; then
    say "starting stopped sandbox"
  else
    say "attaching to already running sandbox"
  fi

  sbx run shell --name "$name" "$@"
}

# Poll until a command succeeds. Returns 1 once the timeout is reached.
wait_until() {
  local timeout="$1"
  local interval="$2"
  shift 2

  local waited=0

  while [ "$waited" -lt "$timeout" ]; do
    if "$@"; then
      return 0
    fi

    sleep "$interval"
    waited=$((waited + interval))
  done

  return 1
}

wait_until_ready() {
  local name="$1"

  wait_until "$READY_TIMEOUT" 5 sandbox_has_settled "$name" || true

  if [ "$(sandbox_status "$name")" = ready ]; then
    return 0
  fi

  say "$name is not ready; its startup log follows" >&2
  sbx exec "$name" cat /var/log/sbx-kit-startup.log >&2 || true
  return 1
}

sandbox_has_settled() {
  case "$(sandbox_status "$1")" in
    ready | failed) return 0 ;;
  esac

  return 1
}

sandbox_status() {
  # The path must match status_file() in
  # .sbx/files/home/.sbx-kit/lib.sh. 1000 is the agent user in every sbx
  # agent image.
  sbx exec "$1" cat /run/user/1000/sbx-kit-status 2>/dev/null || true
}

remove_sandbox() {
  if [ "$KEEP_SANDBOXES" = yes ]; then
    say "keeping $1"
    return
  fi

  sbx rm --force "$1" >/dev/null 2>&1 || true
}

in_sandbox() {
  local name="$1"
  shift

  sbx exec "$name" bash -lc "cd \"\$WORKSPACE_DIR\" && $*"
}
