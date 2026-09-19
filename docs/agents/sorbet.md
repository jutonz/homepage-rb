# Raising a file to `# typed: strict`

How to convert application Ruby under `app/` for an
[HPRB-67](https://linear.app/jt-project42/issue/HPRB-67) child ticket.
Prior art: `docs/adr/0001-typed-policy-scopes.md`,
`docs/adr/0003-typed-strict-in-app-queries.md`.

## The loop

1. Flip only the sigils in the ticket's file list. Change nothing else.
2. Run `mise exec -- bin/srb tc`. The error list is the work. Record the
   count and the error classes before you write a signature — that is
   the red run, and a count that surprises you means the ticket's file
   list is stale.
3. Clear each error.
4. Regenerate any RBI the change invalidates, then run `mise exec --
   bin/ci`.

Most errors are `7017` (a method with no `sig`) and clear mechanically.
The rest are decisions; the sections below carry the ones this repo has
already made.

## Conventions

**Write a bare `sig`.** `config/initializers/sorbet.rb` monkeypatches
`Module` to include `T::Sig`, so a class needs no `extend T::Sig`.
`app/jobs/galleries/remote_video_download_job.rb` is the model. Some
older strict models carry the `extend`; leave those alone.

**A `belongs_to` reads nilable.** The generated RBI types every
`belongs_to` as `T.nilable`, so a call through one needs `T.must`. The
columns are `null: false` with foreign keys and `belongs_to` is required
by default, so nil is unreachable for a persisted record. `T.must(nil)`
raises `TypeError` where the old code raised `NoMethodError`; both
descend from `StandardError`. Check that no `rescue`, `rescue_from`,
`retry_on`, or `discard_on` on the path keys on `NoMethodError`.

**Framework lifecycle methods hold nilable ivars.** A job's `perform`
and a channel's `subscribed` run after the framework built the object,
so an ivar they assign cannot be declared in an `initialize`. Declare it
`T.let(value, T.nilable(Type))` at the assignment.

**A signature on `perform` propagates.** Tapioca rewrites the job's DSL
RBI, so `perform_later` and `perform_now` take the concrete record type
afterwards. Run `mise exec -- bin/tapioca dsl <JobClass>` and commit the
result; `bin/ci` runs `bin/tapioca dsl --verify` and fails on a stale
RBI. Then check the callers the new type reaches.

**`.void` replaces the return value.** A `.void` method returns
`T::Private::Types::Void::VOID`, not `nil`. Confirm no caller reads it.

**80 columns covers handwritten files.** Generated RBIs under
`sorbet/rbi/dsl/` keep their own policy and many already run long.

**Add no spec for a pure type change.** A signature asserts what
sorbet-runtime already enforces. Run the ticket's named regression areas
instead. Where a spec must pass a signed parameter, pass a real
instance: sorbet-runtime rejects an `instance_double`.

## A handwritten RBI needs a guard

Declare a method Sorbet cannot see — one a runtime DSL creates, such as
Action Cable's `identified_by` — in a shim under `sorbet/rbi/shims/`,
rather than reaching it with `T.unsafe`.

A shim is static only, so a spec passes against `T.untyped` exactly as
it passes against the real type. Guard every declaration with
`T.assert_type!` in a file under `sorbet/type_assertions/`, which
`bin/srb tc` checks and the app never loads.

**Prove the guard fails.** For each declaration in the shim, widen it to
`T.untyped` and narrow it to a wrong type, running `bin/srb tc` on each.
A declaration that survives being widened is unguarded, which is the
one failure the assertion file exists to catch. Removing the whole shim
must also fail.

**Assert on a getter, never on an assignment.** Sorbet gives an
assignment expression the type of its right-hand side, not the setter's
declared return, so `T.assert_type!(obj.thing = value, Type)` asserts
only that `value` has the type its own signature already declares. Hold
a setter in the guard with a bare call instead.

A parameter widened to `T.untyped` cannot be caught, and does not need
to be: the value flows in, so a wide parameter introduces no untyped
value into application code.
