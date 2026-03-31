module Galleries
  class BulkUpload
    include ActiveModel::Model

    attr_accessor :signed_id
    attr_accessor :gallery
    attr_accessor :tag_ids
    attr_reader :image

    validates :gallery, presence: true
    validates :signed_id, presence: true

    def save
      return false unless valid?

      @image = gallery.images.create!(
        file: blob,
        processing: true
      )
      all_tags = [tagging_needed, *selected_tags]
      @image.add_tag(*all_tags)

      Galleries::ImageVariantJob.perform_later(@image)
      Galleries::ImagePerceptualHashJob.perform_later(@image)

      true
    end

    private

    def blob
      ActiveStorage::Blob.find_signed!(signed_id)
    end

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
  end
end
