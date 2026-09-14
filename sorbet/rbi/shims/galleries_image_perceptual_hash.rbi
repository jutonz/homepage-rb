# typed: strict

class Galleries::Image
  sig { returns(T.nilable(T::Array[Numeric])) }
  def perceptual_hash; end

  sig do
    params(value: T.nilable(T::Array[Numeric])).returns(
      T.nilable(T::Array[Numeric])
    )
  end
  def perceptual_hash=(value); end
end
