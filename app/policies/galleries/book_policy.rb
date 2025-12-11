module Galleries
  class BookPolicy < ApplicationPolicy
    def index?
      user.present?
    end

    def show?
      gallery_owner?
    end

    def create?
      user.present?
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
      user.present? && record.gallery.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none if user.blank?
        scope.joins(:gallery).where(galleries: {user:})
      end
    end
  end
end
