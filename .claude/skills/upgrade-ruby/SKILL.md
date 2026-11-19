---
name: upgrade-ruby
description: Upgrade this project's Ruby version, with a gem-prep PR first when the new Ruby breaks gems.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# Upgrade Ruby

Two files pin Ruby: `.tool-versions` and the `Dockerfile`. Everything else
follows `.tool-versions`. The `Gemfile` reads it (`ruby file:`), and
`ruby/setup-ruby` in CI reads it too. Bundler writes the `RUBY VERSION` and
`BUNDLED WITH` sections of `Gemfile.lock`.

A patch upgrade is usually a three-file diff (#881). A major or minor upgrade
can cause **fallout**: a gem that refuses the new Ruby, or a process that
dies at runtime while every spec passes. Ruby 4.0.0 had both kinds and was
reverted twice (#584, #589). `after_party` pinned `ruby ~> 3.0`, and the
`prometheus_exporter` sidecar crashed after a few seconds with no error.
Ruby 4.0.1 fixed the crash (#604).

## Step 1 — Pick the target version

```bash
mise ls-remote ruby | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -10
```

Pick the newest stable release in that list. mise hides releases younger
than its `minimum_release_age` setting and prints a warning that says so.
Keep that hold. Go past it only when the user names a version.

The production image is `ruby:<version>-slim`. Confirm that the tag exists
before you edit anything:

```bash
V=X.Y.Z
curl -sf "https://hub.docker.com/v2/repositories/library/ruby/tags/${V}-slim/" \
  >/dev/null && echo FOUND || echo "NOT FOUND"
```

If the tag is missing, wait for Docker to publish it or pick the previous
release.

Done when you have a version that mise lists and Docker Hub has as
`-slim`.

## Step 2 — Bump the pins

1. Set `ruby X.Y.Z` in `.tool-versions`.
2. Set `ARG RUBY_VERSION=X.Y.Z` in the `Dockerfile`.
3. Install the new Ruby and update the lockfile:

   ```bash
   mise install
   mise exec -- bundle install
   mise exec -- gem list bundler    # note the "default:" version
   mise exec -- bundle update --bundler=<default version>
   ```

   Run every command through `mise exec --` until you open a new shell.
   Otherwise the shim cache can still resolve `ruby` to the old version.

`Gemfile.lock` can gain a generic `ffi (x.y.z)` line beside the
platform-specific ones. That line is expected (#604). Leave it.

The `Gemfile` pins `openssl` until the default gem of Ruby catches up.
Compare the pin to `mise exec -- ruby -ropenssl -e 'puts OpenSSL::VERSION'`.
If the default version is the same or newer, delete the pin and its
comment. Treat that change as gem prep in Step 5.

Done when `git diff Gemfile.lock` shows the new `RUBY VERSION` and
`BUNDLED WITH`.

## Step 3 — Find and fix gem fallout

A `bundle install` that fails on `required_ruby_version` shows fallout. A
new deprecation warning in spec output shows it too. For each gem:

1. Find a release that supports the new Ruby:

   ```bash
   curl -s https://rubygems.org/api/v1/versions/<gem>.json \
     | ruby -rjson -e 'JSON.parse($stdin.read).first(8).each do |v|
         puts v.values_at("number", "ruby_version").join(" ")
       end'
   ```

2. Bump it with `mise exec -- bundle update --conservative <gem>`. Read
   the `Gemfile.lock` diff, so you know which other gems moved and why.
3. Regenerate its RBIs with `mise exec -- bin/tapioca gem <gem>`.

If no release supports the new Ruby, stop and report the gem to the user.
That is the signal to hold the upgrade, as with `after_party` on 4.0.0.
Keep warnings visible. Fix the cause, never the warning level.

Done when `bundle install` succeeds and every gem bump has fresh RBIs.

## Step 4 — Verify

```bash
mise exec -- bin/ci
docker build -t homepage-rb:ruby-upgrade-test .
```

Then run the smoke test on the image, because the specs do not start
`prometheus_exporter`. `bin/docker-entrypoint` starts it in the
background in production.

```bash
docker run -d --rm --name ruby-upgrade-exporter -p 9394:9394 \
  --entrypoint bundle homepage-rb:ruby-upgrade-test \
  exec prometheus_exporter --bind 0.0.0.0 --port 9394
for i in {1..9}; do
  docker ps -q -f name=ruby-upgrade-exporter | grep -q . \
    || { echo DIED; break; }
  curl -s -o /dev/null -w "%{http_code}\n" localhost:9394/metrics
  perl -e 'select(undef,undef,undef,10)'
done
```

The first poll can print `000` while the exporter boots. After that, every
poll must print `200`. A `DIED`, or a run of `000`, is a quiet crash. Run
`docker logs ruby-upgrade-exporter` and report the result to the user,
because a patch release of Ruby can be the only fix.

Remove the test artifacts:

```bash
docker stop ruby-upgrade-exporter 2>/dev/null
docker rmi homepage-rb:ruby-upgrade-test
```

Done when `bin/ci` is green, the image builds, and the exporter serves
`200` for the full 90 seconds.

## Step 5 — Open the PRs

Read `git log --oneline -i --grep='upgrade ruby'` to see the title
convention ("Upgrade ruby to X.Y.Z").

**No gem fallout:** open one PR with the pins and the lockfile.

**Gem fallout:** open two stacked PRs, so each one is small and can be
reverted alone.

1. **Gem prep PR.** It has the gem bumps, their RBIs, the `openssl` pin
   removal, and any code fixes. It must stay green on the *current* Ruby.
2. **Bump PR.** It has `.tool-versions`, the `Dockerfile`, and the
   `RUBY VERSION` and `BUNDLED WITH` lines of `Gemfile.lock`. Stack it on
   the prep PR.

To split the work tree:

1. `git checkout -b upgrade-ruby-X.Y.Z-prep main`, then
   `git stash push -m ruby-bump -- .tool-versions Dockerfile`.
2. In `Gemfile.lock`, set `RUBY VERSION` and `BUNDLED WITH` back to their
   values on `main`. Keep the gem changes.
3. Run `mise exec -- bin/ci` on the current Ruby, commit, push, and open
   the PR against `main`.
4. `git checkout -b upgrade-ruby-X.Y.Z`, then `git stash pop`. Repeat
   Step 2.3 to write the new lockfile sections, commit, push, and open the
   PR with `--base upgrade-ruby-X.Y.Z-prep`.

After the prep PR merges, check the bump PR. If GitHub closed it when the
prep branch was deleted, rebase the bump branch onto `main`. Then
force-push it with `--force-with-lease` and open a new PR. Say in the new
PR that it replaces the closed one.
