# 2. Stateless API token authentication

Date: 2026-09-11

## Status

Accepted.

## Context

`Api::BaseController#api_authenticate` resolved the `Authorization`
header to an `Api::Token`, then called `warden.set_user(user)` with no
`store:` option. Warden's default is to store, so every authenticated API
response shipped a `Set-Cookie` for `_homepage_session` carrying
`warden.user.user.key => user.id`.

That cookie is not an API-scoped credential. `serialize_from_session`
resolves the key with `User.find_by(id:)` and never consults
`Api::Token`, so the cookie is a full browser session that the API token
minted. Measured against `64c8bf5`:

```
get /api/current_user  Authorization: Bearer <token>   -> 200
token.destroy!                                          (0 tokens remain)
get /api/current_user  (no Authorization header)        -> 200
get /home              (no Authorization header)        -> 200  (HTML)
```

Revoking an API token therefore did not revoke the access granted through
it. The ticket filed this as hygiene — "a stateless auth path should not
write session cookies" — but it is a credential-revocation hole.

The same store also overwrote a co-resident browser session. A `fetch`
from a signed-in page, a browser extension, or a devtools console signed
that browser in as the API token's owner, silently, and rotated the
session id while doing it.

## Decision

**An API token does not write to the browser session.** The filter
passes `store: false`, so Warden authenticates the request in memory and
writes nothing to the session. A token authenticates the request that
carries it and nothing further, so no token-derived credential outlives
the token.

This is narrower than "the API is stateless", and the narrower claim is
the true one. The API still *accepts* a browser session cookie: a request
carrying one authenticates as that session's user with no
`Authorization` header at all, and this repo depends on it — every
authenticated example in
`spec/requests/api/galleries/images_controller_spec.rb`,
`spec/requests/api/plants/inbox_images_controller_spec.rb`, and
`spec/requests/api/galleries/remote_video_downloads_controller_spec.rb`
signs in with `login_as` and sends no token. Removing that is a
different decision and is not made here. What this decision removes is
the API token's ability to *mint* such a cookie.

`store: false` skips exactly two things: `session_serializer.store`, and
setting `rack.session.options[:renew]`. Warden assigns `@users[scope]`
*before* it consults the option, so `current_user`, Pundit's
`pundit_user`, and `ApplicationCable::Connection` are unaffected inside
the request.

**Losing session id rotation on this path is correct, not a regression to
compensate for.** Rotation defends a privilege transition — the moment an
anonymous visitor becomes an authenticated one. API token authentication
has no such transition, because the token identifies the same user on
every request. What the rotation actually rotated was a *different*
principal's session, in the same breath as overwriting that principal's
user. The rotation and the clobber were the same defect. HPRB-56 put
rotation at the app's one genuine transition, the OAuth callback in
`Session::CallbackController`, and that stays.

Rejected alternatives:

- **Leave it.** The cookie is a durable credential that outlives the
  token that created it. See Context.
- **`reset_session` before `set_user`.** Wrong twice over: there is no
  privilege transition to rotate at, and it would destroy a co-resident
  browser session on every API call — a worse version of the defect it
  was meant to fix.
- **A `Warden::Manager.after_set_user` hook.** HPRB-56 already rejected
  this as broken rather than merely broad: Warden serializes the user into
  the session before the hook runs, so a hook cannot prevent the store.
- **A separate cookie jar for the API.** Solves the clobber and leaves the
  revocation hole, since an API-scoped cookie is still a credential the
  token minted and `Api::Token` still governs nothing.
- **Extracting a Warden strategy or an authentication concern.** One
  adapter is a hypothetical seam; two is a real one. There is exactly one
  API token path, and nothing varies across such a seam. The module and
  its interface are unchanged: inherit the base class, and `current_user`
  is the API token's user or `nil`.

## Consequences

A client that authenticated once by header and then rode the cookie stops
working. Measured: a second API request with no `Authorization` header
returned `200` before this change and returns `401` after it. That is the
intended semantics, and the old behaviour was the revocation hole. No
consumer of `/api/` exists in this repository — `app/javascript`,
`app/views`, `app/components`, `lib`, and `script` were searched — so
nothing here breaks. An external client might, and should send the token
on every request.

**Do not remove `store: false` to make the API "stay logged in".** It
reads as a needless complication and it is the whole decision. Five
examples in `spec/requests/api/current_users_controller_spec.rb` fail if
it goes: the response sets no cookie, an API call answers as the token's
user while leaving a browser session alone, a request carrying no
credential is rejected, a revoked token is rejected, and an API token
buys no access to the HTML site. Each was observed red before the option
was added.

The no-cookie example asserts `response.cookies` is empty rather than
naming `_homepage_session`, which is a Rails default derived from
`module Homepage` and written down nowhere. The cost is that a
*legitimate* future non-secure cookie on an API response turns the
example red, which is the desired place to be stopped. A `secure: true`
cookie slips past it: `always_write_cookie` is false in test and the
request is not SSL, so Rails never writes it. The session cookie this
guards against is not `secure`, which is why the example discriminates
at all — but the guard is narrower than "any cookie".

This also settles what HPRB-56 left open: per-request API authentication
is a commitment of this project, not one commit's phrasing.
