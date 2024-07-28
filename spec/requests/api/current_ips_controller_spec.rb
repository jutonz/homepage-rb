# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::CurrentIpsController do
  describe "show" do
    it "returns the forwarded IP" do
      get(
        "/api/current_ip",
        env: {
          "HTTP_X_FORWARDED_FOR" => "0.0.0.0"
        }
      )

      expect(response.status).to eql(200)
      expect(response.body).to eql("0.0.0.0")
    end
  end
end
