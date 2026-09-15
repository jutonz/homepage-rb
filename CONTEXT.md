# Context

Shared vocabulary for this codebase. Use these terms in code, specs,
issues, and commit messages; prefer them over the synonyms each entry
lists as avoided.

## Authentication

**API token** — the credential that authenticates one API request,
stored as an `Api::Token` and sent in the `Authorization` header. It
authenticates the request that carries it and nothing further: the API
never exchanges it for a cookie, so a client authenticating by token
sends it on every request, and revoking the token ends the access it
granted. See
[ADR 0002](docs/adr/0002-stateless-api-token-authentication.md).

*Avoid*: "bearer token" and "API key". *Bearer* names the header scheme
that carries the credential, not the credential itself.

**Browser session** — the authenticated state a browser client carries
in its session cookie, established at the OAuth callback and resolved
back to a user on each request. It authenticates API requests as readily
as HTML ones, and several API specs rely on that. What an API token
cannot do is create one.

*Avoid*: "session" unqualified. It has three senses here: the Rails
session hash, this, and the `/session` sign-in resource that
`SessionsController` serves.

## Authorization

**Policy** — the authorization rules governing one model. One class per
model under `app/policies/`, named for the model it governs
(`GalleryPolicy` governs `Gallery`). Its predicates — `show?`, `update?`,
`destroy?` — answer whether a user may act on a single record.

**Policy scope** — the subset of a model's records a given user may see,
obtained from `Policy.scope_for(user)`. Where a policy's predicates answer
a question about one record, its policy scope answers the same question
about all of them at once.

*Avoid*: "scope" unqualified, and "Scope class". Both are load-bearing
elsewhere. An unqualified "scope" is an ActiveRecord relation or Warden's
authentication scope, `:user` (`config/initializers/warden.rb`).
`Policy::Scope` was the Pundit construct `scope_for` replaced; HPRB-48
deleted it, and its `scope` attribute confusingly held a model class
rather than a scope of any kind. See
[ADR 0001](docs/adr/0001-typed-policy-scopes.md).

**Model** — the ActiveRecord class a policy governs, available as
`Policy.model`. Inferred from the policy's own name, so a policy whose
name does not name its model overrides it.

## Databases

**Primary database** — the database holding every model this codebase
defines: users, galleries, images, tags, todos. When something here says
"the database" without qualifying it, this is the one.

*Avoid*: "the jobs table" for the primary database's `solid_queue_*`
tables. They are a dead copy left behind when the queue database was
split out, and nothing reads them. HPRB-115 removes them.

**Queue database** — the database Solid Queue owns, holding queued jobs,
their executions, and the recurring task schedule. It is authoritative
for background work: a job the application enqueues lands here, never in
the primary database.

**Cable database** — the database Action Cable owns, holding the pubsub
messages it relays between processes.

## Development environments

**Sandbox** — the microVM `sbx` creates, holding its own kernel, file
system, PostgreSQL, gems, and port 3000. Two sandboxes share nothing, so
two agents can run the suite at once without corrupting each other's
data. `.sbx/sandbox` creates one, running the agent it is asked for.

*Avoid*: "container". A sandbox runs its own kernel, and the difference
decides what it does and does not isolate.

**Attach** — opening an additional shell in a sandbox that already
exists. `.sbx/sandbox` attaches when the named sandbox is present, and
creates when it is not. A stopped sandbox starts first, then accepts the
shell. One sandbox serves any number of attached shells at once.

**Worktree** — the git-linked checkout under `.claude/worktrees/`, made
by `git worktree` and prepared by `bin/worktree-setup`. It isolates the
files an agent edits and nothing more: the databases, port 3000, and the
installed gems stay shared. A sandbox isolates what a worktree cannot.

*Avoid*: "workspace" for a worktree, and for a provisioned machine.
`sbx` uses *workspace* for the host directory it mounts, and
`WORKSPACE_DIR` inside a sandbox names that directory, so the word is
reserved for that sense. The deleted `bin/workspace_setup.sh` used it
for a machine, which is part of what made it ambiguous.

**Agent** — the program a sandbox runs: `shell`, `claude`, or
`opencode`. `.sbx/sandbox --agent` chooses one, and `shell` is the
default. `sbx` supplies the agent and its credentials; the kit supplies
everything the application needs. Two people who choose the same agent
get the same tools.

*Avoid*: "agent" for the person or session doing the work when a sandbox
is in the sentence. `.sbx/sandbox NAME` takes a sandbox name, and naming
it after the worker is what makes the two senses collide.

**Kit** — the checked-in `.sbx/` directory, describing what the kit adds
to an agent's sandbox: packages, toolchain, databases, and the network
allowlist. One kit serves every agent. It is not the whole of what a
sandbox contains, because `sbx` brings the agent and the host pushes in
the agent config.

**Agent config** — the developer's own, personal, never-committed agent
configuration on the host: skills, the global `CLAUDE.md`,
`settings.json`, `agents/`, `plugins/`, and `opencode.json`.
`.sbx/sandbox` pushes it into the sandbox at startup, so an agent in a
sandbox behaves the way it does on the developer's machine. It is the
reason two people running the same kit get the same tools and different
agent setups.

*Avoid*: "agent config" for anything in the repository. The whole point
of the term is that it lives on the host and is personal.

**Template** — the local image holding an already provisioned toolchain,
so that a new sandbox starts in seconds rather than minutes. It is a
cache and never a shipped artifact: `.sbx/build-template` rebuilds it
from the kit, and it holds no repository state, so a branch change never
makes it stale. A template belongs to one agent and is refused for
another, so there is one per agent and the tag names it:
`homepage-rb:claude`.

*Avoid*: "snapshot". It names the same object, and `sbx`, the script,
and `TEMPLATE_TAG` all say *template*.

## Galleries

**Tag filter** — the tag set that narrows which of a gallery's images
are shown. The sidebar on a gallery page edits it. Filtering changes
what the viewer sees; it never changes what an image is tagged with.

**Tag search** — the lookup that finds a tag to attach to something. The
bulk tag dialog, the bulk-upload tag dialog, the per-image tag form, and
the auto-add tag picker each run one. Searching changes what something is
tagged with; it never changes which images the gallery shows.

*Avoid*: "tag search" for the sidebar. Both controls submit the same
`tag_search[query]` parameter to the same `Galleries::TagSearch`, so
the code gives them one name, but they answer different questions.
HPRB-59 arose from that conflation. Since those implementations were
unified they also share `Galleries::TagSearches::ResultsComponent`, so a
`:gallery` branch inside a component named for tag searches is expected.

**Tag search mode** — the surface a tag search serves. The mode names
one caller: the per-image tag form, the gallery sidebar, the bulk-upload
dialog, the bulk tag dialog, or the auto-add picker. It decides which
action the viewer gets beside each result. A new surface adds a mode; it
does not change what the other modes offer.

**Auto-add source** — the tag that triggers an auto-add. Adding it to an
image also adds the auto-add tag.

**Auto-add tag** — the tag that an auto-add applies.

*Avoid*: "auto tag". `BackfillAutoTagsJob` still carries that older name;
HPRB-65 renames it.

**Auto-add rule** — the pairing of one auto-add source with one auto-add
tag. `Galleries::AutoAddTag` is the rule.

*Avoid*: "auto-add tag" for the rule. The class and the `auto_add_tag`
association it holds share one word, and that is what causes the
confusion.
