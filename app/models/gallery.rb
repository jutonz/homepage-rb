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
  has_many :images

  validates :name, presence: true, uniqueness: true

  def self.visible = where(hidden_at: nil)
end
