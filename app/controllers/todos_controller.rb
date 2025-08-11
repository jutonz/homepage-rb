class TodosController < ApplicationController
  before_action :ensure_authenticated!
  skip_after_action :verify_authorized

  def show
  end
end
