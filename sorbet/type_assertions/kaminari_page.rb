# typed: strict
# frozen_string_literal: true

# The shim in sorbet/rbi/shims/kaminari_page.rbi gives a static
# guarantee that rspec cannot see: a spec passes against `T.untyped`
# exactly as it passes against the relation. This file asserts the
# guarantee instead. `bin/srb tc` fails if that shim no longer narrows.
#
# This file must never load, so it lives under sorbet/.
module KaminariPageTypeAssertions
  extend T::Sig

  sig { params(tag: Galleries::Tag).void }
  def self.assertions(tag)
    T.assert_type!(
      tag.images.order(:id).page(1),
      Galleries::Image::PrivateAssociationRelation
    )
  end
end
