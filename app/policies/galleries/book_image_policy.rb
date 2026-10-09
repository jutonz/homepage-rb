# typed: strict

module Galleries
  class BookImagePolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::BookImage} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none if user.blank?
      model
        .joins(book: :gallery)
        .where(galleries: {user:})
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
      gallery_owner?
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
      user.present? && record.book&.gallery&.user == user
    end
  end
end
