module Galleries
  module Images
    class TagSearch
      include ActiveModel::Model

      attr_accessor :gallery
      attr_accessor :image
      attr_accessor :query

      # validates :name, presence: true
      #
      # def save
      #   return false unless valid?

      # ActiveRecord::Base.transaction do
      #   files.each do |file|
      #     next if file.blank?
      #     gallery.images.create!(file:)
      #   end
      # end

      #   true
      # end
      #

      def search
        gallery
          .tags
          .where("galleries_tags.name ILIKE ?", "%#{query}%")
          .where.not(id: image.tags.select(:id))
      end
    end
  end
end
