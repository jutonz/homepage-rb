# == Schema Information
#
# Table name: galleries
#
#  id         :bigint           not null, primary key
#  hidden_at  :datetime
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_galleries_on_name     (name) UNIQUE
#  index_galleries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Gallery < ActiveRecord::Base
  belongs_to :user
  has_many :tags,
    class_name: "Galleries::Tag",
    dependent: :destroy
  has_many :images,
    class_name: "Galleries::Image",
    dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.visible = where(hidden_at: nil)

  def self.hidden = where.not(hidden_at: nil)

  def recently_used_tags(excluded_image_ids: nil, image_limit: 4)
    recently_tagged_image_ids =
      images
        .joins(:image_tags)
        .order(galleries_image_tags: {created_at: :desc})
        .limit(image_limit)
        .select(:id)

    if excluded_image_ids.present?
      recently_tagged_image_ids = recently_tagged_image_ids.where.not(id: excluded_image_ids)
    end

    tag_ids =
      tags
        .joins(:images)
        .where(galleries_images: {id: recently_tagged_image_ids})
        .distinct

    tags.where(id: tag_ids).order(:name)
  end
end
