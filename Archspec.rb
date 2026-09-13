# typed: false

# A file that matches two components counts as a consumer under both
# names. Components that overlap must therefore carry no dependency rule
# (cannot_use, can_only_be_used_by), and a broad "app/**/*.rb" component
# makes every layer rule fail against itself.
component(:channels, in: "app/channels/**/*.rb")
component(:components, in: "app/components/**/*.rb")
component(:controllers, in: "app/controllers/**/*.rb")
component(:forms, in: "app/forms/**/*.rb")
component(:helpers, in: "app/helpers/**/*.rb")
component(:jobs, in: "app/jobs/**/*.rb")
component(:mailers, in: "app/mailers/**/*.rb")
component(:models, in: "app/models/**/*.rb")
component(:policies, in: "app/policies/**/*.rb")
component(:queries, in: "app/queries/**/*.rb")
component(:services, in: "app/services/**/*.rb")

# concrete_jobs overlaps jobs on purpose. It carries only must_implement,
# which reads each file alone and counts no consumers.
component(
  :concrete_jobs,
  in: "app/jobs/**/*.rb",
  except: "app/jobs/application_job.rb"
)

services.must_be_empty(
  because: "this app keeps creator POROs in app/models; a services " \
    "directory needs a deliberate decision, not drift"
)

concrete_jobs.must_implement(
  :perform,
  because: "Active Job calls perform on every job it runs"
)

policies.can_only_be_used_by(
  :controllers,
  because: "controllers own authorization; other layers receive records " \
    "that a policy scope has already filtered"
)

channels.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

components.cannot_use(
  :controllers,
  because: "dependencies point away from the HTTP layer"
)

forms.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

helpers.cannot_use(
  :models,
  because: "helpers format values that a caller already loaded"
)

jobs.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

mailers.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

models.cannot_use(
  :controllers, :components,
  because: "dependencies point away from the HTTP layer"
)

queries.cannot_use(
  :controllers, :components, :policies,
  because: "dependencies point away from the HTTP layer, and controllers " \
    "own authorization"
)

# ArchSpec merges every cannot_call on one component into a single rule
# that carries one reason. A second call with a different reason raises
# "the same rule cannot have two reasons", so each layer below gets
# exactly one call.
#
# Sorbet's `sig do params(...) end` is indistinguishable from
# ActionController's `params` here, so `params` cannot join these lists.
http_response = %i[render redirect_to session cookies]

writes = %i[
  save save! update update! destroy destroy_all delete_all create create!
]

controllers.cannot_call(
  :policy_scope,
  because: "HPRB-48 replaced policy_scope with Policy.scope_for"
)

components.cannot_call(
  :policy_scope, *writes,
  because: "components render state that a caller already saved, and " \
    "HPRB-48 replaced policy_scope with Policy.scope_for"
)

jobs.cannot_call(
  *http_response, :policy_scope,
  because: "jobs do not own the HTTP response, and HPRB-48 replaced " \
    "policy_scope with Policy.scope_for"
)

policies.cannot_call(
  *http_response, :policy_scope, *writes,
  because: "policies answer questions; they own neither the HTTP " \
    "response nor a write, and HPRB-48 replaced policy_scope with " \
    "Policy.scope_for"
)

queries.cannot_call(
  *http_response, :policy_scope, *writes,
  because: "queries read; they own neither the HTTP response nor a " \
    "write, and HPRB-48 replaced policy_scope with Policy.scope_for"
)

models.cannot_call(
  *http_response, :perform_later, :policy_scope, :find_by_sql,
  because: "models own neither the HTTP response nor job enqueueing, " \
    "find_by_sql returns unscoped rows, and HPRB-48 replaced " \
    "policy_scope with Policy.scope_for"
)

components.method_names.matching(/\A(get|set)_/).forbidden(
  because: "a Ruby reader takes the name of the value it returns"
)

models.method_names.matching(/\A(get|set)_/).forbidden(
  because: "a Ruby reader takes the name of the value it returns"
)

policies.method_names.matching(/\A(get|set)_/).forbidden(
  because: "a Ruby reader takes the name of the value it returns"
)

queries.method_names.matching(/\A(get|set)_/).forbidden(
  because: "a Ruby reader takes the name of the value it returns"
)
