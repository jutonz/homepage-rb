module Galleries
  module Images
    class TagSearch
      include ActiveModel::Model

      attr_accessor :gallery
      attr_accessor :image
      attr_accessor :query

      def results
        return Tag.none if query.nil?

        gallery
          .tags
          .where("galleries_tags.name ILIKE ?", "%#{query.strip}%")
          .where.not(id: image.tags.select(:id))
          .order(Galleries::Tag.arel_table[:name])
      end
    end
  end
end
