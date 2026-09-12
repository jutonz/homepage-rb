# typed: strict

# Sorbet's rewriter creates the reader methods for a `Data.define`, but
# it gives them no signature, and the `.rb` file has no syntax to write
# one. Every member of a `Data.define` is therefore an error at
# `# typed: strict`. See https://github.com/sorbet/sorbet/issues/7272 —
# a typed `T::Data` is proposed but not implemented.
#
# These declarations give the two query result objects the member types
# they already carry at runtime. They keep `Result` a `Data`, so value
# equality, `with`, `to_h`, and pattern matching all survive.
#
# An RBI applies to the static checker only, so nothing here runs.
# `sorbet/type_assertions/galleries_query_results.rb` asserts that these
# declarations still narrow.
module Galleries
  class RecentTagsQuery
    class Result
      sig { returns(Galleries::Tag) }
      def tag; end

      sig { returns(Integer) }
      def most_recent_image_id; end
    end
  end

  class RelatedTagsQuery
    class Result
      sig { returns(Galleries::Tag) }
      def tag; end

      sig { returns(Integer) }
      def shared_count; end
    end
  end
end
