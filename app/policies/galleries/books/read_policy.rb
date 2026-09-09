# typed: true

module Galleries
  module Books
    class ReadPolicy < ApplicationPolicy
      Record = type_member { {fixed: Galleries::Book} }

      # This policy governs reads of a book, so its name does not name
      # its model.
      sig { returns(T.class_of(ActiveRecord::Base)) }
      def self.model = Galleries::Book

      def show?
        user.present? && record.gallery&.user == user
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
