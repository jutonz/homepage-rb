# typed: true

module Galleries
  class TagPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Galleries::Tag} }
  end
end
