# typed: true

class UserOwnedPolicy < ApplicationPolicy
  # Untyped upper bound so `owner` below can reach `record.user` without
  # every user-owned model having to share an interface. Subclasses still
  # pin `Record` to a concrete model, so their own code keeps full checking.
  #
  # The known gap: `owner` itself is therefore unchecked — a typo there is
  # not caught. Closing it needs a `user`-bearing interface on the ~10
  # user-owned models, which is model work rather than policy work.
  Record = type_member { {upper: T.untyped} }

  sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
  def self.scope_for(user)
    return model.none if user.blank?
    model.where(user:)
  end

  def index?
    user.present?
  end

  def show?
    user_owns_record?
  end

  def create?
    user.present?
  end

  def new?
    user.present?
  end

  def edit?
    user_owns_record?
  end

  def update?
    user_owns_record?
  end

  def destroy?
    user_owns_record?
  end

  private

  def user_owns_record?
    user.present? && owner == user
  end

  def owner
    record.user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?
      scope.where(user:)
    end
  end
end
