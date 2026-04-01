module Galleries
  class BulkDelete
    include ActiveModel::Model

    attr_accessor :gallery, :image_ids

    validates :gallery, presence: true
    validates :image_ids, presence: true

    def save
      return false unless valid?

      images = gallery.images.where(id: image_ids)

      ActiveRecord::Base.transaction do
        images.destroy_all
      end

      true
    end
  end
end
