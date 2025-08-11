module Api
  class CurrentUsersController < BaseController
    before_action :ensure_authenticated!
    skip_before_action :verify_authorized

    def show
      render(json: current_user, only: %i[id email])
    end
  end
end
