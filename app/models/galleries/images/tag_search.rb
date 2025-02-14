module Galleries
  module Images
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
          .where.not(id: image.tags.select(:id))
          .order(image_tags_count: :desc)
      end
    end
  end
end
