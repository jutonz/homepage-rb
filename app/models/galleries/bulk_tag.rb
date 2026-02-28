module Galleries
  class BulkTag
    include ActiveModel::Model

    attr_accessor :gallery, :image_ids, :tag_id

    validates :gallery, presence: true
    validates :tag_id, presence: true
    validates :image_ids, presence: true

    def save
      return false unless valid?

      tag = gallery.tags.find(tag_id)
      images = gallery.images.where(id: image_ids)

      ActiveRecord::Base.transaction do
        images.each { |image| image.add_tag(tag) }
      end

      true
    rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
      false
    end
  end
end
