# Sandbox kit

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit that gives
one agent its own microVM: its own PostgreSQL, its own gems, its own
node modules, and its own port 3000. Two agents that both run the suite
cannot corrupt each other, because they do not share anything.

This directory is the only source of truth for what a sandbox contains.

```
spec.yaml                    network, environment, and the six scripts below
files/home/.sbx-kit/         the scripts, copied to /home/agent in the sandbox
  install-system             apt packages, PostgreSQL, pgvector, Playwright,
                              the linear, claude, and opencode CLIs
  install-toolchain          the Ruby and Node versions .tool-versions pins
  enable-toolchain-path      puts the mise shims on PATH for the agent
  configure-claude           lets claude use a forwarded subscription token
  link-claude-skills         gives claude the host's skills
  link-opencode-auth         gives opencode the host's logins
  start-postgres             starts the cluster, on every sandbox start
  prepare-checkout           keys, gems, node modules, databases, assets
sandbox                      the entry point: creates or attaches to a sandbox
build-template               rebuilds the local template from this kit
refresh-opencode-auth        keeps the shared ChatGPT login fresh
host-lib.sh                  shared helpers for sandbox and build-template
```

`.sbx/sandbox` is the entry point; everything else here supports it.

## Create a sandbox

```sh
.sbx/sandbox my-agent
```

This creates the sandbox and attaches to it. Run it again with the same
name to re-enter that sandbox rather than build a second one. The name
is required, and `sbx` accepts only letters, numbers, hyphens, and
periods.

