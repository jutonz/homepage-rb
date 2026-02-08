# == Schema Information
#
# Table name: plants_inbox_images
# Database name: primary
#
#  id         :bigint           not null, primary key
#  taken_at   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_plants_inbox_images_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Plants
  class InboxImage < ApplicationRecord
    has_one_attached(:file)

    belongs_to(:user)

    validates(:file, presence: true)
    validates(:taken_at, presence: true)
  end
end
