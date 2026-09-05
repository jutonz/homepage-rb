# Issue tracker: Notion

Issues and specs for this repo live in the **Homepage RB Backlog** Notion
database (under Homepage > Tech):
https://app.notion.com/p/288299751461805a9f70d607c7beef72

Data source: `collection://28829975-1461-80e0-93bd-000b6063f731`

## Schema

- **Name** (title) — issue title
- **Status** (status): `Open` → `In progress` → `Done`
- **Module** (multi-select): `Global`, `Recipes`, `Galleries` — tag with the
  relevant app area(s)

## Conventions

- **Create an issue**: `notion-create-pages` targeting the data source above,
  setting `Name` and `Module`. New pages default to `Status: Open`.
- **Read an issue**: `notion-fetch` on the page URL.
- **List / search issues**: `notion-query-data-sources` against the data
  source above with a `Status`/`Module` filter, or `notion-search` by title.
- **Update status or module**: `notion-update-page`.
- **Comment**: `notion-create-comment`.
- **Close**: set `Status` to `Done` — there is no separate "closed" state.

## Status transitions

- **Starting implementation**: set `Status` to `In progress` before writing
  any code for the ticket. Do this as the first step of the work, not
  retroactively.
- There is no `In review` state in this database. Leave a ticket at
  `In progress` while its PR is open.

## When a skill says "publish to the issue tracker"

Create a page in the Homepage RB Backlog database via `notion-create-pages`.

## When a skill says "fetch the relevant ticket"

`notion-fetch` the page URL, or `notion-query-data-sources` /
`notion-search` by title if only given a name.
