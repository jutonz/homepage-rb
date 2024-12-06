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
    sql = ActiveRecord::Base.sanitize_sql_array([
      <<~SQL,
        SELECT DISTINCT
          galleries_tags.*,
          galleries_tags.name
        FROM galleries_tags
        JOIN galleries_image_tags
          ON galleries_image_tags.tag_id = galleries_tags.id
        JOIN (
          SELECT
            galleries_images.id AS id,
            MAX(galleries_image_tags.created_at) AS max_created_at
          FROM galleries_images
          JOIN galleries_image_tags
            ON galleries_image_tags.image_id = galleries_images.id
          JOIN galleries_tags
            ON galleries_image_tags.tag_id = galleries_tags.id
          WHERE galleries_images.gallery_id = ?
          GROUP BY galleries_images.id
          ORDER BY max_created_at DESC
          LIMIT ?
        ) images
          ON images.id = galleries_image_tags.image_id
        ORDER BY galleries_tags.name
        ;
      SQL
      id,
      image_limit
    ])

    Galleries::Tag.find_by_sql(sql).then do |result|
      if excluded_image_ids.present?
        Galleries::Tag
          .joins(:images)
          .where.not(galleries_images: {id: excluded_image_ids})
          .where(id: result.pluck(:id))
          .distinct
      else
        result
      end
    end
  end
end
