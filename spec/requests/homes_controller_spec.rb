require "rails_helper"

RSpec.describe HomesController do
  describe "show" do
    it "if not logged in, redirects" do
      get(home_path)
      expect(response).to redirect_to(new_session_path)
      expect(session[:return_to]).to eql(home_path)
    end

    it "says hi if logged in" do
      user = create(:user)
      login_as(user)

      get(home_path)

      expect(response.body).to include("Signed in as #{user.email}")
    end

    it "shows an Issues card" do
      user = create(:user)
      login_as(user)

      get(home_path)

      expect(page).to have_css("h3", text: "Issues")
      expect(page).to have_link("View Issues", href: issues_path)
    end
  end
end
