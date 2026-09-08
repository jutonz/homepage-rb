# typed: true

module Galleries
  class RelatedTagsQuery
    Result = Data.define(:tag, :shared_count)

    def self.call(...) = new(...).call

    def initialize(tag:, exclude_tag_ids: [], limit: 10)
      @tag = tag
      @exclude_tag_ids = exclude_tag_ids
      @limit = limit
    end

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

    attr_reader :tag, :exclude_tag_ids, :limit
  end
end
