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
