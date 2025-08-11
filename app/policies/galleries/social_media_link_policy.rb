module Galleries
  class SocialMediaLinkPolicy < ApplicationPolicy
    def new?
      user.present? && user_owns_tag?
    end

    def create?
      user.present? && user_owns_tag?
    end

    def edit?
      user.present? && user_owns_tag?
    end

    def update?
      user.present? && user_owns_tag?
    end

    def destroy?
      user.present? && user_owns_tag?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope
          .joins(tag: :gallery)
          .where(galleries_tags: {user:})
      end
    end

    private

    def user_owns_tag?
      return false unless record.respond_to?(:tag)
      return false unless record.tag

      record.tag.user == user
    end
  end
end
