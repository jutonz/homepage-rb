# typed: strict

module Galleries
  class AutoAddTagPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::AutoAddTag} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none unless user

      model
        .joins(tag: :gallery)
        .where(galleries_tags: {user:})
    end

    sig { returns(T.nilable(T::Boolean)) }
    def new?
      user_owns_tag?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def create?
      user_owns_tag?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def destroy?
      user_owns_tag?
    end

    private

    sig { returns(T.nilable(T::Boolean)) }
    def user_owns_tag?
      user && record.tag&.user == user
    end
  end
end
