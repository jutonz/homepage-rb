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
          gallery.images.create!(file:)
        end
      end

      true
    end
  end
end
