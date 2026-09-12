# 3. `# typed: strict` in `app/queries/`

Date: 2026-09-12

## Status

Accepted.

## Context

Every Ruby file under `app/` sat at `# typed: true`. At that level
Sorbet accepts a new method with no signature in silence, so signature
coverage has no floor and can only drift downward as the app grows.
`bin/srb tc` passes either way, so neither a developer nor a reviewer
nor CI hears about a method that arrives untyped.

Before the codebase commits to `strict` everywhere, the open question
was what `strict` costs per directory. Nobody knew, because no file
under `app/` had ever been raised. This ADR records the measurement so
the next directory can be estimated.

`app/queries/galleries/` is the pilot: three files, stable, already
signed at the public surface. Raising the sigil on those three and
changing nothing else produced 14 errors.

```
$ sed -i '' '1s/# typed: true/# typed: strict/' \
    app/queries/galleries/*.rb
$ bin/srb tc 2>&1 | tail -1
Errors: 14
```

| Class | N | Cleared by | Thought |
|---|---|---|---|
| `7017` `attr_reader`/`def` | 8 | a `sig` above each | mechanical |
| `7017` `Data.define` member | 4 | the RBI shim | upstream bug |
| `7043` `@excluded_image_ids` | 1 | a `T.let` | real decision |
| `6002` `@excluded_image_ids` | 1 | the same `T.let` | none |

The cost divides three ways. **Eight of the 14 were mechanical**: a
`sig { returns(T) }` line above an existing `attr_reader` or `def`,
with the type already visible in the enclosing signature. **Two were
one decision**, because a single `T.let` clears both the `7043` and the
`6002`. **Four were an upstream Sorbet bug** and needed a shim.

Two findings matter for the estimate of the next directory.

The `SQL` and `QUERY` heredoc constants needed **no** annotation.
Sorbet infers `String` from the literal, so the rule that constants
must carry an explicit type costs far less than the documentation
implies. A directory of query objects is mostly heredocs, and none of
them billed.

A multi-name `attr_reader` **must** be split when its names have
different types. Sorbet applies one `sig` to all three names and
rejects the result, so `related_tags_query.rb:57` became three signed
readers. Expect this wherever a class groups its readers on one line.

The shape of the diff:

```
$ git diff --stat
 app/queries/galleries/recent_tags_query.rb    | 18 +++++++++++++++---
 app/queries/galleries/related_tags_query.rb   | 11 +++++++++--
 app/queries/galleries/similar_images_query.rb |  3 ++-
 3 files changed, 26 insertions(+), 6 deletions(-)
```

plus two new files that total 67 lines (`wc -l`): a 36-line shim and a
31-line type-assertion file.

## Decision

**The three files carry `# typed: strict`.** Nothing else in the
repository changes strictness level. `sorbet/config` is untouched.

**The `Data.define` member types live in a Sorbet shim**,
`sorbet/rbi/shims/galleries_query_results.rbi`, and not in app code.

Sorbet's rewriter creates the reader methods for a `Data.define`
without signatures, and the `.rb` file offers no syntax to add one. The
two alternatives were `T::Struct` and a hand-written class. Both were
rejected because both change what `Result` is at runtime:

```
$ mise exec -- bundle exec ruby -e '...'
T::Struct == : false
T::Struct respond_to?(:with): true
T::Struct respond_to?(:deconstruct_keys): false
Data == : true
Data with: true
Data deconstruct_keys: true
```

`T::Struct` loses **value equality** and `deconstruct_keys`. No spec
relies on either today, so the suite would have stayed green while the
semantics changed underneath — the worst shape a change can have. Both
alternatives also add a runtime type check per constructed row — one
per row returned, on a request path — and `sorbet-runtime` is a
production dependency. An RBI applies to the static checker only and
costs nothing at runtime.

This repeats ADR-0001, which answered the same question the same way:
the narrow types live in a shim so the app classes read as application
code rather than as type declarations. Keeping `Result` a `Data` also
means zero knock-on edits — the three ViewComponents that consume a
`Result`, their specs, and every `Result.new` call site are untouched.

