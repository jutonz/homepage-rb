# typed: strict

class IssuePolicy < UserOwnedPolicy
  Record = type_member { {fixed: Issue} }
end
