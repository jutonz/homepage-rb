module Galleries
  class BulkUpload
    include ActiveModel::Model

    attr_accessor :files
    attr_accessor :gallery

    validates :gallery, presence: true
    validates :files, presence: true, length: {minimum: 1}

    def save
      return false unless valid?

      images =
        ActiveRecord::Base.transaction do
          files.filter_map do |file|
            next if file.blank?
            image = gallery.images.create!(file:)
            image.add_tag(tagging_needed)
            image
          end
        end

      generate_variants(images)

      true
    end

    private

    def tagging_needed
      @_tagging_needed ||= Galleries::Tag.tagging_needed(gallery)
    end

    def generate_variants(images)
      # Generate inline since, after this returns, we will immediately redirect
      # to page where variant is shown. We also already should have the image
      # downloaded so processing will be faster this way.
      images.each { Galleries::ImageVariantJob.perform_now(it) }

      images
        .map { Galleries::ImagePerceptualHashJob.new(it) }
        .then { ActiveJob.perform_all_later(it) }
    end
  end
end
