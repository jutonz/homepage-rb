# frozen_string_literal: true

module Api
  class CurrentIpsController < ApplicationController
    def show
      render plain: request.remote_ip
    end
  end
end