The sandbox runs a shell. Run `claude` or `opencode` from inside it; see
[Agents](#agents) below.

### Wait for a sandbox without attaching

```sh
.sbx/sandbox --wait my-agent
```

This creates the sandbox, or starts it when it is stopped, waits for the
startup scripts to finish, and exits. It never attaches. Run it before a
script or an agent starts work in a sandbox.

`sbx` reports a sandbox as running before the startup scripts install the
dependencies and prepare the databases, and a command that starts at that
moment races them. `--wait` returns only once the checkout is ready. When
the sandbox fails to become ready, it prints the startup log and returns
1.

Extra arguments reach `sbx`, so `.sbx/sandbox my-agent -p 3000:3000`
publishes port 3000 at creation. To publish one later, use
`sbx ports my-agent --publish 3000:3000`. A bare `3000` names the
sandbox port and leaves the host port to `sbx`, which picks a free one.

Every sandbox gets a private clone of the checkout, never a bind mount.
The clone sits at the same absolute path as the host checkout, so a path
names the same file on both sides, but a write inside the sandbox never
reaches the host. Commits made inside come back with
`git fetch sandbox-my-agent`; creation adds that remote, and `sbx rm`
removes it again.

`sbx` refuses to clone a git worktree, so create a sandbox from the main
checkout.

The production credential key stays on the host. A sandbox gets the
development and test keys and nothing else.

## Agents

Every sandbox has `claude` and `opencode` on `PATH`. The kit installs the
binaries and no agent-specific configuration. `claude` uses your Claude
subscription when creation forwards a token; see
[Claude subscription](#claude-subscription) below. `opencode` uses the
host's logins; see [opencode logins](#opencode-logins) below.

`install-system` asks for the newest published version of each on every
run, so a sandbox creation that finds its template already current starts
in seconds. When a newer release exists, that sandbox installs it at
creation and pays the download. Rebuild the template to make creation
fast again.

## Linear

Every sandbox has the `linear` CLI on `PATH`. Creation forwards it a
Linear API key from the first of these that has one:

1. `LINEAR_API_KEY`, if exported on the host.
2. Otherwise, the 1Password CLI, if `op` is on the host:
   `op read "$LINEAR_OP_ITEM" --account="$LINEAR_OP_ACCOUNT"`. Override
   `LINEAR_OP_ITEM` / `LINEAR_OP_ACCOUNT` to point at a different vault
   item; both default to this project's own key.

```sh
.sbx/sandbox my-agent
```

This is the real key, not a host-only proxy like the GitHub credential:
the sandbox can do anything that key can do. Neither source is required;
with no export and no usable 1Password entry, the sandbox still comes
up, just without Linear access. `linear` reports its own missing- or
invalid-credential error in that case.

Attaching to an existing sandbox reuses whatever key it was created
with; it does not re-resolve either source. Recreate the sandbox
(`sbx rm` it, then run `.sbx/sandbox` again) to pick up a changed key,
or to add Linear to a sandbox created before this CLI existed in the
kit.

## Claude subscription

Creation forwards `claude` a subscription token, as
`CLAUDE_CODE_OAUTH_TOKEN`, from the first of these that has one:

1. `CLAUDE_CODE_OAUTH_TOKEN`, if exported on the host.
2. Otherwise, the 1Password CLI, if `op` is on the host:
   `op read "$CLAUDE_OP_ITEM" --account="$CLAUDE_OP_ACCOUNT"`. Override
   `CLAUDE_OP_ITEM` / `CLAUDE_OP_ACCOUNT` to point at a different vault
   item; both default to the owner's token.

Generate a token with `claude setup-token`. It lasts a year.

A `shell` sandbox sets `ANTHROPIC_API_KEY=proxy-managed`, and the `sbx`
proxy fills that placeholder only from a stored Anthropic API key, never
from a stored subscription login. `claude` prefers `ANTHROPIC_API_KEY`
to the token, so without a stored API key it reports
`Invalid API key · Fix external API key`. `configure-claude` unsets the
placeholder in every shell of a sandbox that has a token.

An interactive `claude` also ignores the token until its onboarding is
complete, and that onboarding ends with a login. `configure-claude`
marks onboarding complete and trusts the workspace in
`~/.claude.json`, so a session starts at the prompt.

Like the Linear key, this is the real token, not a host-only proxy: the
sandbox can spend your subscription, and the token is readable inside
it. With no token from either source, the sandbox still comes up and
`claude` asks you to log in. Attaching to an existing sandbox reuses the
token it was created with; recreate the sandbox to pick up a new one.

## Claude skills

Creation mounts `~/.claude/skills` from the host into the sandbox at its
host path, and `link-claude-skills` points the agent's
`~/.claude/skills` at it. A skill that is a symlink resolves in the
sandbox too: creation also mounts each directory the symlinks in
`~/.claude/skills` point into, such as the skillshare source. Set
`CLAUDE_SKILLS_DIR` to share a different directory, or
`SHARE_CLAUDE_SKILLS=no` to share none.

The mounts are live, so a skill added or changed on the host appears in
every sandbox without a recreate. The mounts are writable in both
directions, so a skill refined from inside a sandbox changes on the host
too. That also means an agent in the sandbox can change a skill that
`claude` on the host later runs, outside the sandbox; review skill edits
before you use them on the host.

Only a symlink target that exists at creation is mounted; a skill that
links into a new directory needs a recreated sandbox.

`sbx skills import` does not help here: only the agent-specific
sandboxes, such as `sbx create claude`, mount its store, and a `shell`
sandbox does not.

## opencode logins

Log in with `opencode` on the host, and every sandbox that `.sbx/sandbox`
creates after that uses the same logins. This includes a ChatGPT
subscription login made with `/connect`, which `sbx` itself cannot give a
`shell` sandbox.

`sbx` mounts directories, not single files, and the rest of
`~/.local/share/opencode` holds a SQLite database that must not be shared
between machines. So `.sbx/sandbox` moves
`~/.local/share/opencode/auth.json` into `~/.local/share/opencode-auth/`,
leaves a symlink at the old path, and mounts that directory. In the
sandbox, `link-opencode-auth` points the agent's `auth.json` at it.

The mount is live and writable, and `opencode` reads `auth.json` before
each request. A token that one sandbox refreshes reaches the host and
every other sandbox.

OpenAI accepts a refresh token one time only, and `opencode` refreshes a
token only after it expires. Two `opencode` processes that find an expired
token at the same time send the same refresh token, and one of them fails.
To prevent this, the launchd job `homepage-rb.refresh-opencode-auth` runs
`refresh-opencode-auth` every hour, and `.sbx/sandbox` runs it before each
sandbox. It refreshes the ChatGPT login when it expires in less than a
day. Its log is `~/Library/Logs/homepage-rb.refresh-opencode-auth.log`.

Every run of `.sbx/sandbox` repairs this setup: it restores a missing
symlink, moves a new host `auth.json` back into the shared directory, and
reinstalls the job when the job is missing or out of date. The job runs a
copy of the script in `~/Library/Application Support/homepage-rb/`, so it
keeps working after a checkout moves or a worktree is removed.

What no script can repair is a login that OpenAI revokes. The job log
then says so; log in again with `/connect` in `opencode` on the host.

Like the Claude token, these are real credentials. Every login in
`auth.json`, not only ChatGPT, is readable and writable inside the
sandbox, and a `/connect` or a logout in a sandbox changes the host too.
Set `SHARE_OPENCODE_AUTH=no` to share nothing. A sandbox that was created
without the mount needs a recreate to get it.

## Build the template

```sh
./.sbx/build-template
```

Creating a sandbox from scratch installs a toolchain; creating one from
the template does not. The template holds the toolchain and the gem and
npm caches, and no repository state, so a branch change never makes it
stale. It is a local cache, rebuildable on any Mac from this directory,
and is never shared as a file.

`build-template` only saves a template from a sandbox whose suite is
green. Set `KEEP_SANDBOXES=yes` to leave the build sandbox behind for
inspection when the suite fails.

The build never resolves or forwards a Linear key or a Claude token,
from either source above, and never mounts the builder's skills or
opencode logins, so the saved template never carries the builder's own
Linear, Claude, or opencode identity.

## Settings

`host-lib.sh` reads these from the environment:

| Name | Default | Meaning |
| --- | --- | --- |
| `TEMPLATE_TAG` | `homepage-rb:latest` | Template to build and to start from |
| `SANDBOX_CPUS` | `4` | CPUs per sandbox |
| `SANDBOX_MEMORY` | `8g` | Memory per sandbox |
| `READY_TIMEOUT` | `1800` | Seconds to wait for provisioning |
| `SUITE_ATTEMPTS` | `3` | Suite runs `build-template` will try |
| `KEEP_SANDBOXES` | `no` | Leave sandboxes behind instead of removing |
| `SHARE_CLAUDE_SKILLS` | `yes` | Mount the host's Claude skills |
| `CLAUDE_SKILLS_DIR` | `~/.claude/skills` | Host skills directory to mount |
| `SHARE_OPENCODE_AUTH` | `yes` | Mount the host's opencode logins |
| `OPENCODE_AUTH_DIR` | `~/.local/share/opencode-auth` | Host opencode login directory |

The defaults for CPU and memory are deliberate. Left alone, `sbx` gives
one sandbox every host CPU and half the host's memory, which two
concurrent sandboxes cannot share.
