require "rails_helper"

RSpec.describe Session::CallbackController do
  describe "show" do
    it "decodes the jwt and creates a user" do
      jwt, attrs = build(:access_token)

      get(session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      ))

      expect(response.status).to eql(200)
      expect(User.count).to eql(1)
      expect(User.last).to have_attributes(
        foreign_id: attrs[:id],
        email: attrs[:email],
        access_token: jwt,
        refresh_token: "todo"
      )
    end

    it "enqueues seeds for a new user in development" do
      jwt, _attrs = build(:access_token)
      allow(UserSeedJob).to receive(:perform_later)
      allow(Rails.env).to receive(:development?).and_return(true)

      get(session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      ))

      expect(response.status).to eql(200)
      expect(UserSeedJob).to have_received(:perform_later)
    end

    it "doesn't enqueue seeds in test env" do
      jwt, _attrs = build(:access_token)
      allow(UserSeedJob).to receive(:perform_later)

      get(session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      ))

      expect(response.status).to eql(200)
      expect(UserSeedJob).not_to have_received(:perform_later)
    end

    it "logs in an existing user" do
      user = create(:user)
      jwt, _attrs = build(:access_token, user:)

      get(session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      ))

      expect(response.status).to eql(200)
      expect(User.count).to eql(1)
    end

    it "redirects if a return_to value is saved" do
      get(home_path) # establish session

      session[:return_to] = home_path
      user = create(:user)
      jwt, _attrs = build(:access_token, user:)

      get(session_callback_path(
        access_token: jwt,
        refresh_token: "todo"
      ))

      expect(response).to redirect_to(home_path)
    end
  end
end
