# typed: true

class UserGroupPolicy < UserOwnedPolicy
  Record = type_member { {fixed: UserGroup} }

  sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
  def self.scope_for(user)
    return model.none if user.blank?
    model.where(owner: user)
  end

  private

  def owner
    record.owner
  end
end
