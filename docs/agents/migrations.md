# Writing a migration

Facts this repo has paid for. Read it before you write a migration that
drops a table or destroys rows.

## A migration with no `down` is reversible, and silently so

`ActiveRecord::Migration#down` is a no-op when a migration defines only
`up`. Rails raises `ActiveRecord::IrreversibleMigration` for a `change`
block it cannot invert, never for a `down` you left out.

So a drop migration with no `down` answers `bin/rails
db:rollback:primary` with exit 0. It un-records the version and
rewrites the checked-in `db/schema.rb` back to the pre-drop version.
The next `bin/rails db:migrate` then runs `up` against tables that are
gone and dies on `PG::UndefinedTable`, with the adapter's error rather
than yours.

Write the refusal yourself:

```ruby
def down
  raise(ActiveRecord::IrreversibleMigration)
end
```

Measured on HPRB-115, where the ticket and the design both asserted the
opposite and review caught it.

## Drop tables in foreign key order, and name each one

Name every table in an explicit list and drop the dependents before the
table they point at. `force: :cascade` hides which tables a drop
removes, and a failure then names nothing useful.

An ordered list is a landmine: a reader who sorts it breaks the
migration. Give the list a one-line comment that says which table the
foreign keys point at.

## Guard a destructive migration, and let it raise

A migration that destroys rows counts them first and raises, naming
every offending table with its count. All of them, not a sample —
choosing which tables matter means being right about the thing the
guard exists to catch.

Raise rather than skip. `bin/docker-entrypoint` is `#!/bin/bash -e` and
runs `./bin/rails db:prepare`, so a raise stops the container from
starting and the deploy fails loudly. A guard that logged and returned
would leave `db/schema.rb` claiming the rows are gone while they
remain. PostgreSQL DDL is transactional, so the raise rolls the
migration back and the data stays available to inspect.

On HPRB-115 this fired in production against 27 rows a two-year-old
ticket believed were not there. Nothing was destroyed and the site
stayed up.

## The schema files are machine output

Run the migration against the development database and let it rewrite
`db/schema.rb`. Never edit a schema file by hand.

This repo has three databases and three migration paths, declared in
`config/database.yml`: `db/migrate` for primary, `db/queue_migrate` for
Solid Queue, `db/cable_migrate` for Action Cable. A migration in the
wrong path targets the wrong database. Solid Queue connects only to the
queue database.
