# typed: true

module Api
  class TokenPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Api::Token} }
  end
end
