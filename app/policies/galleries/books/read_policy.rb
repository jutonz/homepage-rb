module Galleries
  module Books
    class ReadPolicy < ApplicationPolicy
      def show?
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
end
