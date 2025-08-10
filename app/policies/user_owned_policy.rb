class UserOwnedPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user_owns_record?
  end

  def create?
    user.present?
  end

  def update?
    user_owns_record?
  end

  def destroy?
    user_owns_record?
  end

  private

  def user_owns_record?
    return false unless user
    return false unless record.respond_to?(:user)

    record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?
      scope.where(user:)
    end
  end
end
