require "rails_helper"

RSpec.describe TodosController do
  describe "show" do
    it "includes a link to rooms" do
      login_as(create(:user))
      get(todo_path)
      expect(page).to have_link("Rooms", href: todo_rooms_path)
    end
  end
end
