module Api
  class CurrentUsersController < BaseController
    before_action :ensure_authenticated!

    def show
      render(json: current_user, only: %i[id email])
    end
  end
end
