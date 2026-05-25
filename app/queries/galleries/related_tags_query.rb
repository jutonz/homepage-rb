module Galleries
  class RelatedTagsQuery
    Result = Data.define(:tag, :shared_count)

    def self.call(...) = new(...).call

    def initialize(tag:)
      @tag = tag
    end

    def call
      Galleries::Tag
        .where(gallery_id: tag.gallery_id)
        .where.not(id: tag.id)
        .joins(:image_tags)
        .where(galleries_image_tags: {image_id: tag.image_ids})
        .group("galleries_tags.id")
        .select("galleries_tags.*, COUNT(*) AS shared_count")
        .order(Arel.sql("COUNT(*) DESC"))
        .limit(10)
        .includes(:gallery)
        .map { Result.new(tag: it, shared_count: it.shared_count.to_i) }
    end

    private

    attr_reader :tag
  end
end
