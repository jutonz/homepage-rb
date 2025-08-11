module Galleries
  class SocialMediaLinkPolicy < ApplicationPolicy
    def new?
      user_owns_tag?
    end

    def create?
      user_owns_tag?
    end

    def edit?
      user_owns_tag?
    end

    def update?
      user_owns_tag?
    end

    def destroy?
      user_owns_tag?
    end

    private

    def user_owns_tag?
      user && record.tag.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope
          .joins(tag: :gallery)
          .where(galleries_tags: {user:})
      end
    end
  end
end
