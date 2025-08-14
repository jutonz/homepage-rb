require "rails_helper"

RSpec.describe PendingInvitationComponent, type: :component do
  it "renders pending invitation" do
    invitation = build_stubbed(
      :user_group_invitation,
      created_at: 2.days.ago
    )

    render_inline(described_class.new(invitation:))

    expect(rendered_content).to include(invitation.email)
    expect(rendered_content).to include("Sent 2 days ago")
    expect(rendered_content).to include("Pending")
    expect(rendered_content).to include("Cancel")
  end

  it "renders expired invitation" do
    invitation = build_stubbed(:user_group_invitation, :expired)

    render_inline(described_class.new(invitation:))

    expect(rendered_content).to include(invitation.email)
    expect(rendered_content).to include("Expired")
    expect(rendered_content).to include("Cancel")
  end
end
