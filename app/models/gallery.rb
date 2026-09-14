# typed: strict

# == Schema Information
#
# Table name: galleries
# Database name: primary
#
#  id           :bigint           not null, primary key
#  hidden_at    :datetime
#  images_count :integer          default(0), not null
#  name         :string           not null
#  tags_count   :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
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
  extend T::Sig

  belongs_to :user
  has_many :tags,
    class_name: "Galleries::Tag",
    dependent: :destroy
  has_many :images,
    class_name: "Galleries::Image",
    dependent: :destroy
  has_many :books,
    class_name: "Galleries::Book",
    dependent: :destroy
  has_many :remote_video_downloads,
    class_name: "Galleries::RemoteVideoDownload",
    dependent: :destroy

  validates :name, presence: true, uniqueness: true

  sig do
    returns(T.all(ActiveRecord::Relation, T::Enumerable[Gallery]))
  end
  def self.visible = where(hidden_at: nil)

  sig do
    returns(T.all(ActiveRecord::Relation, T::Enumerable[Gallery]))
  end
  def self.hidden = where.not(hidden_at: nil)

  sig { returns(String) }
  def processing_images_stream_name
    "gallery_#{id}_processing_images"
  end

  sig { returns(String) }
  def remote_video_downloads_stream_name
    "gallery_#{id}_remote_video_downloads"
  end

  sig do
    params(
      excluded_image_ids: T.nilable(T::Array[Integer]),
      image_limit: Integer
    ).returns(T::Array[Galleries::RecentTagsQuery::Result])
  end
  def recently_used_tags(excluded_image_ids: nil, image_limit: 10)
    Galleries::RecentTagsQuery.call(
      gallery: self,
      excluded_image_ids:,
      image_limit:
    )
  end
end
