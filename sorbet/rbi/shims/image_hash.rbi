# typed: strict

class ImageHash
  sig { params(path: String).void }
  def initialize(path); end

  sig { returns(String) }
  def binary_hash; end
end
