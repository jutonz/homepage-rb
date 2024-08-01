require "rails_helper"

RSpec.describe Session::CallbackController do
  describe "show" do
    it "decodes the jwt and creates a user" do
      jwt = build_jwt(email: "hi@t.co", id: 123)
      path = session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      )

      get(path)

      expect(response.status).to eql(200)
      expect(User.count).to eql(1)
      expect(User.last).to have_attributes(
        foreign_id: "123",
        email: "hi@t.co",
        access_token: jwt,
        refresh_token: "todo"
      )
    end
  end

  # TODO: Extract to factory
  def build_jwt(email:, id:)
    payload = {
      sub: {email:, id:}
    }
    JWT.encode(
      payload,
      Rails.application.credentials.auth.secret,
      "HS512"
    )
  end
end
