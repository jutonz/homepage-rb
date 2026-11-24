# Spinel

[Spinel](https://github.com/matz/spinel) is the ahead-of-time compiler
that builds the `hprb` CLI
([HPRB-167](https://linear.app/jt-project42/issue/HPRB-167)). It
compiles a subset of Ruby to C, and then the system `cc` compiles the C
to a native executable. The executable holds no Ruby runtime.

This file records what a spike on 2026-11-24 proved, and the traps it
found. Read it before you bump the Spinel pin or add a `require` to the
CLI.

## Which Spinel

Pin Spinel to master commit
`d64ba6affba325245c7e5a530f7338d6daa3c03a` (2026-11-24). Do not use the
release `2026.10.25`.

- The release's `net/http` has no `body_stream`, no `Net::WriteTimeout`,
  and no `write_timeout:`. A streamed upload compiles without error and
  then raises `NoMethodError: body_stream=` at run time.
- The release also emits invalid C for the bundled `JSON.dump` when a
  program requires `json`, `net/http`, `openssl`, and `optparse`
  together. Master fixes this.
- `body_stream` landed on master on 2026-11-20. Move the pin to a
  release when a release includes it.

Master changes fast: 7,646 commits came between the release and the
pin. Bump the pin on purpose, and only when the native smoke tests
pass.

## Build Spinel

```sh
git clone https://github.com/matz/spinel.git
cd spinel
git checkout d64ba6affba325245c7e5a530f7338d6daa3c03a
make deps
make -j8
make install PREFIX="$PREFIX"
```

- `make deps` downloads the `prism` gem from rubygems.org.
- The Makefile finds a keg-only Homebrew `openssl@3` through
  `brew --prefix openssl@3`. The `openssl` package exists only if the
  libssl headers are present when you build Spinel.
- Spinel is not a gem and has no prebuilt binaries. You must build it
  from source.

## Compile a program

```sh
spinel exe/hprb.rb -o build/hprb
```

Spinel resolves `require` and `require_relative` at compile time, so the
command needs no `-I`. A compile of `hprb` takes about 10 seconds of wall
time and 33 seconds of CPU time.

- Write `--jobs=1`. The form `--jobs 1` produces no binary.
- `--cc="cc -Wno-error=..."` does not turn a C error into a warning.
  It is not a workaround for a code generation bug.

## Link OpenSSL statically

By default, the binary loads `libssl.3.dylib` and `libcrypto.3.dylib`
from `/opt/homebrew/opt/openssl@3/lib` by absolute path. If Homebrew
upgrades or removes `openssl@3`, the binary does not start. Ship the
static build instead.

```sh
P="$PREFIX/lib/spinel"
O=/opt/homebrew/opt/openssl@3/lib
spinel exe/hprb.rb -c -o build/hprb.c --force
cc -O2 -ffp-contract=off -falign-functions=64 -falign-loops=64 \
  -ffunction-sections -fdata-sections -DSP_INT_OVERFLOW_MODE_RAISE \
  -I"$P/lib" -I"$P/lib/regexp" \
  build/hprb.c \
  "$P/packages/json/sp_json.o" "$P/packages/openssl/sp_openssl.o" \
  "$P/packages/stringio/sp_stringio.o" "$P/packages/zlib/sp_zlib.o" \
  "$P/lib/libspinel_rt.a" "$O/libssl.a" "$O/libcrypto.a" -lm \
  -Wl,-dead_strip -o build/hprb-static
```

- `spinel exe/hprb.rb --print-build` prints the flags, the package
  objects, and the libraries. The list of package `.o` files depends on
  what the program requires, so run `--print-build` again after you
  change a `require`.
- `-ffunction-sections`, `-fdata-sections`, and `-Wl,-dead_strip` do not
  come from `--print-build`. They remove unused code.
- The static binary is 7.9 MB (7.0 MB stripped) and links only
  `libSystem`. The dynamic binary is 3.9 MB.

## Certificates

Spinel's `openssl` package reads no environment variables. OpenSSL
itself reads `SSL_CERT_FILE` in `SSL_CTX_set_default_verify_paths`.
When `SSL_CERT_FILE` is not set, OpenSSL reads the path compiled into
it, which is `/opt/homebrew/etc/openssl@3/cert.pem`. The static build
compiles that path into the binary. It does not use the macOS Keychain.

A machine without Homebrew `openssl@3` fails certificate verification
unless something sets `SSL_CERT_FILE`. `SSL_CERT_DIR` should also work,
but the spike did not test it. The spike also did not test whether a
program can set `SSL_CERT_FILE` in its own `ENV` before the first
connection. Prove that before you depend on it.

Verification is on by default. A self-signed certificate, an untrusted
CA, and a hostname mismatch each fail with `certificate verify failed`.

## Source changes Spinel needs

The same source must run under CRuby, because the specs run under
CRuby. These changes work under both.

**Set the length as a header.** `request.content_length = total` raises
`NoMethodError`. Write `request["Content-Length"] = total.to_s`.

**Give a body stream `readpartial`.** Spinel's `net/http` calls
`readpartial(16384)` on a `body_stream`. A custom stream must define
`readpartial(length, outbuf = nil)` and raise `EOFError` at the end.

```ruby
def readpartial(length, outbuf = nil)
  chunk = read(length, outbuf)
  raise EOFError, "end of file reached" if chunk.nil?
  chunk
end
```

**Rescue `Errno::EPIPE`.** When the server resets the connection during
an upload, Spinel raises `Errno::EPIPE`. CRuby raises
`Errno::ECONNRESET`. Rescue both.

## What works

The spike compiled each of these and ran it as a native binary:

- A streamed multipart upload of a 50 MB file, with a byte-for-byte
  sha256 match. Peak memory was 8.5 MB, so the binary does not read
  the file into memory. Progress output appeared incrementally.
- HTTPS with certificate verification, and `JSON.parse` of the body.
- An `OptionParser` subcommand tree, `File` reads and writes, a config
  file written with mode 0600, `ENV`, and `exit` with a status.
- Keyword arguments, `sum(&:size)`, `String#replace`, `format`, `warn`,
  custom exception classes, and `rescue` of a splatted constant list.

18 of 20 parity cases matched CRuby byte for byte on stdout, stderr,
and exit status. The other two differed only in errno text.

## What does not work

These limits apply by design:

- No string `eval`, no `method_missing`, and no `send` or
  `define_method` with a name computed at run time.
- UTF-8 and binary are the only encodings.
- A gem works only if it is a source tree inside the subset. Expect
  `faraday` and `multipart-post` to fail.

These limits apply to `net/http`:

- No proxy support. A proxy argument raises `NotImplementedError`, and
  `net/http` ignores `HTTPS_PROXY`.
- No redirects, no cookie jar, and no HTTP/2.
- No multipart helper. Build the multipart body yourself.
- `Timeout.timeout` does not work on the main thread. Use
  `open_timeout`, `read_timeout`, and `write_timeout` instead.

## Traps

**A missing method compiles.** The docs say that Spinel refuses an
unknown call at compile time. The spike found the opposite: calls to
`body_stream=` and `content_length=` compiled, and then failed at run
time. Specs under CRuby cannot catch this. Run every command of the
native binary against stub servers in CI, and compare the output with
CRuby.

**An "uninitialized constant" warning is an error.** A warning such as
"uninitialized constant ... defined nowhere in the program" can become a
`NameError` at startup. In the spike, an undefined constant in a
top-level array made every command fail.

**Type inference can fail to converge.** The release printed "type
inference did not converge in 128 rounds" when it compiled a method that
took both a `Net::HTTP::Get` and a `Net::HTTP::Post`.

**The generated C is large.** `hprb.c` is 11.8 MB. A C error prints
very long lines, so search the output for `error:`.

## Tools

- `spinel-reduce` shrinks a program that fails. Its `--oracle build`
  mode only checks that the compile fails, and any broken input fails.
  So it reduced the spike's 369 lines to `end`. Pass `--oracle-cmd` with
  a command that searches for the specific error. Run `spinel-flatten`
  first to join a program into one file.
- `spinel-diff` compares a program's output under Spinel and CRuby. The
  spike used its own script instead and did not try `spinel-diff`.
- Spinel's docs describe master. Read the installed
  `lib/spinel/packages/` to see what your pinned version really has.
