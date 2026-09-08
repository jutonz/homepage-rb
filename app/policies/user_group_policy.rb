# typed: true

class UserGroupPolicy < UserOwnedPolicy
  Record = type_member { {fixed: UserGroup} }

  private

  def owner
    record.owner
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?
      scope.where(owner: user)
    end
  end
end
