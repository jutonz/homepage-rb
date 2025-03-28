module Galleries
  class TagSearch
    include ActiveModel::Model

    attr_accessor :gallery
    attr_accessor :image
    attr_accessor :query

    def results
      ilike = query&.strip
      return Tag.none if ilike.nil?
      ilike = ActiveRecord::Base.sanitize_sql_like(ilike)

      gallery
        .tags
        .where("galleries_tags.name ILIKE ?", "%#{ilike}%")
        .then { maybe_exclude_image_tags(it) }
        .order(image_tags_count: :desc)
    end

    private

    def maybe_exclude_image_tags(query)
      if image.present?
        query.where.not(id: image.tags.select(:id))
      else
        query
      end
    end
  end
end
