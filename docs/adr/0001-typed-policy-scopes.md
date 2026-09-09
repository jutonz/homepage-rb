# 1. Typed policy scopes via `Policy.scope_for`

Date: 2026-09-09

## Status

Accepted.

## Context

Controllers reached the records a user may see through Pundit's
`policy_scope(Model)` helper — 71 call sites across 39 controllers.

That helper has no Sorbet signature, so everything downstream of it is
`T.untyped`. `policy_scope(Gallery).find(params[:id]).nmae` typechecks
clean and blows up in production, and it does so in authorization-adjacent
code, which is the code least able to afford a silent hole. Thirty-five of
those call sites are record lookups whose result is then used as a model.

The untypedness cannot be fixed where it lives. A signature for
`policy_scope` would have to say "given `Gallery`, return `Gallery`'s
relation type" — type-level member access on a type parameter, which
Sorbet has no syntax for. Removing the helper is therefore a prerequisite
for typing these lookups, not an alternative to it.

Instantiating the policy's `Scope` class directly at the call site does
not help either. It buys no type safety on its own, and Sorbet refuses
`GalleryPolicy::Scope` outright: it does not walk ancestors for constant
lookup the way Ruby does, and only 14 of 31 policies define their own
`Scope`, so 50 of the 71 call sites name a policy that inherits one.

## Decision

**Every policy answers `scope_for(user)`.** It returns the records that
user may see, replacing `policy_scope(Model)` and the nested `Scope`
class both. `UserOwnedPolicy` supplies the owner-filtered implementation
that most policies want; the seven with a bespoke query define their own.

**The model is inferred from the policy's class name**, not declared:
`GalleryPolicy` governs `Gallery`. Verified against all sixteen policies
that need it. `ApplicationPolicy.model` is overridable for the cases
where the name does not map — `Galleries::Books::ReadPolicy` governs a
`Galleries::Book`.

**The narrow return types live in a Sorbet shim**, not in app code. The
signature on the method itself is the widest true one,
`ActiveRecord::Relation`; `sorbet/rbi/shims/policy_scope_for.rbi` declares
the per-policy `Model::PrivateRelation` that Sorbet actually resolves.

`PrivateRelation` is a Tapioca fiction with no runtime constant behind it,
so an inline signature naming it would have to be wrapped in
`T::Sig::WithoutRuntime` to stay callable. Putting the narrow types in the
shim instead keeps runtime signature checking on for every policy and
keeps the policy classes free of typing boilerplate — they read as
authorization rules, not as type declarations.

The shim carries an entry for all sixteen policies, including the seven
that define `scope_for` in app code because their query is bespoke. The
design this ADR implements expected a 7005 conflict there — a narrowing
declaration on top of a local definition — and planned to leave those
seven wide. Retested against this tree, no conflict occurs: Sorbet takes
the shim's signature for callers while the app-code signature keeps
checking the body and the runtime return. So all sixteen narrow, not
nine.

`sorbet/type_assertions/policy_scope_for.rb` holds the assertions that
keep this honest. It is typechecked and never loaded, and it covers both
shapes — a policy that inherits `scope_for` and one that defines its own
— because they resolve through different paths. `T.assert_type!` fails
on `T.untyped` as well as on a wrong type, so a positive assertion is
enough to catch the shim silently going wide.

## Consequences

`Policy.scope_for(user).find(id)` resolves to the model, and a typo on
the result is a static error — the win this whole exercise was for.

The two mechanisms coexist during the migration. `policy_scope` keeps
working until the last batch of call sites moves (HPRB-42 through
HPRB-47), and the `Scope` classes are deleted after that (HPRB-48). Until
then `spec/policies/scope_for_parity_spec.rb` pins each `scope_for` to the
`Scope` it replaces.

For the same reason each bespoke `scope_for` copies its `Scope#resolve`
verbatim, blank-user guard included, rather than tidying the three
spellings of that guard into one. This is a change to authorization code:
while both mechanisms are live, "is this the same query?" should be
answerable by reading, not only by trusting the parity spec. Normalise
after HPRB-48, when there is nothing left to compare against.

Adding a policy means adding a shim entry, or its `scope_for` stays
`ActiveRecord::Relation` — correct, but untyped where it matters. That is
the cost of the shim, and it is the reason the shim is one file with one
comment explaining itself rather than sixteen scattered declarations.

Do not reintroduce `policy_scope`. It is shorter to type and it gives
back the hole this removed.
