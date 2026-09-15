# Sandbox kit

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit that gives
one agent its own microVM: its own PostgreSQL, its own gems, its own
node modules, and its own port 3000. Two agents that both run the suite
cannot corrupt each other, because they do not share anything.

This directory is the only source of truth for what a sandbox contains.

```
spec.yaml                    network, environment, and the four scripts below
files/home/.sbx-kit/         the scripts, copied to /home/agent in the sandbox
  install-system             apt packages, PostgreSQL, pgvector, Playwright
  install-toolchain          the Ruby and Node versions .tool-versions pins
  start-postgres             starts the cluster, on every sandbox start
  prepare-checkout           keys, gems, node modules, databases, assets
build-template               rebuilds the local template from this kit
host-lib.sh                  shared helpers for bin/sandbox and build-template
```

`bin/sandbox` is the entry point; everything else here supports it.

## Create a sandbox

```sh
bin/sandbox my-agent
```

This creates the sandbox and attaches to it. Run it again with the same
name to re-enter that sandbox rather than build a second one. The name
is required, and `sbx` accepts only letters, numbers, hyphens, and
periods.

The sandbox runs a shell. Run `claude`, or any other agent, from inside
it; the kit carries no agent-specific configuration.

Extra arguments reach `sbx`, so `bin/sandbox my-agent -p 3000` publishes
port 3000 at creation. To publish one later, use
`sbx ports my-agent --publish 3000`.

`--clone` gives the sandbox a private clone rather than a bind mount.
Commits made inside come back with `git fetch sandbox-my-agent`.

The production credential key stays on the host. A sandbox gets the
development and test keys and nothing else.

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

The defaults for CPU and memory are deliberate. Left alone, `sbx` gives
one sandbox every host CPU and half the host's memory, which two
concurrent sandboxes cannot share.
