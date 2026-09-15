# Sandbox kit

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit that gives
one agent its own microVM: its own PostgreSQL, its own gems, its own
node modules, and its own port 3000. Two agents that both run the suite
cannot corrupt each other, because they do not share anything.

This directory describes what the kit adds. It is not the whole of what a
sandbox contains: `sbx` supplies the agent and its credentials, and
`.sbx/sandbox` pushes in the developer's own agent configuration.

```
spec.yaml                    network, environment, and the six scripts below
files/home/.sbx-kit/         the scripts, copied to /home/agent in the sandbox
  install-system             apt packages, PostgreSQL, pgvector, Playwright,
                              the linear CLI
  install-toolchain          the Ruby and Node versions .tool-versions pins
  enable-toolchain-path      puts the mise shims on PATH for every shell
  push-agent-config          the developer's own agent configuration
  start-postgres             starts the cluster, on every sandbox start
  prepare-checkout           keys, gems, node modules, databases, assets
sandbox                      the entry point: creates or attaches to a sandbox
build-template               rebuilds the local templates from this kit
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

## Choose an agent

```sh
.sbx/sandbox my-agent --agent claude
.sbx/sandbox my-agent --agent opencode
```

`--agent` takes `shell`, `claude`, or `opencode`, and defaults to
`shell`. A shell sandbox runs no agent: start one from inside it, or
choose it here and let `sbx` install and authenticate it for you.

A sandbox keeps the agent it was created with. `--agent` therefore only
has an effect when the named sandbox does not exist yet; attaching reads
the agent back from the sandbox. Remove the sandbox and create it again
to change its agent.

`claude` and `opencode` are authenticated by the sandbox proxy from the
credentials the host already holds. You never run `/login` inside a
sandbox, and no API key of yours is written into the sandbox. A `shell`
sandbox gets neither, so an agent you install by hand inside one has
nothing to authenticate with.

The proxy can only supply a credential the host has stored. Check with
`sbx secret ls` and add what is missing: `claude` needs `anthropic`, and
`opencode` needs `openai`. Without one, the agent starts and then reports
that `proxy-managed` is an incorrect API key.

`opencode` also refuses to start on an `opencode.json` that does not
match its schema, and the file is copied from the host verbatim. `mcp`
maps a server name straight to its definition, so a `mcp.servers`
wrapper is rejected.

An agent sandbox also gets the developer's own configuration, refreshed
on every run of this script:

| What | Where it lands | How |
| --- | --- | --- |
| Skills | `~/.claude/skills` | `sbx skills import` into its shared store |
| `~/.claude/CLAUDE.md` | same | symlink to the staged copy |
| `~/.claude/agents/` | same | symlink to the staged copy |
| `~/.claude/settings.json` | same | merged, sandbox keys win |
| `~/.claude/plugins/` | same | copied once, on creation |
| `~/.config/opencode/opencode.json` | same | merged with the MCP gateway |
| `~/.config/opencode/commands/`, `plugins/` | same | symlink |

The copy is staged on the host under
`~/.cache/homepage-rb-sbx/agent-config` and mounted read only, so
conversation history, sessions, and file history never reach a sandbox.
The staging step follows symlinks, so a skill that is a link into a
separate source tree arrives as the skill and not as a dangling link.

Two things this does not do. Skills go into a machine-global store that
`sbx` shares with every sandbox on the host, not only this repository's.
And `sbx skills` is marked experimental, so it may change.

Some of the copied configuration cannot work inside a sandbox, and is
copied anyway rather than maintained as a transform over a personal file:
`opencode.json` names a remote MCP server on a host the network policy
denies, and two model providers on `localhost` that resolve to the
sandbox rather than to the host. Plugin-defined MCP servers may also fail
to start. None of this stops the agent; it makes startup slower and those
features unavailable.

## Extra arguments

Extra arguments reach `sbx`, so `.sbx/sandbox my-agent -p 3000:3000`
publishes port 3000 at creation. To publish one later, use
`sbx ports my-agent --publish 3000:3000`. A bare `3000` names the
sandbox port and leaves the host port to `sbx`, which picks a free one.

`--clone` gives the sandbox a private clone rather than a bind mount.
Commits made inside come back with `git fetch sandbox-my-agent`.

The production credential key stays on the host. A sandbox gets the
development and test keys and nothing else.

## Linear

Every sandbox has the `linear` CLI on `PATH`. Creation forwards it a
Linear API key from the first of these that has one:

1. `LINEAR_API_KEY`, if exported on the host.
2. Otherwise, the 1Password CLI, if `op` is on the host:
   `op read "$LINEAR_OP_ITEM" --account="$LINEAR_OP_ACCOUNT"`. Override
   `LINEAR_OP_ITEM` / `LINEAR_OP_ACCOUNT` to point at a different vault
   item; both default to this project's own key.

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

## Build the templates

```sh
./.sbx/build-template
./.sbx/build-template claude
```

Creating a sandbox from scratch installs a toolchain; creating one from
a template does not. A template holds the toolchain and the gem and npm
caches, and no repository state, so a branch change never makes it
stale. It is a local cache, rebuildable on any Mac from this directory,
and is never shared as a file.

There is one template per agent, tagged `homepage-rb:shell`,
`homepage-rb:claude`, and `homepage-rb:opencode`, because `sbx` refuses
a template built for one agent to a sandbox for another. With no
arguments `build-template` builds all three, which takes about a quarter
of an hour each; name agents to build only those.

`build-template` only saves a template from a sandbox whose suite is
green. Set `KEEP_SANDBOXES=yes` to leave the build sandbox behind for
inspection when the suite fails.

A build sandbox gets no Linear key, no agent config, and no skills: it is
created with `--no-share-skills`, so `sbx` does not even mount its shared
skills store into it. The login `sbx` injects is deleted before the
template is saved. A template is therefore a pure product of the kit and
carries nothing personal.

`TEMPLATE_TAG` used to default to `homepage-rb:latest`, for a single
template. A template saved under the old tag no longer matches any agent
and is not used; remove it with `sbx template rm` and build the new ones.
The entry point says so when the template it wants is missing.

## Settings

`host-lib.sh` reads these from the environment:

| Name | Default | Meaning |
| --- | --- | --- |
| `AGENT` | `shell` | Agent to run; `--agent` sets it |
| `TEMPLATE_REPOSITORY` | `homepage-rb` | Repository half of the template tag |
| `TEMPLATE_TAG` | `$TEMPLATE_REPOSITORY:$AGENT` | Template to start from |
| `SANDBOX_CPUS` | `4` | CPUs per sandbox |
| `SANDBOX_MEMORY` | `8g` | Memory per sandbox |
| `READY_TIMEOUT` | `1800` | Seconds to wait for provisioning |
| `SUITE_ATTEMPTS` | `3` | Suite runs `build-template` will try |
| `KEEP_SANDBOXES` | `no` | Leave sandboxes behind instead of removing |
| `PUSH_AGENT_CONFIG` | `yes` | Stage and push the agent config |
| `IMPORT_SKILLS` | `yes` | Import host skills, and mount them |
| `AGENT_CONFIG_STAGE` | `~/.cache/homepage-rb-sbx/agent-config` | Staged copy |

The defaults for CPU and memory are deliberate. Left alone, `sbx` gives
one sandbox every host CPU and half the host's memory, which two
concurrent sandboxes cannot share.

Plugins are staged once and then copied once, because the plugin
directory is two orders of magnitude larger than the rest of the agent
config combined and re-copying it would slow down every attach. Delete
`~/.cache/homepage-rb-sbx/agent-config` to pick up a plugin change.
