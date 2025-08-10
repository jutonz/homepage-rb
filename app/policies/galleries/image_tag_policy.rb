module Galleries
  class ImageTagPolicy < ApplicationPolicy
    def create?
      user.present? && user_owns_image_and_tag?
    end

    def destroy?
      user.present? && user_owns_image_and_tag?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope
          .joins(image: :gallery, tag: :user)
          .where(
            galleries_images: {galleries: {user:}},
            galleries_tags: {user:}
          )
      end
    end

    private

    def user_owns_image_and_tag?
      return false unless user_owns_image?
      return false unless user_owns_tag?

      true
    end

    def user_owns_image?
      return false unless record.respond_to?(:image)
      return false unless record.image&.respond_to?(:gallery)
      return false unless record.image.gallery

      record.image.gallery.user == user
    end

    def user_owns_tag?
      return false unless record.respond_to?(:tag)
      return false unless record.tag

      record.tag.user == user
    end
  end
end