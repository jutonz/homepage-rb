require "rails_helper"

RSpec.describe ApplicationController do
  it "rescues Pundit::NotAuthorizedError and redirects" do
    stub_controller do
      get "/test"
    end

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(
      "You are not authorized to perform this action."
    )
  end

  def stub_controller(&)
    controller = Class.new(ApplicationController) do
      def show = raise Pundit::NotAuthorizedError
    end

    stub_const("TestsController", controller)

    Rails.application.routes.draw do
      resource :test, only: :show
      root to: "tests#show"
    end

    yield controller
  ensure
    Rails.application.reload_routes!
  end
end
