# typed: true

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

    def index?
      user.present?
    end

    def show?
      gallery_owner?
    end

    def create?
      gallery_owner?
    end

    def new?
      user.present?
    end

    def edit?
      gallery_owner?
    end

    def update?
      gallery_owner?
    end

    def destroy?
      gallery_owner?
    end

    private

    def gallery_owner?
      user.present? && record.book&.gallery&.user == user
    end
  end
end
