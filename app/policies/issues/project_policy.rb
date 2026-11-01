# typed: strict

module Issues
  class ProjectPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Issues::Project} }
  end
end
