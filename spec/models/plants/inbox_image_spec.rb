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
require "rails_helper"

RSpec.describe Plants::InboxImage do
  it { is_expected.to(belong_to(:user)) }

  it { is_expected.to(validate_presence_of(:file)) }
  it { is_expected.to(validate_presence_of(:taken_at)) }

  it "has a valid factory" do
    expect(build(:plants_inbox_image)).to(be_valid)
  end
end
