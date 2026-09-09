# typed: true

# `Gallery` and `Galleries::Image` define these scopes as plain `def self.`
# class methods, not as `scope` macros. Tapioca projects only the macro
# form onto the relation types. A chain such as
# `GalleryPolicy.scope_for(user).visible` therefore resolves to nothing.
#
# These declarations type that chain and keep the class-method idiom
# that the codebase uses everywhere else.
class Gallery::PrivateRelation
  sig { returns(Gallery::PrivateRelation) }
  def visible; end

  sig { returns(Gallery::PrivateRelation) }
  def hidden; end
end

class Galleries::Image::PrivateRelation
  sig { returns(Galleries::Image::PrivateRelation) }
  def unprocessed; end
end
