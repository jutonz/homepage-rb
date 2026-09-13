# typed: false

# Components must not overlap. A file that matches two components counts
# as a consumer under both names, so a broad "app/**/*.rb" component
# makes every layer rule fail against itself.
component(:controllers, in: "app/controllers/**/*.rb")
component(:components, in: "app/components/**/*.rb")
component(:jobs, in: "app/jobs/**/*.rb")
component(:models, in: "app/models/**/*.rb")
component(:policies, in: "app/policies/**/*.rb")
component(:queries, in: "app/queries/**/*.rb")

policies.can_only_be_used_by(
  :controllers,
  because: "controllers own authorization; other layers receive records " \
    "that a policy scope has already filtered"
)

components.cannot_use(
  :controllers,
  because: "dependencies point away from the HTTP layer"
)

jobs.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

models.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

queries.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

# ArchSpec merges every cannot_call on one component into a single rule
# that carries one reason, so each layer below gets exactly one call.
#
# Sorbet's `sig do params(...) end` is indistinguishable from
# ActionController's `params` here, so `params` cannot join these lists.
http_response = %i[render redirect_to session cookies]

controllers.cannot_call(
  :policy_scope,
  because: "HPRB-48 replaced policy_scope with Policy.scope_for"
)

components.cannot_call(
  :policy_scope,
  because: "HPRB-48 replaced policy_scope with Policy.scope_for"
)

jobs.cannot_call(
  *http_response, :policy_scope,
  because: "jobs do not own the HTTP response, and HPRB-48 replaced " \
    "policy_scope with Policy.scope_for"
)

policies.cannot_call(
  *http_response, :policy_scope,
  because: "policies do not own the HTTP response, and HPRB-48 replaced " \
    "policy_scope with Policy.scope_for"
)

queries.cannot_call(
  *http_response, :policy_scope,
  because: "queries do not own the HTTP response, and HPRB-48 replaced " \
    "policy_scope with Policy.scope_for"
)

models.cannot_call(
  *http_response, :perform_later, :policy_scope,
  because: "models own neither the HTTP response nor job enqueueing, and " \
    "HPRB-48 replaced policy_scope with Policy.scope_for"
)
