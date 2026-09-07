# Issue tracker: Linear

Issues and specs for this repo live in the **Homepage RB** Linear team
(key `HPRB`):
https://linear.app/jt-project42/team/HPRB

Tooling: the `linear` CLI (v2.6). Run `linear <command> --help` for flags.

## Schema

- **Title** — issue title
- **State**: `Backlog` → `Todo` → `In Progress` → `In Review` → `Done`
  (`Canceled` / `Duplicate` also exist)
- **Labels**: `Global`, `Recipes`, `Galleries` — tag with the relevant app
  area(s). Team-scoped; the workspace also has `Bug` / `Feature` /
  `Improvement`.

## Conventions

- **Create an issue**: `linear issue create --team HPRB -t "<title>"
  --description-file <path> -s Backlog -l <label>`. Prefer
  `--description-file` over `-d` for markdown bodies. Add `--no-interactive`
  in scripts.
- **Read an issue**: `linear issue view HPRB-123`.
- **List / search issues**: `linear issue query --team HPRB --all-states`.
  Note `linear issue list` is an alias for `issue mine` and only shows
  issues assigned to you — use `issue query` for the whole team.
- **Update state or labels**: `linear issue update HPRB-123 -s "In Progress"`,
  `--add-label` / `--remove-label` to change labels incrementally (`-l`
  replaces the entire set).
- **Comment**: `linear issue comment`.
- **Dependencies**: `linear issue relation add HPRB-123 blocked-by HPRB-456`.
- **Close**: set state to `Done`.

## Status transitions

- **Starting implementation**: set the state to `In Progress` before writing
  any code for the ticket. Do this as the first step of the work, not
  retroactively. `linear issue start HPRB-123` does this too.
- Move to `In Review` while the ticket's PR is open.

## When a skill says "publish to the issue tracker"

Create an issue in the HPRB team via `linear issue create --team HPRB`.

## When a skill says "fetch the relevant ticket"

`linear issue view <id>`, or `linear issue query --team HPRB --all-states`
and match on title if only given a name.

## Migration note

The 35 open / in-progress issues were migrated from the former Notion
database "Homepage RB Backlog" on 2026-09-07. Each carries a
`Migrated from Notion` backlink at the bottom of its description. The 60
`Done` issues were deliberately left behind; the Notion database is
untouched and still readable at
https://app.notion.com/p/288299751461805a9f70d607c7beef72
