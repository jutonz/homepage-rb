set -Eeuo pipefail

SOURCE_DIR="${SOURCE_DIR:-/run/sandbox/source}"
POSTGRES_MAJOR=18
AGENT_MISE_SHIMS=/home/agent/.local/share/mise/shims

# The status file lives on a tmpfs, so a sandbox created from a template never
# starts out claiming to be ready because the template froze a "ready" from the
# machine that built it. The host side reads the same path; see
# .sbx/host-lib.sh.
status_file() {
  local status_dir="/run/user/$(id -u)"

  mkdir -p "$status_dir"
  printf '%s\n' "$status_dir/sbx-kit-status"
}

say() {
  printf '[homepage-rb kit] %s\n' "$*"
}

repo_file() {
  local relative_path="$1"

  if [ -n "${WORKSPACE_DIR:-}" ] && [ -f "$WORKSPACE_DIR/$relative_path" ]; then
    printf '%s\n' "$WORKSPACE_DIR/$relative_path"
    return 0
  fi

  if [ -f "$SOURCE_DIR/$relative_path" ]; then
    printf '%s\n' "$SOURCE_DIR/$relative_path"
    return 0
  fi

  say "cannot find $relative_path in the checkout or in $SOURCE_DIR" >&2
  return 1
}

tool_version() {
  local tool="$1"

  awk -v tool="$tool" '$1 == tool { print $2 }' "$(repo_file .tool-versions)"
}

playwright_version() {
  node -e '
    const fs = require("fs");
    const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const range = pkg.devDependencies.playwright;
    process.stdout.write(range.replace(/^[^0-9]*/, ""));
  ' "$(repo_file package.json)"
}

bundler_version() {
  awk '/^BUNDLED WITH$/ { getline; gsub(/ /, ""); print; exit }' \
    "$(repo_file Gemfile.lock)"
}
