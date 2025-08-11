# frozen_string_literal: true

module Api
  class CurrentIpsController < ApplicationController
    skip_after_action :verify_authorized
    def show
      render plain: request.remote_ip
    end
  end
end
