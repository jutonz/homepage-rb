# == Schema Information
#
# Table name: galleries_books
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_galleries_books_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
module Galleries
  class Book < ActiveRecord::Base
    belongs_to :gallery

    validates :name, presence: true
  end
end
