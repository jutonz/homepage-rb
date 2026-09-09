# typed: strict

# Tapioca generates `Pundit::Authorization#authorize` without a signature,
# so every record handed to it comes back `T.untyped` and loses its type.
#
# For a plain record, `authorize` returns the same object it was given.
# A generic signature states this, so the static type survives at every
# call site, and no call site needs a change.
#
# That identity applies to the plain form only. Pundit also accepts the
# namespaced form `authorize([:admin, post])`. `Pundit::Context` unwraps
# an array with `record.is_a?(Array) ? record.last : record`, so the
# namespaced form returns `post`, not the array. This signature gives the
# wrong type for that form. No code in this app passes an array today.
# If you add such a call, add an overload to this shim, or do not use
# the return value.
#
# Tapioca does not generate or verify this file. A Pundit upgrade that
# changes the parameters of `authorize` leaves this signature stale, and
# Sorbet reports no error. Check this file against the gem after you
# change the Pundit version.
module Pundit::Authorization
  protected

  sig do
    type_parameters(:Record)
      .params(
        record: T.type_parameter(:Record),
        query: T.nilable(T.any(Symbol, String)),
        policy_class: T.untyped
      )
      .returns(T.type_parameter(:Record))
  end
  def authorize(record, query = nil, policy_class: nil); end
end
