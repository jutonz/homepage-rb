FactoryBot.define do
  factory :access_token, class: "Array" do
    transient do
      user { nil }
    end

    sequence(:email_sequence) { "user#{_1}@exmaple.com" }
    email { user&.email || email_sequence }

    sequence(:id_sequence) { _1.to_s }
    id { user&.foreign_id || id_sequence }

    initialize_with do
      # TODO: flesh out to match actual token contents
      payload = {
        sub: {
          email: attributes[:email],
          id: attributes[:id]
        }
      }
      token = JWT.encode(
        payload,
        Rails.application.credentials.auth.secret,
        "HS512"
      )

      # not sure how I feel about this...
      # TODO: value object?
      [token, attributes]
    end
  end
end
