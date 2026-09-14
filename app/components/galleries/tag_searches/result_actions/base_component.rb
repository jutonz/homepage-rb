# typed: true

module Galleries
  module TagSearches
    module ResultActions
      class BaseComponent < ApplicationComponent
        extend T::Helpers

        abstract!

        sig do
          params(
            tag_search: Galleries::TagSearch,
            tag: Galleries::Tag
          ).void
        end
        def initialize(tag_search:, tag:)
          @tag_search = tag_search
          @tag = tag
        end

        sig { abstract.returns(String) }
        def call
        end

        private

        sig { returns(Galleries::TagSearch) }
        attr_reader :tag_search

        sig { returns(Galleries::Tag) }
        attr_reader :tag

        sig { returns(Gallery) }
        def gallery
          tag_search.gallery
        end
      end
    end
  end
end
