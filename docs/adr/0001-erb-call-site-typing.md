# ADR-0001: Static typing of ERB component call sites

**Status:** Accepted
**Date:** 2026-09-08
**Ticket:** HPRB-38

## Context

Component initializers carry `sig`s, but Sorbet never sees the call sites
those signatures were written to protect. Of ~144 `SomeComponent.new` call
sites in `app/`, 130 are in `.html.erb` files Sorbet does not parse and 14
are inside `erb_template <<~ERB` heredocs, which are string literals as far
as it is concerned. Nothing was statically checked.

`config/initializers/sorbet.rb` makes every signature runtime-enforced at
`:always`, so a wrong argument does raise — but only once the page renders.

HPRB-38 asked whether static checking of those call sites is achievable
with tooling available today.

## What we measured

Two things have to work for a template call site to be statically checked:
the embedded Ruby has to be extracted, and its arguments have to have types.
They turned out to be very different problems.

**Extraction is solved.** The `herb` gem parses ERB into a real AST with
per-node source locations and typed control-flow nodes (`ERBIfNode`,
`ERBBlockNode`, `ERBEndNode`). Getting `render(Todo::TaskCardComponent.new(
task: task, room: @room))` out of a template, with its line number and its
enclosing block parameter, is mechanical.

**Argument typing is the real blocker.** Transcribing a call site verbatim
catches nothing when its arguments are the instance variables a template
actually reads, because those are `T.untyped`:

```ruby
# typed: true
render(Todo::TaskCardComponent.new(task: @room, room: @room))
# => No errors! Great job.
```

Declare the same ivar and the identical call site fails:

```ruby
@room = T.let(Todo::Room.new, Todo::Room)
render(Todo::TaskCardComponent.new(task: @room, room: @room))
# => Expected `Todo::Task` but found `Todo::Room` for argument `task`
```

So the wrong-model demonstration from HPRB-21 stays invisible for the same
reason it was invisible there — the ivars come from `policy_scope(...)
.find(...)`, which returns `T.untyped` (HPRB-37). ERB was never the only
thing in the way.

**But a useful class of error is catchable today, untyped ivars and all.**
Keyword names and arity do not depend on argument types, and literal
arguments carry their own. Against fully untyped values Sorbet still
rejects:

- an unrecognized keyword (`romo:` for `room:`)
- a missing required keyword
- a component constant that does not resolve (a misspelled class name)
- a literal of the wrong type (`color: "blue"` where a `Symbol` is declared)

Those are the mistakes that actually happen when a component's signature
changes and a template is left behind.

## Decision

Transcribe the component constructions out of ERB into Ruby that Sorbet
checks, and accept that the transcription is partial.

`lib/erb_call_sites/extractor.rb` emits, for each template, only the
`SomeComponent.new(...)` expressions — not the template. Argument values
that reach outside the template (`t(".title")`, `todo_room_path(@room)`)
are replaced by `T.unsafe(nil)`, keeping the keyword name. Bare identifiers
— block parameters, partial locals — are declared as untyped locals.
Reproducing anything more faithfully would need a typed view context, which
does not exist.

`lib/erb_call_sites/generator.rb` writes those transcriptions to
`sorbet/erb_call_sites/`, mirroring the template path. They are committed,
so the existing `bin/srb tc` step checks them with no second Sorbet run, and
`bin/rake erb_call_sites:verify` — a CI step — fails when they have drifted
from the templates.

The pilot covers `app/views/todo` only. Widening it means adding a
directory to `ErbCallSites::Generator::SOURCES` and regenerating; what it
buys is bounded by the argument typing above, so it is worth doing after
that improves rather than before.

## Consequences

- A wrong keyword, a missing keyword, or a misspelled component in a
  `app/views/todo` template now fails `bin/srb tc`. Demonstrated in
  `spec/lib/erb_call_sites/static_checking_spec.rb`, which runs the real
  type checker over generated transcriptions.
- Everything else in templates is still enforced only at render time, by
  sorbet-runtime. Request and system specs remain the thing that exercises
  those call sites.
- Templates in `app/views/todo` have a generated counterpart that must be
  regenerated when they change. `bin/rake erb_call_sites:generate` does it;
  CI says so when it has not been done.
- The `herb` gem is a development/test dependency. Tapioca cannot compile
  its `**kwargs` signatures, so it is excluded in
  `sorbet/tapioca/config.yml` and stubbed in `sorbet/rbi/shims/herb.rbi`.
- `erb_template` heredocs are not covered. Herb parses them just as well —
  they are ERB in a string — so extending the extractor to read them out of
  `.rb` files is the obvious next increment, worth 14 more call sites.
- **Slot setters are not covered.** `header.with_crumb("Home", home_path)`
  and `header.with_action do` are component call sites too, and they are
  not transcribed: the receiver is the block parameter of a `render`, so
  its type is only recoverable by following the block back to the
  component, and ViewComponent defines the setters through
  `renders_one`/`renders_many` rather than as real methods. Getting these
  needs the DSL reflected into RBIs first, which is a separate piece of
  work from anything above.
- Every `.erb` under a covered directory is transcribed, not just
  `.html.erb`, and a non-html format is kept in the generated name so
  `show.html.erb` and `show.turbo_stream.erb` do not collide. Two templates
  that would still claim the same name — `show.html.erb` alongside
  `_show.html.erb` — raise rather than silently overwriting.

## What would change this

Typed ivars. Once a template's `@room` is known to be a `Todo::Room` —
which needs both a typed `policy_scope`/`find` (HPRB-37) and some typed
view context to declare ivars in — the same transcription starts catching
swapped models, and widening the pilot to all of `app/views` earns its
keep. Until then, do not re-derive the measurement above; it is the answer.
