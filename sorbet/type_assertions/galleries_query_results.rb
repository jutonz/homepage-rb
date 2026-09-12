# typed: strict
# frozen_string_literal: true

# The shim in sorbet/rbi/shims/galleries_query_results.rbi gives a
# static guarantee that rspec cannot see: a spec passes against
# `T.untyped` exactly as it passes against `Galleries::Tag`. This file
# asserts the guarantee instead. `bin/srb tc` fails if that shim no
# longer narrows.
#
# This file must never load, so it lives under sorbet/.
#
# Positive assertions catch a shim that goes wide. `T.assert_type!`
# rejects `T.untyped` as firmly as it rejects a wrong type; the failure
# is "Expected a type but found `T.untyped`".
module GalleriesQueryResultsTypeAssertions
  extend T::Sig

  sig do
    params(
      recent: Galleries::RecentTagsQuery::Result,
      related: Galleries::RelatedTagsQuery::Result
    ).void
  end
  def self.assertions(recent, related)
    T.assert_type!(recent.tag, Galleries::Tag)
    T.assert_type!(recent.most_recent_image_id, Integer)

    T.assert_type!(related.tag, Galleries::Tag)
    T.assert_type!(related.shared_count, Integer)
  end
end
