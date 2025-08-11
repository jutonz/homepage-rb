class HomesController < ApplicationController
  skip_after_action :verify_authorized
  before_action :ensure_authenticated!

  def show
  end
end
