set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
kit_dir="$repo_root/.sbx"

AGENT="${AGENT:-shell}"
TEMPLATE_REPOSITORY="${TEMPLATE_REPOSITORY:-homepage-rb}"
SANDBOX_CPUS="${SANDBOX_CPUS:-4}"
SANDBOX_MEMORY="${SANDBOX_MEMORY:-8g}"
READY_TIMEOUT="${READY_TIMEOUT:-1800}"
USE_TEMPLATE="${USE_TEMPLATE:-yes}"
KEEP_SANDBOXES="${KEEP_SANDBOXES:-no}"
SUITE_ATTEMPTS="${SUITE_ATTEMPTS:-3}"
FORWARD_LINEAR_KEY="${FORWARD_LINEAR_KEY:-yes}"
LINEAR_OP_ITEM="${LINEAR_OP_ITEM:-op://Private/Linear/Beads sync API key}"
LINEAR_OP_ACCOUNT="${LINEAR_OP_ACCOUNT:-my.1password.com}"
PUSH_AGENT_CONFIG="${PUSH_AGENT_CONFIG:-yes}"
IMPORT_SKILLS="${IMPORT_SKILLS:-yes}"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
AGENT_CONFIG_STAGE="${AGENT_CONFIG_STAGE:-\
${XDG_CACHE_HOME:-$HOME/.cache}/homepage-rb-sbx/agent-config}"

AGENTS="shell claude opencode"

say() {
  printf '[sbx] %s\n' "$*"
}

# One template per agent. sbx gives a template the agent of the sandbox
# that saved it, and refuses that template to any other agent. The tag
# therefore names the agent instead of a single "latest".
template_tag() {
  printf '%s\n' "${TEMPLATE_TAG:-$TEMPLATE_REPOSITORY:$AGENT}"
}

check_agent() {
  local candidate

  for candidate in $AGENTS; do
    if [ "$candidate" = "$AGENT" ]; then
      return 0
    fi
  done

  say "unknown agent $AGENT; choose one of $AGENTS" >&2
  return 1
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
  local tag repository
  tag="$(template_tag)"
  repository="${tag%:*}"
  tag="${tag##*:}"

  sbx template ls 2>/dev/null | awk -v repository="$repository" -v tag="$tag" '
    $2 == tag && ($1 == repository || $1 ~ "/" repository "$") { found = 1 }
    END { exit !found }
  '
}

# A shell sandbox runs no agent, so it needs no agent config and no skills.
wants_agent_config() {
  [ "$PUSH_AGENT_CONFIG" = yes ] && [ "$AGENT" != shell ]
}

# cp must dereference. Parts of the agent config are symlinks into a
# separate source tree, and a sandbox that mounts the link instead of the
# target sees nothing.
stage_entry() {
  local source="$1"
  local target="$2"

  [ -e "$source" ] || return 0

  rm -rf "$target"
  cp -RL "$source" "$target"
}

# The plugin directory is far larger than the rest of the agent config. A
# copy on every attach would make attach slow. Delete the staging
# directory to pick up a plugin change.
stage_entry_once() {
  local source="$1"
  local target="$2"

  if [ ! -e "$source" ] || [ -e "$target" ]; then
    return 0
  fi

  cp -RL "$source" "$target"
}

# The sandbox must not mount the real configuration directory. An agent
# writes to its own configuration directory while it runs, and a read-only
# mount breaks the agent. The sandbox mounts this staged copy instead.
stage_agent_config() {
  mkdir -p "$AGENT_CONFIG_STAGE/claude" "$AGENT_CONFIG_STAGE/opencode"

  stage_entry "$CLAUDE_CONFIG_DIR/CLAUDE.md" \
    "$AGENT_CONFIG_STAGE/claude/CLAUDE.md"
  stage_entry "$CLAUDE_CONFIG_DIR/settings.json" \
    "$AGENT_CONFIG_STAGE/claude/settings.json"
  stage_entry "$CLAUDE_CONFIG_DIR/agents" \
    "$AGENT_CONFIG_STAGE/claude/agents"
  stage_entry_once "$CLAUDE_CONFIG_DIR/plugins" \
    "$AGENT_CONFIG_STAGE/claude/plugins"

  stage_entry "$OPENCODE_CONFIG_DIR/opencode.json" \
    "$AGENT_CONFIG_STAGE/opencode/opencode.json"
  stage_entry "$OPENCODE_CONFIG_DIR/commands" \
    "$AGENT_CONFIG_STAGE/opencode/commands"
  stage_entry "$OPENCODE_CONFIG_DIR/plugins" \
    "$AGENT_CONFIG_STAGE/opencode/plugins"
}

