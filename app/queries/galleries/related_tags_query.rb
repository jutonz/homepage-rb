# typed: strict

module Galleries
  class RelatedTagsQuery
    extend T::Sig

    Result = Data.define(:tag, :shared_count)

    sig do
      params(
        tag: Galleries::Tag,
        exclude_tag_ids: T::Array[Integer],
        limit: Integer
      ).returns(T::Array[Result])
    end
    def self.call(tag:, exclude_tag_ids: [], limit: 10)
      new(tag:, exclude_tag_ids:, limit:).call
    end

    sig do
      params(
        tag: Galleries::Tag,
        exclude_tag_ids: T::Array[Integer],
        limit: Integer
      ).void
    end
    def initialize(tag:, exclude_tag_ids: [], limit: 10)
      @tag = tag
      @exclude_tag_ids = exclude_tag_ids
      @limit = limit
    end

    sig { returns(T::Array[Result]) }
    def call
      counts = Galleries::Tag
        .where(gallery_id: tag.gallery_id)
        .where.not(id: [tag.id, *exclude_tag_ids])
        .joins(:image_tags)
        .where(galleries_image_tags: {image_id: tag.image_ids})
        .group("galleries_tags.id")
        .order(Arel.sql("COUNT(*) DESC"))
        .limit(limit)
        .pluck(Arel.sql("galleries_tags.id, COUNT(*)"))

      tags = Galleries::Tag
        .where(id: counts.map(&:first))
        .includes(:gallery)
        .index_by(&:id)

      counts.map do |id, shared_count|
        Result.new(tag: tags.fetch(id), shared_count:)
      end
    end

    private

    sig { returns(Galleries::Tag) }
    attr_reader :tag

    sig { returns(T::Array[Integer]) }
    attr_reader :exclude_tag_ids

    sig { returns(Integer) }
    attr_reader :limit
  end
end
