# typed: strict

module Galleries
  class ImagePolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::Image} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none unless user

      model.joins(:gallery).where(gallery: {user:})
    end

    sig { returns(T.nilable(T::Boolean)) }
    def index?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def show?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def create?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def update?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def destroy?
      user_owns_gallery?
    end

    private

    sig { returns(T.nilable(T::Boolean)) }
    def user_owns_gallery?
      user && record.gallery&.user == user
    end
  end
end
