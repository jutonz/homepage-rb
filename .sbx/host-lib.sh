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
FORWARD_CLAUDE_TOKEN="${FORWARD_CLAUDE_TOKEN:-yes}"
CLAUDE_OP_ITEM="${CLAUDE_OP_ITEM:-op://Private/Claude AI/oauth token}"
CLAUDE_OP_ACCOUNT="${CLAUDE_OP_ACCOUNT:-my.1password.com}"
SHARE_CLAUDE_SKILLS="${SHARE_CLAUDE_SKILLS:-yes}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SHARE_CLAUDE_INSTRUCTIONS="${SHARE_CLAUDE_INSTRUCTIONS:-yes}"
CLAUDE_MD_STAGE="${CLAUDE_MD_STAGE:-$HOME/.local/state/homepage-rb/claude-md}"
SHARE_GIT_IDENTITY="${SHARE_GIT_IDENTITY:-yes}"
SHARE_OPENCODE_AUTH="${SHARE_OPENCODE_AUTH:-yes}"
OPENCODE_AUTH_DIR="${OPENCODE_AUTH_DIR:-$HOME/.local/share/opencode-auth}"
OPENCODE_REFRESH_JOB=homepage-rb.refresh-opencode-auth

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
# the host, read the value from there instead of requiring an export.
resolve_from_1password() {
  local variable="$1"
  local item="$2"
  local account="$3"
  local service="$4"

  if [ -n "${!variable:-}" ] || ! command -v op >/dev/null; then
    return
  fi

  local value

  if value="$(op read "$item" --account="$account" 2>/dev/null)"; then
    export "$variable=$value"
  else
    say "could not read $variable from 1Password;" \
      "the sandbox will have no $service access" >&2
  fi
}

