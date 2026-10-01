# Sandbox kit

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit that gives
one agent its own microVM: its own PostgreSQL, its own gems, its own
node modules, and its own port 3000. Two agents that both run the suite
cannot corrupt each other, because they do not share anything.

This directory holds what is particular to homepage-rb. The agent CLIs,
the host's credentials, skills, instructions, and logins, and the host
scripts that create and wait for a sandbox live in the shared kit at
`~/.config/skillshare/skills/_sbx-kit/`. Its README describes them, and
the contract this directory follows.

```
spec.yaml                    network, environment, and the scripts below
files/home/.sbx-kit/         the scripts, copied to /home/agent in the sandbox
  install-system             apt packages, PostgreSQL, pgvector, mise,
                              Playwright
  install-toolchain          the Ruby and Node versions .tool-versions pins
  enable-toolchain-path      puts the mise shims on PATH for the agent
  start-postgres             starts the cluster, on every sandbox start
  prepare-checkout           keys, gems, node modules, databases, assets
host-lib.sh                  settings, then the shared host-lib.sh
sandbox                      the entry point: creates or attaches to a sandbox
build-template               rebuilds the local template from both kits
```

`.sbx/sandbox` is the entry point; everything else here supports it. It
fails at once when the shared kit is missing; set `SBX_KIT_DIR` to a copy
in another place.

## Create a sandbox

```sh
.sbx/sandbox my-agent
```

This creates the sandbox and attaches to it. Run it again with the same
name to re-enter that sandbox rather than build a second one. The name
is required, and `sbx` accepts only letters, numbers, hyphens, and
periods.

The sandbox runs a shell. Run `claude` or `opencode` from inside it.

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

## Build the template

```sh
./.sbx/build-template
```

Creating a sandbox from scratch installs a toolchain; creating one from
the template does not. The template holds the toolchain and the gem and
npm caches, and no repository state, so a branch change never makes it
stale. It is a local cache, rebuildable on any Mac from both kits, and is
never shared as a file. The build saves nothing unless `bin/rspec`
passes; the shared README has the details.

## Settings

`host-lib.sh` sets these defaults, and the shared kit reads the rest:

| Name | Default | Meaning |
| --- | --- | --- |
| `TEMPLATE_TAG` | `homepage-rb:latest` | Template to build and to start from |
| `SBX_KIT_DIR` | `~/.config/skillshare/skills/_sbx-kit` | The shared kit |
