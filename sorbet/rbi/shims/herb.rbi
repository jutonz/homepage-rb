# typed: strong

# Herb's public entry points take `**kwargs`, which Tapioca compiles into
# `params(path: T.untyped, _arg1: )` -- a signature Sorbet then rejects as
# malformed. The gem is excluded in sorbet/tapioca/config.yml and stubbed
# here instead.
#
# Only the surface lib/erb_call_sites/extractor.rb uses is declared. The
# AST it walks is left untyped: Herb's node classes are generated from its
# C parser and reflecting on them buys nothing the extractor relies on.
module Herb
  class << self
    # Returns a Herb::ParseResult, whose `value` is the document node and
    # whose `errors` are the template's syntax errors.
    sig { params(source: ::String).returns(T.untyped) }
    def parse(source); end
  end
end
