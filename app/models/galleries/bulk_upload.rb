module Galleries
  class BulkUpload
    include ActiveModel::Model

    attr_accessor :files
    attr_accessor :gallery
    attr_accessor :tag_ids

    validates :gallery, presence: true
    validates :files, presence: true, length: {minimum: 1}

    def save
      return false unless valid?

      images =
        ActiveRecord::Base.transaction do
          files.filter_map do |file|
            next if file.blank?
            image = gallery.images.create!(file:)
            all_tags = [tagging_needed, *selected_tags]
            image.add_tag(*all_tags)
            image
          end
        end

      process_images(images)

      true
    end

    private

    def selected_tags
      @_selected_tags ||=
        if tag_ids.present?
          gallery.tags.where(id: tag_ids)
        else
          Galleries::Tag.none
        end
    end

    def tagging_needed
      @_tagging_needed ||= Galleries::Tag.tagging_needed(gallery)
    end

    def process_images(images)
      images.each do |image|
        Galleries::ImageProcessingJob.perform_later(image)
      end
    end
  end
end
