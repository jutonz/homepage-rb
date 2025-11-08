require "rails_helper"

RSpec.describe ApplicationController do
  it "rescues Pundit::NotAuthorizedError and redirects" do
    stub_controller do
      get("/pundit_error")
    end

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(
      "You are not authorized to perform this action."
    )
  end

  it "rescues WardenHelper::UnauthenticatedError and redirects" do
    stub_controller do
      get("/warden_error")
    end

    expect(response).to redirect_to(new_session_path)
    expect(session[:return_to]).to eql("/warden_error")
  end

  def stub_controller(&)
    controller = Class.new(ApplicationController) do
      def pundit_error = raise Pundit::NotAuthorizedError

      def warden_error = raise WardenHelper::UnauthenticatedError
    end

    stub_const("TestsController", controller)

    Rails.application.routes.draw do
      get("/pundit_error", to: "tests#pundit_error")
      get("/warden_error", to: "tests#warden_error")
      resource(:session, only: :new)
      root(to: "tests#pundit_error")
    end

    yield controller
  ensure
    Rails.application.reload_routes!
  end
end
