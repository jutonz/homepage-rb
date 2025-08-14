require "rails_helper"

RSpec.describe UserGroupDetailsComponent, type: :component do
  it "renders user group details" do
    owner = build(:user, email: "owner@example.com")
    user_group = build(:user_group,
      name: "Test Group",
      owner:,
      users_count: 5,
      created_at: Time.zone.parse("2023-06-15"))

    render_inline(described_class.new(user_group:))

    expect(rendered_content).to include("Group Details")
    expect(rendered_content).to include("Test Group")
    expect(rendered_content).to include("owner@example.com")
    expect(rendered_content).to include("June 15, 2023")
    expect(rendered_content).to include("5")
  end

  it "applies correct CSS classes" do
    user_group = build(:user_group, created_at: 1.day.ago)

    render_inline(described_class.new(user_group:))

    expect(rendered_content).to include('class="bg-white rounded-lg border border-gray-200 p-6"')
    expect(rendered_content).to include('class="text-lg font-semibold mb-4"')
  end
end