**`@excluded_image_ids` is `T::Array[Integer]`.** It held
`excluded_image_ids || -1`, an array or an Integer. The `-1` is a SQL
sentinel that leaked into the Ruby type:

```
$ mise exec -- bin/rails runner '...'
Array(nil)  -> id NOT IN (NULL)
Array(-1)   -> id NOT IN (-1)
[-1]        -> id NOT IN (-1)
[]          -> id NOT IN (NULL)
```

`NOT IN (NULL)` is never true, so an empty exclusion list makes the
query return no rows at all. The sentinel therefore survives, but it
moves inside the array: `T.let(excluded_image_ids || [-1],
T::Array[Integer])`. `Array(-1)` and `[-1]` produce identical SQL, so
this preserves behaviour on both the `nil` path and the array path. The
`Array(...)` wrapper at the call site is now provably dead and goes
away.

The alternative type, `T.any(T::Array[Integer], Integer)`, was
rejected. It preserves a value nobody wants to observe and it leaks the
SQL sentinel into the type, which is the opposite of the point.

## Consequences

**The ratchet holds per file, not per directory.** A new file dropped
into `app/queries/` at `# typed: true` is accepted, and nothing in the
build objects. `srb tc` reads a per-file sigil, and Sorbet offers no
per-directory or per-glob strictness setting:

```
$ bin/srb tc --help | grep -E "^ +--typed(-override)? "
      --typed {false,true,strict,strong,[auto]}
      --typed-override <filepath.yaml>
```

`--typed` is global and `--typed-override` takes an explicit per-file
list. What this ticket ratchets is **new methods and new `Data`
members in the three existing files**.

A sigil-floor guard over the directory is the named follow-up. It is
not built here: one directory cannot drift into a pattern, and the
guard would have exactly one call site, so it cannot yet be shown to
earn its maintenance. It starts to pay at the second directory.

**Adding a member to a `Data.define` fails the build until the shim
declares it.** The ratchet is stronger here than for a plain `def`,
because the shim cannot drift out of sync in the dangerous direction:

```
$ # add :probe to Data.define(:tag, :shared_count)
$ bin/srb tc 2>&1 | tail -1
Errors: 1
```

**The shim is an RBI, so it is not runtime-enforced.** `Result#tag` is
statically `Galleries::Tag` with no runtime check behind it. The shim
could also go wide — declare `T.untyped` — and every spec would still
pass, because a spec passes against `T.untyped` exactly as it passes
against `Galleries::Tag`. The assertions that catch this live in
`sorbet/type_assertions/galleries_query_results.rb`. `T.assert_type!`
rejects `T.untyped` as firmly as it rejects a wrong type, so a passing
positive assertion is the proof. Remove the shim and all four
assertions fail.

**The shim, not the sigil, buys the narrow types.** With the shim in
place and the three files back at `# typed: true`, all four assertions
still pass; remove the shim at `# typed: true` and all four fail. So
`Result#tag` and `Result#shared_count` narrow independently of the
strictness level, and the shim could have shipped on its own. What
`# typed: strict` buys is the ratchet, and only the ratchet. The next
directory can therefore take the type wins and the strictness raise as
two separate changes.

The upstream bug is
https://github.com/sorbet/sorbet/issues/7272. A typed `T::Data` is
proposed but not implemented. Delete this shim when it lands.

**The `attr_reader` split fixed a runtime hole by accident.** A `sig`
above a multi-name `attr_reader` binds at runtime to the first name
only (https://github.com/sorbet/sorbet/issues/5685). Measured against
this repository's gems:

```
$ mise exec -- bundle exec ruby -e '...'
a: runtime check fired
b: no runtime check
```

`related_tags_query.rb` had to split for a static reason, and it gains
runtime checks on the second and third readers as a side effect.

**A latent bug survives, recorded and not fixed.** A caller that
passes `excluded_image_ids: []` explicitly still gets `NOT IN (NULL)`
and zero rows. No caller does so today. A fix changes behaviour and
belongs to its own ticket.

**The specs under `spec/queries/` stay at the default `typed: false`.**
They are built on factory calls that arrive as `T.untyped`, so a sigil
there buys nothing until the factory surface is typed.