# Writes the skills directory and each directory that its skill symlinks
# point into. sbx mounts a host directory at its host path, so a symlink
# resolves in the sandbox only when sbx also mounts the symlink target.
claude_skill_directories() {
  local entry

  {
    printf '%s\n' "$CLAUDE_SKILLS_DIR"

    for entry in "$CLAUDE_SKILLS_DIR"/*; do
      if [ -L "$entry" ] && [ -d "$entry" ]; then
        (cd "$CLAUDE_SKILLS_DIR" && cd "$(dirname "$(readlink "$entry")")" \
          && pwd)
      fi
    done
  } | sort -u
}

# An earlier version moved ~/.claude/CLAUDE.md into a directory of its own
# and left a symlink at the old path. Put the file back where the human
# keeps it. An editor that rewrites the file through that symlink replaces
# it, which deletes the shared copy and leaves every existing sandbox
# mounting a directory that no longer exists.
restore_moved_claude_instructions() {
  local host_file="$HOME/.claude/CLAUDE.md"
  local moved_dir="$HOME/.claude/instructions"
  local moved_file="$moved_dir/CLAUDE.md"

  if [ ! -L "$host_file" ] \
    || [ "$(readlink "$host_file")" != "$moved_file" ] \
    || [ ! -f "$moved_file" ]; then
    return 0
  fi

  say "restoring $host_file from $moved_file"
  rm -f "$host_file"
  mv -f "$moved_file" "$host_file"
  rmdir "$moved_dir" 2>/dev/null || true
}

# The skills mount carries ~/.claude/skills, so an agent in a sandbox reads
# every skill the host has. It does not carry ~/.claude/CLAUDE.md, and a
# brief that points an agent at that path finds nothing. The rest of
# ~/.claude holds session transcripts and credentials, which must never
# reach a sandbox, and sbx mounts a directory rather than a single file.
# Thus a copy goes into a staging directory of its own, which the caller
# mounts read-only. The host file itself never moves.
#
# The sandbox reads the copy this makes at creation, not a live view of the
# host file. Agent instructions are read once at start, so a snapshot holds.
# Returns 1 when there is no file to share.
stage_host_claude_instructions() {
  local host_file="$HOME/.claude/CLAUDE.md"

  restore_moved_claude_instructions

  if [ ! -f "$host_file" ]; then
    return 1
  fi

  mkdir -p "$CLAUDE_MD_STAGE"
  cp "$host_file" "$CLAUDE_MD_STAGE/CLAUDE.md"
}

# sbx can mount a directory read/write, but not a single file. The rest of
# ~/.local/share/opencode holds a SQLite database, which must not be shared
# between machines. Thus auth.json moves into a directory of its own, and a
# symlink stays at the old path. Returns 1 when there is no login to share.
link_host_opencode_auth() {
  local host_auth="$HOME/.local/share/opencode/auth.json"
  local shared_auth="$OPENCODE_AUTH_DIR/auth.json"

  if [ -L "$host_auth" ]; then
    if [ "$(readlink "$host_auth")" = "$shared_auth" ]; then
      [ -f "$shared_auth" ]
      return
    fi

    say "$host_auth links somewhere other than $shared_auth;" \
      "not sharing opencode logins" >&2
    return 1
  fi

  if [ -f "$host_auth" ]; then
    say "moving $host_auth to $shared_auth, to share it with sandboxes"
  elif [ -f "$shared_auth" ]; then
    say "restoring the symlink from $host_auth to $shared_auth"
  else
    return 1
  fi

  mkdir -p -m 700 "$OPENCODE_AUTH_DIR"

  if [ -f "$host_auth" ]; then
    mv -f "$host_auth" "$shared_auth"
  fi

  mkdir -p "$(dirname "$host_auth")"
  ln -s "$shared_auth" "$host_auth"
}

# launchd gives a job a minimal PATH, which has no Homebrew jq.
render_opencode_refresh_job() {
  local script="$1"
  local job_log="$2"
  local path

  path="$(dirname "$(command -v jq)"):/usr/bin:/bin"

  cat <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$OPENCODE_REFRESH_JOB</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$script</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>$path</string>
    <key>OPENCODE_AUTH_DIR</key>
    <string>$OPENCODE_AUTH_DIR</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>3600</integer>
  <key>StandardOutPath</key>
  <string>$job_log</string>
  <key>StandardErrorPath</key>
  <string>$job_log</string>
</dict>
</plist>
PLIST
}

# launchd runs a copy of the refresh script, so the job keeps working after
# this checkout moves or its worktree is removed. A job is reloaded only when
# its script or its definition changes.
install_opencode_refresh_job() {
  local support_dir="$HOME/Library/Application Support/homepage-rb"
  local script="$support_dir/refresh-opencode-auth"
  local job_file="$HOME/Library/LaunchAgents/$OPENCODE_REFRESH_JOB.plist"
  local job_log="$HOME/Library/Logs/$OPENCODE_REFRESH_JOB.log"
  local domain="gui/$(id -u)"
  local changed=no
  local definition

  if [ "$(uname -s)" != Darwin ] || ! command -v jq >/dev/null; then
    say "cannot install the $OPENCODE_REFRESH_JOB job; sandboxes" \
      "that refresh at the same time can log each other out" >&2
    return 0
  fi

  mkdir -p "$support_dir" "$(dirname "$job_file")" "$(dirname "$job_log")"

  if ! cmp -s "$kit_dir/refresh-opencode-auth" "$script"; then
    cp "$kit_dir/refresh-opencode-auth" "$script"
    chmod 755 "$script"
    changed=yes
  fi

  definition="$(render_opencode_refresh_job "$script" "$job_log")"

  if [ "$definition" != "$(cat "$job_file" 2>/dev/null)" ]; then
    printf '%s\n' "$definition" > "$job_file"
    changed=yes
  fi

  if [ "$changed" = no ] && launchctl print "$domain/$OPENCODE_REFRESH_JOB" \
    >/dev/null 2>&1; then
    return 0
  fi

  say "loading the $OPENCODE_REFRESH_JOB launchd job"
  launchctl bootout "$domain/$OPENCODE_REFRESH_JOB" 2>/dev/null || true
  launchctl bootstrap "$domain" "$job_file"
}

# Sets up, and repairs, everything that shares the opencode logins of the
# host with sandboxes. Returns 1 when there is nothing to share.
share_opencode_auth() {
  if [ "$SHARE_OPENCODE_AUTH" != yes ] || ! link_host_opencode_auth; then
    return 1
  fi

  install_opencode_refresh_job

  if ! OPENCODE_AUTH_DIR="$OPENCODE_AUTH_DIR" \
    bash "$kit_dir/refresh-opencode-auth"; then
    say "the sandbox starts with a ChatGPT login that does not work" >&2
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

# Writes the flags and the workspace paths that create a sandbox. The results
# are global arrays because macOS ships bash 3.2, which has no name
# references.
build_sandbox_argv() {
  local name="$1"
  local directory

  sandbox_paths=("$repo_root")

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

  # Linear and the Claude subscription are optional and, unlike the
  # credential keys above, forward the developer's own host values rather
  # than ones read from a repo file. A Template build sets both FORWARD_
  # settings to no so a cached Template never acquires or carries the
  # builder's Linear or Claude identity.
  if [ "$FORWARD_LINEAR_KEY" = yes ]; then
    resolve_from_1password LINEAR_API_KEY "$LINEAR_OP_ITEM" \
      "$LINEAR_OP_ACCOUNT" Linear

    if [ -n "${LINEAR_API_KEY:-}" ]; then
      sandbox_argv+=(--env LINEAR_API_KEY)
    fi
  fi

  if [ "$FORWARD_CLAUDE_TOKEN" = yes ]; then
    resolve_from_1password CLAUDE_CODE_OAUTH_TOKEN "$CLAUDE_OP_ITEM" \
      "$CLAUDE_OP_ACCOUNT" "Claude subscription"

    if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
      sandbox_argv+=(--env CLAUDE_CODE_OAUTH_TOKEN)
    fi
  fi

  if [ "$SHARE_CLAUDE_SKILLS" = yes ] && [ -d "$CLAUDE_SKILLS_DIR" ]; then
    sandbox_argv+=(--env "HOST_CLAUDE_SKILLS_DIR=$CLAUDE_SKILLS_DIR")

    while IFS= read -r directory; do
      sandbox_paths+=("$directory")
    done < <(claude_skill_directories)
  fi

  if [ "$SHARE_CLAUDE_INSTRUCTIONS" = yes ] \
    && stage_host_claude_instructions; then
    sandbox_argv+=(
      --env
      "HOST_CLAUDE_INSTRUCTIONS_FILE=$CLAUDE_MD_STAGE/CLAUDE.md"
    )
    # The sandbox only reads the copy, so mount it read-only.
    sandbox_paths+=("$CLAUDE_MD_STAGE:ro")
  fi

  if share_opencode_auth; then
    sandbox_argv+=(--env "HOST_OPENCODE_AUTH_FILE=$OPENCODE_AUTH_DIR/auth.json")
    sandbox_paths+=("$OPENCODE_AUTH_DIR")
  fi

  # A clone inherits the repository's config, never the host's ~/.gitconfig,
  # so git inside has no identity and the first commit fails with "empty
  # ident name". Two short strings carry it, so this needs no mount.
  if [ "$SHARE_GIT_IDENTITY" = yes ]; then
    local git_name git_email

    git_name="$(git -C "$repo_root" config --get user.name || true)"
    git_email="$(git -C "$repo_root" config --get user.email || true)"

    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
      sandbox_argv+=(
        --env "HOST_GIT_USER_NAME=$git_name"
        --env "HOST_GIT_USER_EMAIL=$git_email"
      )
    else
      say "the host has no git user.name and user.email;" \
        "commits inside the sandbox will need one" >&2
    fi
  fi
}

create_sandbox() {
  local name="$1"
  shift

  export_credential_keys
  build_sandbox_argv "$name"

  sbx create "${sandbox_argv[@]}" "$@" "${sandbox_paths[@]}"
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

    sbx run "${sandbox_argv[@]}" "$@" "${sandbox_paths[@]}"
    return
  fi

  share_opencode_auth || true

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
