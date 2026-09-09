# typed: true

module Galleries
  module Books
    class ReadPolicy < ApplicationPolicy
      Record = type_member { {fixed: Galleries::Book} }

      # This policy governs reads of a book, so its name does not name
      # its model.
      sig { returns(T.class_of(ActiveRecord::Base)) }
      def self.model = Galleries::Book

      sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
      def self.scope_for(user)
        return model.none if user.blank?
        model.joins(:gallery).where(galleries: {user:})
      end

      def show?
        user.present? && record.gallery&.user == user
      end
    end
  end
end
