# Context

Shared vocabulary for this codebase. Use these terms in code, specs,
issues, and commit messages; prefer them over the synonyms each entry
lists as avoided.

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
elsewhere. An unqualified "scope" is an ActiveRecord relation, and
`Policy::Scope` is the Pundit construct `scope_for` replaces — it survives
only until HPRB-48 deletes it, and its `scope` attribute confusingly holds
a model class rather than a scope of any kind. See
[ADR 0001](docs/adr/0001-typed-policy-scopes.md).

**Model** — the ActiveRecord class a policy governs, available as
`Policy.model`. Inferred from the policy's own name, so a policy whose
name does not name its model overrides it.
