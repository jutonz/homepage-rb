require "rails_helper"

RSpec.describe ApplicationCable::Connection do
  it "connects with an authenticated user" do
    user = create(:user)

    connect(
      "/cable",
      env: {"warden" => double(user:)}
    )

    expect(connection.current_user).to eq(user)
  end

  it "rejects unauthenticated connections" do
    expect {
      connect(
        "/cable",
        env: {"warden" => double(user: nil)}
      )
    }.to have_rejected_connection
  end
end
