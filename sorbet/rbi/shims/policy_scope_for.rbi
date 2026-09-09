# typed: true

# `scope_for` returns the relation of the model that its policy governs.
# App code cannot say that. The signature would need type-level member
# access on a type parameter — "given `Gallery`, return `Gallery`'s
# relation type" — and Sorbet has no syntax for it. So the signature in
# app code is the widest true one, `ActiveRecord::Relation`, and each
# narrow return type is declared here. `Policy.scope_for(user).find(id)`
# then resolves to that policy's model, not to `T.untyped`.
#
# A second reason keeps these declarations out of app code.
# `PrivateRelation` is a Tapioca fiction with no runtime constant. A
# signature that names it in app code must opt out of runtime checks to
# keep the method callable. Here it narrows the static type, and the
# app-code signature still checks the real return value at runtime.
#
# Seven of these policies also define `scope_for` in app code, because
# their query is bespoke. A narrower type here does not conflict with
# that definition: Sorbet gives callers this signature and still checks
# the body against the one in app code. See ADR 0001.

class Api::TokenPolicy
  sig { params(user: T.nilable(User)).returns(Api::Token::PrivateRelation) }
  def self.scope_for(user); end
end

class GalleryPolicy
  sig { params(user: T.nilable(User)).returns(Gallery::PrivateRelation) }
  def self.scope_for(user); end
end

class Galleries::AutoAddTagPolicy
  sig do
    params(user: T.nilable(User))
      .returns(Galleries::AutoAddTag::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Galleries::BookPolicy
  sig do
    params(user: T.nilable(User)).returns(Galleries::Book::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Galleries::ImagePolicy
  sig do
    params(user: T.nilable(User)).returns(Galleries::Image::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Galleries::SocialMediaLinkPolicy
  sig do
    params(user: T.nilable(User))
      .returns(Galleries::SocialMediaLink::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Galleries::TagPolicy
  sig do
    params(user: T.nilable(User)).returns(Galleries::Tag::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Plants::InboxImagePolicy
  sig do
    params(user: T.nilable(User))
      .returns(Plants::InboxImage::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Plants::PlantImagePolicy
  sig do
    params(user: T.nilable(User))
      .returns(Plants::PlantImage::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Plants::PlantPolicy
  sig { params(user: T.nilable(User)).returns(Plants::Plant::PrivateRelation) }
  def self.scope_for(user); end
end

class RecipeGroupPolicy
  sig { params(user: T.nilable(User)).returns(RecipeGroup::PrivateRelation) }
  def self.scope_for(user); end
end

class Recipes::IngredientPolicy
  sig do
    params(user: T.nilable(User))
      .returns(Recipes::Ingredient::PrivateRelation)
  end
  def self.scope_for(user); end
end

class SharedBills::SharedBillPolicy
  sig do
    params(user: T.nilable(User))
      .returns(SharedBills::SharedBill::PrivateRelation)
  end
  def self.scope_for(user); end
end

class Todo::RoomPolicy
  sig { params(user: T.nilable(User)).returns(Todo::Room::PrivateRelation) }
  def self.scope_for(user); end
end

class Todo::TaskPolicy
  sig { params(user: T.nilable(User)).returns(Todo::Task::PrivateRelation) }
  def self.scope_for(user); end
end

class UserGroupPolicy
  sig { params(user: T.nilable(User)).returns(UserGroup::PrivateRelation) }
  def self.scope_for(user); end
end
