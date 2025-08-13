class UserGroupInvitationPolicy < ApplicationPolicy
  def create?
    user.present? && user == record.user_group.owner
  end

  def show?
    # Anyone can view an invitation (public link with token)
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?
      # Users can see invitations for groups they own
      scope.joins(:user_group).where(user_groups: {owner: user})
    end
  end
end
