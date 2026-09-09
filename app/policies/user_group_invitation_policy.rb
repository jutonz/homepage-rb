# typed: true

class UserGroupInvitationPolicy < ApplicationPolicy
  Record = type_member { {fixed: UserGroupInvitation} }

  sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
  def self.scope_for(user)
    return model.none if user.blank?
    model.joins(:user_group).where(user_groups: {owner: user})
  end

  def create?
    user.present? && user == record.user_group&.owner
  end

  def destroy?
    user.present? && user == record.user_group&.owner
  end

  def show?
    # Anyone can view an invitation (public link with token)
    true
  end
end
