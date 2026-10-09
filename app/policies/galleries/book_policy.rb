# typed: strict

module Galleries
  class BookPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::Book} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none if user.blank?
      model.joins(:gallery).where(galleries: {user:})
    end

    sig { returns(T::Boolean) }
    def index?
      user.present?
    end

    sig { returns(T::Boolean) }
    def show?
      gallery_owner?
    end

    sig { returns(T::Boolean) }
    def create?
      user.present?
    end

    sig { returns(T::Boolean) }
    def new?
      user.present?
    end

    sig { returns(T::Boolean) }
    def edit?
      gallery_owner?
    end

    sig { returns(T::Boolean) }
    def update?
      gallery_owner?
    end

    sig { returns(T::Boolean) }
    def destroy?
      gallery_owner?
    end

    private

    sig { returns(T::Boolean) }
    def gallery_owner?
      user.present? && record.gallery&.user == user
    end
  end
end
