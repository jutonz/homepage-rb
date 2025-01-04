module Galleries
  class BulkUpload
    include ActiveModel::Model

    attr_accessor :files
    attr_accessor :gallery

    validates :gallery, presence: true
    validates :files, presence: true, length: {minimum: 1}

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        files.each do |file|
          next if file.blank?
          image = gallery.images.create!(file:)
          image.add_tag(tagging_needed)
        end
      end

      true
    end

    private

    def tagging_needed
      @_tagging_needed ||=
        gallery
          .tags
          .create_with(user: gallery.user)
          .find_or_create_by(name: "tagging needed")
    end
  end
end