# sbx keeps skills in a machine-global store, and mounts that store into
# every sandbox. The host therefore only imports. The store is shared, so
# an import reaches every sandbox on the machine, not only this
# repository's. sbx marks `skills` experimental.
import_skills() {
  if [ "$IMPORT_SKILLS" != yes ]; then
    return
  fi

  say "importing skills into the shared sandbox store"
  sbx skills import --force >/dev/null || say "could not import skills" >&2
}

# Writes the flags that create a sandbox, and the workspaces that follow
# them. The results are global arrays because macOS ships bash 3.2, which
# has no name references.
build_sandbox_argv() {
  local name="$1"

  sandbox_argv=(
    "$AGENT"
    --name "$name"
    --kit "$kit_dir"
    --clone
    --cpus "$SANDBOX_CPUS"
    --memory "$SANDBOX_MEMORY"
    --env DEVELOPMENT_KEY
    --env TEST_KEY
  )

  workspace_argv=("$repo_root")

  # sbx mounts its machine-global skills store into every sandbox unless
  # this flag turns the mount off. IMPORT_SKILLS=no only stops the import,
  # so the template build needs the flag as well to stay free of the
  # developer's skills.
  if [ "$IMPORT_SKILLS" != yes ]; then
    sandbox_argv+=(--no-share-skills)
  fi

  if [ "$USE_TEMPLATE" = yes ] && template_exists; then
    sandbox_argv+=(--template "$(template_tag)")
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

  # The template build never stages. Its sandbox gets no mount, and the
  # startup step then finds nothing to copy. No condition keeps the agent
  # config out of a saved template; the missing mount does.
  if wants_agent_config; then
    stage_agent_config
    sandbox_argv+=(--env "SBX_KIT_AGENT_CONFIG=$AGENT_CONFIG_STAGE")
    workspace_argv+=("$AGENT_CONFIG_STAGE:ro")
  fi
}

create_sandbox() {
  local name="$1"
  shift

  check_agent
  export_credential_keys
  import_skills
  build_sandbox_argv "$name"

  sbx create "${sandbox_argv[@]}" "$@" "${workspace_argv[@]}"
}

# Writes the state sbx reports for a sandbox, or nothing when no sandbox
# has the name. The ports column is empty for a stopped sandbox, so the
# fields after it shift left. Only $1 and $3 hold in both cases.
sbx_state() {
  local name="$1"

  sbx ls 2>/dev/null | awk -v name="$name" '$1 == name { print $3 }' || true
}

# sbx rejects --kit, --cpus, --memory, --template, and --env when the
# sandbox already exists, so the attach path must not send them. sbx starts
# a stopped sandbox itself.
#
# The staging directory keeps a stable path and is mounted, not copied, so
# refreshing it on the host is what an attached sandbox sees. That is why
# attach still stages and still imports skills.
run_sandbox() {
  local name="$1"
  shift

  check_agent

  local state
  state="$(sbx_state "$name")"

  if [ -z "$state" ]; then
    export_credential_keys
    import_skills
    build_sandbox_argv "$name"

    sbx run "${sandbox_argv[@]}" "$@" "${workspace_argv[@]}"
    return
  fi

  import_skills

  if wants_agent_config; then
    stage_agent_config
  fi

  if [ "$state" = stopped ]; then
    say "starting stopped sandbox"
  else
    say "attaching to already running sandbox"

    # sbx runs the kit's startup steps when it starts a sandbox, and a
    # running sandbox does not start. The merged files would then keep
    # whatever the last start produced, so the push runs again here.
    if wants_agent_config; then
      sbx exec "$name" bash /home/agent/.sbx-kit/push-agent-config \
        >/dev/null || say "could not refresh the agent config" >&2
    fi
  fi

  # sbx reads the agent from the sandbox's own spec when --name gives an
  # existing sandbox, so the attach path must not repeat it. A sandbox
  # keeps the agent it was created with.
  sbx run --name "$name" "$@"
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
