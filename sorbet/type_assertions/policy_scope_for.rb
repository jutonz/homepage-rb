# typed: strict
# frozen_string_literal: true

# `scope_for` gives a static guarantee that rspec cannot see: a spec
# passes against `T.untyped` exactly as it passes against the narrow
# type. This file asserts the guarantee instead. `bin/srb tc` fails if
# the shim in sorbet/rbi/shims/policy_scope_for.rbi no longer narrows.
#
# This file must never load, so it lives under sorbet/.
# `PrivateRelation` is a static fiction with no runtime constant.
#
# Positive assertions catch a shim that goes wide. `T.assert_type!`
# rejects `T.untyped` as firmly as it rejects a wrong type; the failure
# is "Expected a type but found `T.untyped`".
#
# Two policies stand in for all sixteen — the only two shapes there are.
# `GalleryPolicy` inherits `scope_for` from `UserOwnedPolicy`.
# `Galleries::BookPolicy` defines its own.
module PolicyScopeForTypeAssertions
  extend T::Sig

  sig { params(user: T.nilable(User)).void }
  def self.assertions(user)
    T.assert_type!(GalleryPolicy.scope_for(user), Gallery::PrivateRelation)
    T.assert_type!(GalleryPolicy.scope_for(user).find(1), Gallery)

    T.assert_type!(
      GalleryPolicy.scope_for(user).visible,
      Gallery::PrivateRelation
    )

    T.assert_type!(
      Galleries::BookPolicy.scope_for(user).find(1),
      Galleries::Book
    )
  end
end
