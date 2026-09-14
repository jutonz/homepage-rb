# typed: strict
# frozen_string_literal: true

module GalleriesImageBoundariesTypeAssertions
  extend T::Sig

  sig { params(image: Galleries::Image).void }
  def self.assertions(image)
    T.assert_type!(image.perceptual_hash, T.nilable(T::Array[Numeric]))
    T.assert_type!(ImageHash.new("").binary_hash, String)
  end
end
